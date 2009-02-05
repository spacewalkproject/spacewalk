/**
 * Copyright (c) 2009 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation. 
 */

package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;

import org.apache.log4j.Logger;
import org.cobbler.Distro;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * @author paji
 * @version $Rev$
 */
public class CobblerDistroSyncCommand extends CobblerCommand {

    
    private Logger log;
    
    /**
     * Constructor to create a 
     * DistorSyncCommand
     */
    public CobblerDistroSyncCommand() {
        super();
        log = Logger.getLogger(this.getClass());
    }
    

    protected Map<String, Distro> getDistros() {
        Map<String, Distro> toReturn = new HashMap<String, Distro>();
        List<Distro> distros = Distro.list(CobblerXMLRPCHelper.getConnection(
                Config.get().getCobblerAutomatedUser()));
        for (Distro distro : distros) {
            toReturn.put((String)distro.getUid(), distro);
        }
        return toReturn;
    }
    
    
    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {

        List <KickstartableTree> trees = KickstartFactory.lookupKickstartTrees();

        //Any distros exist on spacewalk and not in cobbler?
        Map<String, Distro> cobblerDistros = getDistros();
        for (KickstartableTree tree : trees) {
            
            if (!cobblerDistros.containsKey(tree.getCobblerId())) {
                createDistro(tree, false);
            }
            if (!cobblerDistros.containsKey(tree.getCobblerXenId()) && 
                                                    tree.doesParaVirt()) {
                createDistro(tree, true);
            }            
        }
        
        log.debug(trees);
        log.debug(cobblerDistros);
        //Are there any distros on cobbler that have changed       
        for (KickstartableTree tree : trees) {
            if (cobblerDistros.containsKey(tree.getCobblerId())) {
                Distro cobDistro = cobblerDistros.get(tree.getCobblerId());
                if ((cobDistro.getModified()).getTime() > tree.getModified().getTime()) {
                    syncDistroToSpacewalk(tree, cobDistro);
                }
            }
            if (cobblerDistros.containsKey(tree.getCobblerXenId())) {
                Distro cobDistro = cobblerDistros.get(tree.getCobblerXenId());
                if ((cobDistro.getModified()).getTime() > tree.getModified().getTime()) {
                    syncDistroToSpacewalk(tree, cobDistro);
                }
            }
            tree.setModified(new Date());
        }  
        return null;
    }
    
    
    private void createDistro(KickstartableTree tree, boolean xen) {
        Map ksmeta = new HashMap();
        KickstartUrlHelper helper = new KickstartUrlHelper(tree);
        ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE, 
                helper.getKickstartMediaPath());
        
        if (!xen) {
            log.debug("tree in spacewalk but not in cobbler. " +
                    "creating non-xenpv distro in cobbler : " + tree.getLabel());
            
            Distro distro = Distro.create(
                    CobblerXMLRPCHelper.getConnection(
                               Config.get().getCobblerAutomatedUser()),
                    tree.getCobblerDistroName(), tree.getKernelPath(), 
                    tree.getInitrdPath(), ksmeta);
            tree.setCobblerId(distro.getUid());
            invokeCobblerUpdate();
        }
        else if (tree.doesParaVirt() && xen) {
            log.debug("tree in spacewalk but not in cobbler. " +
                    "creating xenpv distro in cobbler : " + tree.getLabel());
            Distro distroXen = Distro.create(
                    CobblerXMLRPCHelper.getConnection(
                            Config.get().getCobblerAutomatedUser()),
                tree.getCobblerXenDistroName(), tree.getKernelXenPath(), 
                tree.getInitrdXenPath(), ksmeta); 
            tree.setCobblerXenId(distroXen.getUid());
        }
        tree.setModified(new Date());
    }
    
    private void syncDistroToSpacewalk(KickstartableTree tree, Distro distro) {
        log.debug("Syncing distro: " + tree.getLabel() + " known in cobbler as: " +
                distro.getName());
        String kernel;
        String initrd;
        
        //if this is the xenpv distro, then use those paths..
        if (distro.getUid().equals(tree.getCobblerXenId())) {
            kernel = tree.getKernelXenPath();
            initrd = tree.getInitrdXenPath();
        }
        else {
            kernel = tree.getKernelPath();
            initrd = tree.getKernelXenPath();
        }
        
        if (tree.isRhnTree()) {         
            distro.setKernel(kernel);
            distro.setInitrd(initrd);
            distro.save();
        }
        else {
            //Do nothing.  Let us be out of sync with cobbler
        }
    }    
}
