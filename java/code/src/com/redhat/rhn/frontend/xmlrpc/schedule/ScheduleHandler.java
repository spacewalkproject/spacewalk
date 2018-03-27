/**
 * Copyright (c) 2009--2018 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.schedule;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.action.ActionIsChildException;
import com.redhat.rhn.manager.action.ActionIsPickedUpException;
import com.redhat.rhn.manager.action.ActionManager;

import java.util.ArrayList;
import java.util.List;

/**
 * ScheduleHandler
 * @version $Rev$
 * @xmlrpc.namespace schedule
 * @xmlrpc.doc Methods to retrieve information about scheduled actions.
 */
public class ScheduleHandler extends BaseHandler {

    /**
     * Cancel all actions in given list. If an invalid action is provided, none of the
     * actions given will canceled.
     * @param loggedInUser The current user
     * @param actionIds The list of ids for actions to cancel.
     * @return Returns a list of actions with details
     * @throws ActionIsChildException Thrown when attempting to cancel action with
     * prerequisites
     * @throws LookupException Invalid Action ID provided
     *
     * @xmlrpc.doc Cancel all actions in given list. If an invalid action is provided,
     * none of the actions given will canceled.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #array_single("int", "action id")
     * @xmlrpc.returntype #return_int_success()
     */
    public int cancelActions(User loggedInUser, List<Integer> actionIds) throws
            ActionIsChildException, LookupException {
        List actions = new ArrayList<Action>();
        for (Integer actionId : actionIds) {
            Action action = ActionManager.lookupAction(loggedInUser, new Long(actionId));
            for (ServerAction sa : action.getServerActions()) {
                if (ActionFactory.STATUS_PICKEDUP.equals(sa.getStatus())) {
                    throw new ActionIsPickedUpException("Cannot cancel actions in " +
                            "PICKED UP state, aborting...");
                }
            }
            if (action != null) {
                actions.add(action);
            }
        }
        ActionManager.cancelActions(loggedInUser, actions);
        return 1;
    }

    /**
     * Fail specific event on specified system
     * @param loggedInUser The current user
     * @param serverId server id
     * @param actionId action id
     * @return int 1 if successfull
     *
     * @xmlrpc.doc Fail specific event on specified system
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("int", "actionId")
     * @xmlrpc.returntype #return_int_success()
     */

    public int failSystemAction(User loggedInUser, Integer serverId, Integer actionId) {
        return failSystemAction(loggedInUser, serverId, actionId,
                "This action has been manually failed by " + loggedInUser.getLogin());
    }

    /**
     * Fail specific event on specified system and let the user provide
     * some info for this fail.
     * @param loggedInUser The current user
     * @param serverId server id
     * @param actionId action id
     * @param message some info about this fail
     * @return int 1 if successfull
     *
     *
     * @xmlrpc.doc Fail specific event on specified system
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("int", "actionId")
     * @xmlrpc.param #param("string", "message")
     * @xmlrpc.returntype #return_int_success()
     */
    public int failSystemAction(User loggedInUser, Integer serverId, Integer actionId,
                                 String message) {
        return ActionManager.failSystemAction(loggedInUser, serverId.longValue(),
                actionId.longValue(), message);
    }

    /**
     * List all scheduled actions regardless of status.  This includes pending,
     * completed, failed and archived.
     * @param loggedInUser The current user
     * @return Returns a list of actions with details
     *
     * @xmlrpc.doc Returns a list of all actions.  This includes completed, in progress,
     * failed and archived actions.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listAllActions(User loggedInUser) {

        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.allActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the scheduled actions that have succeeded.
     * @param loggedInUser The current user
     * @return Returns a list of actions with details
     *
     * @xmlrpc.doc Returns a list of actions that have completed successfully.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listCompletedActions(User loggedInUser) {
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.completedActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the scheduled actions that are in progress.
     * @param loggedInUser The current user
     * @return Returns a list of actions with details
     *
     * @xmlrpc.doc Returns a list of actions that are in progress.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listInProgressActions(User loggedInUser) {
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.pendingActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the scheduled actions that have failed.
     * @param loggedInUser The current user
     * @return Returns a list of actions with details
     *
     * @xmlrpc.doc Returns a list of actions that have failed.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listFailedActions(User loggedInUser) {
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.failedActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the scheduled actions that have been archived.
     * @param loggedInUser The current user
     * @return Returns a list of actions with details
     *
     * @xmlrpc.doc Returns a list of actions that have been archived.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listArchivedActions(User loggedInUser) {
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.archivedActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the systems that have completed a specific action.
     * @param loggedInUser The current user
     * @param actionId The id of the action.
     * @return Returns a list of systems along with details
     *
     * @xmlrpc.doc Returns a list of systems that have completed a specific action.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "actionId")
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleSystemSerializer
     * #array_end()
     */
    public Object[] listCompletedSystems(User loggedInUser, Integer actionId) {
        Long aid = actionId.longValue();
        Action action = ActionManager.lookupAction(loggedInUser, aid);
        // the third argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.completedSystems(loggedInUser, action, null);
        dr.elaborate();

        return dr.toArray();
    }

    /**
     * List the systems that have a specific action in progress.
     * @param loggedInUser The current user
     * @param actionId The id of the action.
     * @return Returns a list of systems along with details
     *
     * @xmlrpc.doc Returns a list of systems that have a specific action in progress.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "actionId")
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleSystemSerializer
     * #array_end()
     */
    public Object[] listInProgressSystems(User loggedInUser, Integer actionId) {
        Long aid = actionId.longValue();
        Action action = ActionManager.lookupAction(loggedInUser, aid);
        // the third argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.inProgressSystems(loggedInUser, action, null);
        dr.elaborate();

        return dr.toArray();
    }

    /**
     * List the systems that have failed a specific action.
     * @param loggedInUser The current user
     * @param actionId The id of the action.
     * @return Returns a list of systems along with details
     *
     * @xmlrpc.doc Returns a list of systems that have failed a specific action.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "actionId")
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleSystemSerializer
     * #array_end()
     */
    public Object[] listFailedSystems(User loggedInUser, Integer actionId) {
        Long aid = actionId.longValue();
        Action action = ActionManager.lookupAction(loggedInUser, aid);
        // the third argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.failedSystems(loggedInUser, action, null);
        dr.elaborate();
        return dr.toArray();
    }

    /**
     * Reschedule all actions in the given list.
     * @param loggedInUser The current user
     * @param actionIds The list of ids for actions to reschedule.
     * @param onlyFailed only reschedule failed actions
     * @return Returns a list of actions with details
     * @throws FaultException A FaultException is thrown if one of the actions provided
     * is invalid.
     *
     * @xmlrpc.doc Reschedule all actions in the given list.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #array_single("int", "action id")
     * @xmlrpc.param #param_desc("boolean", "onlyFailed",
     *               "True to only reschedule failed actions, False to reschedule all")
     * @xmlrpc.returntype #return_int_success()
     */
    public int rescheduleActions(User loggedInUser, List<Integer> actionIds,
            boolean onlyFailed) throws FaultException {
        for (Integer actionId : actionIds) {
            Action action = ActionManager.lookupAction(loggedInUser, new Long(actionId));
            if (action != null) {
                ActionManager.rescheduleAction(action, onlyFailed);
            }
        }

        return 1;
    }

    /**
     * Archive all actions in the given list.
     * @param loggedInUser The current user
     * @param actionIds The list of ids for actions to archive.
     * @return Returns a integer 1 on success
     * @throws FaultException A FaultException is thrown if one of the actions provided
     * is invalid.
     *
     * @xmlrpc.doc Archive all actions in the given list.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #array_single("int", "action id")
     * @xmlrpc.returntype #return_int_success()
     */
    public int archiveActions(User loggedInUser, List<Integer> actionIds)
            throws FaultException {
        for (Integer actionId : actionIds) {
            Action action = ActionManager.lookupAction(loggedInUser, new Long(actionId));
            if (action != null) {
                action.setArchived(new Long(1));
            }
        }
        return 1;
    }

    /**
     * Delete all archived actions in the given list.
     * @param loggedInUser The current user
     * @param actionIds The list of ids for actions to delete.
     * @return Returns a integer 1 on success
     * @throws FaultException In case of an error
     *
     * @xmlrpc.doc Delete all archived actions in the given list.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #array_single("int", "action id")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteActions(User loggedInUser, List<Integer> actionIds) {
        ActionManager.deleteActionsById(loggedInUser, actionIds);
        return 1;
    }
}


