/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;

import org.apache.log4j.Logger;

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
    

    protected Map<String, Map> getDistros() {
        Map<String, Map> toReturn = new HashMap<String, Map>();
        List<Map> distros = (List<Map>)invokeXMLRPC("get_distros", xmlRpcToken);
        for (Map distro : distros) {
            toReturn.put((String)distro.get("uid"), distro);
        }
        return toReturn;
    }
    
    
    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {

        List <KickstartableTree> trees = KickstartFactory.lookupKickstartTrees();

        //Any distros exist on spacewalk and not on the satellite?
        Map<String, Map> cobblerDistros = getDistros();
        for (KickstartableTree tree : trees) {
            if (!cobblerDistros.containsKey(tree.getCobblerId())) {
                try {
                    createDistro(tree);
                    tree.setModified(new Date());
                }
                catch(RuntimeException e) {
                }
            }
        }
        
        //Are there any distros on cobbler that have changed       
        for (KickstartableTree tree : trees) {
            if (cobblerDistros.containsKey(tree.getCobblerId())) {
                Map cobDistro = cobblerDistros.get(tree.getCobblerId());
                if ((Integer)cobDistro.get("mtime") > tree.getModified().getTime()) {
                    syncDistroToSpacewalk(tree, cobDistro);
                }
            }
        }  
        return null;
    }
    
    private void createDistro(KickstartableTree tree) {
        CobblerDistroCreateCommand creator = new CobblerDistroCreateCommand(tree, user);
        creator.store();
    }
    
    private void syncDistroToSpacewalk(KickstartableTree tree, Map distro) {
        log.debug("Syncing distro: " + tree.getLabel() + " known in cobbler as: " +
                distro.get("name"));
        
        if (tree.isRhnTree()) {
            String handle = (String) invokeXMLRPC("get_distro_handle", distro.get("name"), 
                    xmlRpcToken);
            invokeXMLRPC("modify_distro", handle, "kernel", tree.getKernelPath(), 
                    xmlRpcToken);
            invokeXMLRPC("modify_distro", handle, "initrd", tree.getInitrdPath(), 
                    xmlRpcToken);
            invokeXMLRPC("save_distro", handle, xmlRpcToken);
        }
        else {
            //Do nothing.  Let us be out of sync with cobbler
        }
        
        tree.setModified(new Date());
    }
    

}
