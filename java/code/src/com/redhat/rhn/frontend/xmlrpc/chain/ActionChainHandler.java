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
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchActionException;
import com.redhat.rhn.frontend.xmlrpc.chain.ActionChainRPCCommon.Collector;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.text.SimpleDateFormat;
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
     * @return list of action chains.
     *
     * @xmlrpc.doc List currently available action chains.
     * @xmlrpc.returntype
     *    #array()
     *       #struct("chain")
     *          #prop_desc("string", "label", "Label of an Action Chain")
     *          #prop_desc("string", "entrycount", "Number of entries in the Action Chain")
     *       #struct_end()
     *    #array_end()
     */
    public List<Map<String, Object>> listChains() {
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
     * @param chainLabel The label of the Action Chain.
     * @return List of entries in the particular action chain, if any.
     *
     * @xmlrpc.doc List all actions in the particular Action Chain.
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype
     *    #array()
     *       #struct("entry")
     *          #prop_desc("int", "id", "Action ID")
     *          #prop_desc("string", "label", "Label of an Action")
     *          #prop_desc("string", "created", "Created date/time")
     *          #prop_desc("string", "earliest", "Earliest scheduled date/time")
     *          #prop_desc("string", "type", "Type of the action")
     *          #prop_desc("string", "modified", "Modified date/time")
     *          #prop_desc("string", "cuid", "Creator UID")
     *       #struct_end()
     *    #array_end()
     */
    public List<Map<String, Object>> chainActions(String chainLabel) {
        List<Map<String, Object>> entries = new ArrayList<Map<String, Object>>();
        if (StringUtil.nullOrValue(chainLabel) == null) {
            return entries;
        }

        ActionChain chain = ActionChainFactory.getActionChain(chainLabel);
        if (chain != null && chain.getEntries() != null && !chain.getEntries().isEmpty()) {
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
     * Remove actions from an Action Chain.
     *
     * @param sk Session key.
     * @param chainLabel The label of the Action Chain.
     * @param actionIds List of action IDs.
     * @return State of the action result. Negative is false.
     *         Positive: number of successfully deleted entries.
     *
     * @xmlrpc.doc Remove actions from an Action Chain.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #array_single("string", "actionId")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer removeActions(String sk,
                                 String chainLabel,
                                 List<Integer> actionIds) {
        ActionChainHandler.getLoggedInUser(sk);
        if (StringUtil.nullOrValue(chainLabel) == null) {
            throw new InvalidParameterException("Action Chain label is empty.");
        }
        else if (actionIds.isEmpty()) {
            throw new InvalidParameterException("Session key is empty.");
        }

        ActionChain chain = ActionChainFactory.getActionChain(chainLabel);
        if (chain == null) {
            throw new NoSuchActionException(
                    String.format("Action Chain '%s' was not found.", chainLabel));
        }
        else if (chain.getEntries().isEmpty()) {
            throw new NoSuchActionException(
                    String.format("Action Chain '%s' has no scheduled entries.",
                                  chainLabel));
        }

        List<ActionChainEntry> entriesToDelete = new ArrayList<ActionChainEntry>();
        for (ActionChainEntry entry : chain.getEntries()) {
            for (Integer actionId : actionIds) {
                if (entry.getAction().getId().equals(Long.valueOf(actionId))) {
                    entriesToDelete.add(entry);
                }
            }
        }

        if (entriesToDelete.isEmpty()) {
            throw new NoSuchActionException(
                    String.format("Action Chain '%s' has no such " +
                                  "requested scheduled entries.", chainLabel));
        }

        for (ActionChainEntry entry : entriesToDelete) {
            chain.getEntries().remove(entry);
        }

        return BaseHandler.VALID;
    }

    /**
     * Remove Action Chains by label.
     *
     * @param sk Session key.
     * @param chainLabels List of action labels.
     * @return State of the action result. Negative is false.
     *         Positive: number of successfully deleted entries.
     *
     * @xmlrpc.doc Remove action chains by label.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #array_single("string", "chainLabels")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer removeChains(String sk,
                                List<String> chainLabels) {
        ActionChainHandler.getLoggedInUser(sk);
        if (chainLabels.isEmpty()) {
            throw new InvalidParameterException("No chain labels has been passed!");
        }

        for (String chainName : chainLabels) {
            ActionChain chain = ActionChainFactory.getActionChain(chainName);
            if (chain != null) {
                ActionChainFactory.delete(chain);
            }
            else {
                throw new NoSuchActionException(
                        String.format("Action Chain '%s' was not found.", chainName));
            }
        }

        return BaseHandler.VALID;
    }

    /**
     * Create an Action Chain.
     *
     * @param sk Session key (token)
     * @param chainLabel Label of the action chain
     * @return 1 on success
     *
     * @xmlrpc.doc Create an Action Chain.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action
     */
    public Integer createActionChain(String sk,
                                     String chainLabel) {
        if (StringUtil.nullOrValue(sk) == null) {
            throw new InvalidParameterException("Session key is empty.");
        }
        else if (StringUtil.nullOrValue(chainLabel) == null) {
            throw new InvalidParameterException("Action Chain label is empty.");
        }

        return ActionChainFactory.createActionChain(chainLabel,
                                                    ActionChainHandler.getLoggedInUser(sk))
                .getId().intValue();
    }

    /**
     * Schedule system reboot.
     *
     * @param sk Session key (token)
     * @param serverId Server ID.
     * @param chainLabel Label of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule system reboot.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action
     */
    public Integer addSystemReboot(String sk,
                                   Integer serverId,
                                   String chainLabel) {
        Collector c = new Collector(sk, serverId, chainLabel);
        return ActionChainManager.scheduleRebootAction(
                c.getUser(), c.getServer(),
                new Date(), c.getChain()).getId().intValue();
    }

    /**
     * Adds an action to remove installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainLabel Label of the action chain
     * @return list of action ids, exception thrown otherwise
     *
     * @xmlrpc.doc Adds an action to remove installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param
     *    #array()
     *       #struct("packages")
     *          #prop_desc("string", "label", "Package label")
     *          #prop_desc("string", "version", "Package version")
     *       #struct_end()
     *    #array_end()
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action
     */
    public Integer addPackageRemoval(String sk,
                                     Integer serverId,
                                     List<Map<String, String>> packages,
                                     String chainLabel) {
        Collector c = new Collector(sk, serverId, chainLabel);
        List<Map<String, Long>> selectedPackages = this.acUtil.selectPackages(
                SystemManager.installedPackages(c.getServer().getId(), true), packages, c);
        if (!selectedPackages.isEmpty()) {
            return ActionChainManager.schedulePackageRemoval(
                    c.getUser(), c.getServer(), selectedPackages,
                    new Date(), c.getChain()).getId().intValue();
        }

        throw new InvalidPackageException(
                String.format("No such packages has been found on the system %s.",
                              serverId)
        );
    }

    /**
     * Schedule package installation to an Action Chain.
     *
     * @param sk Session key (token)
     * @param serverId System ID.
     * @param packages List of packages.
     * @param chainLabel Label of the Action Chain.
     * @return True or false in XML-RPC representation: 1 or 0 respectively.
     *
     * @xmlrpc.doc Schedule package installation to an Action Chain.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #array_single("int", "Package ID")
     * @xmlrpc.param #param("string", "chainLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer addPackageInstall(String sk,
                                     Integer serverId,
                                     List<Integer> packages,
                                     String chainLabel) {
        Collector c = new Collector(sk, serverId, chainLabel);
        List<Map<String, Long>> selectedPackages = this.acUtil.resolvePackages(
                packages, c.getUser());
        if (!selectedPackages.isEmpty()) {
            return ActionChainManager.schedulePackageInstall(
                    c.getUser(), c.getServer(), selectedPackages,
                    new Date(), c.getChain()).getId().intValue();
        }

        throw new InvalidPackageException("Packages were not found");
    }

    /**
     * Adds an action to verify installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainLabel Label of the action chain
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer addPackageVerify(String sk,
                                    Integer serverId,
                                    List<Integer> packages,
                                    String chainLabel) {
        Collector c = new Collector(sk, serverId, chainLabel);
        List<Map<String, Long>> selectedPackages = this.acUtil.selectPackages(
                PackageManager.systemPackageList(c.getServer().getId(), null), packages);
        if (!selectedPackages.isEmpty()) {
            return ActionChainManager.schedulePackageVerify(
                    c.getUser(), c.getServer(), selectedPackages,
                    new Date(), c.getChain()).getId().intValue();
        }

        throw new InvalidPackageException("Packages were not found.");
    }

    /**
     * Adds an action to upgrade installed packages on the system.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param packages List of packages
     * @param chainLabel Label of the action chain
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Adds an action to upgrade installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype #int
     */
    public int addPackageUpgrade(String sk,
                                 Integer serverId,
                                 List<Integer> packages,
                                 String chainLabel) {
        Collector c = new Collector(sk, serverId, chainLabel);
        List<Map<String, Long>> selectedPackages = this.acUtil.resolvePackages(
                packages, c.getUser());
        if (!selectedPackages.isEmpty()) {
            return ActionChainManager.schedulePackageUpgrade(
                    c.getUser(), c.getServer(), selectedPackages,
                    new Date(), c.getChain()).getId().intValue();
        }

        throw new InvalidPackageException("Packages were not found.");
    }

    /**
     * Add a remote command as a script.
     *
     * @param sk Session key (token)
     * @param serverId System ID
     * @param chainLabel Label of the action chain.
     * @param uid User ID on the remote system.
     * @param scriptBody Base64 encoded script.
     * @param gid Group ID on the remote system.
     * @param timeout Timeout
     * @return True or false in XML-RPC representation (1 or 0 respectively)
     *
     * @xmlrpc.doc Add a remote command as a script.
     *             NOTE: The script body must be Base64 encoded!
     *
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("int", "serverId", "System ID")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #param_desc("string", "uid", "User ID on the particular system")
     * @xmlrpc.param #param_desc("string", "gid", "Group ID on the particular system")
     * @xmlrpc.param #param_desc("int", "timeout", "Timeout cannot exceed 1200 seconds")
     * @xmlrpc.param #param_desc("string", "scriptBodyBase64", "Base64 encoded script body")
     * @xmlrpc.returntype int actionId - The id of the action or throw an exception
     */
    public Integer addRemoteCommand(String sk,
                                    Integer serverId,
                                    String chainLabel,
                                    String uid,
                                    String gid,
                                    Integer timeout,
                                    String scriptBody) {
        if (StringUtil.nullOrValue(scriptBody) == null) {
            throw new InvalidParameterException("Script body is empty.");
        }

        Collector c = new Collector(sk, serverId, chainLabel);

        List<Long> systems = new ArrayList<Long>();
        systems.add((long) serverId);

        ScriptActionDetails script = ActionManager.createScript(uid, gid, (long) timeout,
            new String(DatatypeConverter.parseBase64Binary(scriptBody)));

        Date date = new Date();

        return ActionChainManager.scheduleScriptRuns(
                             c.getUser(), systems,
                             String.format("Remote Script at %s",
                                           SimpleDateFormat.getDateInstance(
                                                   SimpleDateFormat.MEDIUM).format(date)),
                             script, date, c.getChain())
                .iterator().next().getId().intValue();
    }

    /**
     * Schedule action chain immediately.
     *
     * @param sk Session key (token)
     * @param chainLabel Label of the action chain
     * @return True in XML-RPC representation
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer scheduleNow(String sk,
                               String chainLabel) {
        return this.schedule(sk, chainLabel, new Date());
    }

    /**
     * Schedule action chain immediately.
     *
     * @param sk Session key (token)
     * @param chainLabel Label of the action chain
     * @param date Earliest date
     * @return True in XML-RPC representation
     *
     * @xmlrpc.doc Adds an action to verify installed packages on the system.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #param("dateTime.iso8601", "Earliest date")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer schedule(String sk,
                            String chainLabel,
                            Date date) {
        ActionChainHandler.getLoggedInUser(sk);
        if (StringUtil.nullOrValue(chainLabel) == null) {
            throw new InvalidParameterException("Action Chain label is empty.");
        }

        ActionChain chain = ActionChainFactory.getActionChain(chainLabel);
        if (chain == null) {
            throw new NoSuchActionException(
                    String.format("Action Chain '%s' was not found.", chainLabel));
        }

        ActionChainFactory.schedule(chain, date);

        return BaseHandler.VALID;
    }

    /**
     * Deploy configuration.
     *
     * @param sk Session key (token)
     * @param chainLabel Label of the action chain
     * @param serverId System ID
     * @param revisions List of configuration revisions.
     * @return True in XML-RPC representation
     *
     * @xmlrpc.doc Deploy configuration across the servers.
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "chainLabel", "Label of the chain")
     * @xmlrpc.param #array_single("int", "Revision ID")
     * @xmlrpc.param #array_single("int", "Server ID")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer deployConfiguration(String sk,
                                       String chainLabel,
                                       Integer serverId,
                                       List<Integer> revisions) {
        if (StringUtil.nullOrValue(chainLabel) == null) {
            throw new InvalidParameterException("Action Chain label is empty.");
        }
        else if (revisions.isEmpty()) {
            throw new InvalidParameterException("At least one revision should be given.");
        }

        ActionChain chain = ActionChainFactory.getActionChain(chainLabel);
        if (chain == null) {
            throw new NoSuchActionException(
                    String.format("Action Chain '%s' was not found.", chainLabel));
        }

        List<Long> server = new ArrayList<Long>();
        server.add(serverId.longValue());

        ActionChainManager.createConfigActions(
               ActionChainHandler.getLoggedInUser(sk),
               CollectionUtils.collect(revisions,
                                       new ActionChainRPCCommon.IntegerToLongTransformer()),
               server, ActionFactory.TYPE_CONFIGFILES_DEPLOY, new Date(), chain);

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
     * @xmlrpc.param #param_desc("string", "sessionKey", "Session token, issued at login")
     * @xmlrpc.param #param_desc("string", "previousLabel", "Previous chain label")
     * @xmlrpc.param #param_desc("string", "newLabel", "New chain label")
     * @xmlrpc.returntype #return_int_success()
     */
    public Integer renameChain(String sk,
                               String previousLabel,
                               String newLabel) {
        ActionChainHandler.getLoggedInUser(sk);
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

        ActionChain chain = ActionChainFactory.getActionChain(previousLabel);
        chain.setLabel(newLabel);

        return BaseHandler.VALID;
    }
}
