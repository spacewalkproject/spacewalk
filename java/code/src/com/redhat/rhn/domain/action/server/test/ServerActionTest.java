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
package com.redhat.rhn.domain.action.server.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * ServerActionTest
 * @version $Rev$
 */
public class ServerActionTest extends RhnBaseTestCase {
    
    public void testEquals() {
        ServerAction sa = new ServerAction();
        ServerAction sa2 = null;
        assertFalse(sa.equals(sa2));
        
        sa2 = new ServerAction();
        assertTrue(sa.equals(sa2));
        
        Server one = ServerFactory.createServer();
        sa.setServer(one);
        assertFalse(sa.equals(sa2));
        assertFalse(sa2.equals(sa));
        
        sa2.setServer(ServerFactory.createServer());
        assertTrue(sa.equals(sa2));
        
        one.setName("foo");
        assertFalse(sa.equals(sa2));
        
        sa2.setServer(one);
        assertTrue(sa.equals(sa2));
        
        Action parent = new Action();
        parent.setId(new Long(243));
        sa.setParentAction(parent);
        assertFalse(sa.equals(sa2));
        
        sa2.setParentAction(parent);
        assertTrue(sa.equals(sa2));
    }
    
    public void testCreate() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Action parent = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ServerAction child = createServerAction(ServerFactoryTest
                .createTestServer(user), parent);
        
        parent.addServerAction(child);
        ActionFactory.save(parent);

        assertNotNull(parent.getId());
        assertTrue(child.getParentAction().equals(parent));
        assertNotNull(parent.getServerActions());
        assertNotNull(parent.getServerActions().toArray()[0]);
        assertTrue(child.equals(parent.getServerActions().toArray()[0]));
    }
    
    /**
     * Test fetching a ServerAction
     * @throws Exception
     */
    public void testLookupServerAction() throws Exception {
        Action newA = ActionFactoryTest.createAction(UserTestUtils.createUser("testUser", 
                UserTestUtils.createOrg("testOrg")), ActionFactory.TYPE_REBOOT);
        Long id = newA.getId();
        Action a = ActionFactory.lookupById(id);
        assertNotNull(a);
        assertNotNull(a.getServerActions());
        ServerAction sa = (ServerAction) a.getServerActions().toArray()[0];
        assertNotNull(sa);
        assertNotNull(sa.getParentAction());
    }
    
    /**
     * Create a new ServerAction
     * @param newS
     * @param newA
     * @return ServerAction created
     * @throws Exception
     */
    public static ServerAction createServerAction(Server newS, Action newA) 
        throws Exception {
        ServerAction sa = new ServerAction();
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        sa.setRemainingTries(new Long(10));
        sa.setServer(newS);
        sa.setParentAction(newA);
        newA.addServerAction(sa);
        return sa;
    }
}
