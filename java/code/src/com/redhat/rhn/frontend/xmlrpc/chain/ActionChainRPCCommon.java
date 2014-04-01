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
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.system.SystemManager;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Common mix-in for package resolving.
 *
 * @author bo
 */
public class ActionChainRPCCommon {
    protected static final String[] COMBO_KEYS = new String[]{"evr_id", "arch_id", "name_id"};

    /**
     * Parameters collector.
     */
    public static class Collector {
        private final User user;
        private final Server server;
        private final ActionChain chain;
        private boolean freshChain;

        /**
         * Collector constructor.
         * @param sessionToken
         * @param serverId
         * @param chainName
         */
        public Collector(String sessionToken,
                         Integer serverId,
                         String chainName) {
            this.freshChain = false;
            if (StringUtil.nullOrValue(sessionToken) == null) {
                this.user = null;
            }
            else {
                this.user = ActionChainHandler.getLoggedInUser(sessionToken);
            }

            Server system;
            try {
                system = SystemManager.lookupByIdAndUser((long) serverId, user);
            }
            catch (Exception ex) {
                system = null;
            }
            this.server = system;

            if (StringUtil.nullOrValue(chainName) == null) {
                this.chain = null;
            }
            else {
                this.freshChain = ActionChainFactory.getActionChain(chainName) == null;
                this.chain = ActionChainFactory.getOrCreateActionChain(
                    chainName, this.user);
            }
        }

        /**
         * Flush the chain as long as it was freshly created and is empty in case when
         * XML-RPC result is invalid.
         */
        public int cleanup(int rpcResult) {
            if (rpcResult == BaseHandler.INVALID && this.chain != null) {
                if (this.freshChain && this.chain.getEntries().isEmpty()) {
                    ActionChainFactory.delete(this.chain);
                }
            }

            return rpcResult;
        }

        private String str(String value) {
            value = StringUtil.nullOrValue(value);
            return value == null ? "" : value;
        }

        /**
         * Collector constructor.
         *
         * @param sessionToken
         * @param servername
         * @param ip
         * @param chainName
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
                this.server = system;
            }
            else {
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

                this.server = found ? system : null;
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

        /**
         * Verifies if the collector is valid.
         * @return boolean
         */
        boolean isValid() {
            return this.getServer() != null &&
                   this.getUser() != null &&
                   this.getChain() != null;
        }
    }

    /**
     * Set the package data into a map from the package list item for transformation.
     *
     * @param pi
     * @return map
     */
    private Map<String, Object> getPkgData(PackageListItem pi) {
        Map pkgData = new HashMap<String, String>();
        pkgData.put("id", pi.getId());
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
     * @param allPackages
     * @param userPackages
     * @param c
     * @return selectedPackages
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
     * @param allPackages
     * @param userPackages
     * @return selectedPackages
     */
    public List<Map<String, Long>> selectPackages(List allPackages,
                                     List<Integer> userPackages) {
        List<Map<String, Long>> selected = new ArrayList<Map<String, Long>>();
        for (Object pkgContainer : allPackages) {
            if ((pkgContainer instanceof PackageListItem) ||
                (pkgContainer instanceof UpgradablePackageListItem)) {
                Map pkgData = this.getPkgData((PackageListItem) pkgContainer);
                for (Integer pkgId : userPackages) {
                    if (((Long) pkgData.get("id")) == (long) pkgId) {
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
}
