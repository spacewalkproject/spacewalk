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
package com.redhat.rhn.manager.action;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.MissingCapabilityException;
import com.redhat.rhn.manager.MissingEntitlementException;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * An ActionManager companion to deal with Action Chains.
 *
 * Methods in this class are intended to replace similar methods in
 * ActionManager adding Action Chains support. It was decided to keep
 * this class separate to avoid adding significant complexity to ActionManager.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ActionChainManager {

    /**
     * Utility class constructor.
     */
    private ActionChainManager() {
    }

    /**
     * Schedules package installations.
     * @param user the user
     * @param server the server
     * @param packages the packages
     * @param earliest the earliest execution date
     * @param actionChain the action chain or null
     * @return the package action
     * @see com.redhat.rhn.manager.action.ActionManager#schedulePackageInstall
     */
    public static PackageAction schedulePackageInstall(User user, Server server,
        List<Map<String, Long>> packages, Date earliest, ActionChain actionChain) {

        if (!server.isSolaris()) {
            return (PackageAction) schedulePackageAction(user, packages,
                ActionFactory.TYPE_PACKAGES_UPDATE, earliest, actionChain, server);
        }
        return (PackageAction) schedulePackageAction(user, packages,
            ActionFactory.TYPE_SOLARISPKGS_INSTALL, earliest, actionChain, server);
    }


    /**
     * Schedules package removals.
     * @param user the user
     * @param server the server
     * @param packages the packages
     * @param earliest the earliest execution date
     * @param actionChain the action chain or null
     * @return the package action
     * @see com.redhat.rhn.manager.action.ActionManager#schedulePackageRemoval
     */
    public static PackageAction schedulePackageRemoval(User user, Server server,
        List<Map<String, Long>> packages, Date earliest, ActionChain actionChain) {
        if (!server.isSolaris()) {
            return (PackageAction) schedulePackageAction(user, packages,
                ActionFactory.TYPE_PACKAGES_REMOVE, earliest, actionChain, server);
        }
        return (PackageAction) schedulePackageAction(user, packages,
            ActionFactory.TYPE_SOLARISPKGS_REMOVE, earliest, actionChain, server);
    }

    /**
     * Schedules package upgrades.
     * @param user the user
     * @param server the server
     * @param packages the packages
     * @param earliest the earliest execution date
     * @param actionChain the action chain or null
     * @return the package action
     * @see com.redhat.rhn.manager.action.ActionManager#schedulePackageUpgrade
     */
    public static PackageAction schedulePackageUpgrade(User user, Server server,
        List<Map<String, Long>> packages, Date earliest, ActionChain actionChain) {
        return schedulePackageInstall(user, server, packages, earliest, actionChain);
    }

    /**
     * Schedules package verifications.
     * @param user the user
     * @param server the server
     * @param packages the packages
     * @param earliest the earliest execution date
     * @param actionChain the action chain or null
     * @return the package action
     * @see com.redhat.rhn.manager.action.ActionManager#schedulePackageVerify
     */
    public static PackageAction schedulePackageVerify(User user, Server server,
        List<Map<String, Long>> packages, Date earliest, ActionChain actionChain) {
        return (PackageAction) schedulePackageAction(user, packages,
            ActionFactory.TYPE_PACKAGES_VERIFY, earliest, actionChain, server);
    }


    /**
     * Schedules generic package actions on a single server.
     * @param scheduler the scheduler
     * @param packages the packages involved
     * @param type the type
     * @param earliest the earliest execution date
     * @param actionChain the action chain or null
     * @param server the server
     * @return the action
     * @see com.redhat.rhn.manager.action.ActionManager#schedulePackageAction
     */
    private static Action schedulePackageAction(User scheduler,
        List<Map<String, Long>> packages, ActionType type, Date earliest,
        ActionChain actionChain, Server server) {
        Set<Server> servers = new HashSet<Server>();
        servers.add(server);
        return schedulePackageAction(scheduler, packages, type, earliest, actionChain,
            servers).iterator().next();
    }

    /**
     * Schedules generic package actions on multiple servers.
     * @param scheduler the scheduler
     * @param packages the packages involved
     * @param type the type
     * @param earliest the earliest execution date
     * @param actionChain the action chain or null
     * @param servers the servers involved
     * @return a set of actions
     * @see com.redhat.rhn.manager.action.ActionManager#schedulePackageAction
     */
    private static Set<Action> schedulePackageAction(User scheduler,
        List<Map<String, Long>> packages, ActionType type, Date earliestAction,
        ActionChain actionChain, Set<Server> servers) {

        String name = ActionManager.getActionName(type);
        Set<Long> serverIds = new HashSet<Long>();
        for (Server server : servers) {
            serverIds.add(server.getId());
        }

        Set<Action> result = scheduleAction(scheduler, type, name, earliestAction,
            actionChain, serverIds);

        for (Action action : result) {
            ActionManager.addPackageActionDetails(action, packages);
        }

        return result;
    }

    /**
     * Schedules script actions for the given servers
     * @param scheduler User scheduling the action
     * @param sids Servers for which the action affects
     * @param script The set of packages to be removed
     * @param name Name of Script action
     * @param earliest Earliest occurrence of the script
     * @param actionChain the action chain or null
     * @return Scheduled ScriptRunAction(s)
     * @throws MissingCapabilityException if any server in the list is missing
     *             script.run schedule fails
     * @throws MissingEntitlementException if any server in the list is missing
     *             Provisioning schedule fails
     * @see com.redhat.rhn.manager.action.ActionManager#scheduleScriptRun
     */
    public static Set<Action> scheduleScriptRuns(User scheduler, List<Long> sids,
        String name, ScriptActionDetails script, Date earliest, ActionChain actionChain) {

        ActionManager.checkScriptingOnServers(sids);

        Set<Long> sidSet = new HashSet<Long>();
        sidSet.addAll(sids);

        Set<Action> result = scheduleAction(scheduler,
                ActionFactory.TYPE_SCRIPT_RUN, name, earliest, actionChain, sidSet);
        for (Action action : result) {
            ((ScriptRunAction)action).setScriptActionDetails(script);
            ActionFactory.save(action);
        }
        return result;
    }

    /**
     * Create a Config Action.
     * @param user The user scheduling the action.
     * @param revisions A set of revision ids as Longs
     * @param serverIds A set of server ids as Longs
     * @param type The type of config action
     * @param earliest The earliest time this action could execute.
     * @param actionChain the action chain or null
     * @return The created config action
     * @see com.redhat.rhn.manager.action.ActionManager#createConfigAction
     */
    public static Set<Action> createConfigActions(User user, Collection<Long> revisions,
        Collection<Long> serverIds, ActionType type, Date earliest,
        ActionChain actionChain) {

        List <Server> servers = SystemManager.hydrateServerFromIds(serverIds, user);
        return createConfigActionForServers(user, revisions, servers, type, earliest,
            actionChain);
    }

    /**
     * Create a Config Action.
     * @param user The user scheduling the action.
     * @param revisions A set of revision ids as Longs
     * @param servers A set of server objects
     * @param type The type of config action
     * @param earliest The earliest time this action could execute.
     * @param actionChain the action chain or null
     * @return The created config action
     * @see com.redhat.rhn.manager.action.ActionManager#createConfigActionForServers
     */
    public static Set<Action> createConfigActionForServers(User user,
        Collection<Long> revisions, Collection<Server> servers, ActionType type,
        Date earliest, ActionChain actionChain) {
        Set<Action> result = new HashSet<Action>();
        if (actionChain == null) {
            Action action = ActionManager.createConfigActionForServers(user, revisions,
                servers, type, earliest);
            if (action != null) {
                result.add(action);
            }
        }
        else {
            for (Server server : servers) {
                ConfigAction action = ActionManager
                    .createConfigAction(user, type, earliest);
                ActionManager.checkConfigActionOnServer(type, server);
                ActionChainFactory.queueActionChainEntry(action, actionChain, server);
                ActionManager.addConfigurationRevisionsToAction(user, revisions, action,
                    server);
                ActionFactory.save(action);
                result.add(action);
            }
        }
        return result;
    }

    /**
     * Schedule a RebootAction against a system
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param earliestAction Date run the Action
     * @param actionChain the action chain or null
     * @return a scheduled reboot action
     * @see com.redhat.rhn.manager.action.ActionManager#scheduleRebootAction
     */
    public static Action scheduleRebootAction(User scheduler, Server srvr,
        Date earliestAction, ActionChain actionChain) {
        Set<Long> serverIds = new HashSet<Long>();
        serverIds.add(srvr.getId());
        Set<Action> actions = scheduleAction(scheduler, ActionFactory.TYPE_REBOOT,
            ActionFactory.TYPE_REBOOT.getName(), earliestAction, actionChain, serverIds);
        return actions.iterator().next();
    }

    /**
     * Schedules generic actions on multiple servers.
     *
     * @param scheduler the scheduler
     * @param type the type
     * @param name the name
     * @param earliest the earliest execution date
     * @param actionChain the action chain or null
     * @param serverIds the server ids
     * @return a set of actions
     * @see com.redhat.rhn.manager.action.ActionManager#scheduleAction
     */
    private static Set<Action> scheduleAction(User scheduler, ActionType type, String name,
        Date earliest, ActionChain actionChain, Set<Long> serverIds) {
        Set<Action> result = new HashSet<Action>();

        if (actionChain == null) {
            Action action = ActionManager.createAction(scheduler, type, name,
                earliest);
            ActionManager.scheduleForExecution(action, serverIds);
            result.add(action);
        }
        else {
            for (Long serverId : serverIds) {
                Action action = ActionManager.createAction(scheduler, type, name,
                    earliest);
                ActionChainFactory.queueActionChainEntry(action, actionChain, serverId);
                result.add(action);
            }
        }

        return result;
    }
}
