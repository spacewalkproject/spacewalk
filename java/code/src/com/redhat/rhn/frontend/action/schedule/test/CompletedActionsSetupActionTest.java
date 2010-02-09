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
package com.redhat.rhn.frontend.action.schedule.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * CompletedActionsSetupActionTest
 * @version $Rev$
 */
public class CompletedActionsSetupActionTest extends RhnMockStrutsTestCase {

    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/schedule/CompletedActions");
    }




    public void testPerformExecute() throws Exception {


        actionPerform();
        verifyForwardPath("/WEB-INF/pages/schedule/completedactions.jsp");
        Object test = request.getAttribute("dataset");
        assertNotNull(test);

    }

    public void testPerformSubmit() throws Exception {



        Server server = ServerFactoryTest.createTestServer(user);

        Action act = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ServerAction sAction = ActionFactoryTest.createServerAction(server, act);
        sAction.setStatus(ActionFactory.STATUS_COMPLETED);
        TestUtils.saveAndFlush(sAction);


        RhnSet set = RhnSetDecl.ACTIONS_COMPLETED.get(user);
        set.addElement(act.getId());
        RhnSetManager.store(set);

        request.addParameter(RhnAction.SUBMITTED, "true");
        request.addParameter("dispatch", "Archive Errata");
        actionPerform();
        verifyActionMessage("message.actionArchived");
        verifyForwardPath("/schedule/CompletedActions.do");


    }

}
