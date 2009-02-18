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
package com.redhat.rhn.frontend.action.schedule.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.schedule.CompletedActionsAction;
import com.redhat.rhn.frontend.action.schedule.ScheduledActionAction;

/**
 * CompletedActionsActionTest
 * @version $Rev$
 */
public class CompletedActionsActionTest extends ScheduledActionActionTestCase {

    protected ScheduledActionAction getAction() {
        return new CompletedActionsAction();
    }
    
    protected void createServerAction(User user, Action action) throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);
        ServerAction saction = ServerActionTest.createServerAction(server, action);
        saction.setStatus(ActionFactory.STATUS_COMPLETED);
        ActionFactory.save(action);
        
    }
    
    protected String getListName() {
        return "completed_action_list";
    }
    
}
