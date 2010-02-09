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
package com.redhat.rhn.frontend.action.user.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.user.VisibleSystemsListAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.Action;

/**
 * VisibleSystemsListActionTest
 * @version $Rev$
 */
public class VisibleSystemsListActionTest extends RhnBaseTestCase {

    public void testSelectAll() throws Exception {
        Action action = new VisibleSystemsListAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupClampListBounds();

        
        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        TestUtils.saveAndFlush(user);
        ServerFactoryTest.createTestServer(user, true, 
                        ServerConstants.getServerGroupTypeEnterpriseEntitled());
        
        ah.getRequest().setupAddParameter("newset", (String[]) null);
        ah.getRequest().setupAddParameter("items_on_page", (String[]) null);
        ah.getRequest().setupAddParameter("items_selected", (String[]) null);
        ah.getRequest().setupAddParameter("uid", user.getId().toString());
        
        RhnSetDecl.SYSTEMS.clear(user);
        assertTrue(0 == RhnSetDecl.SYSTEMS.get(user).size());
        ah.executeAction("selectall");
        assertTrue(0 < RhnSetDecl.SYSTEMS.get(user).size());
    }
}
