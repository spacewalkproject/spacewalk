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
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.UpgradablePackageListItem;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.domain.rhnpackage.Package;

import org.cobbler.XmlRpcException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
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
         * Collector constructor.
         *
         * @param sessionToken Session token
         * @param servername Server name
         * @param ip IP Address
         * @param chainName Chain label
         */
        public Collector(String sessionToken,
                         String servername,
                         String ip,
                         String chainName) {
            ip = this.str(ip);
            servername = this.str(servername).toLowerCase();
            boolean found = false;
            this.user = ActionChainHandler.getLoggedInUser(sessionToken);
            this.chain = ActionChainFactory.getOrCreateActionChain(chainName, this.user);
            Server system = null;
            if (servername.isEmpty() && ip.isEmpty()) {
                throw new XmlRpcException("Server name or an IP address should be given.");
            }

            for (Iterator it = SystemManager.systemList(
                    this.user, null).iterator(); it.hasNext();) {
                system = SystemManager.lookupByIdAndUser(
                        ((SystemOverview) it.next()).getId(), this.user);

                if ((!servername.isEmpty() &&
                         !system.getName().toLowerCase().equals(servername)) ||
                        (!ip.isEmpty() && (!this.str(system.getIp6Address()).equals(ip) &&
                                           !this.str(system.getIpAddress()).equals(ip)))) {
                    continue;
                }

                found = true;
                break;
            }

            if (found) {
                this.server = system;
            }
            else {
                throw new XmlRpcException(String.format("Cannot find server %s.",
                        (servername.isEmpty() ? (ip + " by IP address") : servername)));
            }
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
    private Map<String, Object> getPkgData(PackageListItem pi) {
        Map pkgData = new HashMap<String, Object>();
        pkgData.put("id", pi.getPackageId());
        pkgData.put("version", pi.getVersion());
        pkgData.put("release", pi.getRelease());
        pkgData.put("name", pi.getName());
        pkgData.put("evr_id", pi.getEvrId());
        pkgData.put("arch_id", pi.getArchId());
        pkgData.put("name_id", pi.getNameId());

        return pkgData;
    }

    /**
     * Selects the packages by the list of names.
     *
     * @param allPackages All available packages with data object.
     * @param userPackages User packages
     * @param c Collector object
     * @return selectedPackages List of selected packages
     */
    public List<Map<String, Long>> selectPackages(List allPackages,
                                                   List<Map<String, String>> userPackages,
                                                   Collector c) {
        List<Map<String, Long>> packages = new ArrayList<Map<String, Long>>();
        for (Object pkgContainer : allPackages) {
            Map pkgData;
            if (pkgContainer instanceof Map) {
                pkgData = (Map) pkgContainer;
            }
            else if ((pkgContainer instanceof PackageListItem) ||
                       (pkgContainer instanceof UpgradablePackageListItem)) {
                pkgData = this.getPkgData((PackageListItem) pkgContainer);
            }
            else {
                return packages;
            }

            Map<String, Long> container = new HashMap<String, Long>();
            for (Map<String, String> userPkgData : userPackages) {
                String pkgName = StringUtil.nullOrValue(userPkgData.get("name"));
                if (pkgName == null) {
                    continue;
                }

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
    public List<Map<String, Long>> selectPackages(List allPackages,
                                     List<Integer> userPackages) {
        List<Map<String, Long>> selected = new ArrayList<Map<String, Long>>();
        for (Object pkgContainer : allPackages) {
            if ((pkgContainer instanceof PackageListItem) ||
                (pkgContainer instanceof UpgradablePackageListItem)) {
                Map pkgData = this.getPkgData((PackageListItem) pkgContainer);
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
