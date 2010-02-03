/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.config.ConfigUploadAction;
import com.redhat.rhn.domain.action.errata.ErrataAction;
import com.redhat.rhn.domain.action.kickstart.KickstartAction;
import com.redhat.rhn.domain.action.kickstart.KickstartActionDetails;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestAction;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestActionDetails;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.solaris.SolarisPackagePatchClusterInstallAction;
import com.redhat.rhn.domain.action.solaris.SolarisPackagePatchInstallAction;
import com.redhat.rhn.domain.action.solaris.SolarisPackagePatchRemoveAction;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.impl.PublishedErrata;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageDelta;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PatchSet;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageMetadata;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.MissingCapabilityException;
import com.redhat.rhn.manager.MissingEntitlementException;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.kickstart.ProvisionVirtualInstanceCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerVirtualSystemCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import org.cobbler.Profile;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ActionManager - the singleton class used to provide Business Operations
 * on Actions where those operations interact with other top tier Business
 * Objects.
 * 
 * Operations that require the Action make changes to 
 * @version $Rev$ 
 */
public class ActionManager extends BaseManager {
    private static Logger log = Logger.getLogger(ActionManager.class);
    
    // List of package names that we want to make sure we dont 
    // remove when doing a package sync.  Never remove running kernel
    // for instance.
    public static final String[] PACKAGES_NOT_REMOVABLE = {"kernel"};

    /**
     * This was extracted to a constant from the
     * {@link #scheduleAction(User, Server, ActionType, String, Date)} method. At the time
     * it was in there, there was a comment "hmm 10?". Not sure what the hesitation is
     * but I wanted to retain that comment with regard to this value. 
     */
    private static final Long REMAINING_TRIES = 10L;
    
    private ActionManager() {
    }
    
    /**
     * Removes a list of actions.
     * @param actionIds actions to remove
     * @return int the number of failed action removals
     */
    public static int removeActions(List actionIds) {
        int failed = 0;
        for (Iterator ids = actionIds.iterator(); ids.hasNext();) {
            Long actionId = (Long) ids.next();
            failed += ActionFactory.removeAction(actionId);
        }
        return failed;
    }

    /**
     * Retreive the specified Action, assuming that the User making the request
     * has the required permissions.
     * @param user The user making the lookup request.
     * @param aid The id of the Action to lookup.
     * @return the specified Action.
     * @throws com.redhat.rhn.common.hibernate.LookupException if the Action
     * can't be looked up.
     */
    public static Action lookupAction(User user, Long aid) {
        Action returnedAction = null;
        if (aid == null) {
            return null;
        }

        returnedAction = ActionFactory.lookupByUserAndId(user, aid);
        
        //TODO: put this in the hibernate lookup query
        SelectMode m = ModeFactory.getMode("Action_queries", "visible_to_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("aid", aid);
        if (m.execute(params).size() < 1) {
            returnedAction = null;
        }
        
        if (returnedAction == null) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e =
                new LookupException("Could not find action with id: " + aid);
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.action"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.action"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.action"));
            throw e;
        }
        
        return returnedAction;
    }

    
    
    /**
     * Lookup the last completed Action on a Server
     *  given the user, action type and server.
     * This is useful especially in cases where we want to 
     * find the last deployed config action ...
     *  
     * @param user the user doing the search (needed for permssion checking)
     * @param type the action type of the action to be queried.
     * @param server the server who's latest completed action is desired.
     * @return the Action found or null if none exists
     */
    public static Action lookupLastCompletedAction(User user, 
                                            ActionType type,
                                            Server server) {
        // TODO: check on user visibility ??
        
        return ActionFactory.lookupLastCompletedAction(user, type, server);
    }
    
    
    
    /**
     * Archives the action set with the given label.
     * @param user User associated with the set of actions.
     * @param label Action label to be updated.
     */
    public static void archiveActions(User user, String label) {
        WriteMode m = ModeFactory.getWriteMode("Action_queries", 
                                               "archive_actions"); 
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("label", label);
        m.executeUpdate(params);
    }
    
    /**
     * Cancels all actions in given list.
     * @param user User associated with the set of actions.
     * @param actionsToCancel List of actions to be cancelled.
     */
    public static void cancelActions(User user, List actionsToCancel) {
        java.util.Iterator it = actionsToCancel.iterator();
        while (it.hasNext()) {
            Action a = (Action)it.next();
            cancelAction(user, a);
        }
    }
    
    /**
     * Cancels the server actions associated with a given action, and if
     * required deals with assicuated pending kickstart actions.
     * 
     * Actions themselves are not deleted, only the ServerActions associated
     * with them.
     *  
     * @param user User requesting the action be cancelled.
     * @param action Action to be cancelled.
     */
    public static void cancelAction(User user, Action action) {
        log.debug("Cancelling action: " + action.getId() + " for user: " + user.getLogin());
        
        // Can only top level actions:
        if (action.getPrerequisite() != null) {
            throw new ActionIsChildException();
        }
        
        Set actionsToDelete = new HashSet();
        actionsToDelete.add(action);
        actionsToDelete.addAll(ActionFactory.lookupDependentActions(action));
        
        // Delete the server actions associated with the actions queried:
        StringBuffer actionsToDeleteBuffer = new StringBuffer(
                "Actions to be cancelled (including children):");
        Iterator iter = actionsToDelete.iterator();
        while (iter.hasNext()) {
            Action a = (Action)iter.next();
            actionsToDeleteBuffer.append(" " + a.getId());
        }

        Set servers = new HashSet();
        Iterator serverActionsIter = action.getServerActions().iterator();
        while (serverActionsIter.hasNext()) {
            ServerAction sa = (ServerAction)serverActionsIter.next();
            servers.add(sa.getServer());
        }
        KickstartFactory.failKickstartSessions(actionsToDelete, servers);

        ActionFactory.deleteServerActionsByParent(actionsToDelete);
    }

    /**
     * Adds a server to an action
     * @param sid The server id
     * @param action The parent action
     */
    public static void addServerToAction(Long sid, Action action) {
        ActionFactory.addServerToAction(sid, action);
    }
    
    /**
     * Creates an errata action with the specified Org
     * @return The created action
     * @param org The org that needs the errata.
     * @param errata The errata pertaining to this action
     */
    public static ErrataAction createErrataAction(Org org, Errata errata) {
        ErrataAction a = (ErrataAction) createErrataAction((User) null, errata);
        a.setOrg(org);
        return a;
    }

    /**
     * Creates an errata action 
     * @return The created action
     * @param user The user scheduling errata
     * @param errata The errata pertaining to this action
     */
    public static Action createErrataAction(User user, Errata errata) {
        ErrataAction a = (ErrataAction)ActionFactory
                             .createAction(ActionFactory.TYPE_ERRATA);
        if (user != null) {
            a.setSchedulerUser(user);
            a.setOrg(user.getOrg());
        }
        a.addErrata(errata);
        
        Object[] args = new Object[2];
        args[0] = errata.getAdvisory();
        args[1] = errata.getSynopsis();
        a.setName(LocalizationService.getInstance().getMessage("action.name", args));
        return a;
    }
    
    /**
     * Create a Config Upload action. This is a much different action from the
     * other config actions (doesn't involve revisions).
     * @param user The scheduler for this config action.
     * @param filenames A set of config file name ids as Longs
     * @param server The server for which to schedule this action.
     * @param channel The config channel to which files will be uploaded.
     * @param earliest The soonest time that this action could be executed.
     * @return The created upload action
     */
    public static Action createConfigUploadAction(User user, Set filenames,
            Server server, ConfigChannel channel, Date earliest) {
        //TODO: right now, our general rule is that upload actions will
        //always upload into the sandbox for a system. If we ever wish to
        //make that a strict business rule, here is where we can verify that
        //the given channel is the sandbox for the given server.
        
        ConfigUploadAction a = 
            (ConfigUploadAction)ActionFactory.createAction(
                    ActionFactory.TYPE_CONFIGFILES_UPLOAD, earliest);
        a.setOrg(user.getOrg());
        a.setSchedulerUser(user);
        a.setName(a.getActionType().getName());
        //put a single row into rhnActionConfigChannel
        a.addConfigChannelAndServer(channel, server);
        //put a single row into rhnServerAction
        addServerToAction(server.getId(), a);
        
        //now put a row into rhnActionConfigFileName for each path we have.
        Iterator i = filenames.iterator();
        while (i.hasNext()) {
            Long cfnid = (Long)i.next();
            /*
             * We are using ConfigurationFactory to lookup the config file name
             * instead of ConfigurationManager.  If we used ConfigurationManager,
             * then we couldn't have new file names because the user wouldn't
             * have access to them yet.
             */
            ConfigFileName name = ConfigurationFactory.lookupConfigFileNameById(cfnid);
            if (name != null) {
                a.addConfigFileName(name, server);
            }
        }
        
        //if this is a pointless action, don't do it.
        if (a.getRhnActionConfigFileName().size() < 1) {
            return null;
        }
        
        ActionFactory.save(a);
        return a;
    }
    
    /**
     * Create a Config File Diff action.
     * @param user The user scheduling a diff action.
     * @param revisions A set of revision ids as Longs
     * @param serverIds A set of server ids as Longs
     * @return The created diff action
     */
    public static Action createConfigDiffAction(User user, 
                                                Collection<Long> revisions, 
                                                Collection<Long> serverIds) {
        //diff actions are non-destructive, so there is no point to schedule them for any
        //later than now.
        return createConfigAction(user, revisions, serverIds,
                ActionFactory.TYPE_CONFIGFILES_DIFF, new Date());
    }
    
    /**
     * Create a Config Action.
     * @param user The user scheduling the action.
     * @param revisions A set of revision ids as Longs
     * @param servers A set of server objects 
     * @param type The type of config action
     * @param earliest The earliest time this action could execute.
     * @return The created config action
     */
    public static Action createConfigActionForServers(User user, 
                                                Collection<Long> revisions,
                                                Collection<Server> servers,
                                                ActionType type, Date earliest) {
        //create the action
        ConfigAction a = (ConfigAction)ActionFactory.createAction(type, earliest);
        
        /** This is not localized, because the perl that prints this when the action is 
         *  rescheduled doesn't do localization.  If the reschedule page ever get 
         *  converted to java, we should pass in a LS key and then simply do the lookup
         *  on display
         */
        a.setName(a.getActionType().getName());        
        a.setOrg(user.getOrg());
        a.setSchedulerUser(user);
        for (Server server : servers) {
            if (ActionFactory.TYPE_CONFIGFILES_DEPLOY.equals(type) &&
                       !SystemManager.clientCapable(server.getId(),
                                    SystemManager.CAP_CONFIGFILES_DEPLOY)) {
                throw new MissingCapabilityException(
                        SystemManager.CAP_CONFIGFILES_DEPLOY, server);
            }
            ActionFactory.addServerToAction(server.getId(), a);
        
            //now that we made a server action, we must make config revision actions
            //which depend on the server as well.
            for (Long revId : revisions) {
                try {
                    ConfigRevision rev = ConfigurationManager.getInstance()
                        .lookupConfigRevision(user, revId);
                    ActionFactory.addConfigRevisionToAction(rev, server, a);
                }
                catch (LookupException e) {
                    log.error("Failed lookup for revision " + revId + 
                            "by user " + user.getId());
                } //catch                
            }
        }
        if (a.getServerActions().size() < 1) {
            return null;
        }
        ActionFactory.save(a);
        return a;
    }    
    
    
    
    /**
     * Create a Config Action.
     * @param user The user scheduling the action.
     * @param revisions A set of revision ids as Longs
     * @param serverIds A set of server ids as Longs
     * @param type The type of config action
     * @param earliest The earliest time this action could execute.
     * @return The created config action
     */
    public static Action createConfigAction(User user, Collection<Long> revisions,
            Collection<Long> serverIds, ActionType type, Date earliest) {
        List <Server> servers = SystemManager.hydrateServerFromIds(serverIds, user);
        return createConfigActionForServers(user, revisions, servers, type, earliest);
    }
    
    /**
     * 
     * @param user The user scheduling the patch removal
     * @param server The server patch removal applies to
     * @param set The set of patches to remove
     * @return Patch removal Action to perform
     */
    public static Action createPatchRemoveAction(User user, Server server, RhnSet set) {
        // throw error if pkgs are empty?
      
        ServerAction sa = new ServerAction();
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        sa.setRemainingTries(new Long(5)); 
        sa.setServer(server);

        SolarisPackagePatchRemoveAction patchAction = 
            (SolarisPackagePatchRemoveAction) ActionFactory.createAction(
                ActionFactory.TYPE_SOLARISPKGS_PATCHREMOVE);
        patchAction.setOrg(user.getOrg());
        patchAction.setName("Patch Removal");
        patchAction.setSchedulerUser(user);
        patchAction.addServerAction(sa);
        sa.setParentAction(patchAction);
        ActionFactory.save(patchAction);

        // for each item in the set create a package action detail
        WriteMode m = ModeFactory.getWriteMode("Action_queries", "schedule_action_no_arch");
        for (Iterator itr = set.getElements().iterator(); itr.hasNext();) {
            RhnSetElement rse = (RhnSetElement) itr.next();
            Map params = new HashMap();
            params.put("action_id", patchAction.getId());
            params.put("name_id", rse.getElement());
            params.put("evr_id", rse.getElementTwo());
            m.executeUpdate(params);
        }       
        
        return patchAction;
    }
    
    /**
     * 
     * @param user The user scheduling the patch removal
     * @param server The server patch removal applies to
     * @param set The set of patches to remove
     * @return Patch intsall Action to perform
     * 
     * TODO factor patch actions into one method
     */
    public static Action createPatchInstallAction(User user, Server server, RhnSet set) {
        // throw error if pkgs are empty?
      
        ServerAction sa = new ServerAction();
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        sa.setRemainingTries(new Long(5)); 
        sa.setServer(server);

        SolarisPackagePatchInstallAction patchAction = 
            (SolarisPackagePatchInstallAction) ActionFactory.createAction(
                ActionFactory.TYPE_SOLARISPKGS_PATCHINSTALL);
        patchAction.setOrg(user.getOrg());
        patchAction.setName("Patch Install");
        patchAction.setSchedulerUser(user);
        patchAction.addServerAction(sa);
        sa.setParentAction(patchAction);
        ActionFactory.save(patchAction);

        // for each item in the set create a package action detail
        for (Iterator itr = set.getElements().iterator(); itr.hasNext();) {
            RhnSetElement rse = (RhnSetElement) itr.next();
            WriteMode m = ModeFactory.getWriteMode("Action_queries",
                "schedule_action_no_arch");
            Map params = new HashMap();
            params.put("action_id", patchAction.getId());
            params.put("name_id", rse.getElement());
            params.put("evr_id", rse.getElementTwo());
            m.executeUpdate(params);    
        }       
        
        return patchAction;
    }

    /**
     * 
     * @param user The user scheduling the patch cluster install
     * @param server The server patch cluster install applies to
     * @param patchSet The patch cluster to install
     * @return Patch Cluster install Action to perform
     * 
     */
    public static Action createPatchSetInstallAction(User user,
                                                     Server server,
                                                     PatchSet patchSet) {

        SolarisPackagePatchClusterInstallAction patchSetAction
            = (SolarisPackagePatchClusterInstallAction)
              createBaseAction(user,
                               server,
                               ActionFactory.TYPE_SOLARISPKGS_PATCHCLUSTERINSTALL);

        patchSetAction.setName("Patch Cluster Install");

        ActionFactory.save(patchSetAction);

        WriteMode m = ModeFactory.getWriteMode("Action_queries", "schedule_action_no_arch");
        Map params = new HashMap();
        params.put("action_id", patchSetAction.getId());
        params.put("name_id", patchSet.getPackageName().getId());
        params.put("evr_id", patchSet.getPackageEvr().getId());
        m.executeUpdate(params);
        
        return patchSetAction;
    }

    /**
     *
     * @param user   The user scheduling the action
     * @param server The server the action is being scheduled for
     * @param type   The type of the action
     *
     * @return The Action we have created
     *
     */
     public static Action createBaseAction(User user, Server server, ActionType type) {

        Action action = 
            ActionFactory.createAction(type);

        action.setSchedulerUser(user);
        action.setOrg(user.getOrg());

        ServerAction sa = new ServerAction();
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        sa.setRemainingTries(new Long(5)); 
        sa.setServer(server);

        sa.setParentAction(action);
        action.addServerAction(sa);

        return action;
     }
    
    /**
     * Stores the action in the database through hibernate
     * @param actionIn The action to be stored
     */
    public static void storeAction(Action actionIn) {
        ActionFactory.save(actionIn);
    }

    /**
     * Reschedule the action so it can be attempted again.
     *
     * @param action Action to reschedule
     */
    public static void rescheduleAction(Action action) {
        rescheduleAction(action, false);
    }

    /**
     * Reschedule the action so it can be attempted again.
     *
     * @param action Action to reschedule
     * @param onlyFailed reschedule only the ServerActions w/failed status
     */    
    public static void rescheduleAction(Action action, boolean onlyFailed) {
        //5 was hardcoded from perl :/
        if (onlyFailed) {
            ActionFactory.rescheduleFailedServerActions(action, 5L);
        }
        else {
            ActionFactory.rescheduleAllServerActions(action, 5L);
        }
    }    

    /**
     * Retrieve the list of unarchived scheduled actions for the
     * current user
     * @param user The user in question
     * @param pc The details of which results to return
     * @param age how many days old a system can be in order to count as a "recently"
     * scheduled action
     * @return A list containing the pending actions for the user
     */
    public static DataResult recentlyScheduledActions(User user, PageControl pc, 
                                                        long age) {
        SelectMode m = ModeFactory.getMode("Action_queries", 
                                           "recently_scheduled_action_list");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("age", new Long(age));
        
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Retrieve the list of all actions for a particular user.
     * This includes pending, completed, failed and archived actions.
     * @param user The user in question
     * @param pc The details of which results to return
     * @return A list containing the all actions for the user
     */
    public static DataResult allActions(User user, PageControl pc) {
        return getActions(user, pc, "all_action_list");
    }
    
    /**
     * Retrieve the list of pending actions for a particular user
     * @param user The user in question
     * @param pc The details of which results to return
     * @return A list containing the pending actions for the user
     */
    public static DataResult pendingActions(User user, PageControl pc) {
        return getActions(user, pc, "pending_action_list");
    }
    
    /**
     * Retrieve the list of pending actions for a particular user within the given set.
     * 
     * @param user The user in question
     * @param pc The details of which results to return
     * @param setLabel Label of an RhnSet of actions IDs to limit the results to.
     * @return A list containing the pending actions for the user.
     */
    public static DataResult pendingActionsInSet(User user, PageControl pc, 
            String setLabel) {
        
        return getActions(user, pc, "pending_actions_in_set", setLabel);
    }
    
    /**
     * Retrieve the list of failed actions for a particular user
     * @param user The user in question
     * @param pc The details of which results to return
     * @return A list containing the pending actions for the user
     */
    public static DataResult failedActions(User user, PageControl pc) {
        return getActions(user, pc, "failed_action_list");
    }
    
    /**
     * Retrieve the list of completed actions for a particular user
     * @param user The user in question
     * @param pc The details of which results to return
     * @return A list containing the pending actions for the user
     */
    public static DataResult completedActions(User user, PageControl pc) {
        return getActions(user, pc, "completed_action_list");
    }
    
    /**
     * Retrieve the list of completed actions for a particular user
     * @param user The user in question
     * @param pc The details of which results to return
     * @return A list containing the pending actions for the user
     */
    public static DataResult archivedActions(User user, PageControl pc) {
        return getActions(user, pc, "archived_action_list");
    }
    
     /**
     * Helper method that does the work of getting a specific 
     * DataResult for scheduled actions.
     * @param user The user in question
     * @param pc The details of which results to return
     * @param mode The mode
     * @return Returns a list containing the actions for the user
     */
    private static DataResult getActions(User user, PageControl pc, String mode, 
            String setLabel) {
        SelectMode m = ModeFactory.getMode("Action_queries", mode);
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        if (setLabel != null) {
            params.put("set_label", setLabel);
        }
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        dr.setElaborationParams(params);
        return dr;
    }
    
    /**
     * Helper method that does the work of getting a specific 
     * DataResult for scheduled actions.
     * @param user The user in question
     * @param pc The details of which results to return
     * @param mode The mode
     * @return Returns a list containing the actions for the user
     */
    private static DataResult getActions(User user, PageControl pc, String mode) {
        return getActions(user, pc, mode, null);
    }
    
    /**
     * Returns the list of packages associated with a specific action.
     * @param aid The action id for the action in question
     * @param pc The details of which results to return
     * @return Return a list containing the packages for the action.
     */
    public static DataResult getPackageList(Long aid, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Package_queries", 
                           "packages_associated_with_action");
        Map params = new HashMap();
        params.put("aid", aid);
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns the list of errata associated with a specific action.
     * @param aid The action id for the action in question
     * @return Return a list containing the errata for the action.
     */
    public static DataResult getErrataList(Long aid) {
        SelectMode m = ModeFactory.getMode("Errata_queries",
                           "errata_associated_with_action");

        Map params = new HashMap();
        params.put("aid", aid);

        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns the list of details associated with a config file upload action.
     * @param aid The action id for the action in question
     * @return Return a list containing the errata for the action.
     */
    public static DataResult getConfigFileUploadList(Long aid) {
        SelectMode m = ModeFactory.getMode("config_queries", "upload_action_status");

        Map params = new HashMap();
        params.put("aid", aid);

        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns the list of details associated with a config file deploy action.
     * @param aid The action id for the action in question
     * @return Return a list containing the details for the action.
     */
    public static DataResult getConfigFileDeployList(Long aid) {
        SelectMode m = ModeFactory.getMode("config_queries", "config_action_revisions");

        Map params = new HashMap();
        params.put("aid", aid);

        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns the list of details associated with a config file diff action.
     * @param aid The action id for the action in question
     * @return Return a list containing the details for the action.
     */
    public static DataResult getConfigFileDiffList(Long aid) {
        SelectMode m = ModeFactory.getMode("config_queries", "diff_action_revisions");

        Map params = new HashMap();
        params.put("aid", aid);

        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }
    
    /**
     * Retrieves the systems that have completed a given action
     * @param user The user in question.
     * @param action The Action.
     * @param pc The PageControl.
     * @param mode The DataSource mode to run
     * @return Returns list containing the completed systems.
     */
    private static DataResult getActionSystems(User user, 
                                              Action action, 
                                              PageControl pc,
                                              String mode) {
        
        SelectMode m = ModeFactory.getMode("System_queries", mode);
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("aid", action.getId());
        params.put("user_id", user.getId());
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }
    
    /**
     * Retrieves the systems that have completed a given action
     * @param user The user in question.
     * @param action The Action.
     * @param pc The PageControl.
     * @return Returns list containing the completed systems.
     */
    public static DataResult completedSystems(User user, 
                                              Action action, 
                                              PageControl pc) {
        
        return getActionSystems(user, action, pc, "systems_completed_action");
    }
    
    /**
     * Retrieves the systems that are in the process of completing
     * a given action
     * @param user The user in question.
     * @param action The Action.
     * @param pc The PageControl.
     * @return Returns list containing the completed systems.
     */
    public static DataResult inProgressSystems(User user, 
                                              Action action, 
                                              PageControl pc) {
        
        return getActionSystems(user, action, pc, "systems_in_progress_action");
    }
    
    /**
     * Retrieves the systems that failed completing
     * a given action
     * @param user The user in question.
     * @param action The Action.
     * @param pc The PageControl.
     * @return Returns list containing the completed systems.
     */
    public static DataResult failedSystems(User user, 
                                              Action action, 
                                              PageControl pc) {
        
        return getActionSystems(user, action, pc, "systems_failed_action");
    }
    
    /**
     * Schedules a package list refresh action for the given server.
     * @param scheduler User scheduling the action.
     * @param server Server for which the action affects.
     * @return The scheduled PackageAction
     */
    public static PackageAction schedulePackageRefresh(User scheduler, Server server) {
        return (schedulePackageRefresh(scheduler, server, new Date()));
    }

    /**
     * Schedules a package list refresh action for the given server.
     * @param scheduler User scheduling the action.
     * @param server Server for which the action affects.
     * @param earliest The earliest time this action should be run.
     * @return The scheduled PackageAction
     */
    public static PackageAction schedulePackageRefresh(User scheduler, Server server, 
            Date earliest) {
        PackageAction pa = (PackageAction) schedulePackageAction(scheduler,
            (List) null, ActionFactory.TYPE_PACKAGES_REFRESH_LIST, earliest, server);
        storeAction(pa);
        return pa;
    }

    /**
     * Schedules a package runtransaction action.
     * @param scheduler User scheduling the action.
     * @param server Server for which the action affects.
     * @param pkgs List of PackageMetadata's to be run.
     * @param earliest The earliest time this action should be run.
     * @return The scheduled PackageAction
     */
    public static PackageAction schedulePackageRunTransaction(User scheduler,
            Server server, List pkgs, Date earliest) {
        
        if (pkgs == null || pkgs.isEmpty()) {
            return null;
        }

        Action action = scheduleAction(scheduler, server,
                ActionFactory.TYPE_PACKAGES_RUNTRANSACTION, 
                "Package Synchronization", new Date());
        action.setEarliestAction(earliest);

        if (!SystemManager.clientCapable(server.getId(), 
                "packages.runTransaction")) {
            // We need to schedule a hardware refresh to pull 
            // in the packages.runTransaction capability
            Action hwrefresh = 
                scheduleHardwareRefreshAction(scheduler, server, earliest);
            ActionFactory.save(hwrefresh);
            action.setPrerequisite(hwrefresh);
        }
        
        ActionFactory.save(action);
        
        PackageDelta pd = new PackageDelta();
        pd.setLabel("delta-" + System.currentTimeMillis());
        PackageFactory.save(pd);
        
        if (pkgs != null) {
          // this is SOOOO WRONG, we need to get rid of DataSource
          WriteMode m = ModeFactory.getWriteMode("Action_queries", 
                  "insert_package_delta_element"); 
          for (Iterator itr = pkgs.iterator(); itr.hasNext();) {
              PackageMetadata pm = (PackageMetadata) itr.next();
              Map params = new HashMap();
              params.put("delta_id", pd.getId());
              if (pm.getComparisonAsInt() == PackageMetadata.KEY_THIS_ONLY) {
                  
                  if (log.isDebugEnabled()) {
                      log.debug("compare returned [KEY_THIS_ONLY]; " +
                                "deleting package from system");
                  }

                  params.put("operation", ActionFactory.TXN_OPERATION_DELETE);
                  params.put("n", pm.getName());
                  params.put("v", pm.getSystem().getVersion());
                  params.put("r", pm.getSystem().getRelease());
                  String epoch = pm.getSystem().getEpoch();
                  params.put("e", epoch != null ? epoch : "");
                  params.put("a", pm.getSystem().getArch() != null ?
                          pm.getSystem().getArch() : "");
                  m.executeUpdate(params);
              }
              else if (pm.getComparisonAsInt() == PackageMetadata.KEY_OTHER_ONLY) {
                  
                  if (log.isDebugEnabled()) {
                      log.debug("compare returned [KEY_OTHER_ONLY]; " +
                                "installing package to system: " + 
                                pm.getName() + "-" + pm.getOtherEvr());
                  }
                  
                  params.put("operation", ActionFactory.TXN_OPERATION_INSERT);
                  params.put("n", pm.getName());
                  params.put("v", pm.getOther().getVersion());
                  params.put("r", pm.getOther().getRelease());
                  String epoch = pm.getOther().getEpoch();
                  params.put("e", epoch != null ? epoch : "");
                  params.put("a", pm.getOther().getArch() != null ?
                          pm.getOther().getArch() : "");
                  m.executeUpdate(params);

              }
              else if (pm.getComparisonAsInt() == PackageMetadata.KEY_THIS_NEWER ||
                       pm.getComparisonAsInt() == PackageMetadata.KEY_OTHER_NEWER) {
                  
                  if (log.isDebugEnabled()) {
                      log.debug("compare returned [KEY_THIS_NEWER OR KEY_OTHER_NEWER]; " +
                                "deleting package ["  + pm.getName() + "-" +
                                pm.getSystemEvr() + "] from system " +
                                "installing package ["  + pm.getName() + "-" + 
                                pm.getOther().getEvr() + "] to system");
                  }
                  
                  String epoch;
                  if (isPackageRemovable(pm.getName())) {
                      params.put("operation", ActionFactory.TXN_OPERATION_DELETE);
                      params.put("n", pm.getName());
                      params.put("v", pm.getSystem().getVersion());
                      params.put("r", pm.getSystem().getRelease());
                      epoch = pm.getSystem().getEpoch();
                      params.put("e", epoch != null ? epoch : "");
                      params.put("a", pm.getSystem().getArch() != null ?
                          pm.getOther().getArch() : "");
                      m.executeUpdate(params);
                  }
                  
                  params.put("operation", ActionFactory.TXN_OPERATION_INSERT);
                  params.put("n", pm.getName());
                  params.put("v", pm.getOther().getVersion());
                  params.put("r", pm.getOther().getRelease());
                  epoch = pm.getOther().getEpoch();
                  params.put("e", epoch != null ? epoch : "");
                  params.put("a", pm.getOther().getArch() != null ?
                          pm.getOther().getArch() : "");
                  m.executeUpdate(params);
              }
          }
        }
        
        // this is SOOOO WRONG, we need to get rid of DataSource
        WriteMode m = ModeFactory.getWriteMode("Action_queries", 
            "insert_action_package_delta"); 
        Map params = new HashMap();
        params.put("action_id", action.getId());
        params.put("delta_id", pd.getId());
        m.executeUpdate(params);
        
        return (PackageAction) action;
    }

    // Check if we want to delete the old package when installing  a
    // new rev of one.
    private static boolean isPackageRemovable(String name) {
        for (int i = 0; i < PACKAGES_NOT_REMOVABLE.length; i++) {
            log.debug("Checking: " + name + " for: " + PACKAGES_NOT_REMOVABLE[i]);
            if (name.equals(PACKAGES_NOT_REMOVABLE[i])) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Schedules one or more package removal actions for the given server.
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliestAction Date of earliest action to be executed
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageRemoval(User scheduler,
            Server srvr, RhnSet pkgs, Date earliestAction) {
        if (!srvr.isSolaris()) {
            return (PackageAction) schedulePackageAction(scheduler, srvr, pkgs,
                ActionFactory.TYPE_PACKAGES_REMOVE, earliestAction);
        }
        else {
            return (PackageAction) schedulePackageAction(scheduler, srvr, pkgs,
                ActionFactory.TYPE_SOLARISPKGS_REMOVE, earliestAction);
        }
    }

    
    /**
     * Schedules one or more package removal actions for the given server.
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The list of packages to be removed.
     * @param earliestAction Date of earliest action to be executed
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageRemoval(User scheduler,
            Server srvr, List<Map<String, Long>> pkgs, Date earliestAction) {
        if (!srvr.isSolaris()) {
            return (PackageAction) schedulePackageAction(scheduler, pkgs,
                ActionFactory.TYPE_PACKAGES_REMOVE, earliestAction, srvr);
        }
        else {
            return (PackageAction) schedulePackageAction(scheduler, pkgs,
                ActionFactory.TYPE_SOLARISPKGS_REMOVE, earliestAction, srvr);
        }
    }
    
    /**
     * Schedules one or more package removal actions on one or more servers.
     * 
     * @param scheduler      user scheduling the action.
     * @param serverIds        servers from which to remove the packages
     * @param pkgs           list of packages to be removed.
     * @param earliestAction date of earliest action to be executed
     */
    public static void schedulePackageRemoval(User scheduler,
            Collection<Long> serverIds, List<Map<String, Long>> pkgs, Date earliestAction) {

        // Different handling for package removal on solaris v. rhel, so split out
        // the servers first in case the list is mixed.
        Set<Long> rhelServers = new HashSet<Long>();
        rhelServers.addAll(ServerFactory.listLinuxSystems(serverIds));
        Set<Long> solarisServers = new HashSet<Long>();
        solarisServers.addAll(ServerFactory.listSolarisSystems(serverIds));
        
        // Since the solaris v. rhel distinction results in a different action type,
        // we'll end up with 2 actions created if the server list is mixed
        if (!rhelServers.isEmpty()) {
            schedulePackageAction(scheduler, pkgs, ActionFactory.TYPE_PACKAGES_REMOVE,
                earliestAction, rhelServers);
        }
        
        if (!solarisServers.isEmpty()) {
            schedulePackageAction(scheduler, pkgs, ActionFactory.TYPE_SOLARISPKGS_REMOVE,
                earliestAction, solarisServers);
        }
    }
    
    /**
     * Schedules one or more package upgrade actions for the given server.
     * Note: package upgrade = package install
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliestAction Date of earliest action to be executed
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageUpgrade(User scheduler,
            Server srvr, RhnSet pkgs, Date earliestAction) {
        return schedulePackageInstall(scheduler, srvr, pkgs, earliestAction);
    }

    /**
     * Schedules one or more package upgrade actions for the given servers.
     * Note: package upgrade = package install
     * @param scheduler User scheduling the action.
     * @param sids list of server ids on which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliestAction Date of earliest action to be executed
     */
    public static void schedulePackageUpgrades(User scheduler,
            List<Long> sids, List<Map<String, Long>> pkgs, Date earliestAction) {
        schedulePackageInstall(scheduler, sids, pkgs, earliestAction);
    }

    /**
     * Schedules one or more package upgrade actions for the given server.
     * Note: package upgrade = package install
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliestAction Date of earliest action to be executed
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageUpgrade(User scheduler,
            Server srvr, List<Map<String, Long>> pkgs, Date earliestAction) {
        return schedulePackageInstall(scheduler, srvr, pkgs, earliestAction);
    }    
    
    /**
     * Schedules one or more package installation actions for the given server.
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliestAction Date of earliest action to be executed
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageInstall(User scheduler,
            Server srvr, List pkgs, Date earliestAction) {
        if (!srvr.isSolaris()) {
            return (PackageAction) schedulePackageAction(scheduler, pkgs,
                ActionFactory.TYPE_PACKAGES_UPDATE, earliestAction, srvr);
        }
        else {
            return (PackageAction) schedulePackageAction(scheduler, pkgs,
                ActionFactory.TYPE_SOLARISPKGS_INSTALL, earliestAction, srvr);
        }
    }
    
    /**
     * Schedules one or more package installation actions on one or more servers.
     * @param scheduler      user scheduling the action.
     * @param serverIds        server ids for which the packages should be installed
     * @param pkgs           set of packages to be removed.
     * @param earliestAction date of earliest action to be executed
     */
    public static void schedulePackageInstall(User scheduler,
            Collection<Long> serverIds, List pkgs, Date earliestAction) {
        
        // Different handling for package installs on solaris v. rhel, so split out
        // the servers first in case the list is mixed.
        Set<Long> rhelServers = new HashSet<Long>();
        rhelServers.addAll(ServerFactory.listLinuxSystems(serverIds));
        Set<Long> solarisServers = new HashSet<Long>();
        solarisServers.addAll(ServerFactory.listSolarisSystems(serverIds));
        
        // Since the solaris v. rhel distinction results in a different action type,
        // we'll end up with 2 actions created if the server list is mixed
        if (!rhelServers.isEmpty()) {
            schedulePackageAction(scheduler, pkgs, ActionFactory.TYPE_PACKAGES_UPDATE,
                earliestAction, rhelServers);
        }
        
        if (!solarisServers.isEmpty()) {
            schedulePackageAction(scheduler, pkgs, ActionFactory.TYPE_SOLARISPKGS_INSTALL,
                earliestAction, solarisServers);
        }
        
    }
    
    /**
     * Schedules one or more package installation actions for the given server.
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliestAction Date of earliest action to be executed
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageInstall(User scheduler,
            Server srvr, RhnSet pkgs, Date earliestAction) {
        if (!srvr.isSolaris()) {
            return (PackageAction) schedulePackageAction(scheduler, srvr, pkgs,
                    ActionFactory.TYPE_PACKAGES_UPDATE, earliestAction);
        }
        else {
            return (PackageAction) schedulePackageAction(scheduler, srvr, pkgs, 
                    ActionFactory.TYPE_SOLARISPKGS_INSTALL, earliestAction);
        }
    }
    
    /**
     * Schedules one or more package verification actions for the given server.
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliest Earliest occurrence of the script.
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageVerify(User scheduler,
            Server srvr, RhnSet pkgs, Date earliest) {
        return (PackageAction) schedulePackageAction(scheduler, srvr, pkgs,
                ActionFactory.TYPE_PACKAGES_VERIFY, earliest);
    }
       
    /**
     * Schedules one or more package verification actions for the given server.
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param earliest Earliest occurrence of the script.
     * @return Currently scheduled PackageAction
     */
    public static PackageAction schedulePackageVerify(User scheduler,
            Server srvr, List<Map<String, Long>> pkgs, Date earliest) {
        return (PackageAction) schedulePackageAction(scheduler, pkgs,
            ActionFactory.TYPE_PACKAGES_VERIFY, earliest, srvr);
    }    
    /**
     * Schedules one or more package installation actions for the given server.
     * Note: package upgrade = package install
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param script The set of packages to be removed.
     * @param name Name of Script action.
     * @param earliest Earliest occurrence of the script.
     * @return Currently scheduled ScriptRunAction
     */
    public static ScriptRunAction scheduleScriptRun(User scheduler,
            Server srvr, String name, ScriptActionDetails script, Date earliest) {
        
        if (!SystemManager.clientCapable(srvr.getId(), "script.run")) {
            throw new MissingCapabilityException("script.run", srvr);
        }
        
        if (!SystemManager.hasEntitlement(srvr.getId(), EntitlementManager.PROVISIONING)) {
            throw new MissingEntitlementException(
                    EntitlementManager.PROVISIONING.getHumanReadableLabel());
        }
        
        ScriptRunAction sra = (ScriptRunAction) scheduleAction(scheduler, srvr,
                ActionFactory.TYPE_SCRIPT_RUN, name, earliest);
        sra.setScriptActionDetails(script);
        ActionFactory.save(sra);
        return sra;
    }
    
    /**
     * Creates a ScriptActionDetails which contains an arbitrary script to be
     * run by a ScriptRunAction.
     * @param username Username of script
     * @param groupname Group script runs as 
     * @param script Script contents
     * @param timeout script timeout
     * @return ScriptActionDetails containing script to be run by ScriptRunAction
     */
    public static ScriptActionDetails createScript(String username,
            String groupname, Long timeout, String script) {
        
        return ActionFactory.createScriptActionDetails(username, groupname,
                timeout, script);
    }
    
    private static Action scheduleAction(User scheduler, ActionType type, String name,
                                         Date earliestAction, Set<Long> serverIds) {
        /**
         * We have to relookup the type here, because most likely a static final variable
         *  was passed in.  If we use this and the .reload() gets called below
         *  if we try to save a new action the instace of the type in the cache
         *  will be different than the final static variable
         *  sometimes hibernate is no fun
         */
        type = ActionFactory.lookupActionTypeByLabel(type.getLabel());
        Action action = createScheduledAction(scheduler, type, name, earliestAction);
        ActionFactory.save(action);
        ActionFactory.getSession().flush();
        ActionFactory.getSession().refresh(action);
       
        
        Map params = new HashMap();
        params.put("status_id", ActionFactory.STATUS_QUEUED.getId());
        params.put("tries", REMAINING_TRIES);
        params.put("parent_id", action.getId());
        //params.put("sid", sid);
        
        WriteMode m = ModeFactory.getWriteMode("Action_queries", 
                "insert_server_actions"); 
        List<Long> sidList = new ArrayList<Long>();
        sidList.addAll(serverIds);
        m.executeUpdate(params,  sidList);
            
            
            //action.addServerAction(sa);
        
        return action;
    }
    
    private static Action scheduleAction(User scheduler, Server srvr,
            ActionType type, String name, Date earliestAction) {
        
        Action action = createScheduledAction(scheduler, type, name, earliestAction);

        ServerAction sa = new ServerAction();
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        sa.setRemainingTries(REMAINING_TRIES);
        sa.setServer(srvr);
        
        action.addServerAction(sa);
        sa.setParentAction(action);
        
        return action;
    }

    private static Action createScheduledAction(User scheduler, ActionType type,
                                                String name, Date earliestAction) {
        Action pa = ActionFactory.createAction(type);
        pa.setName(name);
        pa.setOrg(scheduler.getOrg());
        pa.setSchedulerUser(scheduler);
        pa.setEarliestAction(earliestAction);
        return pa;
    }

    /**
     * Schedule a KickstartAction against a system
     * @param ksdata KickstartData to associate with this Action
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param earliestAction Date run the Action
     * @param appendString extra options to add to the action.
     * @param kickstartHost host that serves up the kickstart file.
     * @return Currently scheduled KickstartAction
     */
    public static KickstartAction scheduleKickstartAction(
            KickstartData ksdata, User scheduler, Server srvr,
            Date earliestAction, String appendString, String kickstartHost) {
        if (log.isDebugEnabled()) {
            log.debug("scheduleKickstartAction(KickstartData ksdata=" + ksdata + 
                    ", User scheduler=" + scheduler + ", Server srvr=" + srvr + 
                    ", Date earliestAction=" + earliestAction + 
                    ", String appendString=" + appendString + 
                    ", String kickstartHost=" + kickstartHost + ") - start");
        }
        
        return scheduleKickstartAction(ksdata.getPreserveFileLists(), scheduler, srvr, 
                                        earliestAction, appendString, kickstartHost);
         
    }
    
    /**
     * Schedule a KickstartAction against a system
     * @param fileList file preservation lists to be included in the system records.
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param earliestAction Date run the Action
     * @param appendString extra options to add to the action.
     * @param kickstartHost host that serves up the kickstart file.
     * @return Currently scheduled KickstartAction
     */
    public static KickstartAction scheduleKickstartAction(
            Set<FileList> fileList, User scheduler, Server srvr,
            Date earliestAction, String appendString, String kickstartHost) {
        if (log.isDebugEnabled()) {
            log.debug("scheduleKickstartAction(" + 
                    ", User scheduler=" + scheduler + ", Server srvr=" + srvr + 
                    ", Date earliestAction=" + earliestAction + 
                    ", String appendString=" + appendString + 
                    ", String kickstartHost=" + kickstartHost + ") - start");
        }
        
        KickstartAction ksaction = (KickstartAction) scheduleAction(scheduler, srvr, 
                ActionFactory.TYPE_KICKSTART_INITIATE, 
                ActionFactory.TYPE_KICKSTART_INITIATE.getName(), 
                earliestAction);
        KickstartActionDetails kad = new KickstartActionDetails();
        kad.setAppendString(appendString);
        kad.setParentAction(ksaction);
        kad.setKickstartHost(kickstartHost);
        ksaction.setKickstartActionDetails(kad);
        if (fileList != null) {
            for (FileList list : fileList) {
                kad.addFileList(list);
            }
        }

        return ksaction;
    }

    
    /**
     * Schedule a KickstartGuestAction against a system
     * @param pcmd most information needed to create this action
     * @param ksSessionId Kickstart Session ID to associate with this action
     * @return Currently scheduled KickstartAction
     */
    public static KickstartGuestAction scheduleKickstartGuestAction(
            ProvisionVirtualInstanceCommand pcmd,
            Long ksSessionId
            ) {

        KickstartGuestAction ksAction = (KickstartGuestAction)
            scheduleAction(pcmd.getUser(),
                           pcmd.getHostServer(),
                           ActionFactory.TYPE_KICKSTART_INITIATE_GUEST,
                           ActionFactory.TYPE_KICKSTART_INITIATE_GUEST.getName(), 
                           pcmd.getScheduleDate());
        KickstartGuestActionDetails kad = new KickstartGuestActionDetails();
        kad.setAppendString(pcmd.getExtraOptions());
        kad.setParentAction(ksAction);
        
        kad.setDiskGb(pcmd.getLocalStorageSize());
        kad.setMemMb(pcmd.getMemoryAllocation().longValue());
        kad.setVirtBridge(pcmd.getVirtBridge());
        kad.setDiskPath(pcmd.getFilePath());
        kad.setVcpus(new Long(pcmd.getVirtualCpus()));
        kad.setGuestName(pcmd.getGuestName());
        kad.setKickstartSessionId(ksSessionId);
        
        Profile cProfile = Profile.lookupById(CobblerXMLRPCHelper.getConnection(
           pcmd.getUser()), pcmd.getKsdata().getCobblerId());
        CobblerVirtualSystemCommand vcmd = new CobblerVirtualSystemCommand(
                pcmd.getServer(), cProfile.getName(), pcmd.getGuestName(),
                pcmd.getKsdata());
        kad.setCobblerSystemName(vcmd.getCobblerSystemRecordName());

        kad.setKickstartHost(pcmd.getKickstartServerName());
        ksAction.setKickstartGuestActionDetails(kad);
        return ksAction;
    }
    
    /**
     * Schedule a KickstartAction against a system
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param earliestAction Date run the Action
     * @return Currently scheduled KickstartAction
     */
    public static Action scheduleRebootAction(User scheduler, Server srvr,
            Date earliestAction) {
        return scheduleAction(scheduler, srvr, ActionFactory.TYPE_REBOOT, 
                ActionFactory.TYPE_REBOOT.getName(), earliestAction);
    }

    /**
     * Schedule a KickstartAction against a system
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param earliestAction Date run the Action
     * @return Currently scheduled KickstartAction
     */
    public static Action scheduleHardwareRefreshAction(User scheduler, Server srvr,
            Date earliestAction) {
        return scheduleAction(scheduler, srvr, ActionFactory.TYPE_HARDWARE_REFRESH_LIST, 
                ActionFactory.TYPE_HARDWARE_REFRESH_LIST.getName(), earliestAction);
    }
    
    /**
     * Schedules all Errata for the given system.
     * @param scheduler Person scheduling the action.
     * @param srvr Server whose errata is going to be scheduled.
     * @param earliest Earliest possible time action will occur.
     * @return Currently scheduled Errata Actions 
     */
    public static List scheduleAllErrataUpdate(User scheduler, Server srvr,
            Date earliest) {
        DataResult errata = SystemManager.unscheduledErrata(scheduler, srvr.getId(), null);
        errata.elaborate();
        // I don't have time to model SQL into Hibernate lingo, and I don't want
        // to have to write yet another one off SQL query just to overcome
        // Hibernate.
        // If someone wants to model this into Hibernate please do so:
        //        SELECT DISTINCT E.id, E.update_date
        //        FROM rhnErrata E,
        //             rhnServerNeededPackageCache SNPC
        //       WHERE EXISTS (SELECT server_id FROM rhnUserServerPerms USP
        //             WHERE USP.user_id = :user_id AND USP.server_id = :sid)
        //         AND SNPC.server_id = :sid
        //         AND SNPC.errata_id = E.id
        //         AND NOT EXISTS (SELECT SA.server_id 
        //                           FROM rhnActionErrataUpdate AEU,
        //                                rhnServerAction SA,
        //                                rhnActionStatus AST
        //                          WHERE SA.server_id = :sid
        //                            AND SA.status = AST.id
        //                            AND AST.name IN('Queued', 'Picked Up')
        //                            AND AEU.action_id = SA.action_id
        //                            AND AEU.errata_id = E.id )
        //      ORDER BY E.update_date, E.id
        // 
        // And don't forget the errataOverview elaborator
        List actions = new LinkedList();
        for (Iterator itr = errata.iterator(); itr.hasNext();) {
            PublishedErrata e = (PublishedErrata) itr.next();
            
            Object[] args = new Object[2];
            args[0] = e.getAdvisory();
            args[1] = e.getSynopsis();
            String name = LocalizationService.getInstance().getMessage(
                    "action.name", args);

            ErrataAction action = (ErrataAction) scheduleAction(scheduler, srvr,
                    ActionFactory.TYPE_ERRATA, name, earliest);
            action.addErrata(e);
            ActionFactory.save(action);
            actions.add(action);
        }

        return actions;
    }
    
    /**
     * Remove the system from the passed in Action.
     * @param serverIn to remove from Action
     * @param actionIn to process
     */
    public static void removeSystemFromAction(Server serverIn, Action actionIn) {
        CallableMode m = ModeFactory.getCallableMode("System_queries",
            "remove_from_action");
        Map inParams = new HashMap();
        inParams.put("server_id", serverIn.getId());
        inParams.put("action_id", actionIn.getId());
        m.execute(inParams, new HashMap());

    }

    /**
     * Schedules an install of a package
     * @param scheduler The user scheduling the action.
     * @param srvr The server that this action is for.
     * @param nameId nameId rhnPackage.name_id
     * @param evrId evrId of package
     * @param archId archId of package
     * @return The action that has been scheduled.
     */
    public static Action schedulePackageInstall(User scheduler, Server srvr, 
            Long nameId, Long evrId, Long archId) {
        List packages = new LinkedList();
        Map row = new HashMap();
        row.put("name_id", nameId);
        row.put("evr_id", evrId);
        row.put("arch_id", archId);
        packages.add(row);
        return schedulePackageInstall(scheduler, srvr, packages, new Date());
    }
    
    /**
     * Schedules a package action of the given type for the given server with the
     * packages given as a list.
     * @param scheduler The user scheduling the action.
     * @param pkgs A list of maps containing keys 'name_id', 'evr_id' and 
     *             optional 'arch_id' with Long values.
     * @param type The type of the package action.  One of the static types found in
     *             ActionFactory
     * @param earliestAction The earliest time that this action could happen.
     * @param servers The server(s) that this action is for.
     * @return The action that has been scheduled.
     */
    public static Action schedulePackageAction(User scheduler,
                                            List pkgs,
                                            ActionType type,
                                            Date earliestAction,
                                            Server...servers) {
        Set<Long> serverIds = new HashSet<Long>();
        for (Server s : servers) {
            serverIds.add(s.getId());
        }
        return schedulePackageAction(scheduler, pkgs, type, earliestAction, serverIds);
    }
    
    /**
     * Schedules a package action of the given type for the given server with the
     * packages given as a list.
     * @param scheduler The user scheduling the action.
     * @param pkgs A list of maps containing keys 'name_id', 'evr_id' and 
     *             optional 'arch_id' with Long values.
     * @param type The type of the package action.  One of the static types found in
     *             ActionFactory
     * @param earliestAction The earliest time that this action could happen.
     * @param serverIds The server ids that this action is for.
     * @return The action that has been scheduled.
     */
    public static Action schedulePackageAction(User scheduler,
                                               List pkgs,
                                               ActionType type,
                                               Date earliestAction,
                                               Set<Long> serverIds) {

        String name = "";
        if (type.equals(ActionFactory.TYPE_PACKAGES_REMOVE) ||
            type.equals(ActionFactory.TYPE_SOLARISPKGS_REMOVE)) {
            name = "Package Removal";
        }
        else if (type.equals(ActionFactory.TYPE_PACKAGES_UPDATE) ||
                 type.equals(ActionFactory.TYPE_SOLARISPKGS_INSTALL)) {
            name = "Package Install";
        }
        else if (type.equals(ActionFactory.TYPE_PACKAGES_REFRESH_LIST)) {
            name = "Package List Refresh";
        }
        else if (type.equals(ActionFactory.TYPE_PACKAGES_DELTA)) {
            name = "Package Synchronization";
        }

        Action action = scheduleAction(scheduler, type, name, earliestAction, serverIds);
        ActionFactory.save(action);
        
        if (pkgs != null) {
          // for each item in the set create a package action detail
          // I'm using datasource to insert the records instead of 
          // hibernate. It seems terribly inefficient to lookup a
          // packagename and packageevr object to insert the ids into the
          // correct table if I already have the ids.
          for (Iterator itr = pkgs.iterator(); itr.hasNext();) {
              Map rse = (Map) itr.next();
              Map params = new HashMap();
              Long nameId = (Long) rse.get("name_id");
              Long evrId = (Long) rse.get("evr_id");
              Long archId = (Long) rse.get("arch_id");
              if (nameId == null || evrId == null) {
                  throw new IllegalArgumentException("name_id or " +
                        "evr_id are not in the Map passed into " +
                        "this method.  Please populate the Map " +
                        "with the name_id and evr_id items");
              }
              params.put("action_id", action.getId());
              params.put("name_id", nameId);
              params.put("evr_id", evrId);

              WriteMode m = null;
              if (archId == null) {
                  m = ModeFactory.getWriteMode("Action_queries", 
                          "schedule_action_no_arch");
              } 
              else {
                  params.put("arch_id", archId);
                  m = ModeFactory.getWriteMode("Action_queries", "schedule_action"); 
              }
              m.executeUpdate(params);
          }
        }
        
        return action;
    }    
    
    /**
     * Schedules the appropriate package action
     * @param scheduler User scheduling the action.
     * @param srvr Server for which the action affects.
     * @param pkgs The set of packages to be removed.
     * @param type The Action Type
     * @param earliestAction Date of earliest action to be executed
     * @return scheduled Package Action
     */
    private static Action schedulePackageAction(User scheduler,
            Server srvr, RhnSet pkgs, ActionType type, Date earliestAction) {

        List packages = new LinkedList();
        Iterator i = pkgs.getElements().iterator();
        while (i.hasNext()) {
            RhnSetElement rse = (RhnSetElement) i.next();
            Map row = new HashMap();
            row.put("name_id", rse.getElement());
            row.put("evr_id", rse.getElementTwo());
            row.put("arch_id", rse.getElementThree());
            // bugzilla: 191000, we forgot to populate the damn LinkedList :(
            packages.add(row);
        }
        return schedulePackageAction(scheduler, packages, type, earliestAction, srvr
        );
    }

    
}
