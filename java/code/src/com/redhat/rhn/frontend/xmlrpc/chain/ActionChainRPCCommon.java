/**
 * Copyright (c) 2014 SUSE
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

package com.redhat.rhn.frontend.xmlrpc.chain;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.UpgradablePackageListItem;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.domain.rhnpackage.Package;

import org.cobbler.XmlRpcException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.Transformer;

/**
 * Common mix-in for package resolving.
 */
public class ActionChainRPCCommon {
    protected static final String[] COMBO_KEYS = new String[]{
        "evr_id", "arch_id", "name_id"
    };

    /**
     * Transformer from Long to Integer for the XML-RPC compatibility.
     */
    public static class IntegerToLongTransformer implements Transformer {
        // TODO: add javadoc
        @Override
        public Long transform(Object value) {
            return value == null ? null : ((Integer) value).longValue();
        }
    }

    /**
     * Parameters collector.
     */
    public static class Collector {
        private final User user;
        private final Server server;
        private final ActionChain chain;

        /**
         * Collector constructor.
         * @param sessionToken Session token
         * @param serverId System ID
         * @param chainLabel Chain label
         */
        // TODO: get rid of this class and add three methods to parent class.
        public Collector(String sessionToken,
                         Integer serverId,
                         String chainLabel) {
            if (StringUtil.nullOrValue(sessionToken) == null) {
                throw new XmlRpcException("Invalid session token.");
            }

            this.user = ActionChainHandler.getLoggedInUser(sessionToken);
            this.server = SystemManager.lookupByIdAndUser((long) serverId, user);

            if (StringUtil.nullOrValue(chainLabel) == null) {
                throw new XmlRpcException("Invalid Action Chain label.");
            }

            this.chain = ActionChainFactory.getActionChain(chainLabel);
            if (chain == null) {
                throw new XmlRpcException("Action Chain " + chainLabel + " not found.");
            }
        }

        private String str(String value) {
            value = StringUtil.nullOrValue(value);
            return value == null ? "" : value;
        }

        /**
         * Get the chain.
         * @return chain
         */
        ActionChain getChain() { return chain; }

        /**
         * Get the server.
         * @return server
         */
        Server getServer() { return server; }

        /**
         * Get the user.
         * @return user
         */
        User getUser() { return user; }
    }

    /**
     * Set the package data into a map from the package list item for transformation.
     *
     * @param pi PackageListItem object
     * @return map Carrier data
     */
    private Map<String, Object> getPackageData(PackageListItem pi) {
        Map<String, Object> packageData = new HashMap<String, Object>();
        packageData.put("id", pi.getPackageId());
        packageData.put("version", pi.getVersion());
        packageData.put("release", pi.getRelease());
        packageData.put("name", pi.getName());
        packageData.put("evr_id", pi.getEvrId());
        packageData.put("arch_id", pi.getArchId());
        packageData.put("name_id", pi.getNameId());

        return packageData;
    }

    /**
     * Selects the packages by the list of names.
     *
     * @param allPackages All available packages with data object.
     * @param userPackages User packages
     * @param c Collector object
     * @return selectedPackages List of selected packages
     */
    // TODO: remove
    public List<Map<String, Long>> selectPackages(List<Map<String, Object>> allPackages,
                                                   List<Map<String, String>> userPackages,
                                                   Collector c) {
        List<Map<String, Long>> packages = new ArrayList<Map<String, Long>>();
        for (Map<String, Object> pkgData : allPackages) {
            Map<String, Long> container = new HashMap<String, Long>();
            for (Map<String, String> userPkgData : userPackages) {
                String pkgName = userPkgData.get("name");

                String userPackageVersion = StringUtil.nullOrValue(
                    userPkgData.get("version"));
                if (userPackageVersion != null &&
                    !userPackageVersion.equals(pkgData.get("version"))) {
                    continue;
                }

                String userPackageRelease = StringUtil.nullOrValue(
                    userPkgData.get("release"));
                if (userPackageRelease != null &&
                    !userPackageRelease.equals(pkgData.get("release"))) {
                    continue;
                }

                container.put("evr_id", (Long) pkgData.get("evr_id"));
                container.put("arch_id", (Long) pkgData.get("arch_id"));
                container.put("name_id", (Long) pkgData.get("name_id"));

                if (pkgData.get("name").toString().toLowerCase().contains(
                    pkgName.toLowerCase())) {
                    packages.add(container);
                }
            }
        }

        return packages;
    }

    /**
     * Select wanted packages.
     *
     * @param allPackages All available packages with data object.
     * @param userPackages User packages
     * @return selectedPackages List of selected packages
     */
    //TODO: remove
    public List<Map<String, Long>> selectPackages(List<Object> allPackages,
                                     List<Integer> userPackages) {
        List<Map<String, Long>> selected = new ArrayList<Map<String, Long>>();
        for (Object pkgContainer : allPackages) {
            if ((pkgContainer instanceof PackageListItem) ||
                (pkgContainer instanceof UpgradablePackageListItem)) {
                Map<String, Object> pkgData =
                        this.getPackageData((PackageListItem) pkgContainer);
                for (Integer pkgId : userPackages) {
                    if (((Long) pkgData.get("id")).equals(Long.valueOf(pkgId))) {
                        Map<String, Long> pkgCombo = new HashMap<String, Long>();
                        for (String key : ActionChainRPCCommon.COMBO_KEYS) {
                            pkgCombo.put(key, (Long) pkgData.get(key));
                        }
                        selected.add(pkgCombo);
                    }
                }
            }
        }

        return selected;
    }

    /**
     * Resolve packages from IDs.
     *
     * @param userPackages User packages
     * @param user User of the system
     * @return selectedPackages Map of the selected packages
     */
    public List<Map<String, Long>> resolvePackages(List<Integer> userPackages, User user) {
        List<Map<String, Long>> selected = new ArrayList<Map<String, Long>>();
        for (Integer pkgId : userPackages) {
            Map<String, Long> pkgMap = new HashMap<String, Long>();

            Package pkg = PackageManager.lookupByIdAndUser(
                    new Long(pkgId.longValue()), user);
            if (pkg == null) {
                throw new InvalidPackageException(pkgId.toString());
            }

            pkgMap.put("name_id", pkg.getPackageName().getId());
            pkgMap.put("evr_id", pkg.getPackageEvr().getId());
            pkgMap.put("arch_id", pkg.getPackageArch().getId());

            selected.add(pkgMap);
        }

        return selected;
    }
}
