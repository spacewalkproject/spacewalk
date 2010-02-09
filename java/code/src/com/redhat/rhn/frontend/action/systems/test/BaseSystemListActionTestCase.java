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
package com.redhat.rhn.frontend.action.systems.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.systems.BaseSystemListAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * BaseSystemListActionTest
 * @version $Rev$
 */
public abstract class BaseSystemListActionTestCase extends RhnBaseTestCase {

    public void testAddOne() throws Exception {
        BaseSystemListAction action = createAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupProcessPagination();
        
        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        // Create a server that can be put in the set. Note that the
        // server is not set up entirely right for subclasses, which would
        // only display servers with certain attributes, e.g. a satellite.
        // But this test is only concerned with keeping a server in the set
        // w/o having it cleaned up by the set cleaner
        Server server = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        UserManager.storeUser(user);
        String sid = server.getId().toString();
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", new String[] { sid });
        ah.executeAction("updatelist");
        
        RhnSetActionTest.verifyRhnSetData(ah.getUser(), RhnSetDecl.SYSTEMS, 1);
    }

    public void testSelectAll() throws Exception {
        BaseSystemListAction action = createAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupProcessPagination();
        
        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(user);
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[]) null);
        ah.executeAction("selectall");
        // This test only ensures that 'Select All' doesn't blow up.
        // To really test that something got selected, we would have to create an
        // appropriate system for each of the subclasses. The fact that the set cleaner
        // doesn't clean servers that should stay in the set is already tested by 
        // testAddOne()
    }
    
    protected abstract BaseSystemListAction createAction();
}
