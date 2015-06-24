/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;

import org.apache.log4j.Logger;
import org.cobbler.Distro;

import java.io.File;
import java.util.Arrays;
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
            toReturn.put(distro.getUid(), distro);
        }
        return toReturn;
    }


    /**
     * Sync spacewalk distros that have a null cobblerId
     *  we do this in store as well, (while doing other syncing
     *  tasks, but this is needed occasionally outside of store.
     * @return an error if applicable
     */
    public ValidatorError syncNullDistros() {
        List<String> errors = new LinkedList<String>();
        List<KickstartableTree> unSynced = KickstartFactory.listUnsyncedKickstartTrees();
        String err;
        for (KickstartableTree tree : unSynced) {

            if (!tree.isPathsValid()) {
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
        return new ValidatorError("kickstart.cobbler.distro.syncfail", messages);
    }



    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        List<String> errors = new LinkedList<String>();

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
        // Are there any distros that have changed
        for (KickstartableTree tree : trees) {
            Distro cobDistro = null;
            if (cobblerDistros.containsKey(tree.getCobblerId())) {
                cobDistro = cobblerDistros.get(tree.getCobblerId());
            }
            else if (cobblerDistros.containsKey(tree.getCobblerXenId())) {
                cobDistro = cobblerDistros.get(tree.getCobblerXenId());
            }
            if (cobDistro != null) {
                // last_modified is updated:
                // 1) if we're inserting a new kickstartable tree
                // 2) if we're updating a row and not changing cobbler_id, cobbler_xen_id,
                //    and last_modified -- aka we update tree_path or something
                // 3) if you update it explicitly
                // If everything is updated then they should be the same, this loop sets
                // last_modified. If dates are different then sync Spacewalk's data to
                // cobbler. Syncing the other way is not supported. Round to within
                // 1 second to smooth out differences between storing fractional seconds
                // or not.
                if (Math.abs(cobDistro.getModified().getTime() -
                        tree.getLastModified().getTime()) > 1000) {
                    syncSpacewalkToDistro(tree);
                    // we've synced; set tree.last_modified to indicate we're in-sync
                    cobDistro.reload();
                    tree.setLastModified(cobDistro.getModified());
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
        return new ValidatorError("kickstart.cobbler.distro.syncfail", messages);
    }


    private String createDistro(KickstartableTree tree, boolean xen) {
        String treeLabel = tree.getLabel();
        log.debug("Trying to create: " + treeLabel + " in cobbler over xmlrpc");

        Map ksmeta = createKsMetadataFromTree(tree);

        if (!xen) {

            log.debug("tree missing in cobbler. " +
                    "creating non-xenpv distro in cobbler : " + treeLabel);

            try {
                tree.getKernelPath();
            }
            catch (ValidatorException e) {
                return "ERROR: No kernel found in this path: [" +
                        StringUtil.join(", ", Arrays.asList(tree.getDefaultInitrdPath())) +
                        "] Cannot create the distro in cobbler which" +
                        " makes this kickstart distribution: [" + treeLabel +
                        "] unusable.";
            }

            try {
                tree.getInitrdPath();
            }
            catch (ValidatorException e) {
                return "ERROR: No initrd found in this path: [" +
                        StringUtil.join(", ", Arrays.asList(tree.getDefaultInitrdPath())) +
                        "] Cannot create the distro in cobbler which" +
                        " makes this kickstart distribution: [" + treeLabel +
                        "] unusable.";
            }

            Distro distro = Distro.create(CobblerXMLRPCHelper.getAutomatedConnection(),
                    tree.getCobblerDistroName(), tree.getKernelPath(),
                    tree.getInitrdPath(), ksmeta, tree.getInstallType().getCobblerBreed(),
                    tree.getInstallType().getCobblerOsVersion(),
                    tree.getChannel().getChannelArch().cobblerArch());
            tree.setCobblerId(distro.getUid());
            invokeCobblerUpdate();
        }
        else if (tree.doesParaVirt() && xen) {
            log.debug("tree missing in cobbler. " +
                    "creating xenpv distro in cobbler : " + treeLabel);

            String error =
                validateKernelInitrd(treeLabel,
                        tree.getKernelXenPath(), tree.getInitrdXenPath());
            if (error != null) {
                return error;
            }

            Distro distroXen = Distro.create(CobblerXMLRPCHelper.getAutomatedConnection(),
                    tree.getCobblerXenDistroName(), tree.getKernelXenPath(),
                    tree.getInitrdXenPath(), ksmeta,
                    tree.getInstallType().getCobblerBreed(),
                    tree.getInstallType().getCobblerOsVersion(),
                    tree.getChannel().getChannelArch().cobblerArch());
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
                         "] Cannot create the distro in cobbler which" +
                         " makes this kickstart distribution: [" + label +
                         "] unusable.";

            log.error(msg);
            return msg;
        }
        File initrd = new File(initrdPath);
        if (!initrd.exists()) {
            String msg = "ERROR: No initrd found in this path: [" + initrdPath +
                         "] Cannot create the distro in cobbler which" +
                         " makes this kickstart distribution: [" + label +
                         "] unusable.";
            log.error(msg);
            return msg;
        }
        return null;
    }

    private void syncSpacewalkToDistro(KickstartableTree tree) {
        if (tree.isRhnTree()) {
            log.debug("Syncing: " + tree.getLabel() + " to cobbler over xmlrpc");
            CobblerDistroEditCommand command = new CobblerDistroEditCommand(tree);
            command.store();
        }
    }
}
