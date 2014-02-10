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
import com.redhat.rhn.domain.action.ActionChainEntry;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.UpgradablePackageListItem;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import javax.xml.bind.DatatypeConverter;

/**
 * @xmlrpc.namespace actionchains
 * @xmlrpc.doc Provides the namespace for the Action Chain methods.
 * @author bo
 */
public class ActionChainHandler extends BaseHandler {
    private static final String[] COMBO_KEYS = new String[]{"evrid", "archid", "nameid"};

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
                         String chainName) {
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
                this.chain = ActionChainFactory.getOrCreateActionChain(
                    chainName, this.user);
            }
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
         * @param chain
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
     * Select wanted packages.
     *
     * @param allPackages
     * @param userPackages
     * @return selectedPackages
     */
    private List<Map<String, Long>> selectPackages(List allPackages,
                                     List<Integer> userPackages) {
        List<Map<String, Long>> selected = new ArrayList<Map<String, Long>>();
        for (Object pkgContainer : allPackages) {
            if ((pkgContainer instanceof PackageListItem) ||
                (pkgContainer instanceof UpgradablePackageListItem)) {
                Map pkgData = this.getPkgData((PackageListItem) pkgContainer);
                for (Integer pkgId : userPackages) {
                    if (((Long) pkgData.get("id")) == (long) pkgId) {
                        Map<String, Long> pkgCombo = new HashMap<String, Long>();
                        for (String key : ActionChainHandler.COMBO_KEYS) {
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
        pkgData.put("evrid", pi.getEvrId());
        pkgData.put("archid", pi.getArchId());
        pkgData.put("nameid", pi.getNameId());

        return pkgData;
    }

    /**
     * Selects the packages by the list of names.
     *
     * @param allPackages
     * @param userPackages
     * @return selectedPackages
     */
    private List<Map<String, Long>> selectPackages(List allPackages,
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

                container.put("evr_id", (Long) pkgData.get("evrid"));
                container.put("arch_id", (Long) pkgData.get("archid"));
                container.put("name_id", (Long) pkgData.get("nameid"));

                if (pkgData.get("name").toString().toLowerCase().contains(
                    pkgName.toLowerCase())) {
                    packages.add(container);
                }
            }
        }

        return packages;
    }

    /**
     * List currently available action chains.
     *
     * @return list of action chains.
     *
     * @xmlrpc.doc List currently available action chains.
     * @xmlrpc.returntype
     *    #array()
     *       #struct("chain")
     *          #prop_desc("string", "name", "Name of an Action Chain")
     *          #prop_desc("string", "entrycount", "Number of entries in the Action Chain")
     *       #struct_end()
     *    #array_end()
     */
    public List<Map<String, String>> listChains() {
        List<Map<String, String>> chains = new ArrayList<Map<String, String>>();
        for (ActionChain actionChain : ActionChainFactory.getActionChains()) {
            Map<String, String> info = new HashMap<String, String>();
            info.put("name", actionChain.getLabel());
            info.put("entrycount", (actionChain.getEntries() != null ?
                                    actionChain.getEntries().size() : 0) + "");
            chains.add(info);
        }

        return chains;
    }

    /**
     * List all actions in the particular Action Chain.
     *
     * @param chainName The label of the Action Chain.
     * @return List of entries in the particular action chain, if any.
     *
     * @xmlrpc.doc List all actions in the particular Action Chain.
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype
     *    #array()
     *       #struct("entry")
     *          #prop_desc("string", "name", "Name of an Action")
     *          #prop_desc("string", "created", "Created date/time")
     *          #prop_desc("string", "earliest", "Earliest scheduled date/time")
     *          #prop_desc("string", "type", "Type of the action")
     *          #prop_desc("string", "modified", "Modified date/time")
     *          #prop_desc("string", "cuid", "Creator UID")
     *       #struct_end()
     *    #array_end()
     */
    public List<Map<String, Object>> chainActions(String chainName) {
        List<Map<String, Object>> entries = new ArrayList<Map<String, Object>>();
        if (StringUtil.nullOrValue(chainName) == null) {
            return entries;
        }

        ActionChain chain = ActionChainFactory.getActionChain(chainName);
        if (chain != null && chain.getEntries() != null && !chain.getEntries().isEmpty()) {
            for (ActionChainEntry entry : chain.getEntries()) {
                Map<String, Object> info = new HashMap<String, Object>();
                info.put("name", entry.getAction().getName());
                info.put("created", entry.getAction().getCreated());
                info.put("earliest", entry.getAction().getEarliestAction());
                info.put("type", entry.getAction().getActionType().getName());
                info.put("modified", entry.getAction().getModified());
                info.put("cuid", entry.getAction().getSchedulerUser().getLogin());
                entries.add(info);
            }
        }

        return entries;
    }

    /**
     * Remove actions from an Action Chain.
     *
     * @param chainName The label of the Action Chain.
     * @param actionNames List of action names.
     * @return State of the action result. Negative is false.
     *         Positive: number of successfully deleted entries.
     *
     * @xmlrpc.doc Remove actions from an Action Chain.
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.param #array_single("string", "actionName")
     * @xmlrpc.returntype #int
     */
    public int removeActions(String chainName,
                             List<String> actionNames) {
        if (StringUtil.nullOrValue(chainName) == null || actionNames.isEmpty()) {
            return BaseHandler.INVALID;
        }

        int d = 0;
        ActionChain chain = ActionChainFactory.getActionChain(chainName);
        if (chain != null && !chain.getEntries().isEmpty()) {
            List<ActionChainEntry> entriesToDelete = new ArrayList<ActionChainEntry>();
            for (ActionChainEntry entry : chain.getEntries()) {
                for (String actionName : actionNames) {
                    if (entry.getAction().getName().equals(actionName)) {
                        entriesToDelete.add(entry);
                    }
                }
            }

            if (!entriesToDelete.isEmpty()) {
                for (ActionChainEntry entry : entriesToDelete) {
                    d += chain.getEntries().remove(entry) ? 1 : 0;
                }
            }
        }

        return d > 0 ? d : this.bool(Boolean.FALSE);
    }

    /**
     * Remove Action Chains by label.
     *
     * @param chainNames List of action names.
     * @return State of the action result. Negative is false.
     *         Positive: number of successfully deleted entries.
     *
     * @xmlrpc.doc Remove action chains by label.
     * @xmlrpc.param #array_single("string", "chainLabels")
     * @xmlrpc.returntype #int
     */
    public int removeChains(List<String> chainNames) {
        if (chainNames.isEmpty()) {
            return BaseHandler.INVALID;
        }

        int d = 0;
        for (String chainName : chainNames) {
            ActionChain chain = ActionChainFactory.getActionChain(chainName);
            if (chain != null) {
                ActionChainFactory.delete(chain);
                d++;
            }
        }

        return d > 0 ? d : BaseHandler.INVALID;
    }

    /**
     * Schedule system reboot.
     *
     * @param sk Session key (token)
     * @param serverId Server ID.
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule system reboot.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addSystemReboot(String sk, Integer serverId, String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }

        return this.bool(ActionChainManager.scheduleRebootAction(c.getUser(),
                                                            c.getServer(),
                                                            new Date(),
                                                            c.getChain()) != null);
    }

    /**
     * Adds an action to remove installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverName Name of the server (without the domain name)
     * @param serverIp IP address.
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to remove installed packages on the system.
     *             Server IP and/or name is required. Both name and IP cannot be empty.
     *             Server name should be exact, without the domain name.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "serverName")
     * @xmlrpc.param #param("string", "serverIp")
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
    public int addPackageRemoval(String sk,
                                 String serverName,
                                 String serverIp,
                                 List<Map<String, String>> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverName, serverIp, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }

        List<Map<String, Long>> selectedPackages = this.selectPackages(
            SystemManager.installedPackages(c.getServer().getId(), true), packages, c);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageRemoval(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }

    /**
     * Adds an action to remove installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to remove installed packages on the system.
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
    public int addPackageRemoval(String sk,
                                 Integer serverId,
                                 List<Map<String, String>> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }

        List<Map<String, Long>> selectedPackages = this.selectPackages(
            SystemManager.installedPackages(c.getServer().getId(), true), packages, c);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageRemoval(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }

    /**
     * Schedule package installation to an Action Chain.
     *
     * @param sk Session key (token)
     * @param serverId System ID.
     * @param packages List of packages.
     * @param chainName Name (label) of the Action Chain.
     * @return True or false in XML-RPC representation: 1 or 0 respectively.
     *
     * @xmlrpc.doc Schedule package installation to an Action Chain.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("int", "Package ID")
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addPackageInstall(String sk,
                                 Integer serverId,
                                 List<Integer> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }

        List<Map<String, Long>> selectedPackages = this.selectPackages(
            PackageManager.systemAvailablePackages(c.getServer().getId(), null), packages);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageInstall(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }

    /**
     * Schedule an action to install desired packages on the system.
     *
     * @param sk Session key (token)
     * @param serverName Name of the server (without the domain name)
     * @param serverIp IP address.
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule an action to install desired packages on the system.
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
                                 String serverName,
                                 String serverIp,
                                 List<Map<String, String>> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverName, serverIp, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }

        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.systemAvailablePackages(
                        c.getServer().getId(), null), packages, c);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageInstall(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }


    /**
     * Adds an action to verify installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverName Name of the server (without the domain name)
     * @param serverIp IP address.
     * @param packages List of packages.
     * @param chainName Name of the action chain.
     * @return True or false in XML-RPC representation (1 or 0 respectively).
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "serverName")
     * @xmlrpc.param #param("string", "serverIp")
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
                                String serverName, String serverIp,
                                List<Map<String, String>> packages,
                                String chainName) {
        Collector c = new Collector(sk, serverName, serverIp, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }

        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.systemPackageList(c.getServer().getId(), null), packages, c);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageVerify(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }

    /**
     * Adds an action to verify installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addPackageVerify(String sk,
                                Integer serverId,
                                List<Integer> packages,
                                String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }
        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.systemPackageList(c.getServer().getId(), null), packages);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageVerify(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }

    /**
     * Adds an action to upgrade installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverName Name of the server (without the domain name)
     * @param serverIp IP address.
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Adds an action to upgrade installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "serverName")
     * @xmlrpc.param #param("string", "serverIp")
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
                                 String serverName,
                                 String serverIp,
                                 List<Map<String, String>> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverName, serverIp, chainName);
        if (c.getServer() == null) {
            return BaseHandler.INVALID;
        }

        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.upgradable(c.getServer().getId(), null), packages, c);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageUpgrade(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }

    /**
     * Adds an action to upgrade installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainName Name of the action chain
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Adds an action to upgrade installed packages on the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param #param("string", "chainName")
     * @xmlrpc.returntype #int
     */
    public int addPackageUpgrade(String sk,
                                 Integer serverId,
                                 List<Integer> packages,
                                 String chainName) {
        Collector c = new Collector(sk, serverId, chainName);
        if (!c.isValid()) {
            return BaseHandler.INVALID;
        }

        List<Map<String, Long>> selectedPackages = this.selectPackages(
                PackageManager.upgradable(c.getServer().getId(), null), packages);
        if (!selectedPackages.isEmpty()) {
            return this.bool(ActionChainManager.schedulePackageUpgrade(
                c.getUser(), c.getServer(), selectedPackages,
                new Date(), c.getChain()) != null);
        }

        return BaseHandler.INVALID;
    }

    /**
     * Add a remote command as a script.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param uid User ID on the remote system.
     * @param scriptBody Base64 encoded script.
     * @param gid Group ID on the remote system.
     * @param timeout Timeout
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Add a remote command as a script.
     *             NOTE: The script body must be Base64 encoded!
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "uid", "User ID on the particular system")
     * @xmlrpc.param #param("string", "gid", "Group ID on the particular system")
     * @xmlrpc.param #param("int", "timeout", "Timeout cannot exceed 1200 seconds")
     * @xmlrpc.param #param("string", "scriptBodyBase64", "Base64 encoded script body")
     * @xmlrpc.returntype #int
     */
    public int addRemoteCommand(String sk,
                                Integer serverId,
                                String uid,
                                String gid,
                                Integer timeout,
                                String scriptBody) {
        Collector c = new Collector(sk, serverId, scriptBody);

        List<Long> systems = new ArrayList<Long>();
        systems.add((long) serverId);

        if (timeout > 1200) {
            timeout = 1200;
        }

        if (timeout < 1) {
            timeout = 120;
        }

        ScriptActionDetails script = ActionManager.createScript(uid, gid, (long) timeout,
            new String(DatatypeConverter.parseBase64Binary(scriptBody)));

        Date date = new Date();

        return this.bool(ActionChainManager.scheduleScriptRuns(
            c.getUser(), systems,
            String.format("Remote Script at %s",
                          SimpleDateFormat.getDateInstance(
                              SimpleDateFormat.MEDIUM).format(date)),
            script, date, c.getChain()) != null);
    }
}
