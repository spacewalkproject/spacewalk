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
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchActionException;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.bind.DatatypeConverter;

import org.apache.commons.collections.CollectionUtils;

/**
 * @xmlrpc.namespace actionchain
 * @xmlrpc.doc Provides the namespace for the Action Chain methods.
 */
public class ActionChainHandler extends BaseHandler {

    private final ActionChainRPCCommon acUtil;

    /**
     * Parameters collector.
     */
    public ActionChainHandler() {
        this.acUtil = new ActionChainRPCCommon();
    }

    /**
     * List currently available action chains.
     *
     * @param sessionKey Session token.
     * @return list of action chains.
     *
     * @xmlrpc.doc List currently available action chains.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * @xmlrpc.returntype #array() #struct("chain") #prop_desc("string",
     * "label", "Label of an Action Chain") #prop_desc("string", "entrycount",
     * "Number of entries in the Action Chain") #struct_end() #array_end()
     */
    public List<Map<String, Object>> listChains(String sessionKey) {
        BaseHandler.getLoggedInUser(sessionKey);

        List<Map<String, Object>> chains = new ArrayList<Map<String, Object>>();
        for (ActionChain actionChain : ActionChainFactory.getActionChains()) {
            Map<String, Object> info = new HashMap<String, Object>();
            info.put("label", actionChain.getLabel());
            info.put("entrycount", actionChain.getEntries().size());
            chains.add(info);
        }

        return chains;
    }

    /**
     * List all actions in the particular Action Chain.
     *
     * @param sessionKey Session token.
     * @param chainLabel The label of the Action Chain.
     * @return List of entries in the particular action chain, if any.
     *
     * @xmlrpc.doc List all actions in the particular Action Chain.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype #array() #struct("entry") #prop_desc("int", "id",
     * "Action ID") #prop_desc("string", "label", "Label of an Action")
     * #prop_desc("string", "created", "Created date/time") #prop_desc("string",
     * "earliest", "Earliest scheduled date/time") #prop_desc("string", "type",
     * "Type of the action") #prop_desc("string", "modified",
     * "Modified date/time") #prop_desc("string", "cuid", "Creator UID")
     * #struct_end() #array_end()
     */
    public List<Map<String, Object>> listChainActions(String sessionKey,
                                                      String chainLabel) {
        List<Map<String, Object>> entries = new ArrayList<Map<String, Object>>();
        ActionChain chain = this.acUtil.getActionChainByLabel(chainLabel);

        if (chain.getEntries() != null && !chain.getEntries().isEmpty()) {
            for (ActionChainEntry entry : chain.getEntries()) {
                Map<String, Object> info = new HashMap<String, Object>();
                info.put("id", entry.getAction().getId());
                info.put("label", entry.getAction().getName());
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
     * Remove an action from the Action Chain.
     *
     * @param sessionKey Session key.
     * @param chainLabel The label of the Action Chain.
     * @param actionId Action ID.
     * @return State of the action result. Negative is false. Positive: number
     * of successfully deleted entries.
     *
     * @xmlrpc.doc Remove actions from an Action Chain.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #param_desc("int", "actionId", "Action ID")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer removeAction(String sessionKey, String chainLabel, Integer actionId) {
        BaseHandler.getLoggedInUser(sessionKey);
        ActionChain chain = this.acUtil.getActionChainByLabel(chainLabel);

        for (ActionChainEntry entry : chain.getEntries()) {
            if (entry.getAction().getId().equals(Long.valueOf(actionId))) {
                chain.getEntries().remove(entry);
                return BaseHandler.VALID;
            }
        }

        throw new NoSuchActionException("ID: " + actionId);
    }

    /**
     * Remove Action Chains by label.
     *
     * @param sessionKey Session key.
     * @param chainLabel Action Chain label.
     * @return State of the action result. Negative is false. Positive: number
     * of successfully deleted entries.
     *
     * @xmlrpc.doc Remove action chains by label.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #array_single("string", "chainLabels")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer removeActionChain(String sessionKey, String chainLabel) {
        BaseHandler.getLoggedInUser(sessionKey);
        ActionChainFactory.delete(this.acUtil.getActionChainByLabel(chainLabel));

        return BaseHandler.VALID;
    }

    /**
     * Create an Action Chain.
     *
     * @param sessionKey Session key (token)
     * @param chainLabel Label of the action chain
     * @return 1 on success
     *
     * @xmlrpc.doc Create an Action Chain.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action
     */
    public Integer createActionChain(String sessionKey, String chainLabel) {
        if (StringUtil.nullOrValue(chainLabel) == null) {
            throw new InvalidParameterException("Chain label is missing");
        }

        return ActionChainFactory.createActionChain(
                chainLabel, BaseHandler.getLoggedInUser(sessionKey)
        ).getId().intValue();
    }

    /**
     * Schedule system reboot.
     *
     * @param sessionKey Session key (token)
     * @param serverId Server ID.
     * @param chainLabel Label of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule system reboot.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action
     */
    public Integer addSystemReboot(String sessionKey, Integer serverId, String chainLabel) {
        User user = BaseHandler.getLoggedInUser(sessionKey);
        return ActionChainManager.scheduleRebootAction(
                user, this.acUtil.getServerById(serverId, user), new Date(),
                this.acUtil.getActionChainByLabel(chainLabel)
        ).getId().intValue();
    }

    /**
     * Adds an action to remove installed packages on the system.
     *
     * @param sessionKey Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainLabel Label of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to remove installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #array() #struct("packages") #prop_desc("string", "label",
     * "Package label") #prop_desc("string", "version", "Package version")
     * #struct_end() #array_end()
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action or exception
     */
    @SuppressWarnings("unchecked")
    public Integer addPackageRemoval(String sessionKey,
                                     Integer serverId,
                                     List<Integer> packages,
                                     String chainLabel) {
        if (packages.isEmpty()) {
            throw new InvalidParameterException("No specified packages.");
        }

        User user = BaseHandler.getLoggedInUser(sessionKey);
        return ActionChainManager.schedulePackageRemoval(user,
                this.acUtil.getServerById(serverId, user),
                this.acUtil.resolvePackages(packages,
                                            BaseHandler.getLoggedInUser(sessionKey)),
                new Date(),
                this.acUtil.getActionChainByLabel(chainLabel)).getId().intValue();
    }

    /**
     * Schedule package installation to an Action Chain.
     *
     * @param sessionKey Session key (token)
     * @param serverId System ID.
     * @param packages List of packages.
     * @param chainLabel Label of the Action Chain.
     * @return True or false in XML-RPC representation: 1 or 0 respectively.
     *
     * @xmlrpc.doc Schedule package installation to an Action Chain.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #array_single("int", "Package ID")
     * @xmlrpc.param #param("string", "chainLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer addPackageInstall(String sessionKey,
                                     Integer serverId,
                                     List<Integer> packages,
                                     String chainLabel) {
        if (packages.isEmpty()) {
            throw new InvalidParameterException("No specified packages.");
        }

        User user = BaseHandler.getLoggedInUser(sessionKey);
        return ActionChainManager.schedulePackageInstall(user,
                this.acUtil.getServerById(serverId, user),
                this.acUtil.resolvePackages(packages, user), new Date(),
                this.acUtil.getActionChainByLabel(chainLabel)
        ).getId().intValue();
    }

    /**
     * Adds an action to verify installed packages on the system.
     *
     * @param sessionKey Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainLabel Label of the action chain
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer addPackageVerify(String sessionKey,
                                    Integer serverId,
                                    List<Integer> packages,
                                    String chainLabel) {
        if (packages.isEmpty()) {
            throw new InvalidParameterException("No specified packages.");
        }

        User user = BaseHandler.getLoggedInUser(sessionKey);
        Server server = this.acUtil.getServerById(serverId, user);
        return ActionChainManager.schedulePackageVerify(
                user, server, this.acUtil.resolvePackages(packages, user), new Date(),
                this.acUtil.getActionChainByLabel(chainLabel)
        ).getId().intValue();
    }

    /**
     * Adds an action to upgrade installed packages on the system.
     *
     * @param sessionKey Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainLabel Label of the action chain
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Adds an action to upgrade installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype - actionID or throw an exception
     */
    public int addPackageUpgrade(String sessionKey,
                                 Integer serverId,
                                 List<Integer> packages,
                                 String chainLabel) {
        if (packages.isEmpty()) {
            throw new InvalidParameterException("No specified packages.");
        }

        User user = BaseHandler.getLoggedInUser(sessionKey);
        Server server = this.acUtil.getServerById(serverId, user);
        return ActionChainManager.schedulePackageUpgrade(
                user, server, this.acUtil.resolvePackages(packages, user), new Date(),
                this.acUtil.getActionChainByLabel(chainLabel)).getId().intValue();
    }

    /**
     * Add a remote command as a script.
     *
     * @param sessionKey Session key (token)
     * @param serverId System ID
     * @param chainLabel Label of the action chain.
     * @param uid User ID on the remote system.
     * @param scriptBody Base64 encoded script.
     * @param gid Group ID on the remote system.
     * @param timeout Timeout
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Add a remote command as a script. NOTE: The script body must
     * be Base64 encoded!
     *
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #param_desc("string", "uid",
     * "User ID on the particular system")
     * @xmlrpc.param #param_desc("string", "gid",
     * "Group ID on the particular system")
     * @xmlrpc.param #param_desc("int", "timeout",
     * "Timeout cannot exceed 1200 seconds")
     * @xmlrpc.param #param_desc("string", "scriptBodyBase64",
     * "Base64 encoded script body")
     * @xmlrpc.returntype int actionId - The id of the action or throw an
     * exception
     */
    public Integer addScriptRun(String sessionKey, Integer serverId, String chainLabel,
            String uid, String gid, Integer timeout, String scriptBody) {
        List<Long> systems = new ArrayList<Long>();
        systems.add((long) serverId);

        ScriptActionDetails script = ActionManager.createScript(
                uid, gid, (long) timeout, new String(
                        DatatypeConverter.parseBase64Binary(scriptBody)));
        return ActionChainManager.scheduleScriptRuns(
                BaseHandler.getLoggedInUser(sessionKey), systems, null, script, new Date(),
                this.acUtil.getActionChainByLabel(chainLabel)
        ).iterator().next().getId().intValue();
    }

    /**
     * Schedule action chain immediately.//TODO: not immediately
     *
     * @param sessionKey Session key (token)
     * @param chainLabel Label of the action chain
     * @param date Earliest date
     * @return True in XML-RPC representation
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #param("dateTime.iso8601", "Earliest date")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer schedule(String sessionKey, String chainLabel, Date date) {
        BaseHandler.getLoggedInUser(sessionKey);
        ActionChainFactory.schedule(this.acUtil.getActionChainByLabel(chainLabel), date);

        return BaseHandler.VALID;
    }

    /**
     * Deploy configuration.
     *
     * @param sessionKey Session key (token)
     * @param chainLabel Label of the action chain
     * @param serverId System ID
     * @param revisions List of configuration revisions.
     * @return True in XML-RPC representation
     *
     * @xmlrpc.doc Deploy configuration across the servers.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #array_single("int", "Revision ID")
     * @xmlrpc.param #array_single("int", "Server ID")
     * @xmlrpc.returntype #return_int_success()
     */
    @SuppressWarnings("unchecked")
    public Integer addConfigurationDeployment(String sessionKey,
                                              String chainLabel,
                                              Integer serverId,
                                              List<Integer> revisions) {
        if (revisions.isEmpty()) {
            throw new InvalidParameterException("At least one revision should be given.");
        }

        List<Long> server = new ArrayList<Long>();
        server.add(serverId.longValue());

        ActionChainManager.createConfigActions(BaseHandler.getLoggedInUser(sessionKey),
                CollectionUtils.collect(revisions,
                        new ActionChainRPCCommon.IntegerToLongTransformer()), server,
                ActionFactory.TYPE_CONFIGFILES_DEPLOY,
                new Date(), this.acUtil.getActionChainByLabel(chainLabel));

        return BaseHandler.VALID;
    }

    /**
     * Rename Action Chain.
     *
     * @param sk Session key (token)
     * @param previousLabel Previous (existing) label of the Action Chain
     * @param newLabel New (desired) label of the Action Chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule system reboot.
     * @xmlrpc.param #param_desc("string", "sessionKey",
     * "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "previousLabel",
     * "Previous chain label")
     * @xmlrpc.param #param_desc("string", "newLabel", "New chain label")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer renameChain(String sk, String previousLabel, String newLabel) {
        BaseHandler.getLoggedInUser(sk);
        if (previousLabel.equals(newLabel)) {
            throw new InvalidParameterException("New label of the Action Chain should " +
                    "not be the same as previous!");
        }
        else if (previousLabel.isEmpty()) {
            throw new InvalidParameterException("Previous label cannot be empty.");
        }
        else if (newLabel.isEmpty()) {
            throw new InvalidParameterException("New label cannot be empty.");
        }

        this.acUtil.getActionChainByLabel(previousLabel).setLabel(newLabel);

        return BaseHandler.VALID;
    }
}
