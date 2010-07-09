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
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;


public class PendingActionsDeleteConfirmActionTest extends RhnMockStrutsTestCase {

    public void testConfirmDeleteActions() throws Exception {
        Action a = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        Server server = ServerFactoryTest.createTestServer(user, true);
        ServerAction saction = ServerActionTest.createServerAction(server, a);
        saction.setStatus(ActionFactory.STATUS_QUEUED);

        Action b = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ServerAction saction2 = ServerActionTest.createServerAction(server, b);
        saction2.setStatus(ActionFactory.STATUS_QUEUED);

        ActionFactory.save(a);
        ActionFactory.save(b);

        RhnSet set = RhnSetDecl.ACTIONS_PENDING.get(user);
        set.addElement(a.getId());
        set.addElement(b.getId());
        RhnSetManager.store(set);

        set = RhnSetDecl.ACTIONS_PENDING.get(user);
        addDispatchCall("actions.jsp.confirmcancelactions");
        setRequestPathInfo("/schedule/PendingActionsDeleteConfirm");
        actionPerform();
        verifyActionMessage("message.actionsCancelled");
    }


}
