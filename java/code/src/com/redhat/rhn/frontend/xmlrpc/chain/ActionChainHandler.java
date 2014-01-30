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
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author bo
 */
public class ActionChainHandler extends BaseHandler {
    /**
     * Parameters collector.
     */
    private static class Collector {
        private final User user;
        private final Server server;
        private final ActionChain chain;

        /**
         * Collector constructor.
         * @param sessionToken
         * @param serverId
         * @param chainName
         */
        public Collector(String sessionToken,
                         Integer serverId,
                         String chain) {
            this.user = ActionChainHandler.getLoggedInUser(sessionToken);
            this.server = SystemManager.lookupByIdAndUser((long) serverId, user);
            this.chain = ActionChainFactory.getOrCreateActionChain(chain, this.user);
        }

        ActionChain getChain() {return chain;}
        Server getServer() {return server;}
        User getUser() {return user;}
    }

    /**
     * Selects the packages by the list of names.
     * @param allPackages
     * @param userPackages
     * @return
     */
    private List<Map<String, Long>> selectPackages(List allPackages,
                                                   List<Map<String, String>> userPackages,
                                                   Collector c) {
        List<Map<String, Long>> packages = new ArrayList();
        for (Object pkgContainer : allPackages) {
            Map pkgData;
            if (pkgContainer instanceof Map) {
                pkgData = (Map) pkgContainer;
                System.err.println("pkgdata (hash)> " + pkgData);
            } else if ((pkgContainer instanceof PackageListItem) ||
                       (pkgContainer instanceof UpgradablePackageListItem)) {
                PackageListItem pi = (PackageListItem) pkgContainer;
                pkgData = new HashMap<String, String>();
                pkgData.put("version", pi.getVersion());
                pkgData.put("release", pi.getRelease());
                pkgData.put("name", pi.getName());
                pkgData.put("evrid", pi.getEvrId());
                pkgData.put("archid", pi.getArchId());
                pkgData.put("nameid", pi.getNameId());
            } else {
                return packages;
            }

            Map<String, Long> container = new HashMap<String, Long>();
            for (Map<String, String> userPkgData : userPackages) {
                String pkgName = StringUtil.nullOrValue(userPkgData.get("name"));
                if (pkgName == null) {
                    continue;
                }

                String userPackageVersion = StringUtil.nullOrValue(userPkgData.get("version"));
                if (userPackageVersion != null && !userPackageVersion.equals(pkgData.get("version"))) {
                    continue;
                }

                String userPackageRelease = StringUtil.nullOrValue(userPkgData.get("release"));
                if (userPackageRelease != null && !userPackageRelease.equals(pkgData.get("release"))) {
                    continue;
                }

                container.put("evr_id", (Long) pkgData.get("evrid"));
                container.put("arch_id", (Long) pkgData.get("archid"));
                container.put("name_id", (Long) pkgData.get("nameid"));

                if (pkgData.get("name").toString().toLowerCase().contains(pkgName.toLowerCase())) {
                    packages.add(container);
                }
            }
        }

        return packages;
    }

    // Action chain
    public Object[] listChains(String sk) {
        //ActionChainFactory.getActionChains()
        return null;
    }

    /**
     * Adds an action to remove installed packages on the system.
     * @param sk Session key (token)
     * @param serverId Server ID
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param
     *    #array()
     *       #struct("packages")
     *          #prop_desc("string", "name", "Package name")
     *          #prop_desc("string", "version", "Package version")
     *       #struct_end()
     *    #array_end()
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addPackageRemoval(String sk, Integer serverId,
                                 List<Map<String, String>> packages, String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        List<Map<String, Long>> selectedPackages = this.selectPackages(
                SystemManager.installedPackages((long) serverId, true), packages, c);
        if (!selectedPackages.isEmpty()) {
            ActionChainManager.schedulePackageRemoval(c.getUser(), c.getServer(),
                                                 selectedPackages,new Date(), c.getChain());
            return 1;
        }

        return -1;
    }

    /**
     * Adds an action to install desired packages on the system.
     * @param sk Session key (token)
     * @param serverId Server ID
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param
     *    #array()
     *       #struct("packages")
     *          #prop_desc("string", "name", "Package name")
     *          #prop_desc("string", "version", "Package version")
     *       #struct_end()
     *    #array_end()
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addPackageInstall(String sk,
                                 Integer serverId,
                                 List<Map<String, String>> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.systemAvailablePackages((long) serverId, null), packages, c);
        if (!selectedPackages.isEmpty()) {
            ActionChainManager.schedulePackageInstall(c.getUser(), c.getServer(),
                                                 selectedPackages,new Date(), c.getChain());
            return 1;
        }

        return -1;
    }


    /**
     * Adds an action to verify installed packages on the system.
     * @param sk Session key (token)
     * @param serverId Server ID
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param
     *    #array()
     *       #struct("packages")
     *          #prop_desc("string", "name", "Package name")
     *          #prop_desc("string", "version", "Package version")
     *       #struct_end()
     *    #array_end()
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addPackageVerify(String sk,
                                Integer serverId,
                                List<Map<String, String>> packages,
                                String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.systemPackageList((long) serverId, null), packages, c);
        if (!selectedPackages.isEmpty()) {
            ActionChainManager.schedulePackageVerify(c.getUser(), c.getServer(),
                                                selectedPackages, new Date(), c.getChain());
            return 1;
        }

        return 0;
    }

    /**
     * Adds an action to upgrade installed packages on the system.
     * @param sk Session key (token)
     * @param serverId Server ID
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param
     *    #array()
     *       #struct("packages")
     *          #prop_desc("string", "name", "Package name")
     *          #prop_desc("string", "version", "Package version")
     *       #struct_end()
     *    #array_end()
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addPackageUpgrade(String sk,
                                 Integer serverId,
                                 List<Map<String, String>> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.upgradable((long) serverId, null), packages, c);
        if (!selectedPackages.isEmpty()) {
            ActionChainManager.schedulePackageUpgrade(c.getUser(), c.getServer(),
                                                 selectedPackages,new Date(), c.getChain());
            return 1;
        }

        return -1;
    }
}
