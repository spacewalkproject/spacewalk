/**
 * Copyright (c) 2015 SUSE LLC
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

import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;
import org.cobbler.CobblerConnection;
import org.cobbler.Distro;

import java.util.HashMap;
import java.util.Map;

/**
 * Singleton helper with methods for creating/updating cobbler
 * Distro from KickstartableTree.
 */
public class CobblerDistroHelper {

    private static CobblerDistroHelper instance;

    private CobblerDistroHelper() { }

    /**
     * Returns an instance of this this class (singleton).
     * @return instance of this this class (singleton).
     */
    public static synchronized CobblerDistroHelper getInstance() {
        if (instance == null) {
            instance = new CobblerDistroHelper();
        }
        return instance;
    }

    /**
     * Create a new (non-XEN) cobbler Distro from the given tree.
     * Update this tree with the ID of the new Distro.
     *
     * @param cobblerConnection connection to use to communicate with Cobbler
     * @param tree tree containing information for creating the new Distro
     * @return newly created Distro instance
     */
    public Distro createDistroFromTree(CobblerConnection cobblerConnection,
                                       KickstartableTree tree) {
        Map<String, String> ksmeta = createKsMetadataFromTree(tree);

        Distro distro = Distro.create(cobblerConnection,
                tree.getCobblerDistroName(), tree.getKernelPath(),
                tree.getInitrdPath(), ksmeta,
                tree.getInstallType().getCobblerBreed(),
                tree.getInstallType().getCobblerOsVersion(),
                tree.getChannel().getChannelArch().cobblerArch());
        tree.setCobblerId(distro.getUid());
        return distro;
    }

    /**
     * Create a new XEN cobbler Distro from the given tree.
     * Update this tree with the ID of the new Distro.
     *
     * @param cobblerConnection connection to use to communicate with Cobbler
     * @param tree tree containing information for creating the new Distro
     * @return newly created Distro instance
     */
    public Distro createXenDistroFromTree(CobblerConnection cobblerConnection,
                                          KickstartableTree tree) {
        Map<String, String> ksmeta = createKsMetadataFromTree(tree);
        Distro xen = Distro.create(cobblerConnection, tree.getCobblerXenDistroName(),
                tree.getKernelXenPath(),
                tree.getInitrdXenPath(), ksmeta,
                tree.getInstallType().getCobblerBreed(),
                tree.getInstallType().getCobblerOsVersion(),
                tree.getChannel().getChannelArch().cobblerArch());
        tree.setCobblerXenId(xen.getId());
        return xen;
    }

    /**
     * Update the existing (non-XEN) cobbler Distro using data from the given tree.
     *
     * @param distro Distro instance to be updated
     * @param tree tree containing information for updating the new Distro
     */
     public void updateDistroFromTree(Distro distro, KickstartableTree tree) {
        Map<String, String> ksmeta = createKsMetadataFromTree(tree);

        distro.setInitrd(tree.getInitrdPath());
        distro.setKernel(tree.getKernelPath());
        distro.setBreed(tree.getInstallType().getCobblerBreed());
        distro.setOsVersion(tree.getInstallType().getCobblerOsVersion());
        distro.setKsMeta(ksmeta);
        distro.setArch(tree.getChannel().getChannelArch().cobblerArch());
        distro.setKernelOptions(tree.getKernelOptions());
        distro.setKernelPostOptions(tree.getKernelOptionsPost());
        distro.save();
    }

    /**
     * Update the existing XEN cobbler Distro using data from the given tree.
     *
     * @param distro Distro instance to be updated
     * @param tree tree containing information for updating the new Distro
     */
    public void updateXenDistroFromTree(Distro distro, KickstartableTree tree) {
        Map<String, String> ksmeta = createKsMetadataFromTree(tree);

        distro.setKernel(tree.getKernelXenPath());
        distro.setInitrd(tree.getInitrdXenPath());
        distro.setBreed(tree.getInstallType().getCobblerBreed());
        distro.setOsVersion(tree.getInstallType().getCobblerOsVersion());
        distro.setKsMeta(ksmeta);
        distro.setArch(tree.getChannel().getChannelArch().cobblerArch());
        distro.setKernelOptions(tree.getKernelOptions());
        distro.setKernelPostOptions(tree.getKernelOptionsPost());
        distro.save();
    }

    private Map<String, String> createKsMetadataFromTree(KickstartableTree tree) {
        Map<String, String> ksmeta = new HashMap<String, String>();

        KickstartUrlHelper helper = new KickstartUrlHelper(tree);
        ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE,
                helper.getKickstartMediaPath());

        if (!tree.isRhnTree()) {
            ksmeta.put("org", tree.getOrgId().toString());
        }

        if (tree.getInstallType().isSUSE()) {
            ksmeta.put("autoyast", "true");
        }

        return ksmeta;
    }
}
