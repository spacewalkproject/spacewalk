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
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * PackageListSetupActionTest
 * @version $Rev$
 */
public class PackageListSetupActionTest extends RhnMockStrutsTestCase {
    
    public void testPeformExecute() throws Exception {
        
        setRequestPathInfo("/schedule/PackageList");

        user.addRole(RoleFactory.ORG_ADMIN);
        Action a = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        Server server = ServerFactoryTest.createTestServer(user, true);
        ServerActionTest.createServerAction(server, a);
        ActionManager.storeAction(a);
        addRequestParameter("aid", a.getId().toString());
        addRequestParameter("newset", (String)null);
        addRequestParameter("returnvisit", (String) null);
        actionPerform();
        assertNotNull(getRequest().getAttribute("dataset"));
        assertNotNull(getRequest().getAttribute("actionname"));
    }
        
   public void testPerformExecuteBad() {
       setRequestPathInfo("/schedule/PackageList");
        
        addRequestParameter("aid", (String) null);
        actionPerform();
        assertTrue(getActualForward().contains("errors/badparam.jsp"));
   }
   
   
   public void testPerformExecuteBad2() {
        setRequestPathInfo("/schedule/PackageList");
        addRequestParameter("aid", "-99999");
        actionPerform();
        assertTrue(getActualForward().contains("errors/lookup.jsp"));
    }

}
