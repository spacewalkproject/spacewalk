/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.domain.action;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateRuntimeException;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.config.ConfigRevisionAction;
import com.redhat.rhn.domain.action.config.ConfigRevisionActionResult;
import com.redhat.rhn.domain.action.config.ConfigUploadAction;
import com.redhat.rhn.domain.action.config.ConfigUploadMtimeAction;
import com.redhat.rhn.domain.action.config.DaemonConfigAction;
import com.redhat.rhn.domain.action.errata.ErrataAction;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestToolsChannelSubscriptionAction;
import com.redhat.rhn.domain.action.kickstart.KickstartHostToolsChannelSubscriptionAction;
import com.redhat.rhn.domain.action.kickstart.KickstartInitiateAction;
import com.redhat.rhn.domain.action.kickstart.KickstartInitiateGuestAction;
import com.redhat.rhn.domain.action.kickstart.KickstartScheduleSyncAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionDetails;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.solaris.SolarisPackagePatchClusterInstallAction;
import com.redhat.rhn.domain.action.solaris.SolarisPackagePatchInstallAction;
import com.redhat.rhn.domain.action.solaris.SolarisPackagePatchRemoveAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationDestroyAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationRebootAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationResumeAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationSchedulePollerAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationSetMemoryAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationSetVcpusAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationShutdownAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationStartAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationSuspendAction;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.log4j.Logger;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;

import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ActionFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.action.Action objects from the
 * database.
 * @version $Rev$ 
 */
public class ActionFactory extends HibernateFactory {

    private static ActionFactory singleton = new ActionFactory();
    private static Logger log = Logger.getLogger(ActionFactory.class);
    private static Set actionArchTypes;
    
    private ActionFactory() {
        super();
        setupActionArchTypes();
    }
    
    private void setupActionArchTypes() {
        synchronized (this) {
            Session session = null;
            try {
                session = HibernateFactory.getSession();
                List types = session.getNamedQuery("ActionArchType.loadAll")
                                               //Retrieve from cache if there
                                               .setCacheable(true).list();
                
                actionArchTypes = new HashSet();
                Iterator i = types.iterator();
                while (i.hasNext()) {
                    ActionArchType type = (ActionArchType) i.next();
                    actionArchTypes.add(type);
                }
            }
            catch (HibernateException he) {
                log.error("Error loading ActionArchTypes from DB", he);
                throw new 
                    HibernateRuntimeException("Error loading ActionArchTypes from db");
            }
        }
    }
    
    /**
     * Removes an action from all its associated systems
     * @param actionId action to remove
     * @return the number of failed systems to remove an action for.
     */
    public static int removeAction(Long actionId) {

        Session session = HibernateFactory.getSession();
        List<Number> ids = session.getNamedQuery("Action.findServerIds")
                    .setLong("action_id", actionId).list();
        int failed = 0;
        for (Number id : ids) {
            try {
                removeActionForSystem(actionId, id);
            }
            catch (Exception e) {
                failed++;
            }
        }
        return failed;
    }
    
    /**
     * Remove an action for an rhnset of system ids with the given label
     * @param actionId the action to remove
     * @param setLabel the set label to pull the ids from
     * @param user the user witht he set
     * @return the number of failed systems to remove an action for.
     */
    public static int removeActionForSystemSet(Number actionId, 
            String setLabel, User user) {
        
        RhnSet set = RhnSetManager.findByLabel(user.getId(), setLabel, null);
        Set<Long> ids = set.getElementValues();
        int failed = 0;
        for (Long sid : ids) {
            try {
                removeActionForSystem(actionId, sid);
            }
            catch (Exception e) {
                failed++;
            }
        }
        return failed;
    }
    
    private  static void removeActionForSystem(Number actionId, Number sid) {
        CallableMode mode = 
            ModeFactory.getCallableMode("System_queries", "delete_action_for_system");
        Map params = new HashMap();
        params.put("action_id", actionId);
        params.put("server_id",  sid);
        mode.execute(params, new HashMap());
    }
    
    
    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    protected Logger getLogger() {
        return log;
    }
    
    /**
     * Creates a ServerAction and adds it to an Action
     * @param sid The server id
     * @param parent The parent action
     */
    public static void addServerToAction(Long sid, Action parent) {
        addServerToAction(ServerFactory.lookupByIdAndOrg(sid,
                parent.getOrg()), parent);
    }
    
    /**
     * Creates a ServerAction and adds it to an Action
     * @param server The server
     * @param parent The parent action
     */
    public static void addServerToAction(Server server, Action parent) {
        ServerAction sa = new ServerAction();
        sa.setCreated(new Date());
        sa.setModified(new Date());
        sa.setStatus(STATUS_QUEUED);
        sa.setServer(server);
        sa.setParentAction(parent);
        sa.setRemainingTries(new Long(5)); //arbitrary number from perl
        parent.addServerAction(sa);
    }
    
    /**
     * Create a ConfigRevisionAction for the given server and add it to the parent action.
     * @param revision The config revision to add to the action.
     * @param server The server for the action
     * @param parent The parent action
     */
    public static void addConfigRevisionToAction(ConfigRevision revision, Server server,
            ConfigAction parent) {
        ConfigRevisionAction cra = new ConfigRevisionAction();
        cra.setConfigRevision(revision);
        cra.setCreated(new Date());
        cra.setModified(new Date());
        cra.setServer(server);
        parent.addConfigRevisionAction(cra);
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
    public static ScriptActionDetails createScriptActionDetails(String username,
            String groupname, Long timeout, String script) {
        ScriptActionDetails sad = new ScriptActionDetails();
        sad.setUsername(username);
        sad.setGroupname(groupname);
        sad.setTimeout(timeout);

        try {
            sad.setScript(script.getBytes("UTF-8"));
        }
        catch (UnsupportedEncodingException uee) {
                throw new
                    IllegalArgumentException(
                            "This VM or environment doesn't support UTF-8");
        }
        
        return sad;
    }

    /**
     * Check to see if a server has a pending kickstart scheduled
     * @param serverId server
     * @return true if found, otherwise false
     */
    public static boolean doesServerHaveKickstartScheduled(Long serverId) {
        Session session = HibernateFactory.getSession();
        Query query = 
            session.getNamedQuery("ServerAction.findPendingKickstartsForServer");
        query.setParameter("serverId", serverId);
        query.setParameter("label", "kickstart.initiate");
        List retval = query.list();
        return (retval != null && retval.size() > 0);
    }
    
    /**
     * Create a new Action from scratch.
     * @param typeIn the type of Action we want to create
     * @return the Action created
     */
    public static Action createAction(ActionType typeIn) {
        return createAction(typeIn, new Date());
    }
    
    /**
     * Create a new Action from scratch
     * with the given earliest execution.
     * @param typeIn the type of Action we want to create
     * @param earliest The earliest time that this action can occur.
     * @return the Action created
     */
    public static Action createAction(ActionType typeIn, Date earliest) {
        Action retval;
        if (typeIn.equals(TYPE_ERRATA)) { 
            retval = new ErrataAction();
        } 
        else if (typeIn.equals(TYPE_SCRIPT_RUN)) {
            retval = new ScriptRunAction();
        }
        else if (typeIn.equals(TYPE_CONFIGFILES_DIFF) ||
                typeIn.equals(TYPE_CONFIGFILES_DEPLOY) ||
                typeIn.equals(TYPE_CONFIGFILES_VERIFY)) {
            retval = new ConfigAction();
        } 
        else if (typeIn.equals(TYPE_CONFIGFILES_UPLOAD)) {
            retval = new ConfigUploadAction();
        }
        else if (typeIn.equals(TYPE_PACKAGES_AUTOUPDATE) ||
                 typeIn.equals(TYPE_PACKAGES_DELTA) ||
                 typeIn.equals(TYPE_PACKAGES_REFRESH_LIST) ||
                 typeIn.equals(TYPE_PACKAGES_REMOVE) ||
                 typeIn.equals(TYPE_PACKAGES_RUNTRANSACTION) ||
                 typeIn.equals(TYPE_PACKAGES_UPDATE) ||
                 typeIn.equals(TYPE_PACKAGES_VERIFY) ||
                 typeIn.equals(TYPE_SOLARISPKGS_REMOVE) ||
                 typeIn.equals(TYPE_SOLARISPKGS_INSTALL)) {
           retval = new PackageAction();
        }
        else if (typeIn.equals(TYPE_CONFIGFILES_MTIME_UPLOAD)) {
            retval = new ConfigUploadMtimeAction();
        }
        //Kickstart Actions
        else if (typeIn.equals(TYPE_KICKSTART_SCHEDULE_SYNC)) {
            retval = new KickstartScheduleSyncAction();
        }
        else if (typeIn.equals(TYPE_KICKSTART_INITIATE)) {
            retval = new KickstartInitiateAction();
        }
        else if (typeIn.equals(TYPE_KICKSTART_INITIATE_GUEST)) {
            retval = new KickstartInitiateGuestAction();
        }
        else if (typeIn.equals(TYPE_DAEMON_CONFIG)) { 
            retval = new DaemonConfigAction();
        }
        else if (typeIn.equals(TYPE_SOLARISPKGS_PATCHREMOVE)) {
            retval = new SolarisPackagePatchRemoveAction();
        }
        else if (typeIn.equals(TYPE_SOLARISPKGS_PATCHINSTALL)) {
            retval = new SolarisPackagePatchInstallAction();
        }
        else if (typeIn.equals(TYPE_SOLARISPKGS_PATCHCLUSTERINSTALL)) {
            retval = new SolarisPackagePatchClusterInstallAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_SHUTDOWN)) {
            retval = new VirtualizationShutdownAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_START)) {
            retval = new VirtualizationStartAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_SUSPEND)) {
            retval = new VirtualizationSuspendAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_RESUME)) {
            retval = new VirtualizationResumeAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_REBOOT)) {
            retval = new VirtualizationRebootAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_DESTROY)) {
            retval = new VirtualizationDestroyAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_SET_MEMORY)) {
            retval = new VirtualizationSetMemoryAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_SET_VCPUS)) {
            retval = new VirtualizationSetVcpusAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_SCHEDULE_POLLER)) {
            retval = new VirtualizationSchedulePollerAction();
        }
        else if (typeIn.equals(TYPE_VIRTIZATION_HOST_SUBSCRIBE_TO_TOOLS_CHANNEL)) {
            retval = new KickstartHostToolsChannelSubscriptionAction();
        }
        else if (typeIn.equals(TYPE_VIRTUALIZATION_GUEST_SUBSCRIBE_TO_TOOLS_CHANNEL)) {
            retval = new KickstartGuestToolsChannelSubscriptionAction();
        }

        else {
            retval = new Action();
        }
        retval.setActionType(typeIn);
        retval.setCreated(new Date());
        retval.setModified(new Date());
        if (earliest == null) {
            earliest = new Date();
        }
        retval.setEarliestAction(earliest);
        //in perl(modules/rhn/RHN/DB/Scheduler.pm) version is given a 2.
        //So that's what I did.
        retval.setVersion(new Long(2));
        retval.setArchived(new Long(0)); //not archived
        return retval;
    }

    /**
     * Lookup an Action by the id, assuming that it is in the same Org as
     * the user doing the search.  This method ensures security around the 
     * Action.
     * @param user the user doing the search
     * @param id of the Action to search for
     * @return the Action found
     */
    public static Action lookupByUserAndId(User user, Long id) {
        Map params = new HashMap();
        params.put("aid", id);
        params.put("orgId", user.getOrg().getId());
        return (Action)singleton.lookupObjectByNamedQuery(
                                        "Action.findByIdandOrgId", params);
    }
    

    /**
     * Lookup the total server action count for an action
     * @param org the org to look
     * @param action the action id
     * @return the count
     */
    public static Integer getServerActionCount(Org org, Action action) {
        Map params = new HashMap();
        params.put("aid", action.getId());
        params.put("orgId", org.getId());
        return (Integer)singleton.lookupObjectByNamedQuery(
                                        "Action.getServerActionCount", params);
    }
    
    
    /**
     * Lookup the number of server actions for a particular action that have 
     *      a certain status
     * @param org the org to look
     * @param status the status you want
     * @param action the action id
     * @return the count
     */
    public static Integer getServerActionCountByStatus(Org org, Action action, 
            ActionStatus status) {
        Map params = new HashMap();
        params.put("aid", action.getId());
        params.put("stid", status.getId());
        return (Integer)singleton.lookupObjectByNamedQuery(
                                        "Action.getServerActionCountByStatus", params);
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
        Map params = new HashMap();
        params.put("userId", user.getId());
        params.put("actionTypeId", type.getId());
        params.put("serverId", server.getId());
        return (Action)singleton.lookupObjectByNamedQuery(
                         "Action.findLastActionByServerIdAndActionTypeIdAndUserId",
                             params);
    }
        
    
    /**
     * Lookup a Action by their id
     * @param id the id to search for
     * @return the Action found
     */
    public static Action lookupById(Long id) {
        Session session = HibernateFactory.getSession();
        Action a = (Action)session.get(Action.class, id);
        return a;
    }

    /**
     * Helper method to get a ActionType by label
     * @param label the Action to lookup
     * @return Returns the ActionType corresponding to label
     * @throws Exception
     */
    public static ActionType lookupActionTypeByLabel(String label) {
        Map params = new HashMap();
        params.put("label", label);
        return (ActionType) 
            singleton.lookupObjectByNamedQuery("ActionType.findByLabel", params, true);
    }

    /**
     * Helper method to get a ActionStatus by Name
     * @param name the name of the status we want to lookup.
     * @return Returns the ActionStatus corresponding to name
     */
    private static ActionStatus lookupActionStatusByName(String name) {
        Map params = new HashMap();
        params.put("name", name);
        return (ActionStatus) 
            singleton.lookupObjectByNamedQuery("ActionStatus.findByName", params, true);

    }
    
    /**
     * Helper method to get a ConfigRevisionActionResult by 
     *  Action Config Revision Id
     * @param actionConfigRevisionId the id of the ActionConfigRevision
     *                  for whom we want to lookup the result
     * @return The ConfigRevisionActionResult corresponding to the revison ID.
     */
    public static ConfigRevisionActionResult 
                    lookupConfigActionResult(Long actionConfigRevisionId) {
        Map params = new HashMap();
        params.put("id", actionConfigRevisionId);
        return (ConfigRevisionActionResult) 
            singleton.lookupObjectByNamedQuery("ConfigRevisionActionResult.findById",
                                                                    params, true);        
    }    

    /**
     * Helper method to get a ConfigRevisionAction by 
     *  Action Config Revision Id
     * @param id the id of the ActionConfigRevision
     *                  for whom we want to lookup the result
     * @return The ConfigRevisionAction corresponding to the revison ID.
     */
    public static ConfigRevisionAction 
                    lookupConfigRevisionAction(Long id) {

        Session session = HibernateFactory.getSession();
        ConfigRevisionAction c = (ConfigRevisionAction) session.
            get(ConfigRevisionAction.class, id);
        return c;
    }
    
    /**
     * Insert or Update a Action.
     * @param actionIn Action to be stored in database.
     */
    public static void save(Action actionIn) {
        /**
         * If we are trying to commit a package action, make sure
         * the packageEvr stored proc is called first so that 
         * the foreign key constraint holds.
         */
        if (actionIn.getActionType().equals(TYPE_PACKAGES_AUTOUPDATE) ||
            actionIn.getActionType().equals(TYPE_PACKAGES_DELTA) ||
            actionIn.getActionType().equals(TYPE_PACKAGES_REFRESH_LIST) ||
            actionIn.getActionType().equals(TYPE_PACKAGES_REMOVE) ||
            actionIn.getActionType().equals(TYPE_PACKAGES_RUNTRANSACTION) ||
            actionIn.getActionType().equals(TYPE_PACKAGES_UPDATE) ||
            actionIn.getActionType().equals(TYPE_PACKAGES_VERIFY)) {
            
            PackageAction action = (PackageAction) actionIn;
            Set details = action.getDetails();           
            Iterator ditr = details.iterator();
            while (ditr.hasNext()) {
                PackageActionDetails detail = (PackageActionDetails) ditr.next();
                PackageEvr evr = detail.getEvr();

                // It is possible to have a Package Action with only a package name
                if (evr != null) {
                    //commit each packageEvr
                    PackageEvr newEvr = PackageEvrFactory.save(evr);
                    detail.setEvr(newEvr);
                }
            }
        }
        singleton.saveObject(actionIn);
    }
    
    /**
     * Remove a Action from the DB
     * @param actionIn Action to be removed from database.
     */
    public static void remove(Action actionIn) {
        singleton.removeObject(actionIn);
    }

    /**
     * Check the ActionType against the ActionArchType to see 
     * 
     * @param actionCheck the Action we want to see if the type matches against
     * @param actionStyle the String type we want to check
     * @return boolean if the passed in Action matches the actionStyle from 
     *         the set of ActionArchTypes
     */
    public static boolean checkActionArchType(Action actionCheck, String actionStyle) {
        Iterator i = actionArchTypes.iterator();
        while (i.hasNext()) {
            ActionArchType at = (ActionArchType) i.next();
            if (at.getActionType().equals(actionCheck.getActionType()) && 
                    at.getActionStyle().equals(actionStyle)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Recursively query the hierarchy of actions dependent on a given 
     * parent. While recursive, only one query is executed per level in
     * the hierarchy, and action hierarchies tend to not be more than
     * two levels deep.
     *  
     * @param parentAction Parent action. 
     * @return Set of actions dependent on the given parent.
     */
    public static Set lookupDependentActions(Action parentAction) {
        Session session = HibernateFactory.getSession();
        
        Set returnSet = new HashSet();
        List actionsAtHierarchyLevel = new LinkedList();
        actionsAtHierarchyLevel.add(parentAction.getId());
        do {
            Query findDependentActions = session.getNamedQuery(
                    "Action.findDependentActions");
            findDependentActions.setParameterList("action_ids", actionsAtHierarchyLevel);
            List results = findDependentActions.list();
            returnSet.addAll(results);
            // Reset list of actions for the next hierarchy level:
            actionsAtHierarchyLevel = new LinkedList();
            for (Iterator i = results.iterator(); i.hasNext();) {
                actionsAtHierarchyLevel.add(((Action)i.next()).getId());
            }
        }
        while (actionsAtHierarchyLevel.size() > 0);
        
        return returnSet;
    }
    
    /**
     * Delete the server actions associated with the given set of parent actions.
     * @param parentActions Set of parent actions.
     */
    public static void deleteServerActionsByParent(Set parentActions) {
        Session session = HibernateFactory.getSession();
        
        Query serverActionsToDelete = 
            session.getNamedQuery("ServerAction.deleteByParentActions");
        serverActionsToDelete.setParameterList("actions", parentActions);
        serverActionsToDelete.executeUpdate();
    }
    /**
     * Lookup a List of Action objects for a given Server.
     * @param user the user doing the search
     * @param serverIn you want to limit the list of Actions to
     * @return List of Action objects
     */
    public static List listActionsForServer(User user, Server serverIn) {
        Map params = new HashMap();
        params.put("orgId", user.getOrg().getId());
        params.put("server", serverIn);
        return (List) singleton.listObjectsByNamedQuery(
                                        "Action.findByServerAndOrgId", params);
    }
    
    /**
     * Lookup a List of ServerAction objects for a given Server.
     * @param serverIn you want to limit the list of Actions to
     * @return List of ServerAction objects
     */
    public static List listServerActionsForServer(Server serverIn) {
        Map params = new HashMap();
        params.put("server", serverIn);
        return (List) singleton.listObjectsByNamedQuery(
                                        "ServerAction.findByServer", params);
    }
    
    /**
     * Reschedule All Failed Server Actions associated with an action
     * @param action the action who's server actions you are rescheduling
     * @param tries the number of tries to set (should be set to 5)
     */
    public static void rescheduleFailedServerActions(Action action, Long tries) {
        singleton.getSession().getNamedQuery("Action.rescheduleFailedActions")
                .setParameter("action", action)
                .setParameter("tries", tries)                
                .setParameter("failed", ActionFactory.STATUS_FAILED)
                .setParameter("queued", ActionFactory.STATUS_QUEUED).executeUpdate();
    }
    
    /**
     * Reschedule All Server Actions associated with an action
     * @param action the action who's server actions you are rescheduling
     * @param tries the number of tries to set (should be set to 5)
     */    
    public static void rescheduleAllServerActions(Action action, Long tries) {
        singleton.getSession().getNamedQuery("Action.rescheduleAllActions")
                .setParameter("action", action)
                .setParameter("tries", tries)
                .setParameter("queued", ActionFactory.STATUS_QUEUED).executeUpdate();
    }
    
    
    /**
    * The constant representing the Action Status QUEUED
    */
    public static final ActionStatus STATUS_QUEUED = 
            lookupActionStatusByName("Queued");
    /**
    * The constant representing the Action Status COMPLETED
    */
    public static final ActionStatus STATUS_COMPLETED = 
            lookupActionStatusByName("Completed");
    
    /**
    * The constant representing the Action Status FAILED
    */
    public static final ActionStatus STATUS_FAILED = 
            lookupActionStatusByName("Failed");

    /**
     * The constant representing Package Refresh List action.  [ID:1]
     */
    public static final ActionType TYPE_PACKAGES_REFRESH_LIST = 
            lookupActionTypeByLabel("packages.refresh_list");

    /**
     * The constant representing Hardware Refreshlist action.  [ID:2]
     */
    public static final ActionType TYPE_HARDWARE_REFRESH_LIST = 
            lookupActionTypeByLabel("hardware.refresh_list");

    /**
     * The constant representing Package Update action.  [ID:3]
     */
    public static final ActionType TYPE_PACKAGES_UPDATE = 
            lookupActionTypeByLabel("packages.update");

    /**
     * The constant representing Package Remove action.  [ID:4]
     */
    public static final ActionType TYPE_PACKAGES_REMOVE = 
            lookupActionTypeByLabel("packages.remove");
    
    /**
     * The constant representing Errata action.  [ID:5]
     */
    public static final ActionType TYPE_ERRATA = 
            lookupActionTypeByLabel("errata.update");
    
    /**
     * The constant representing RHN Get server up2date config action. [ID:6]
     */
    public static final ActionType TYPE_UP2DATE_CONFIG_GET = 
            lookupActionTypeByLabel("up2date_config.get");

    /**
     * The constant representing RHN Update server up2date config action.  [ID:7]
     */
    public static final ActionType TYPE_UP2DATE_CONFIG_UPDATE = 
            lookupActionTypeByLabel("up2date_config.update");
    
    /**
     * The constant representing Package Delta action.  [ID:8]
     */
    public static final ActionType TYPE_PACKAGES_DELTA = 
            lookupActionTypeByLabel("packages.delta");

    /**
     * The constant representing Reboot action.  [ID:9]
     */
    public static final ActionType TYPE_REBOOT = 
            lookupActionTypeByLabel("reboot.reboot");
    
    /**
     * The constant representing Rollback Config action.  [ID:10]
     */
    public static final ActionType TYPE_ROLLBACK_CONFIG = 
            lookupActionTypeByLabel("rollback.config");

    /**
     * The constant representing "Refresh server-side transaction list"  [ID:11]
     */
    public static final ActionType TYPE_ROLLBACK_LISTTRANSACTIONS = 
            lookupActionTypeByLabel("rollback.listTransactions");

    /**
     * The constant representing "Automatic package installation".  [ID:13]
     */
    public static final ActionType TYPE_PACKAGES_AUTOUPDATE = 
            lookupActionTypeByLabel("packages.autoupdate");

    /**
     * The constant representing "Package Synchronization".  [ID:14]
     */
    public static final ActionType TYPE_PACKAGES_RUNTRANSACTION = 
            lookupActionTypeByLabel("packages.runTransaction");
        
    
    /**
     * The constant representing "Import config file data from system".  [ID:15]
     */
    public static final ActionType TYPE_CONFIGFILES_UPLOAD = 
            lookupActionTypeByLabel("configfiles.upload");

    /**
     * The constant representing "Deploy config files to system".  [ID:16]
     */
    public static final ActionType TYPE_CONFIGFILES_DEPLOY = 
            lookupActionTypeByLabel("configfiles.deploy");

    /**
     * The constant representing "Verify deployed config files" [ID:17]
     */
    public static final ActionType TYPE_CONFIGFILES_VERIFY = 
            lookupActionTypeByLabel("configfiles.verify");

    /**
     * The constant representing 
     * "Show differences between profiled config files and deployed config files"  [ID:18]
     */
    public static final ActionType TYPE_CONFIGFILES_DIFF = 
            lookupActionTypeByLabel("configfiles.diff");
    
    /**
     * The constant representing "Initiate a kickstart".  [ID:19]
     */
    public static final ActionType TYPE_KICKSTART_INITIATE = 
            lookupActionTypeByLabel("kickstart.initiate");
    

    /**
     * The constant representing "Initiate a kickstart for a guest".
     */
    public static final ActionType TYPE_KICKSTART_INITIATE_GUEST = 
            lookupActionTypeByLabel("kickstart_guest.initiate");
    
    /**
     * The constant representing "Schedule a package sync for kickstarts".  [ID:20]
     */
    public static final ActionType TYPE_KICKSTART_SCHEDULE_SYNC = 
            lookupActionTypeByLabel("kickstart.schedule_sync");
    
    /**
     * The constant representing "Schedule a package install for activation key".  [ID:21]
     */
    public static final ActionType TYPE_ACTIVATION_SCHEDULE_PKG_INSTALL = 
            lookupActionTypeByLabel("activation.schedule_pkg_install");

    /**
     * The constant representing "Schedule a config deploy for activation key"  [ID:22]
     */
    public static final ActionType TYPE_ACTIVATION_SCHEDULE_DEPLOY = 
            lookupActionTypeByLabel("activation.schedule_deploy");

    /**
     * The constant representing 
     * "Upload config file data based upon mtime to server" [ID:23]
     */
    public static final ActionType TYPE_CONFIGFILES_MTIME_UPLOAD = 
            lookupActionTypeByLabel("configfiles.mtime_upload");

    /**
     * The constant representing "Solaris Package Install" [ID:24]
     */
    public static final ActionType TYPE_SOLARISPKGS_INSTALL = 
            lookupActionTypeByLabel("solarispkgs.install");

    /**
     * The constant representing "Solaris Package Removal". [ID:25]
     */
    public static final ActionType TYPE_SOLARISPKGS_REMOVE = 
            lookupActionTypeByLabel("solarispkgs.remove");

    /**
     * The constant representing "Solaris Patch Install" [ID:26]
     */
    public static final ActionType TYPE_SOLARISPKGS_PATCHINSTALL = 
            lookupActionTypeByLabel("solarispkgs.patchInstall");

    /**
     * The constant representing "Solaris Patch Removal" [ID:27]
     */
    public static final ActionType TYPE_SOLARISPKGS_PATCHREMOVE = 
            lookupActionTypeByLabel("solarispkgs.patchRemove");

    /**
     * The constant representing "Solaris Patch Cluster Install" [ID:28]
     */
    public static final ActionType TYPE_SOLARISPKGS_PATCHCLUSTERINSTALL = 
            lookupActionTypeByLabel("solarispkgs.patchClusterInstall");

    /**
     * The constant representing "Solaris Patch Cluster Removal" [ID:29]
     */
    public static final ActionType TYPE_SOLARISPKGS_PATCHCLUSTERREMOVE = 
            lookupActionTypeByLabel("solarispkgs.patchClusterRemove");

    /**
     * The constant representing "Run an arbitrary script".  [ID:30]
     */
    public static final ActionType TYPE_SCRIPT_RUN = 
            lookupActionTypeByLabel("script.run");

    /**
     * The constant representing "Solaris Package List Refresh". [ID:31]
     */
    public static final ActionType TYPE_SOLARISPKGS_REFRESH_LIST = 
            lookupActionTypeByLabel("solarispkgs.refresh_list");
    
    /**
     * The constant representing "RHN Daemon Configuration".  [ID:32]
     */
    public static final ActionType TYPE_DAEMON_CONFIG = 
            lookupActionTypeByLabel("rhnsd.configure");
    
    /**
     * The constant representing "Verify deployed packages"  [ID:33]
     */
    public static final ActionType TYPE_PACKAGES_VERIFY = 
            lookupActionTypeByLabel("packages.verify");

    /**
     * The constant representing "Allows for rhn-applet use with an PRODUCTNAME"  [ID:34]
     */
    public static final ActionType TYPE_RHN_APPLET_USE_SATELLITE = 
            lookupActionTypeByLabel("rhn_applet.use_satellite");

    /**
     * The constant representing "Rollback a transaction".  [ID:197542]
     */
    public static final ActionType TYPE_ROLLBACK_ROLLBACK = 
            lookupActionTypeByLabel("rollback.rollback");

    /**
     * The constant representing "Shuts down a Xen domain."  [ID:36]
     */
    public static final ActionType TYPE_VIRTUALIZATION_SHUTDOWN = 
            lookupActionTypeByLabel("virt.shutdown");

    /**
     * The constant representing "Starts up a Xen domain."  [ID:37]
     */
    public static final ActionType TYPE_VIRTUALIZATION_START = 
            lookupActionTypeByLabel("virt.start");

    /**
     * The constant representing "Suspends a Xen domain."  [ID:38]
     */
    public static final ActionType TYPE_VIRTUALIZATION_SUSPEND = 
            lookupActionTypeByLabel("virt.suspend");
    
    /**
     * The constant representing "Resumes a Xen domain."  [ID:39]
     */
    public static final ActionType TYPE_VIRTUALIZATION_RESUME = 
            lookupActionTypeByLabel("virt.resume");

    /**
     * The constant representing "Reboots a Xen domain."  [ID:40]
     */
    public static final ActionType TYPE_VIRTUALIZATION_REBOOT = 
            lookupActionTypeByLabel("virt.reboot");
    
    /**
     * The constant representing "Destroys a Xen Domain."  [ID:41]
     */
    public static final ActionType TYPE_VIRTUALIZATION_DESTROY = 
            lookupActionTypeByLabel("virt.destroy");

    /**
     * The constant representing "Sets the maximum memory usage for a Xen domain." [ID:42]
     */
    public static final ActionType TYPE_VIRTUALIZATION_SET_MEMORY = 
            lookupActionTypeByLabel("virt.setMemory");

    /**
     * The constant representing "Sets the Vcpu usage for a Xen domain." [ID:48]
     */
    public static final ActionType TYPE_VIRTUALIZATION_SET_VCPUS = 
            lookupActionTypeByLabel("virt.setVCPUs");

    /**
     * The constant representing "Sets when the poller should run."  [ID:43]
     */
    public static final ActionType TYPE_VIRTUALIZATION_SCHEDULE_POLLER = 
            lookupActionTypeByLabel("virt.schedulePoller");

    /**
     * The constant representing "Schedule a package install of host specific
     * functionality."  [ID:44]
     */
    public static final ActionType TYPE_VIRTUALIZATION_HOST_PACKAGE_INSTALL = 
            lookupActionTypeByLabel("kickstart_host.schedule_virt_host_pkg_install"); 

    /**
     * The constant representing "Schedule a package install of guest specific
     * functionality."  [ID:45]
     */
    public static final ActionType TYPE_VIRTUALIZATION_GUEST_PACKAGE_INSTALL = 
            lookupActionTypeByLabel("kickstart_guest.schedule_virt_guest_pkg_install");
    
    /**
     * The constant representing "Subscribes a server to the RHN Tools channel 
     * associated with its base channel." [ID:46]
     */
    public static final ActionType TYPE_VIRTIZATION_HOST_SUBSCRIBE_TO_TOOLS_CHANNEL =
            lookupActionTypeByLabel("kickstart_host.add_tools_channel");
    
    /**
     * The constant represting "Subscribes a virtualization guest to the RHN Tools channel
     * associated with its base channel." [ID: 47]
     */
    public static final ActionType TYPE_VIRTUALIZATION_GUEST_SUBSCRIBE_TO_TOOLS_CHANNEL =
            lookupActionTypeByLabel("kickstart_guest.add_tools_channel");

    public static final String TXN_OPERATION_INSERT = "insert";
    public static final String TXN_OPERATION_DELETE = "delete";
    
}

