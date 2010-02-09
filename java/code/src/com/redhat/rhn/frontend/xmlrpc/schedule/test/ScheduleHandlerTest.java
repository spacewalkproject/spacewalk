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
package com.redhat.rhn.frontend.xmlrpc.schedule.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.xmlrpc.schedule.ScheduleHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.action.ActionManager;

import java.util.ArrayList;
import java.util.List;

public class ScheduleHandlerTest extends BaseHandlerTestCase {

    private ScheduleHandler handler = new ScheduleHandler();

    public void testCancelActions() throws Exception {

        // setup
        
        //obtain number of actions from action manager
        DataResult actions = ActionManager.allActions(admin, null);
        int numActions = actions.size();

        //compare against number retrieved from api... should be the same
        Object[] apiActions = handler.listAllActions(adminKey);
        assertEquals(numActions, apiActions.length);

        //add new actions and verify that the value returned by the api
        //has increased correctly
        Server server = ServerFactoryTest.createTestServer(admin, true);
        
        Action a1 = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction1 = ServerActionTest.createServerAction(server, a1);
        saction1.setStatus(ActionFactory.STATUS_COMPLETED);

        Action a2 = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction2 = ServerActionTest.createServerAction(server, a2);
        saction2.setStatus(ActionFactory.STATUS_QUEUED);
        
        Action a3 = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction3 = ServerActionTest.createServerAction(server, a3);
        saction3.setStatus(ActionFactory.STATUS_FAILED);

        apiActions = handler.listAllActions(adminKey);
        assertEquals(numActions + 3, apiActions.length);

        // execute
        List<Integer> actionIds = new ArrayList<Integer>();
        actionIds.add(a1.getId().intValue());
        actionIds.add(a3.getId().intValue());
        int result = handler.cancelActions(adminKey, actionIds);

        // verify
        assertEquals(1, result);
        apiActions = handler.listAllActions(adminKey);
        assertEquals(numActions + 1, apiActions.length);
    }

    public void testListAllActions() throws Exception {

        // setup
        //obtain number of actions from action manager
        DataResult actions = ActionManager.allActions(admin, null);
        int numActions = actions.size();

        //compare against number retrieved from api... should be the same
        Object[] apiActions = handler.listAllActions(adminKey);
        assertEquals(numActions, apiActions.length);

        //add new actions and verify that the value returned by the api
        //has increased correctly
        Server server = ServerFactoryTest.createTestServer(admin, true);
        
        Action a1 = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction1 = ServerActionTest.createServerAction(server, a1);
        saction1.setStatus(ActionFactory.STATUS_COMPLETED);

        Action a2 = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction2 = ServerActionTest.createServerAction(server, a2);
        saction2.setStatus(ActionFactory.STATUS_QUEUED);
        
        Action a3 = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction3 = ServerActionTest.createServerAction(server, a3);
        saction3.setStatus(ActionFactory.STATUS_FAILED);
        
        // execute 
        apiActions = handler.listAllActions(adminKey);

        // verify
        assertEquals(numActions + 3, apiActions.length);
    }
    
    public void testListCompletedActions() throws Exception {

        //obtain number of actions from action manager
        DataResult actions = ActionManager.completedActions(admin, null);
        int numActions = actions.size();

        //compare against number retrieved from api... should be the same
        Object[] apiActions = handler.listCompletedActions(adminKey);
        
        assertEquals(numActions, apiActions.length);

        //add a new action and verify that the value returned by the api
        //has increased
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Action a = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction = ServerActionTest.createServerAction(server, a);
        saction.setStatus(ActionFactory.STATUS_COMPLETED);

        apiActions = handler.listCompletedActions(adminKey);

        assertTrue(apiActions.length > numActions);
    }

    public void testListInProgressActions() throws Exception {
        //obtain number of actions from action manager
        DataResult actions = ActionManager.pendingActions(admin, null);
        int numActions = actions.size();

        //compare against number retrieved from api... should be the same
        Object[] apiActions = handler.listInProgressActions(adminKey);
        
        assertEquals(numActions, apiActions.length);

        //add a new action and verify that the value returned by the api
        //has increased
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Action a = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction = ServerActionTest.createServerAction(server, a);
        saction.setStatus(ActionFactory.STATUS_QUEUED);

        apiActions = handler.listInProgressActions(adminKey);

        assertTrue(apiActions.length > numActions);
    }

    public void testListFailedActions() throws Exception {
        //obtain number of actions from action manager
        DataResult actions = ActionManager.failedActions(admin, null);
        int numActions = actions.size();

        //compare against number retrieved from api... should be the same
        Object[] apiActions = handler.listFailedActions(adminKey);
        
        assertEquals(numActions, apiActions.length);

        //add a new action and verify that the value returned by the api
        //has increased
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Action a = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction = ServerActionTest.createServerAction(server, a);
        saction.setStatus(ActionFactory.STATUS_FAILED);

        apiActions = handler.listFailedActions(adminKey);

        assertTrue(apiActions.length > numActions);
    }

    public void testListArchivedActions() throws Exception {
        //obtain number of actions from action manager
        DataResult actions = ActionManager.archivedActions(admin, null);
        int numActions = actions.size();

        //compare against number retrieved from api... should be the same
        Object[] apiActions = handler.listArchivedActions(adminKey);
        
        assertEquals(numActions, apiActions.length);

        //add a new action and verify that the value returned by the api
        //has increased
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Action a = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        a.setArchived(new Long(1));
        ServerAction saction = ServerActionTest.createServerAction(server, a);
        saction.setStatus(ActionFactory.STATUS_QUEUED);

        apiActions = handler.listArchivedActions(adminKey);

        assertTrue(apiActions.length > numActions);       
    }

    public void testListCompletedSystems() throws Exception {
        //create a new action 
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Action action = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction = ServerActionTest.createServerAction(server, action);
        saction.setStatus(ActionFactory.STATUS_COMPLETED);
        
        //obtain number of systems from action manager
        DataResult systems = ActionManager.completedSystems(admin, action, null);
        int numSystems = systems.size();

        //compare against number retrieved from api... should be the same
        Object[] apiSystems = handler.listCompletedSystems(adminKey, 
            action.getId().intValue());
        
        assertTrue(apiSystems.length > 0);
        assertEquals(numSystems, apiSystems.length);
    }

    public void testListInProgressSystems() throws Exception {
        //create a new action 
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Action action = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction = ServerActionTest.createServerAction(server, action);
        saction.setStatus(ActionFactory.STATUS_QUEUED);
        
        //obtain number of systems from action manager
        DataResult systems = ActionManager.inProgressSystems(admin, action, null);
        int numSystems = systems.size();

        //compare against number retrieved from api... should be the same
        Object[] apiSystems = handler.listInProgressSystems(adminKey, 
            action.getId().intValue());
        
        assertTrue(apiSystems.length > 0);
        assertEquals(numSystems, apiSystems.length);
    }

    public void testListFailedSystems() throws Exception {
        //create a new action 
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Action action = ActionFactoryTest.createAction(admin, 
                ActionFactory.TYPE_PACKAGES_UPDATE);
        ServerAction saction = ServerActionTest.createServerAction(server, action);
        saction.setStatus(ActionFactory.STATUS_FAILED);
        
        //obtain number of systems from action manager
        DataResult systems = ActionManager.failedSystems(admin, action, null);
        int numSystems = systems.size();

        //compare against number retrieved from api... should be the same
        Object[] apiSystems = handler.listFailedSystems(adminKey, 
            action.getId().intValue());
        
        assertTrue(apiSystems.length > 0);
        assertEquals(numSystems, apiSystems.length);
    }
}
