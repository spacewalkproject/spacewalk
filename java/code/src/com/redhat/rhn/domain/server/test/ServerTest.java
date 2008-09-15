/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerInfo;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;


/**
 * ServerTest
 * @version $Rev$
 */
public class ServerTest extends RhnBaseTestCase {
    
    private class VirtEntitledServer extends Server {
        public VirtEntitledServer(User user) {
            setOrg(user.getOrg());
            ServerGroupManager manager = ServerGroupManager.getInstance();
            EntitlementServerGroup group = manager.
                        lookupEntitled(EntitlementManager.VIRTUALIZATION, user);
            List servers = new ArrayList();
            servers.add(this);
            manager.addServers(group, servers, user);
        }
    }
    
    private class ServerWithGuests extends Server {
        public ServerWithGuests() {
            VirtualInstance vi = new VirtualInstance();
            vi.setUuid(TestUtils.randomString());
            addGuest(vi);
        }
    }
    
    /**
     * @param arg0
     */
    public ServerTest(String arg0) {
        super(arg0);
    }

    public void testIsInactive() throws Exception {
        Server s = ServerFactory.createServer();
        s.setServerInfo(new ServerInfo());
        Calendar pcal = Calendar.getInstance();
        pcal.setTime(new Timestamp(System.currentTimeMillis()));
        pcal.roll(Calendar.MINUTE, -5);
        s.getServerInfo().setCheckin(pcal.getTime());
        assertFalse(s.isInactive());
    }

    
    public void testSetBaseEntitlement() throws Exception {
        Server s = ServerTestUtils.createTestSystem();
        SystemManager.removeAllServerEntitlements(s.getId());
        UserTestUtils.addManagement(s.getCreator().getOrg());
        s.setBaseEntitlement(EntitlementManager.MANAGEMENT);
        TestUtils.saveAndFlush(s);
        s = (Server) reload(s);
        assertTrue(s.getBaseEntitlement().equals(EntitlementManager.MANAGEMENT));
    }
    
    public void testIsEntitlementAllowed() throws Exception {
        User user = UserTestUtils.findNewUser();
        UserTestUtils.addMonitoring(user.getOrg());
        UserTestUtils.addProvisioning(user.getOrg());
        UserTestUtils.addVirtualizationPlatform(user.getOrg());
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest = 
            ((VirtualInstance) host.getGuests().iterator().next()).getGuestSystem();
        guest.setBaseEntitlement(EntitlementManager.MANAGEMENT);
        
        assertFalse(guest.isEntitlementAllowed(EntitlementManager.VIRTUALIZATION));
        assertFalse(guest.isEntitlementAllowed(EntitlementManager.VIRTUALIZATION_PLATFORM));
        assertTrue(guest.isEntitlementAllowed(EntitlementManager.PROVISIONING));
        
        assertTrue(host.isEntitlementAllowed(EntitlementManager.PROVISIONING));
        assertTrue(host.isEntitlementAllowed(EntitlementManager.VIRTUALIZATION_PLATFORM));
        
        assertNotNull(host.getValidAddonEntitlementsForServer());
        assertEquals(4, host.getValidAddonEntitlementsForServer().size());
        
    }
    
    public void xxxtestServerWithVirtEntitlementIsVirtualHost() {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = new VirtEntitledServer(user);
        server = (Server) TestUtils.saveAndReload(server);
        assertTrue(server.isVirtualHost());
    }
    
    public void xxtestServerWithGuestsIsVirtualHost() {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = new ServerWithGuests();
        server.setOrg(user.getOrg());
        
        assertTrue(server.isVirtualHost());
    }
}
