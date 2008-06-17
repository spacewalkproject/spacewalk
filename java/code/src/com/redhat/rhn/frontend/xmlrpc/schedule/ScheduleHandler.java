/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.action.ActionManager;

/**
 * ScheduleHandler
 * @version $Rev$
 * @xmlrpc.namespace schedule
 * @xmlrpc.doc Methods to retrieve information about actions scheduled 
 * within the Spacewalk
 */
public class ScheduleHandler extends BaseHandler {
   
    /**
     * List the scheduled actions that have succeeded.
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return Returns a list of actions with details
     * 
     * @xmlrpc.doc Returns a list of actions that have completed successfully.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listCompletedActions(String sessionKey) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used. 
        DataResult dr = ActionManager.completedActions(loggedInUser, null);
        return dr.toArray();
    }
    
    /**
     * List the scheduled actions that are in progress.
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return Returns a list of actions with details
     * 
     * @xmlrpc.doc Returns a list of actions that are in progress.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listInProgressActions(String sessionKey) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used. 
        DataResult dr = ActionManager.pendingActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the scheduled actions that have failed.
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return Returns a list of actions with details
     * 
     * @xmlrpc.doc Returns a list of actions that have failed.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listFailedActions(String sessionKey) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.        
        DataResult dr = ActionManager.failedActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the scheduled actions that have been archived.
     * @param sessionKey The sessionkey for the session containing the logged in user.
     * @return Returns a list of actions with details
     * 
     * @xmlrpc.doc Returns a list of actions that have been archived.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     * #array()
     *   $ScheduleActionSerializer
     * #array_end()
     */
    public Object[] listArchivedActions(String sessionKey) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
        // the second argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.        
        DataResult dr = ActionManager.archivedActions(loggedInUser, null);
        return dr.toArray();
    }

    /**
     * List the systems that have completed a specific action.
     * @param sessionKey The sessionkey for the session containing the logged in user.
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
    public Object[] listCompletedSystems(String sessionKey, Integer actionId) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
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
     * @param sessionKey The sessionkey for the session containing the logged in user.
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
    public Object[] listInProgressSystems(String sessionKey, Integer actionId) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
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
     * @param sessionKey The sessionkey for the session containing the logged in user.
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
    public Object[] listFailedSystems(String sessionKey, Integer actionId) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        
        Long aid = actionId.longValue();
        Action action = ActionManager.lookupAction(loggedInUser, aid);
        // the third argument is "PageControl". This is not needed for the api usage;
        // therefore, null will be used.
        DataResult dr = ActionManager.failedSystems(loggedInUser, action, null); 
        dr.elaborate();
        return dr.toArray();
    }
}
