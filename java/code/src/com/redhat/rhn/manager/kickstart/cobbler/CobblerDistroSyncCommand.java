/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;

import org.apache.log4j.Logger;
import org.cobbler.Distro;

import java.io.File;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
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
        List<Distro> distros = Distro.list(CobblerXMLRPCHelper.getAutomatedConnection());
        for (Distro distro : distros) {
            toReturn.put((String)distro.getUid(), distro);
        }
        return toReturn;
    }


    /**
     * Sync spacewalk distros that have a null cobblerId
     *  we do this in store as well, (while doing other syncing
     *  tasks, but this is needed occasoinally outside of store.
     * @return an error if applicable
     */
    public ValidatorError syncNullDistros() {
        List errors = new LinkedList();
        List<KickstartableTree> unSynced = KickstartFactory.listUnsyncedKickstartTrees();
        String err;
        for (KickstartableTree tree : unSynced) {

            if (!tree.isValid()) {
                log.warn("Could not sync tree " + tree.getLabel());
                continue;
            }

            Distro distro = Distro.lookupByName(
                    CobblerXMLRPCHelper.getAutomatedConnection(),
                    tree.getCobblerDistroName());
            if (distro != null) {
                tree.setCobblerId(distro.getUid());
            }
            else {
                log.debug("syncing null distro " + tree.getLabel());
                err = createDistro(tree, false);
                if (err != null) {
                    errors.add(err);
                }
            }

            //Now do virt
            if (tree.doesParaVirt() && tree.getCobblerXenId() == null) {
                distro = Distro.lookupByName(
                        CobblerXMLRPCHelper.getAutomatedConnection(),
                        tree.getCobblerXenDistroName());
                if (distro != null) {
                    tree.setCobblerXenId(distro.getUid());
                }
                else {
                    err = createDistro(tree, true);
                    if (err != null) {
                        errors.add(err);
                    }
                }
            }

        }
        StringBuffer messages = new StringBuffer();
        for (int i = 0; i < errors.size(); i++) {
            messages.append(errors.get(i));
            messages.append("\n");
        }
        if (messages.length() == 0) {
            return null;
        }
        else {
            return new ValidatorError("kickstart.cobbler.distro.syncfail", messages);
        }
    }



    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        List errors = new LinkedList();

        List <KickstartableTree> trees = KickstartFactory.lookupKickstartTrees();

        //Any distros exist on spacewalk and not in cobbler?
        Map<String, Distro> cobblerDistros = getDistros();
        for (KickstartableTree tree : trees) {
            if (!cobblerDistros.containsKey(tree.getCobblerId())) {
                String err = createDistro(tree, false);
                if (err != null) {
                    errors.add(err);
                }
            }
            if (!cobblerDistros.containsKey(tree.getCobblerXenId()) &&
                                                    tree.doesParaVirt()) {
                String err = createDistro(tree, true);
                if (err != null) {
                    errors.add(err);
                }
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
        StringBuffer messages = new StringBuffer();
        for (int i = 0; i < errors.size(); i++) {
            messages.append(errors.get(i));
            messages.append("\n");
        }
        if (messages.length() == 0) {
            return null;
        }
        else {
            return new ValidatorError("kickstart.cobbler.distro.syncfail", messages);
        }
    }


    private String createDistro(KickstartableTree tree, boolean xen) {
        log.debug("Trying to create: " + tree.getLabel() + " in cobbler over xmlrpc");
        Map ksmeta = new HashMap();
        KickstartUrlHelper helper = new KickstartUrlHelper(tree);
        ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE,
                helper.getKickstartMediaPath());



        if (!xen) {

            log.debug("tree in spacewalk but not in cobbler. " +
                    "creating non-xenpv distro in cobbler : " + tree.getLabel());

            String error =
                validateKernelInitrd(tree.getLabel(),
                        tree.getKernelPath(), tree.getInitrdPath());
            if (error != null) {
                return error;
            }

            Distro distro = Distro.create(
                    CobblerXMLRPCHelper.getAutomatedConnection(),
                    tree.getCobblerDistroName(), tree.getKernelPath(),
                    tree.getInitrdPath(), ksmeta);
            tree.setCobblerId(distro.getUid());
            invokeCobblerUpdate();
        }
        else if (tree.doesParaVirt() && xen) {
            log.debug("tree in spacewalk but not in cobbler. " +
                    "creating xenpv distro in cobbler : " + tree.getLabel());

            String error =
                validateKernelInitrd(tree.getLabel(),
                        tree.getKernelXenPath(), tree.getInitrdXenPath());
            if (error != null) {
                return error;
            }

            Distro distroXen = Distro.create(
                    CobblerXMLRPCHelper.getAutomatedConnection(),
                tree.getCobblerXenDistroName(), tree.getKernelXenPath(),
                tree.getInitrdXenPath(), ksmeta);
            tree.setCobblerXenId(distroXen.getUid());
        }
        tree.setModified(new Date());
        return null;
    }

    private String validateKernelInitrd(String label, String kernelPath,
            String initrdPath) {
        File kernel = new File(kernelPath);
        if (!kernel.exists()) {
            String msg = "ERROR: No kernel found in this path: [" + kernelPath +
                         "] Spacewalk cant create the distro in cobbler which" +
                         " makes this kickstart distribution: [" + label +
                         "] unusable to Spacewalk.";

            log.error(msg);
            return msg;
        }
        File initrd = new File(initrdPath);
        if (!initrd.exists()) {
            String msg = "ERROR: No initrd found in this path: [" + initrdPath +
                         "] Spacewalk cant create the distro in cobbler which" +
                         " makes this kickstart distribution: [" + label +
                         "] unusable to Spacewalk.";
            log.error(msg);
            return msg;
        }
        return null;
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
