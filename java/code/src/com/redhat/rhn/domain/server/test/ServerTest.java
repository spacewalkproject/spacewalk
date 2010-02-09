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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerInfo;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;


/**
 * ServerTest
 * @version $Rev$
 */
public class ServerTest extends BaseTestCaseWithUser {
    
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
        Server s = ServerTestUtils.createTestSystem(user);
        SystemManager.removeAllServerEntitlements(s.getId());
        UserTestUtils.addManagement(s.getCreator().getOrg());
        s.setBaseEntitlement(EntitlementManager.MANAGEMENT);
        TestUtils.saveAndFlush(s);
        s = (Server) reload(s);
        assertTrue(s.getBaseEntitlement().equals(EntitlementManager.MANAGEMENT));
    }
    
    public void testIsEntitlementAllowed() throws Exception {
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
    
    public void testNetworkInterfaces() throws Exception {
        Server s = ServerTestUtils.createTestSystem(user);
        NetworkInterface device = NetworkInterfaceTest.createTestNetworkInterface(s);
        s = (Server) TestUtils.saveAndReload(s);
        Server s2 = ServerTestUtils.createTestSystem(user);
        s2 = (Server) TestUtils.saveAndReload(s2);
        NetworkInterfaceTest.createTestNetworkInterface(s2);
        TestUtils.saveAndReload(s2);
        assertTrue("we didnt make it to the end", true);
    }
    
    public void testGetIpAddress() throws Exception {
        Server s = ServerTestUtils.createTestSystem(user);
        s.setNetworkInterfaces(new HashSet());
        assertNull(s.getIpAddress());
            
        
        String hwAddr = "AA:AA:BB:BB:CC:CC";
        String ipAddr = "172.31.1.102";

        NetworkInterface aaa = NetworkInterfaceTest.createTestNetworkInterface(s, "aaa", 
                ipAddr, hwAddr);

        NetworkInterface bbb = NetworkInterfaceTest.createTestNetworkInterface(s, "bbb", 
                ipAddr, hwAddr);

        NetworkInterface zzz = NetworkInterfaceTest.createTestNetworkInterface(s, "zzz", 
                ipAddr, hwAddr);
        
        NetworkInterface eth0 = NetworkInterfaceTest.createTestNetworkInterface(s, "eth0", 
                ipAddr, hwAddr);
        
        NetworkInterface eth1 = NetworkInterfaceTest.createTestNetworkInterface(s, "eth1", 
                ipAddr, hwAddr);
        
        s = (Server) TestUtils.saveAndReload(s);
        
        assertNotNull(s.getIpAddress());

        NetworkInterface lo = NetworkInterfaceTest.createTestNetworkInterface(s, "lo", 
                "127.0.0.1", null);
        s.addNetworkInterface(lo);
        
        NetworkInterface virbr0 = NetworkInterfaceTest.
            createTestNetworkInterface(s, "virbr0", 
                "172.31.2.1", "AA:FF:CC:DD:DD");
        s.addNetworkInterface(virbr0);
        
        NetworkInterface ni = s.findPrimaryNetworkInterface();
        assertEquals(ipAddr, ni.getIpaddr());
        
        assertEquals(ipAddr, s.getIpAddress());
        assertEquals(hwAddr, s.getHardwareAddress());
        
    }
    
    
    public void xxxtestServerWithVirtEntitlementIsVirtualHost() {
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = new VirtEntitledServer(user);
        server = (Server) TestUtils.saveAndReload(server);
        assertTrue(server.isVirtualHost());
    }
    
    public void xxtestServerWithGuestsIsVirtualHost() {
        Server server = new ServerWithGuests();
        server.setOrg(user.getOrg());
        
        assertTrue(server.isVirtualHost());
    }
    
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

}
