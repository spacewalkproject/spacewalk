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
package com.redhat.rhn.manager.system.test;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorWarning;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.test.CustomDataKeyTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageEvrFactoryTest;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.CPU;
import com.redhat.rhn.domain.server.CustomDataValue;
import com.redhat.rhn.domain.server.Device;
import com.redhat.rhn.domain.server.Dmi;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Location;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Network;
import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.test.CPUTest;
import com.redhat.rhn.domain.server.test.CustomDataValueTest;
import com.redhat.rhn.domain.server.test.DeviceTest;
import com.redhat.rhn.domain.server.test.DmiTest;
import com.redhat.rhn.domain.server.test.LocationTest;
import com.redhat.rhn.domain.server.test.NetworkTest;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.server.test.ServerGroupTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.CustomDataKeyOverview;
import com.redhat.rhn.frontend.dto.EssentialServerDto;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestStatics;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Hibernate;
import org.hibernate.Session;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * SystemManagerTest
 * @version $Rev$
 */
public class SystemManagerTest extends RhnBaseTestCase {

    public static final Long NUM_CPUS = new Long(5);
    public static final int HOST_RAM_MB = 2048;
    public static final int HOST_SWAP_MB = 1024;
    
    public void testSnapshotServer() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true, 
                            ServerConstants.getServerGroupTypeProvisioningEntitled());
        Long id = server.getId();

        assertTrue(SystemManager.serverHasFeature(id, "ftr_snapshotting"));
        assertEquals(new Integer(0), numberOfSnapshots(id));
        SystemManager.snapshotServer(null, "test");
        assertEquals(new Integer(0), numberOfSnapshots(id));
        SystemManager.snapshotServer(server, "Testing snapshots");
        assertEquals(new Integer(1), numberOfSnapshots(id));
    }
    
    /*
     * I know this is ugly, but since we haven't got the sever snapshotting feature fully 
     * worked out in java yet, just do a sql query to make sure the stored proc worked.
     */
    private Integer numberOfSnapshots(Long sid) {
        Session session = HibernateFactory.getSession();
        Integer count = (Integer) session.createSQLQuery("Select count(*) as cnt " + 
                                                         "  from rhnSnapshot " +
                                                         " where server_id = " + sid)
                                         .addScalar("cnt", Hibernate.INTEGER)
                                         .uniqueResult();
        return count;
    }
    
    public void testDeleteServer() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server s = ServerFactoryTest.createTestServer(user, true);
        Long id = s.getId();
        
        Server test = SystemManager.lookupByIdAndUser(id, user);
        assertNotNull(test);
        
        SystemManager.deleteServer(user, id);
        
        try {
            test = SystemManager.lookupByIdAndUser(id, user);
            fail("Found deleted server");
        }
        catch (LookupException e) {
            //success
        }
    }
    
    public void testDeleteVirtualServer() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest = ((VirtualInstance) host.getGuests().iterator().next()).
            getGuestSystem();
        Long sid = guest.getId();
        
        Server test = SystemManager.lookupByIdAndUser(sid, user);
        assertNotNull(test);
        
        SystemManager.deleteServer(user, sid);
        
        try {
            test = SystemManager.lookupByIdAndUser(sid, user);
            fail("Found deleted server");
        }
        catch (LookupException e) {
            // expected
        }

    }
    
    public void testDeleteVirtualServerHostDeleted() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest = ((VirtualInstance) host.getGuests().iterator().next()).
            getGuestSystem();
        Long sid = guest.getId();
        
        Server test = SystemManager.lookupByIdAndUser(sid, user);
        assertNotNull(test);
        
        // Delete the host first:
        SystemManager.deleteServer(user, host.getId());
        TestUtils.flushAndEvict(host);
        
        SystemManager.deleteServer(user, sid);
        TestUtils.flushAndEvict(guest);
        
        try {
            test = SystemManager.lookupByIdAndUser(sid, user);
            fail("Found deleted server");
        }
        catch (LookupException e) {
            // expected
        }

    }

    public void testSystemsNotInSg() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        
        // Create a test server so we have one in the list.
        Server s = ServerFactoryTest.createTestServer(user, true);
        ManagedServerGroup sg = ServerGroupTestUtils.createManaged(user);
        
        DataResult<SystemOverview> systems = SystemManager.
                                          systemsNotInGroup(user, sg, null);
        assertNotNull(systems);
        assertFalse(systems.isEmpty());
        assertTrue(serverInList(s, systems));
        
        
        SystemManager.addServerToServerGroup(s, sg);
        systems = SystemManager.systemsNotInGroup(user, sg, null);
        assertFalse(serverInList(s, systems));
    }    
    
    private boolean serverInList(Server s, List<SystemOverview> servers) {
        for (SystemOverview dto : servers) {
            if (dto.getId().equals(s.getId())) {
                return true;
            }
        }
        return false;
    }
    
    public void testSystemList() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        
        // Create a test server so we have one in the list.
        ServerFactoryTest.createTestServer(user, true);
        
        DataResult systems = SystemManager.systemList(user, null);
        assertNotNull(systems);
        assertFalse(systems.isEmpty());
        assertTrue(systems.size() > 0);
    }
    
    public void testSystemWithFeature() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(20);
        DataResult systems = SystemManager.systemsWithFeature(user, "ftr_probes", pc);
        int origCount = systems.size();
        
        user.addRole(RoleFactory.ORG_ADMIN);
        // Create a test server so we have one in the list.
        Server s = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeMonitoringEntitled());
        ServerFactory.save(s);
        
        systems = SystemManager.systemsWithFeature(user, 
                ServerConstants.FEATURE_PROBES, pc);
        int newCount = systems.size();
        assertNotNull(systems);

        assertFalse(systems.isEmpty());
        assertTrue(systems.size() > 0);
        assertTrue(newCount > origCount);
        assertTrue(systems.size() <= 20);
    }

    
    public void testSystemsInGroup() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ServerGroup group = ServerGroupTestUtils.createManaged(user);
        int origCount = SystemManager.systemsInGroup(group.getId(), null).size();
        
        group.setOrg(server.getOrg());
        ServerFactory.save(server);
        ServerFactory.addServerToGroup(server, group);
        
        DataResult systems = SystemManager.systemsInGroup(group.getId(), null);
        assertNotNull(systems);
        assertFalse(systems.isEmpty());
        assertTrue(systems.size() > origCount);
        boolean found = false;
        Iterator i = systems.iterator();
        while (i.hasNext()) {
            SystemOverview so = (SystemOverview) i.next();
            if (so.getId().longValue() == 
                server.getId().longValue()) {
                found = true;
            }
        }
        assertTrue(found); 
    }
    
    
    public void testCountActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(user);
        
        assertEquals(0, SystemManager.countActions(server.getId()));
        
        Action action = ActionFactoryTest.createAction(user, 
                ActionFactory.TYPE_CONFIGFILES_UPLOAD);
        ServerActionTest.createServerAction(server, action);
        ActionFactory.save(action);
        
        assertEquals(1, SystemManager.countActions(server.getId()));
        
        Action action2 = ActionFactoryTest.createAction(user, 
                ActionFactory.TYPE_CONFIGFILES_UPLOAD);
        ServerActionTest.createServerAction(server, action2);
        ActionFactory.save(action);
        
        assertEquals(2, SystemManager.countActions(server.getId()));
    }
    
    public void testCountPackageActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(user);
        
        assertEquals(0, SystemManager.countActions(server.getId()));
        
        Action action = ActionFactoryTest.createAction(user, 
                ActionFactory.TYPE_PACKAGES_DELTA);
        ServerActionTest.createServerAction(server, action);
        ActionFactory.save(action);
        
        assertEquals(1, SystemManager.countActions(server.getId()));
        
        Action action2 = ActionFactoryTest.createAction(user, 
                ActionFactory.TYPE_PACKAGES_AUTOUPDATE);
        ServerActionTest.createServerAction(server, action2);
        ActionFactory.save(action);
        
        assertEquals(2, SystemManager.countActions(server.getId()));
        
    }
    
    public void testUnscheduledErrata() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true);
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(20);
        
        DataResult errata = SystemManager.unscheduledErrata(user, server.getId(), pc);
        assertNotNull(errata);
        assertTrue(errata.isEmpty());
        assertTrue(errata.size() == 0);
        assertFalse(SystemManager.hasUnscheduledErrata(user, server.getId()));
        
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        for (Iterator itr = e.getPackages().iterator(); itr.hasNext();) {
            Package pkg = (Package) itr.next();
            ErrataCacheManager.insertNeededPackageCache(server.getId(),
                    e.getId(), pkg.getId());
        }
        
        errata = SystemManager.unscheduledErrata(user, server.getId(), pc);
        assertNotNull(errata);
        assertFalse(errata.isEmpty());
        assertTrue(errata.size() == 1);
        assertTrue(SystemManager.hasUnscheduledErrata(user, server.getId()));
    }
    
    
    public void testEntitleServer() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerTestUtils.createTestSystem(user);
        ChannelTestUtils.setupBaseChannelForVirtualization(user, 
                server.getBaseChannel());
        UserTestUtils.addProvisioning(user.getOrg());
        UserTestUtils.addMonitoring(user.getOrg());
        UserTestUtils.addVirtualization(user.getOrg());
        UserTestUtils.addVirtualizationPlatform(user.getOrg());
        TestUtils.saveAndFlush(user.getOrg());
        
        assertTrue(SystemManager.canEntitleServer(server, 
                EntitlementManager.MONITORING));
        assertTrue(SystemManager.canEntitleServer(server, 
                EntitlementManager.PROVISIONING));
        assertTrue(SystemManager.canEntitleServer(server, 
                EntitlementManager.VIRTUALIZATION));
        assertTrue(SystemManager.canEntitleServer(server, 
                EntitlementManager.VIRTUALIZATION_PLATFORM));
        
        assertFalse(SystemManager.entitleServer(server,
                EntitlementManager.VIRTUALIZATION).hasErrors());
        assertFalse(SystemManager.entitleServer(server,
                EntitlementManager.VIRTUALIZATION_PLATFORM).hasErrors());
        assertFalse(SystemManager.entitleServer(server,
                EntitlementManager.MONITORING).hasErrors());
        assertFalse(SystemManager.entitleServer(server,
                EntitlementManager.PROVISIONING).hasErrors());
        server = (Server) reload(server);
        
        assertTrue(server.hasEntitlement(EntitlementManager.PROVISIONING));
        // By adding virt_platform above we swapped out virt
        assertFalse(server.hasEntitlement(EntitlementManager.VIRTUALIZATION));
        
        SystemManager.entitleServer(server, EntitlementManager.MONITORING);
        SystemManager.entitleServer(server, EntitlementManager.PROVISIONING);
        SystemManager.entitleServer(server, EntitlementManager.VIRTUALIZATION);
        SystemManager.entitleServer(server, EntitlementManager.VIRTUALIZATION_PLATFORM);
        
        // One assert for kicks
        assertTrue(server.hasEntitlement(EntitlementManager.PROVISIONING));

        // Removal
        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.VIRTUALIZATION);
        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.VIRTUALIZATION_PLATFORM);
        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.MONITORING);
        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.PROVISIONING);
        
        server = (Server) reload(server);
        
        assertFalse(server.hasEntitlement(EntitlementManager.PROVISIONING));
        assertFalse(server.hasEntitlement(EntitlementManager.MONITORING));
        assertFalse(server.hasEntitlement(EntitlementManager.VIRTUALIZATION));
        assertFalse(server.hasEntitlement(EntitlementManager.VIRTUALIZATION_PLATFORM));

    }
    
    public void testEntitleVirtForGuest() throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuest();
        User user = host.getCreator();
        UserTestUtils.addVirtualization(user.getOrg());
        
        Server guest = 
            ((VirtualInstance) host.getGuests().iterator().next()).getGuestSystem();
        guest.addChannel(ChannelTestUtils.createBaseChannel(user));
        ServerTestUtils.addVirtualization(user, guest);
        
        assertTrue(SystemManager.entitleServer(guest,
                EntitlementManager.VIRTUALIZATION).hasErrors());
        assertFalse(guest.hasEntitlement(EntitlementManager.VIRTUALIZATION));
    }
    
    public void testEntitleMaxMembers() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerTestUtils.createTestSystem(user);
        
        UserTestUtils.addProvisioning(user.getOrg());
        EntitlementServerGroup group = ServerGroupFactory.lookupEntitled(
                                                EntitlementManager.PROVISIONING, 
                                                user.getOrg());
        group.setMaxMembers(new Long(0));
        TestUtils.saveAndFlush(group);
        TestUtils.flushAndEvict(group);
        
        ValidatorResult vr =
            SystemManager.entitleServer(server, EntitlementManager.PROVISIONING);
        assertTrue("we shoulda gotten an error", vr.hasErrors());
        ValidatorError ve = vr.getErrors().get(0);
        assertEquals("system.entitle.noslots", ve.getKey());
        
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest = ((VirtualInstance) 
                host.getGuests().iterator().next()).getGuestSystem();
        
        EntitlementServerGroup pgroup = ServerGroupFactory.lookupEntitled(
                                                EntitlementManager.PROVISIONING, 
                                                user.getOrg());
        pgroup.setMaxMembers(new Long(pgroup.getCurrentMembers().longValue() + 1));

        TestUtils.saveAndFlush(pgroup);
        TestUtils.flushAndEvict(pgroup);
        
        assertFalse(SystemManager.entitleServer(host, EntitlementManager.PROVISIONING)
                .hasErrors());
        assertTrue(host.hasEntitlement(EntitlementManager.PROVISIONING));
        assertTrue(SystemManager.entitleServer(server, EntitlementManager.PROVISIONING)
                .hasErrors());
        guest.setBaseEntitlement(EntitlementManager.MANAGEMENT);
        assertFalse(SystemManager.entitleServer(guest, EntitlementManager.PROVISIONING)
                .hasErrors());
    }
    
    public void testVirtualEntitleServer() throws Exception {
        // User and server
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerTestUtils.createTestSystem(user);
        Channel[] children = ChannelTestUtils.setupBaseChannelForVirtualization(user, 
                server.getBaseChannel());
        
        Channel rhnTools = children[0];
        Channel rhelVirt = children[1];
        
        // Entitlements
        UserTestUtils.addVirtualization(user.getOrg());
        TestUtils.saveAndFlush(user.getOrg());

        assertTrue(SystemManager.canEntitleServer(server, 
                EntitlementManager.VIRTUALIZATION));
        
        ValidatorResult retval = SystemManager.entitleServer(server,
                EntitlementManager.VIRTUALIZATION);
        
        server = (Server) reload(server);
        
        String key = null;
        if (retval.getErrors().size() > 0) {
            key = retval.getErrors().get(0).getKey();
        }
        assertFalse("Got back: " + key, retval.hasErrors());
        
        // Test stuff!
        assertTrue(server.hasEntitlement(EntitlementManager.VIRTUALIZATION));
        assertTrue(server.getChannels().contains(rhnTools));
        if (!ConfigDefaults.get().isSpacewalk()) {
            assertTrue(server.getChannels().contains(rhelVirt));
        }
        
        
        // Test removal
        SystemManager.removeServerEntitlement(server.getId(), 
                EntitlementManager.VIRTUALIZATION);
        
        server = (Server) reload(server);
        assertFalse(server.hasEntitlement(EntitlementManager.VIRTUALIZATION));
        
    }
    
    public void testSwapVirts() throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuest();
        User user = host.getCreator();
        UserTestUtils.addVirtualization(user.getOrg());
        UserTestUtils.addVirtualizationPlatform(user.getOrg());
        assertTrue(SystemManager.hasEntitlement(host.getId(), 
                EntitlementManager.VIRTUALIZATION));
        assertFalse(SystemManager.hasEntitlement(host.getId(), 
                        EntitlementManager.VIRTUALIZATION_PLATFORM));        
        ValidatorResult result = SystemManager.entitleServer(host,
                                        EntitlementManager.VIRTUALIZATION_PLATFORM);
        assertFalse(result.hasErrors());
        assertTrue(SystemManager.hasEntitlement(host.getId(), 
                                EntitlementManager.VIRTUALIZATION_PLATFORM));
        assertFalse(SystemManager.hasEntitlement(host.getId(), 
                                        EntitlementManager.VIRTUALIZATION));
        host = (Server) reload(host);
        result = SystemManager.entitleServer(host,
                                        EntitlementManager.VIRTUALIZATION);
         assertFalse(result.hasErrors());
         assertTrue(SystemManager.hasEntitlement(host.getId(), 
                                 EntitlementManager.VIRTUALIZATION));
         assertFalse(SystemManager.hasEntitlement(host.getId(), 
                             EntitlementManager.VIRTUALIZATION_PLATFORM));
        
    }    
    
    
    public void testGetServerEntitlement() throws Exception {
        // create a new server
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(user);
        ArrayList entitlements = SystemManager.getServerEntitlements(server.getId());
        assertFalse(entitlements.isEmpty());
        assertTrue(entitlements.contains(EntitlementManager.UPDATE));
    }
    
    public void testClientCapability() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(user);
        Long ver = new Long(1);
        giveCapability(server.getId(), SystemManager.CAP_PACKAGES_VERIFY, ver);
        assertTrue(SystemManager.clientCapable(server.getId(),
                SystemManager.CAP_PACKAGES_VERIFY));
    }
    
    
    /**
     * This utility method associates a particular system with a given
     * capability.  This is backend code that has not yet been implemented
     * in Java. This type of code should NEVER EVER be seen outside of a test.
     * @param sid Server id
     * @param capability Capability to add
     * @param version version number
     * @throws SQLException thrown if there's a problem which should cause
     * the test to fail.
     */
    public static void giveCapability(Long sid, String capability, Long version)
        throws SQLException {
        
        WriteMode m = ModeFactory.getWriteMode("test_queries",
                                                    "add_to_client_capabilities");
        Map params = new HashMap();
        params.put("sid", sid);
        params.put("capability", capability);
        params.put("version", version);
        m.executeUpdate(params);        
    }
    
    public void testCompatibleWithServer() throws Exception {
        
        /*
         * here we create a user as an org admin.
         * then we create two (minimum) Servers owned by the user and
         * which are enterprise_entitled.
         * We add the test channel to each of the servers.  This allows
         * us to test the compatibleWithServer method.
         */
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server srvr = ServerFactoryTest.createTestServer(user, true,
                ServerFactory.lookupServerGroupTypeByLabel("enterprise_entitled"));
        
        Server srvr1 = ServerFactoryTest.createTestServer(user, true,
                ServerFactory.lookupServerGroupTypeByLabel("enterprise_entitled"));
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        srvr.addChannel(channel);
        srvr1.addChannel(channel);
        TestUtils.saveAndFlush(srvr);
        TestUtils.saveAndFlush(srvr1);
        UserManager.storeUser(user);

        
        // Ok let's finally test what we came here for.
        List list = SystemManager.compatibleWithServer(user, srvr);
        assertNotNull("List is null", list);
        assertFalse("List is empty", list.isEmpty());
        boolean found = false;
        for (Iterator itr = list.iterator(); itr.hasNext();) {
            Object o = itr.next();
            
            assertEquals("List contains something other than Profiles",
                    HashMap.class, o.getClass());
            Map s = (Map) o;
            if (srvr1.getName().equals(s.get("name"))) {
                found = true;
            }
        }
        assertTrue("Didn't get back the expected values", found);

    }
    
    public void testSubscribeServerToChannel() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        
        Server server = ServerFactoryTest.createTestServer(user, true);
        Channel channel = ChannelFactoryTest.createTestChannel(user);

        int before = server.getChannels().size();
        SystemManager.subscribeServerToChannel(user, server, channel);
        
        server = (Server) reload(server);
        
        int after = server.getChannels().size();
        assertTrue(after > before);
    }
    public void testSystemSearch() throws Exception {
        
        User user = UserTestUtils.findNewUser("testUser", "testOrg");

        Server s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        
        /* setup needed for needed package query */
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        e.setAdvisoryType(ErrataFactory.ERRATA_TYPE_SECURITY);
        
        Package p = PackageManagerTest.addPackageToSystemAndChannel(
                "test-package-name" + TestUtils.randomString(), s, 
                ChannelFactoryTest.createTestChannel(user));
        
        
        /*ServerGroup group = ServerGroupTestUtils.createEntitled(org);
        SystemManager.addServerToServerGroup(s, group);
        UserFactory.save(user);
        OrgFactory.save(org);*/
        int rows = ErrataCacheManager.insertNeededPackageCache(
                s.getId(), e.getId(), p.getId());
        assertEquals(1, rows); 
        
        /* CPU query setup */
        CPU cpu = CPUTest.createTestCpu();
        cpu.setServer(s);
        s.setCpu(CPUTest.createTestCpu());
        
        /* Network setup */
        Network network = NetworkTest.createTestNetwork();
        network.setServer(s);
        s.addNetwork(network);
        
        /* Dmi setup */
        Dmi dmi = DmiTest.createTestDmi();
        dmi.setServer(s);
        s.setDmi(dmi);
        
        /* fake device setup */
        Device device = DeviceTest.createTestDevice();
        device.setServer(s);
        s.addDevice(device);
        
        /* Location setup */
        Location loc = LocationTest.createTestLocation();
        loc.setServer(s);
        s.setLocation(loc);
        
        /* custom data value */
        CustomDataValue value = CustomDataValueTest.createTestCustomDataValue(user, 
                                CustomDataKeyTest.createTestCustomDataKey(user), 
                                s);
        s.addCustomDataValue(value);
        
        TestUtils.saveAndFlush(s);
        s = (Server) reload(s);
        
        /* Here we create a hashmap with the name of each query as the key
         * and the value being a search string that WILL return a result, namely
         * our test system we created above
         */
        Map map = new HashMap();
        map.put("systemsearch_name_and_description", s.getName());
        map.put("systemsearch_id", s.getId().toString());
        // map.put("systemsearch_checkin", "-1"); 
        // map.put("systemsearch_registered", "0");
        map.put("systemsearch_cpu_model", cpu.getModel());
        map.put("systemsearch_cpu_mhz_lt", new Long(CPUTest.MHZ_NUMERIC + 50).toString());
        map.put("systemsearch_cpu_mhz_gt", new Long(CPUTest.MHZ_NUMERIC - 50).toString());
        map.put("systemsearch_ram_lt", new Long(s.getRam() + 50).toString());
        map.put("systemsearch_ram_gt", new Long(s.getRam() - 50).toString());
        map.put("systemsearch_hwdevice_description", device.getDescription());
        map.put("systemsearch_hwdevice_driver", device.getDriver());
        map.put("systemsearch_hwdevice_device_id", device.getProp2());
        map.put("systemsearch_hwdevice_vendor_id", device.getProp1());
        map.put("systemsearch_dmi_system", dmi.getSystem());
        map.put("systemsearch_dmi_bios", dmi.getBios().getVendor());
        map.put("systemsearch_dmi_asset", dmi.getAsset());
        map.put("systemsearch_hostname", network.getHostname());
        map.put("systemsearch_ip", network.getIpaddr());
        map.put("systemsearch_needed_packages", p.getPackageName().getName());
        map.put("systemsearch_installed_packages", p.getPackageName().getName());
        map.put("systemsearch_custom_info", value.getValue());
        map.put("systemsearch_location_address", loc.getAddress1());
        map.put("systemsearch_location_building", loc.getBuilding());
        map.put("systemsearch_location_room", loc.getRoom());
        map.put("systemsearch_location_rack", loc.getRack());
        
        Iterator i = map.keySet().iterator();
        
        clearSession();
        
        /* Loop through the set of keys which is our queries
         * For each query we check that if we search on it,
         * we find our system. Then we check the other possible
         * combinations of search options which should all return nothing.
         */
        while (i.hasNext()) {
            String viewMode = (String) i.next();
            String searchValue = (String) map.get(viewMode);
            
            DataResult dr = SystemManager.systemSearch(user, 
                                                       searchValue, 
                                                       viewMode,  
                                                       Boolean.FALSE, 
                                                       "all", 
                                                       null);

            assertFalse(viewMode + " is empty with value: " + searchValue, 
                    dr.isEmpty());
            
            dr = SystemManager.systemSearch(user, 
                                            searchValue, 
                                            viewMode,  
                                            Boolean.FALSE, 
                                            "system_list", 
                                            null);
            
            assertTrue(viewMode + " has items with value: " + searchValue,
                    dr.isEmpty());

            dr = SystemManager.systemSearch(user, 
                                            searchValue, 
                                            viewMode,  
                                            Boolean.TRUE, 
                                            "system_list", 
                                            null);

            assertTrue(viewMode + " has items with value: " + searchValue,
                    dr.isEmpty());
        }
        
    }
    
    public void testGetSsmSystemsSubscribedToChannel() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        
        Server s = ServerTestUtils.createTestSystem(user);
        
        RhnSetDecl.SYSTEMS.clear(user);
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        set.addElement(s.getId());
        RhnSetManager.store(set);
        
        List<Map> systems = SystemManager.getSsmSystemsSubscribedToChannel(user, 
                s.getBaseChannel().getId());
        assertEquals(1, systems.size());
        Map result1 = systems.get(0);
        assertEquals(s.getName(), result1.get("name"));
        assertEquals(s.getId(), result1.get("id"));
    }
    
    public void testNoBaseChannelInSet() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);

        // Get ourselves a system
        Server s = ServerTestUtils.createTestSystem(user);
        SystemManager.unsubscribeServerFromChannel(user, s, s.getBaseChannel());
        
        // insert sys into system-set
        RhnSetDecl.SYSTEMS.clear(user);
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        set.addElement(s.getId());
        RhnSetManager.store(set);
        
        // ask for the base channels of all systems in the system-set for the test user
        DataResult dr = SystemManager.systemsWithoutBaseChannelsInSet(user);
        assertNotNull(dr);
        assertEquals(dr.size(), 1);
        EssentialServerDto m = (EssentialServerDto)dr.get(0);
        Long id = m.getId().longValue();
        assertTrue(s.getId().equals(id));
        
        // Create a new no-base-channel-server
        Server s2 = ServerTestUtils.createTestSystem(user);
        SystemManager.unsubscribeServerFromChannel(user, s2, s2.getBaseChannel());
        
        // We should NOT see it yet
        dr = SystemManager.systemsWithoutBaseChannelsInSet(user);
        assertNotNull(dr);
        assertEquals(dr.size(), 1);
        
        // Add it to the SSM set and look again
        set.addElement(s2.getId());
        RhnSetManager.store(set);
        dr = SystemManager.systemsWithoutBaseChannelsInSet(user);
        assertNotNull(dr);
        assertEquals(dr.size(), 2);
    }
    
    public void testRegisteredList() throws Exception {
        User user = UserTestUtils.findNewUser(TestStatics.TESTUSER, TestStatics.TESTORG);
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ServerGroup group = ServerGroupTest
                .createTestServerGroup(user.getOrg(), null);
        SystemManager.addServerToServerGroup(server, group);
        ServerFactory.save(server);
        
        DataResult dr = SystemManager.registeredList(user, null, 0);
        assertNotEmpty(dr);
    }
    
    public void testDeactivateSatellite() throws Exception {
        // Server s = ServerFactory.lookupById(new Long(1007294616));
        Server s = ServerTestUtils.createTestSystem();
        flushAndEvict(s);
        s = (Server) reload(s);
        assertNotNull(s);
        try {
            SystemManager.deactivateSatellite(s);
            fail("Should have thrown an NotActivatedSatelliteException");
        }
        catch (Exception e) {
           // do nothing
        }
    }
    
    public void testDeactivateProxy() throws Exception {
        User user = UserTestUtils.findNewUser(TestStatics.TESTUSER, TestStatics.TESTORG);
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestProxyServer(user, true);
        assertTrue(server.isProxy());
        server = SystemManager.deactivateProxy(server);
        ServerFactory.save(server);
        server = (Server) reload(server);
        assertFalse(server.isProxy());
    }
    
    public void testCanServerSubscribeToChannel() throws Exception {
        Server server = ServerTestUtils.createTestSystem();
        Channel childChannel = ChannelTestUtils.createChildChannel(server.getCreator(), 
                server.getBaseChannel());
        assertTrue(SystemManager.canServerSubscribeToChannel(server.getCreator().getOrg(), 
                server, childChannel));
    }
    
    private void addCpuToServer(Server s) {
        CPU cpu = new CPU();
        cpu.setArch(ServerFactory.lookupCPUArchByName(CPUTest.ARCH_NAME));
        cpu.setServer(s);
        cpu.setFamily(CPUTest.FAMILY);
        cpu.setMHz(CPUTest.MHZ);
        cpu.setModel(CPUTest.MODEL);
        cpu.setNrCPU(NUM_CPUS);
        TestUtils.saveAndFlush(cpu);
        TestUtils.reload(s);
    }

    public void testVcpuSettingExceeds32() throws Exception {
        Server host = setupHostWithGuests(1);
        VirtualInstance vi = (VirtualInstance)host.getGuests().iterator().next();
        
        // Currently 32 is the maximum supported number of vcpus on both 32 and 64-bit
        // systems:
        ValidatorResult result = SystemManager.validateVcpuSetting(vi.getId(), 33);
        List errors = result.getErrors();
        assertEquals(1, errors.size());
        assertEquals("systems.details.virt.vcpu.limit.msg", 
                ((ValidatorError)errors.get(0)).getKey());
    }

    public void testVcpuSettingExceedsPhysicalCpus() throws Exception {
        Server host = setupHostWithGuests(1);
        VirtualInstance vi = (VirtualInstance)host.getGuests().iterator().next();
        
        // Warning should result from attempting to set vcpus greater than the
        // physical hosts cpus:
        ValidatorResult result = SystemManager.validateVcpuSetting(vi.getId(), 6);
        assertEquals(0, result.getErrors().size());

        List warnings = result.getWarnings();
        assertEquals(2, warnings.size());
        assertEquals("systems.details.virt.vcpu.exceeds.host.cpus",
                ((ValidatorWarning)warnings.get(0)).getKey());
    }

    // Increasing the vCPUs should create a warning that if the new setting exceeds
    // what the guest was booted with, it will require a reboot to take effect.
    public void testVcpuIncreaseWarning() throws Exception {
        Server host = setupHostWithGuests(1);
        VirtualInstance vi = (VirtualInstance)host.getGuests().iterator().next();
        
        ValidatorResult result = SystemManager.validateVcpuSetting(vi.getId(), 3);
        assertEquals(0, result.getErrors().size());

        List warnings = result.getWarnings();
        assertEquals(1, warnings.size());
        assertEquals("systems.details.virt.vcpu.increase.warning",
                ((ValidatorWarning)warnings.get(0)).getKey());
    }

    public void testMemoryChangeWarnings() throws Exception {
        Server host = setupHostWithGuests(1);
        
        List guestIds = new LinkedList();
        VirtualInstance vi = (VirtualInstance)host.getGuests().iterator().next();
        guestIds.add(vi.getId());

        ValidatorResult result = SystemManager.validateGuestMemorySetting(guestIds, 
            512);
        List errors = result.getErrors();
        assertEquals(0, errors.size());
        List warnings = result.getWarnings();
        assertEquals(2, warnings.size());
    }

    private Server setupHostWithGuests(int numGuests) throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuests(numGuests);
        host.setRam(HOST_RAM_MB);
        addCpuToServer(host);
        User user = host.getCreator();
        UserTestUtils.addVirtualization(user.getOrg());

        for (Iterator it = host.getGuests().iterator(); it.hasNext();) {
            VirtualInstance vi = (VirtualInstance)it.next();
            Server guest = vi.getGuestSystem();
            guest.addChannel(ChannelTestUtils.createBaseChannel(user));
            ServerTestUtils.addVirtualization(user, guest);
        }
        return host;
    }

    public void testListCustomKeys() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        admin.addRole(RoleFactory.ORG_ADMIN);


        CustomDataKey key = new CustomDataKey();
        key.setCreator(admin);
        key.setLabel("testdsfd");
        key.setDescription("test desc");
        key.setOrg(admin.getOrg());
        key.setLastModifier(admin);
        HibernateFactory.getSession().save(key);


        List list = SystemManager.listDataKeys(admin);
        assertTrue(1 == list.size());
        CustomDataKeyOverview dataKey = (CustomDataKeyOverview) list.get(0);
        assertEquals(key.getLabel(), dataKey.getLabel());
    }

    /**
     * Note: This test tests multiple calls in SystemManager.
     * 
     * @throws Exception
     */
    public void testErrataCountsForSystem() throws Exception {
        
        // Setup
        User admin = UserTestUtils.findNewUser("errataUser1", "errataOrg1");
        Org org = admin.getOrg();
        
        Server server = ServerTestUtils.createTestSystem(admin);
        ServerFactory.save(server);
        TestUtils.flushAndEvict(server);

        // Will be used for both errata types. Represents an upgraded version of a package
        // that comes with the errata.
        PackageEvr upgradedPackageEvr =
            PackageEvrFactory.createPackageEvr("1", "1.0.0", "2");
        upgradedPackageEvr =
            (PackageEvr)TestUtils.saveAndReload(upgradedPackageEvr);
        
        ServerTestUtils.populateServerErrataPackages(org, server,
            upgradedPackageEvr, ErrataFactory.ERRATA_TYPE_SECURITY);
        ServerTestUtils.populateServerErrataPackages(org, server,
            upgradedPackageEvr, ErrataFactory.ERRATA_TYPE_BUG);

        // Test
        int criticalCount = 
            SystemManager.countCriticalErrataForSystem(admin, server.getId());
        int nonCriticalCount =
            SystemManager.countNoncriticalErrataForSystem(admin, server.getId());

        // Verify
        assertEquals(1, criticalCount);
        assertEquals(1, nonCriticalCount);
    }

    /**
     * Creates two packages and errata agains the specified server. An installed package
     * with the default EVR is created and installed to the server. The newer package
     * is created with the given EVR and is the package associated with the errata. 
     * 
     * @param org
     * @param server
     * @param upgradedPackageEvr
     * @param errataType
     * @throws Exception
     */
    private void populateServerErrataPackages(Org org, Server server,
                                              PackageEvr upgradedPackageEvr,
                                              String errataType)
        throws Exception {
        
        Errata errata = ErrataFactoryTest.createTestErrata(org.getId());
        errata.setAdvisoryType(errataType);        
        TestUtils.saveAndFlush(errata);
        
        Package installedPackage = PackageTest.createTestPackage(org);
        TestUtils.saveAndFlush(installedPackage);
        
        Session session = HibernateFactory.getSession();
        session.flush();
        
        Package upgradedPackage = PackageTest.createTestPackage(org);
        upgradedPackage.setPackageName(installedPackage.getPackageName());
        upgradedPackage.setPackageEvr(upgradedPackageEvr);
        TestUtils.saveAndFlush(upgradedPackage);
        
        ErrataCacheManager.insertNeededPackageCache(
                server.getId(), errata.getId(), installedPackage.getId());
    }

    public void testSsmSystemPackagesToRemove() throws Exception {

        // Setup
        User admin = UserTestUtils.findNewUser("ssmUser1", "ssmOrg1");
        Org org = admin.getOrg();

        //    Create Test Servers
        Server server1 = ServerTestUtils.createTestSystem(admin);
        ServerFactory.save(server1);

        Server server2 = ServerTestUtils.createTestSystem(admin);
        ServerFactory.save(server2);

        //    Create Test Packages
        Package installedPackage1 = PackageTest.createTestPackage(org);
        Package installedPackage2 = PackageTest.createTestPackage(org);

        //    Associate the servers and packages
        PackageManagerTest.associateSystemToPackageWithArch(server1, installedPackage1);
        PackageManagerTest.associateSystemToPackageWithArch(server1, installedPackage2);

        PackageManagerTest.associateSystemToPackageWithArch(server2, installedPackage1);

        //    Add the servers to the SSM set
        RhnSet ssmSet = RhnSetManager.findByLabel(admin.getId(),
            RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        if (ssmSet == null) {
            ssmSet = RhnSetManager.createSet(admin.getId(),
                RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        }

        assert ssmSet != null;

        ssmSet.addElement(server1.getId());
        ssmSet.addElement(server2.getId());
        RhnSetManager.store(ssmSet);

        ssmSet = RhnSetManager.findByLabel(admin.getId(),
            RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        assert ssmSet != null;

        ServerTestUtils.addServerPackageMapping(server1.getId(), installedPackage1);
        ServerTestUtils.addServerPackageMapping(server1.getId(), installedPackage2);
        
        ServerTestUtils.addServerPackageMapping(server2.getId(), installedPackage1);
        
        //    Add the servers to the SSM set
        ServerTestUtils.addServersToSsm(admin, server1.getId(), server2.getId());
        
        //    Simulate the user selecting every package in the list
        RhnSet packagesSet =
            RhnSetManager.createSet(admin.getId(),
                RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel(), SetCleanup.NOOP);

        packagesSet.addElement(installedPackage1.getPackageName().getId(),
            installedPackage1.getPackageEvr().getId(),
            installedPackage1.getPackageArch().getId());

        packagesSet.addElement(installedPackage2.getPackageName().getId(),
            installedPackage2.getPackageEvr().getId(),
            installedPackage2.getPackageArch().getId());

        RhnSetManager.store(packagesSet);

        packagesSet = RhnSetManager.findByLabel(admin.getId(),
            RhnSetDecl.SSM_REMOVE_PACKAGES_LIST.getLabel(), SetCleanup.NOOP);
        assert packagesSet != null;

        assertNotNull(packagesSet);
        
        // Test
        DataResult result =
            SystemManager.ssmSystemPackagesToRemove(admin, packagesSet.getLabel(), false);
        assertNotNull(result);
        
        //   Need explicit elaborate call here; list tag will do this in the UI
        result.elaborate();

        // Verify
        assertEquals(2, result.size());

        for (Object r : result) {
            Map map = (Map)r;
            
            if (map.get("id").equals(server1.getId())) {
                assertEquals(server1.getName(), map.get("system_name"));
        
                assertTrue(map.get("elaborator0") instanceof List);
                List result1Packages = (List)map.get("elaborator0");
                assertEquals(2, result1Packages.size());
            }
            else if (map.get("id").equals(server2.getId())) {
                assertEquals(server2.getName(), (map.get("system_name")));
        
                assertTrue(map.get("elaborator0") instanceof List);
                List result2Packages = (List)map.get("elaborator0");
                assertEquals(1, result2Packages.size());                
            }
            else {
                fail("Found ID that wasn't expected: " + map.get("id"));
            }
        }
    }

    public void testDeleteNote() throws Exception {
        // Setup
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerTestUtils.createTestSystem(admin);
        int sizeBefore = server.getNotes().size();
        server.addNote(admin, "Test Subject", "Test Body");
        ServerFactory.save(server);
        TestUtils.flushAndEvict(server);

        server = ServerFactory.lookupById(server.getId());
        int sizeAfter = server.getNotes().size();
        assertTrue(sizeAfter == (sizeBefore + 1));

        Note deleteMe = (Note) server.getNotes().iterator().next();

        // Test
        SystemManager.deleteNote(admin, server.getId(), deleteMe.getId());

        // Verify
        server = ServerFactory.lookupById(server.getId());
        int sizeAfterDelete = server.getNotes().size();
        assertEquals(sizeBefore, sizeAfterDelete);
    }
    
    public void testDeleteNotes() throws Exception {
        // Setup
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerTestUtils.createTestSystem(admin);
        int sizeBefore = server.getNotes().size();
        server.addNote(admin, "Test Subject 1", "Test Body");
        server.addNote(admin, "Test Subject 2", "Test Body");
        server.addNote(admin, "Test Subject 3", "Test Body");
        server.addNote(admin, "Test Subject 4", "Test Body");
        ServerFactory.save(server);
        TestUtils.flushAndEvict(server);

        server = ServerFactory.lookupById(server.getId());
        int sizeAfter = server.getNotes().size();
        assertTrue(sizeAfter == (sizeBefore + 4));

        // Test
        SystemManager.deleteNotes(admin, server.getId());

        // Verify
        server = ServerFactory.lookupById(server.getId());
        int sizeAfterDelete = server.getNotes().size();
        assertEquals(0, sizeAfterDelete);
        
    }


    public void testHasPackageAvailable() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerTestUtils.createTestSystem(admin);

        Package pack = PackageTest.createTestPackage(admin.getOrg());
        assertFalse(SystemManager.hasPackageAvailable(server,
                pack.getPackageName().getId(), pack.getPackageArch().getId(),
                pack.getPackageEvr().getId()));

        assertFalse(SystemManager.hasPackageAvailable(server,
                pack.getPackageName().getId(), null,
                pack.getPackageEvr().getId()));

        server.getBaseChannel().addPackage(pack);
        TestUtils.saveAndFlush(pack);
        assertTrue(SystemManager.hasPackageAvailable(server,
                pack.getPackageName().getId(), pack.getPackageArch().getId(),
                pack.getPackageEvr().getId()));
        assertTrue(SystemManager.hasPackageAvailable(server,
                pack.getPackageName().getId(), null,
                pack.getPackageEvr().getId()));

    }
    public void testListSystemsWithNeededPackage() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true);
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(20);

        DataResult errata = SystemManager.unscheduledErrata(user, server.getId(), pc);
        assertNotNull(errata);
        assertTrue(errata.isEmpty());
        assertTrue(errata.size() == 0);
        assertFalse(SystemManager.hasUnscheduledErrata(user, server.getId()));

        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        for (Iterator itr = e.getPackages().iterator(); itr.hasNext();) {
            Package pkg = (Package) itr.next();
            ErrataCacheManager.insertNeededPackageCache(server.getId(),
                    e.getId(), pkg.getId());
            List<SystemOverview> systems =
                SystemManager.listSystemsWithNeededPackage(user, pkg.getId());
            assertTrue(systems.size() == 1);
            SystemOverview so = systems.get(0);
            assertEquals(so.getId(), server.getId());
        }

        errata = SystemManager.unscheduledErrata(user, server.getId(), pc);
        assertNotNull(errata);
        assertFalse(errata.isEmpty());
        assertTrue(errata.size() == 1);
        assertTrue(SystemManager.hasUnscheduledErrata(user, server.getId()));
    }

    public void testListInstalledPackage() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server s = ServerFactoryTest.createTestServer(user);

        List<Map<String, Long>> list = SystemManager.listInstalledPackage("kernel", s);
        assertTrue(list.isEmpty());

        InstalledPackage p = new InstalledPackage();
        p.setArch(PackageFactory.lookupPackageArchByLabel("x86_64"));
        p.setName(PackageManager.lookupPackageName("kernel"));
        p.setEvr(PackageEvrFactoryTest.createTestPackageEvr());
        p.setServer(s);
        Set set = new HashSet();
        set.add(p);
        s.setPackages(set);

        ServerFactory.save(s);

        list = SystemManager.listInstalledPackage("kernel", s);
        assertTrue(list.size() == 1);
        assertEquals(list.get(0).get("name_id"), p.getName().getId());
        assertEquals(list.get(0).get("evr_id"), p.getEvr().getId());

    }

}
