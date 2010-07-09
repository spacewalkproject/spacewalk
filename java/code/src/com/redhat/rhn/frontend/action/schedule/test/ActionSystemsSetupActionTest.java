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

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.action.schedule.ActionSystemsSetupAction;
import com.redhat.rhn.frontend.action.schedule.InProgressSystemsSetupAction;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * ActionSystemsSetupActionTest
 * @version $Rev$
 */
public class ActionSystemsSetupActionTest extends RhnBaseTestCase {

    public void testPeformExecute() throws Exception {
        ActionSystemsSetupAction action = new InProgressSystemsSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        sah.getRequest().setupAddParameter("aid", (String)null);
        try {
            sah.executeAction();
            fail();
        }
        catch (BadParameterException e) {
            //no op
        }

        sah.getRequest().setupAddParameter("aid", "-99999");
        try {
            sah.executeAction();
            fail();
        }
        catch (LookupException e) {
            //no op
        }

        sah.getUser().addRole(RoleFactory.ORG_ADMIN);
        Action a = ActionFactoryTest.createAction(sah.getUser(),
                ActionFactory.TYPE_CONFIGFILES_DEPLOY);
        Server server = ServerFactoryTest.createTestServer(sah.getUser(), true);
        ServerActionTest.createServerAction(server, a);
        ActionManager.storeAction(a);

        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("aid", a.getId().toString());
        sah.getRequest().setupAddParameter("filter_string", "");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);

        sah.executeAction();
        assertNotNull(sah.getRequest().getAttribute("pageList"));
        assertNotNull(sah.getRequest().getAttribute("user"));
        assertNotNull(sah.getRequest().getAttribute("action"));
        assertNotNull(sah.getRequest().getAttribute("actionname"));
        assertNotNull(sah.getRequest().getAttribute("newset"));
        assertNotNull(sah.getRequest().getAttribute("set"));
    }

}
