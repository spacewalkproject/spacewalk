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
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.schedule.InProgressSystemsAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * InProgressSystemsActionTest
 * @version $Rev$
 */
public class InProgressSystemsActionTest extends RhnBaseTestCase {

    public void testSelectAll() throws Exception {
        InProgressSystemsAction action = new InProgressSystemsAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupProcessPagination();

        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);

        Action a = ActionFactoryTest.createAction(user,
                ActionFactory.TYPE_HARDWARE_REFRESH_LIST);

        for (int i = 0; i < 4;  i++) {
            Server server = ServerFactoryTest.createTestServer(user, true);
            ServerActionTest.createServerAction(server, a);
        }

        ah.getRequest().setupAddParameter("aid", a.getId().toString());
        ah.getRequest().setupAddParameter("aid", a.getId().toString()); //stupid mock
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        ah.executeAction("selectall");

        RhnSetActionTest.verifyRhnSetData(user.getId(), "unscheduleaction", 4);
    }

}
