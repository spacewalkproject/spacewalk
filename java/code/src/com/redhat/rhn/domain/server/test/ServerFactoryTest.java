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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.ChannelProduct;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.channel.test.ChannelFamilyFactoryTest;
import com.redhat.rhn.domain.common.ProvisionState;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.test.CustomDataKeyTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Device;
import com.redhat.rhn.domain.server.Dmi;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Network;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.domain.server.ProxyInfo;
import com.redhat.rhn.domain.server.SatelliteServer;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.ServerHistoryEvent;
import com.redhat.rhn.domain.server.ServerInfo;
import com.redhat.rhn.domain.server.ServerSnapshot;
import com.redhat.rhn.domain.server.ServerSnapshotTagLink;
import com.redhat.rhn.domain.server.SnapshotTag;
import com.redhat.rhn.domain.server.SnapshotTagName;
import com.redhat.rhn.domain.server.UndefinedCustomDataKeyException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.collections.CollectionUtils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ServerFactoryTest
 * @version $Rev$
 */
public class ServerFactoryTest extends RhnBaseTestCase {
    private User usr;
    private Server server;
    public static final int TYPE_SERVER_SATELLITE = 0;
    public static final int TYPE_SERVER_PROXY = 1;
    public static final int TYPE_SERVER_NORMAL = 2;
    public static final int TYPE_SERVER_VIRTUAL = 3;
    public static final String RUNNING_KERNEL = "2.6.9-55.EL";

    public void setUp() throws Exception {
        usr = UserTestUtils.findNewUser("testUser", "testOrg");
        server = createTestServer(usr);
        assertNotNull(server.getId());
    }
    
    
    public void aTestChannels() throws Exception {
        System.out.println(
                "FIXME ASAP: rhnuser NEEDS access to rhnChannelCloned for this to work");
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Server testServer = createTestServer(user);
        Channel parent = ChannelFactoryTest.createTestChannel(user);
        parent.setParentChannel(null);
        
        Channel child = ChannelFactoryTest.createTestChannel(user);
        child.setParentChannel(parent);
        
        testServer.addChannel(parent);
        testServer.addChannel(child);
        
        Channel test = testServer.getBaseChannel();
        assertEquals(parent.getId(), test.getId());
        
        assertEquals(2, testServer.getChannels().size());
    }
    
    public void testCustomDataValues() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Org org = user.getOrg();
        Server testServer = createTestServer(user);

        // make sure we dont' have anything defined for this server yet
        Set vals = testServer.getCustomDataValues();
        assertEquals(0, vals.size());
        
        // create a test key and add to org
        CustomDataKey testKey = CustomDataKeyTest.createTestCustomDataKey(user);
        org.addCustomDataKey(testKey);
        assertTrue(org.hasCustomDataKey(testKey.getLabel()));
        assertNull(testServer.getCustomDataValue(testKey));
        
        // add the test key to the server and make sure we can get to it.
        testServer.addCustomDataValue(testKey.getLabel(), "foo", user);
        assertNotNull(testServer.getCustomDataValue(testKey));
        assertTrue(testServer.getCustomDataValues().size() > 0);
        
        // try sending null for key
        int numVals = testServer.getCustomDataValues().size();
        try {
            testServer.addCustomDataValue(new CustomDataKey(), "foo", user);
            fail("server.addCustomDataValue() allowed a value set for an undefined key.");
        }
        catch (UndefinedCustomDataKeyException e) {
            //success
        }
        assertEquals(numVals, testServer.getCustomDataValues().size());
        
    }
    
    public void testServerLookup() {
        assertNull(ServerFactory.lookupByIdAndOrg(new Long(-1234), usr.getOrg()));
        assertNotNull(ServerFactory.lookupByIdAndOrg(server.getId(),
                usr.getOrg()));
    }

    public void testServerArchLookup() {
        assertNull(ServerFactory.lookupServerArchByLabel("8dafs8320921kfgbzz"));
        assertNotNull(ServerFactory.lookupServerArchByLabel("i386-redhat-linux"));
    }
    
    public void testServerGroupType() throws Exception {
        //let's hope nobody calls their server group this
        assertNull(ServerFactory.lookupServerGroupTypeByLabel("8dafs8320921kfgbzz"));
        assertNotNull(ServerConstants.getServerGroupTypeUpdateEntitled());
        assertNotNull(ServerFactory.lookupServerGroupTypeByLabel(
                ServerConstants.getServerGroupTypeUpdateEntitled().getLabel()));
    }
    
    public void testCreateServer() throws Exception {
        Server newS = createTestServer(usr);
        newS.setNetworkInterfaces(new HashSet());
        // make sure our many-to-one mappings were set and saved
        assertNotNull(newS.getOrg());
        assertNotNull(newS.getCreator());
        assertNotNull(newS.getServerArch());
        assertNotNull(newS.getProvisionState());

        Note note1 = NoteTest.createTestNote();
        Note note2 = NoteTest.createTestNote();
        newS.addNote(note1);
        newS.addNote(note2);
        
        Network network1 = NetworkTest.createTestNetwork();
        Network network2 = NetworkTest.createTestNetwork();
        newS.addNetwork(network1);
        newS.addNetwork(network2);
        
        NetworkInterface netint1 = NetworkInterfaceTest.createTestNetworkInterface();
        NetworkInterface netint2 = NetworkInterfaceTest.createTestNetworkInterface();
        newS.addNetworkInterface(netint1);
        newS.addNetworkInterface(netint2);
        
        ServerFactory.save(newS);
        
        Server server2 = ServerFactory.lookupByIdAndOrg(newS.getId(), 
                usr.getOrg());
        Set notes = server2.getNotes();
        assertTrue(notes.size() == 2);
        Note note = (Note) notes.toArray()[0];
        assertEquals(server2.getId(), note.getServer().getId());
        
        Set networks = server2.getNetworks();
        assertTrue(networks.size() == 2);
        Network net = (Network) networks.toArray()[0];
        assertEquals(server2.getId(), net.getServer().getId());
        
        Set interfaces = server2.getNetworkInterfaces();
        assertTrue(interfaces.size() == 2);
        NetworkInterface netint = (NetworkInterface) interfaces.toArray()[0];
        assertEquals(server2.getId(), netint.getServer().getId());
    }        

    /**
     * Test editing a server group.
     * @throws Exception
     */
    public void testServerGroups() throws Exception {
        Long id = server.getId();
        
        Collection servers = new ArrayList();
        servers.add(server);
        ServerGroupManager manager = ServerGroupManager.getInstance();
        usr.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        ManagedServerGroup sg1 = manager.create(usr, "FooFooFOO", "Foo Description");
        manager.addServers(sg1, servers, usr);
        
        server = (Server)reload(server);
        assertTrue(server.getEntitledGroups().size() == 1);
        assertTrue(server.getManagedGroups().size() == 1);
        
        
        String changedName = "The group name has been changed" + 
            TestUtils.randomString();
        sg1.setName(changedName);
        
        ServerFactory.save(server);
        
        //Evict from session to make sure that we get a fresh server
        //from the db.
        HibernateFactory.getSession().evict(server);
        
        Server server2 = ServerFactory.lookupByIdAndOrg(id, usr.getOrg());
        assertTrue(server2.getManagedGroups().size() == 1);
        sg1 = (ManagedServerGroup) server2.getManagedGroups().iterator().next();
        
        assertEquals(changedName, sg1.getName());
        
    }
    
    public void testAddRemove() throws Exception {

        //Test adding/removing server from group
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        ServerGroupTestUtils.createManaged(user);
        Server testServer = createTestServer(user);
        Org org = user.getOrg();
        
        ManagedServerGroup group = (ManagedServerGroup)
                                                    org.getManagedServerGroups().
                                                        iterator().next();

        assertNotNull(group);
        ServerGroupFactory.save(group);
        Long membersBefore = group.getCurrentMembers();
        
        ServerFactory.addServerToGroup(testServer, group);
        //HibernateFactory.getSession().refresh(group);
        Long membersAfter = group.getCurrentMembers();
        
        assertTrue(membersBefore.intValue() < membersAfter.intValue());
        
        ServerFactory.removeServerFromGroup(testServer, group);
        group = (ManagedServerGroup) reload(group);
        
        Long membersFinally = group.getCurrentMembers();
        assertEquals(membersBefore, membersFinally);
        
    }
    
    public void testAddNoteToServer() throws Exception {
        Set notes = server.getNotes();
        assertNotNull(notes);
        assertTrue(notes.isEmpty());
        
        Note note = new Note();
        note.setCreator(usr);
        note.setSubject("Test Note subject");
        note.setNote("Body text");
        Note note2 = new Note();
        note2.setCreator(usr);
        note2.setSubject("Test Note 2 subject");
        note2.setNote("Body of note");
        
        server.addNote(note);
        server.addNote(note2);
        server.addNote(usr, "Test Note 3 subject", "Boddy of note");
        ServerFactory.save(server);
        //Evict from session to make sure that we get a fresh server
        //from the db.
        flushAndEvict(server);
        Server server2 = ServerFactory.lookupByIdAndOrg(server.getId(), 
                usr.getOrg());
        notes = server2.getNotes();
        assertNotNull(notes);
        assertFalse(notes.isEmpty());
        assertEquals(3, notes.size());
    }
    
    public void testAddDeviceToServer() throws Exception {
        
        Set devs = server.getDevices();
        assertNotNull(devs);
        assertTrue(devs.isEmpty());
        
        // create two devices
        Device audio = new Device();
        audio.setBus(Device.BUS_PCI);
        audio.setDeviceClass(Device.CLASS_AUDIO);
        audio.setProp1("Zeus Vendor");
        
        Device usb = new Device();
        usb.setBus(Device.BUS_USB);
        usb.setDeviceClass(Device.CLASS_USB);
        usb.setProp1("Some property");
        
        // add devices to the server and store
        server.addDevice(audio);
        server.addDevice(usb);
        ServerFactory.save(server);
        
        //Evict from session to make sure that we get a fresh server
        //from the db.
        flushAndEvict(server);
        
        Server server2 = ServerFactory.lookupByIdAndOrg(server.getId(), 
                usr.getOrg());
        devs = server2.getDevices();
        assertNotNull(devs);
        assertFalse(devs.isEmpty());
        assertEquals(2, devs.size());
    }
    
    public void testAddingRamToServer() throws Exception {
        server.setRam(1024);
        assertEquals(1024, server.getRam());
        
        server.setSwap(256);
        assertEquals(256, server.getSwap());
        
        ServerFactory.save(server);
        //Evict from session to make sure that we get a fresh server
        //from the db.
        flushAndEvict(server);
        
        Server server2 = ServerFactory.lookupByIdAndOrg(server.getId(), 
                usr.getOrg());
        assertEquals(1024, server2.getRam());
        assertEquals(256, server2.getSwap());
    }
    
    public void testAddingDmiToServer() throws Exception {
        
        Dmi dmi = new Dmi();
        dmi.setServer(server);
        dmi.setVendor("ZEUS computers");
        dmi.setSystem("1234UKX");
        dmi.setProduct("1234UKX");
        dmi.setBios("IBM", "PDKT28AUS", "10/21/1999");
        dmi.setAsset("(board: CNR780A1K11) (system: 23N7011)");
        dmi.setBoard("MSI");
        
        server.setDmi(dmi);
        
        assertEquals(dmi, server.getDmi());
        
        ServerFactory.save(server);
        //Evict from session to make sure that we get a fresh server
        //from the db.
        flushAndEvict(server);
        
        Server server2 = ServerFactory.lookupByIdAndOrg(server.getId(), 
                usr.getOrg());
        assertEquals(dmi, server2.getDmi());
    }
    
    /**
     * Test making two Servers.
     * @throws Exception
     */
    public void testTwoServers() throws Exception {
        Server s1 = createTestServer(usr);
        Server s2 = createTestServer(usr);
        assertNotNull(s1);
        assertNotNull(s2);
    }
    
    /**
     * Test server is not Solaris.
     * @throws Exception
     */
    public void testNotSolarisServer() throws Exception {
        Server s1 = createTestServer(usr);
        assertFalse(s1.isSolaris());
    }
    
    public void testGetChildChannels() throws Exception {
        Server s1 = ServerTestUtils.createTestSystem(usr);
        assertNull(s1.getChildChannels());

        s1.addChannel(ChannelTestUtils.createChildChannel(usr, s1.getBaseChannel()));
        s1.addChannel(ChannelTestUtils.createChildChannel(usr, s1.getBaseChannel()));
        assertEquals(2, s1.getChildChannels().size());
    }

    /**
     * Test that server has a specific entitlement.
     * @throws Exception
     */
    public void aTestServerHasSpecificEntitlement() throws Exception {

        Server s = createTestServer(usr);

        // Add three different entitlements.

        SystemManager.entitleServer(s, EntitlementManager.PROVISIONING);
        SystemManager.entitleServer(s, EntitlementManager.MONITORING);
        SystemManager.entitleServer(s, EntitlementManager.NONLINUX);

        // Check the last entitlement we added.

        assertTrue(s.hasEntitlement(EntitlementManager.NONLINUX));

    }

    /**
     * Test that server does not have a specific entitlement.
     * @throws Exception
     */
    public void testServerDoesNotHaveSpecificEntitlement() throws Exception {

        // The default test server should not have a monitoring entitlement.

        Server s = createTestServer(usr);
        assertFalse(s.hasEntitlement(EntitlementManager.MONITORING));
    }
    
    public void testFindVirtHostsExceedingGuestLimitByOrg() throws Exception {
        HostBuilder builder = new HostBuilder(usr);
        List expectedViews = new ArrayList();
        
        expectedViews.add(builder.createVirtHost().withGuests(10).build()
                .asHostAndGuestCountView());
        expectedViews.add(builder.createVirtHost().withGuests(6).build()
                .asHostAndGuestCountView());
        expectedViews.add(builder.createVirtHost().withGuests(1).build()
                .asHostAndGuestCountView());
        
        builder.createVirtHost().withUnregisteredGuests(2);
        
        builder.createVirtPlatformHost().withGuests(5).build();
        builder.createVirtPlatformHost().withGuests(2).build();
        
        builder.createNonVirtHost().withGuests(2).build();
        builder.createNonVirtHost().withGuests(5).build();
                
        List actualViews = ServerFactory.findVirtHostsExceedingGuestLimitByOrg(
                usr.getOrg());
        
        assertTrue(CollectionUtils.isEqualCollection(expectedViews, actualViews));        
    }
    
    public void testFindVirtPlatformHostsByOrg() throws Exception {
        HostBuilder builder = new HostBuilder(usr);
        List expectedViews = new ArrayList();
        
        expectedViews.add(builder.createVirtPlatformHost().withGuests(1).build()
                .asHostAndGuestCountView());
        expectedViews.add(builder.createVirtPlatformHost().withGuests(3).build()
                .asHostAndGuestCountView());
        expectedViews.add(builder.createVirtPlatformHost().withGuests(8).build()
                .asHostAndGuestCountView());
        
        builder.createVirtPlatformHost().withUnregisteredGuests(2);
        
        builder.createVirtHost().withGuests(2).build();
        builder.createVirtHost().withGuests(6).build();
        
        builder.createNonVirtHost().withGuests(3).build();
        builder.createNonVirtHost().withGuests(5).build();
        
        List actualViews = ServerFactory.findVirtPlatformHostsByOrg(usr.getOrg());
        
        assertTrue(CollectionUtils.isEqualCollection(expectedViews, actualViews));
    }    

    /**
     * Create a test Server and commit it to the DB.
     * @param owner the owner of this Server
     * @return Server that was created
     */
    public static Server createTestServer(User owner) throws Exception {
        return createTestServer(owner, false);
    }
    
    public static Server createTestServer(User owner, boolean ensureOwnerAccess,
            ServerGroupType type) throws Exception {
        return createTestServer(owner, ensureOwnerAccess, type, TYPE_SERVER_NORMAL, 
                                new Date());
    }
    
    public static Server createTestServer(User owner, boolean ensureOwnerAccess,
            ServerGroupType type, Date dateCreated) throws Exception {
        return createTestServer(owner, ensureOwnerAccess, type, TYPE_SERVER_NORMAL, 
                                dateCreated);
    }
    
    public static Server createTestServer(User owner, boolean ensureOwnerAccess,
            ServerGroupType type, int stype) throws Exception {
        return createTestServer(owner, ensureOwnerAccess, type, stype, new Date());
    }

    /**
     * Create a test Server and commit it to the DB.
     * @param owner the owner of this Server
     * @param ensureOwnerAccess this flag will make sure the owner passed in has
     *                          access to the new server. 
     * @return Server that was created
     */
    private static Server createTestServer(User owner, boolean ensureOwnerAccess,
            ServerGroupType type, int stype, Date dateCreated)
        throws Exception {
        
        //Create a server and a server group
        EntitlementServerGroup sg = ServerGroupTestUtils.createEntitled(owner.getOrg(),
                                                                        type);
        if (sg.getMaxMembers() != null) {
            sg.setMaxMembers(new Long(sg.getMaxMembers().longValue() + 10L));
        }
        Server newS = createServer(stype);
        
        // We have to commit this change manually since 
        // ServerGroups aren't actually mapped from within 
        // the Server class.
        TestUtils.saveAndFlush(owner);
        
        populateServer(newS, owner, stype);
        createProvisionState(newS, "Test Description", "Test Label");
        createServerInfo(newS, dateCreated, new Long(0));
        
        NetworkInterface netint = new NetworkInterface();
        netint.setBroadcast("foo.bar.doo.doo");
        netint.setHwaddr("AA:AA:BB:BB:CC:CC");
        netint.setIpaddr("127.0.0.1");
        netint.setModule("test");
        netint.setNetmask("255.255.255.0");
        
        netint.setName(TestUtils.randomString());
        
        netint.setServer(newS);
        newS.addNetworkInterface(netint);


        
        ServerFactory.save(newS);
        ServerFactory.addServerToGroup(newS, sg);

        /* Since we added a server to the Org we need
         * to update the User's permissions as associated with
         * that server (if the caller wants us to)
         * 
         * Here is a diagram of the table structure.  We want to update USP, but that
         * happens indirectly through rhn_cache.update_perms_for_user.  Therefore, we
         * have to update SGM and USGP in order to connect the dots.
         * SGM happened with ServerFactory.addServerToGroup(newS, sg).  Now we update
         * USGP with UserManager.grantServerGroupPermission(owner, sg.getId().longValue()).
         * 
         * |-----|                 |-----|
         * | USP |------|   |------|USGP |                  USP = rhnUserServerPerms
         * |-----|      |   |      |-----|                  USGP = rhnUserServerGroupPerms
         *    |         |   |         |                     S = rhnServer
         *    |         |   |         |                     WC = web_contact
         *    v         v   v         v                     SG = rhnServerGroup
         * |-----|     |-----|     |-----|                  SGM = rhnServerGroupMembers
         * |  S  |     | WC  |     | SG  |
         * |-----|     |-----|     |-----|
         *    ^                       ^
         *    |                       |
         *    |        |-----|        |
         *    |--------| SGM |--------|
         *             |-----|
         */
        if (ensureOwnerAccess) {
            ManagedServerGroup sg2 = ServerGroupTestUtils.createManaged(owner);
            ServerFactory.addServerToGroup(newS, sg2);
            TestUtils.saveAndFlush(sg2);
        }

        /*
         * Since adding a server to a group is done by a stored proc, the 
         * server object at this point doesn't know it has any groups; ie., 
         * newS.getGroups() == null. To fix this, we need to evict newS
         * from the session and look it back up.
         * This shouldn't be a problem in prod, just something we have to do 
         * in our test code until we move to hib3 and can work with stored 
         * procs.
         */
        // commitAndCloseSession();
        // System.out.println("COMMITED SESSION!\n\n");
        
        
        Long id = newS.getId();
        HibernateFactory.getSession().flush();
        HibernateFactory.getSession().evict(newS);
        newS = ServerFactory.lookupByIdAndOrg(id, owner.getOrg());
        assertNotNull(newS.getEntitledGroups());
        assertNotNull(newS.getManagedGroups());
        assertNotNull(newS.getServerInfo());
        assertNotNull(newS.getServerInfo().getCheckinCounter());
        return newS;
    }
    
    private static void populateServer(Server s, User owner, int type) throws Exception {
        s.setCreator(owner);
        s.setOrg(owner.getOrg());
        s.setDigitalServerId("ID-" + TestUtils.randomString());
        s.setOs("Red Hat Linux");
        s.setRunningKernel(RUNNING_KERNEL);
        s.setName("serverfactorytest" + TestUtils.randomString() + ".rhn.redhat.com");
        s.setRelease("9");
        s.setSecret("999999999999999");
        s.setAutoDeliver("N");
        s.setAutoUpdate("N");
        s.setLastBoot(new Long(System.currentTimeMillis()));
        s.setServerArch(ServerFactory.lookupServerArchByLabel("i386-redhat-linux"));
        s.setCreated(new Date());
        s.setModified(new Date());
        s.setRam(1024);
        
        if (type == TYPE_SERVER_SATELLITE) {
            SatelliteServer ss = (SatelliteServer) s;
            //ideally we should read in a valid cert and pass it in to setCert
            ss.setCert("dummy blob");
            ss.setProduct("SPACEWALK-001");
            ss.setOwner("Spacewalk Test Cert");
            ss.setIssued("2007-07-13 00:00:00");
            ss.setExpiration("2020-07-13 00:00:00");
            ss.setVersion("4.0");
        } 
        else if (type == TYPE_SERVER_PROXY) {
            ProxyInfo info = new ProxyInfo();
            info.setVersion("10", "10", "10");
            info.setServer(s);
            s.setProxyInfo(info);
        }
    }
    
    private static ProvisionState createProvisionState(Server srvr,
            String description, String label) {
        // Create/Set provisionState
        ProvisionState p = new ProvisionState();
        p.setDescription(description);
        p.setLabel(label + TestUtils.randomString());
        srvr.setProvisionState(p);
        
        return p;
    }
    
    private static ServerInfo createServerInfo(Server srvr, Date checkin, Long cnt) {
        ServerInfo si = new ServerInfo();
        si.setCheckin(checkin);
        si.setCheckinCounter(cnt);
        si.setServer(srvr);
        srvr.setServerInfo(si);
        return si;
    }
    
    public static Server createTestServer(User owner, boolean ensureOwnerAccess)
        throws Exception {
        
        return createTestServer(owner, ensureOwnerAccess,
                ServerConstants.getServerGroupTypeUpdateEntitled());
    }
    
    private static Server createServer(int type) {
        switch(type) {
            case TYPE_SERVER_SATELLITE:
                return new SatelliteServer();
            case TYPE_SERVER_PROXY:
            case TYPE_SERVER_NORMAL:
                return ServerFactory.createServer();
            
            default:
                return null;
        }
    }
    
    // This may be busted , can comment out
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
        UserManager.storeUser(user);
        
        Server srvr = createTestServer(user, true,
                ServerFactory.lookupServerGroupTypeByLabel("enterprise_entitled"));
        
        Server srvr1 = createTestServer(user, true,
                ServerFactory.lookupServerGroupTypeByLabel("enterprise_entitled"));
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        srvr.addChannel(channel);
        srvr1.addChannel(channel);
        ServerFactory.save(srvr);
        ServerFactory.save(srvr1);
        flushAndEvict(srvr1);
        srvr = (Server) reload(srvr);
        // Ok let's finally test what we came here for.
        List list = ServerFactory.compatibleWithServer(user, srvr);
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
    
    public void testListAdministrators() throws Exception {
       
        //The org admin user
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        admin.addRole(RoleFactory.ORG_ADMIN);        

        //the non-orgadmin user who is a member of the group
        User regular =   UserTestUtils.createUser("testUser2", admin.getOrg().getId());
        regular.removeRole(RoleFactory.ORG_ADMIN);
        
        //a user who shouldn't be able to admin the system
        User nonGroupAdminUser = UserTestUtils.createUser(
                 "testUser3", admin.getOrg().getId());
        nonGroupAdminUser.removeRole(RoleFactory.ORG_ADMIN);
        
        ManagedServerGroup group = ServerGroupTestUtils.createManaged(admin);  
               
        //create server set and add it to the group
        Server serverToSearch = ServerFactoryTest.createTestServer(admin, true);
        Set servers = new HashSet();
        servers.add(serverToSearch);
        ServerGroupManager manager = ServerGroupManager.getInstance();
        manager.addServers(group, servers, admin);
        assertTrue(group.getServers().size() > 0);
        //create admins set and add it to the grup
        Set admins = new HashSet();
        admins.add(regular);
        manager.associateAdmins(group, admins, admin);
        assertTrue(manager.canAccess(regular, group));
        ServerGroupFactory.save(group);        
        group = (ManagedServerGroup) reload(group);
        UserFactory.save(admin);
        admin = (User) reload(admin);
        UserFactory.save(regular);
        regular = (User) reload(regular);
        UserFactory.save(nonGroupAdminUser);
        nonGroupAdminUser = (User) reload(nonGroupAdminUser);

        List <User> users = ServerFactory.listAdministrators(serverToSearch);
        System.out.println(users);
        System.out.println("regular->" + regular);
        System.out.println("Admins->" + admins);
        boolean containsAdmin = false;
        boolean containsRegular = false;     
        boolean containsNonGroupAdmin = false;  //we want this to be false to pass

        for (User user : users) {
              if (user.getLogin().equals(admin.getLogin())) {
                  containsAdmin = true;
              }
              if (user.getLogin().equals(regular.getLogin())) {
                  containsRegular = true;
              }
              if (user.getLogin().equals(nonGroupAdminUser.getLogin())) {
                  containsNonGroupAdmin = true;
              }
        }
         assertTrue(containsAdmin);
         assertTrue(containsRegular);
         assertFalse(containsNonGroupAdmin);                 
      }
        
    public void testGetServerHistory() throws Exception {

        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        Server serverTest = ServerFactoryTest.createTestServer(u);
        ServerHistoryEvent event1 = new ServerHistoryEvent();
        event1.setSummary("summary1");
        event1.setDetails("details1");
        event1.setServer(serverTest);

        Set history = serverTest.getHistory();
        history.add(event1);

        ServerFactory.save(serverTest);
        TestUtils.saveAndFlush(event1);
        event1 = (ServerHistoryEvent) reload(event1);

        assertEquals(((ServerHistoryEvent) serverTest.getHistory().toArray()[0]),
                    event1);
    }
 
    
    /**
     * Creates a true proxy server by creating a test system, creating a base channel, 
     *      subscribing the system to that base channel, creating a child channel, 
     *      setting all the values of that child channel to make it a proxy channel,
     *      and then activating the system as a proxy
     * @param owner user that is creating the proxy
     * @param ensureOwnerAccess if set to true, a Server Group will be created for that 
     *          user and system
     * @return the created proxy server
     * @throws Exception
     */
    public static Server createTestProxyServer(User owner, boolean ensureOwnerAccess) 
                throws Exception {
        Server server = createTestServer(owner, ensureOwnerAccess);
        Channel baseChan = ChannelFactoryTest.createBaseChannel(owner);
        server.addChannel(baseChan);
        
        Channel proxyChan = ChannelFactoryTest.createTestChannel(owner);
        Set chanFamilies = new HashSet();
        
        ChannelFamily proxyFam = ChannelFamilyFactory.lookupByLabel(
                ChannelFamilyFactory.PROXY_CHANNEL_FAMILY_LABEL, owner.getOrg());
        if (proxyFam == null) {
            proxyFam = ChannelFamilyFactoryTest.createTestChannelFamily(owner);
            proxyFam.setLabel(ChannelFamilyFactory.PROXY_CHANNEL_FAMILY_LABEL);
            ChannelFamilyFactory.save(proxyFam);
        }
        chanFamilies.add(proxyFam);
        
        ChannelProduct product = new ChannelProduct();
        product.setProduct("proxy" + TestUtils.randomString());
        product.setVersion("1.1");
        product.setBeta(false);
        proxyChan.setProduct(product);  
        proxyChan.setChannelFamilies(chanFamilies);
        proxyChan.setParentChannel(baseChan);
        
        ChannelFactory.save(baseChan);
        ChannelFactory.save(proxyChan);
        product = (ChannelProduct) TestUtils.saveAndReload(product);
        
        SystemManager.activateProxy(server, "1.1");
        SystemManager.storeServer(server);
        return server;
    }
    
    
    public void testUnsubscribeFromAllChannels() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg", true);
        
        ChannelFactoryTest.createBaseChannel(admin);
        Server serverIn = ServerFactoryTest.createTestServer(admin);
        
        server  = ServerFactory.unsubscribeFromAllChannels(admin, serverIn);
        assertEquals(0, server.getChannels().size());
    }
    
    public void testSet() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server serverIn = ServerFactoryTest.createTestServer(admin, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        RhnSet set = RhnSetDecl.SYSTEMS.get(admin);
        set.addElement(serverIn.getId(), null);
        RhnSetManager.store(set);
        List<Server> servers = ServerFactory.listSystemsInSsm(admin);
        assertEquals(1, servers.size());
        assertEquals(serverIn, servers.get(0));
    }    
    
    private ServerSnapshot generateSnapshot(Server server2) {
        ServerSnapshot snap = new ServerSnapshot();
        snap.setServer(server2);
        snap.setOrg(server2.getOrg());
        snap.setReason("blah");
        return snap;
    }
    
    
    public void testListSnapshotsForServer() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server2 = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server2);
        ServerGroup grp = ServerGroupTestUtils.createEntitled(server2.getOrg());
        snap.addGroup(grp);
        
        TestUtils.saveAndFlush(snap);        
        List<ServerSnapshot> list = ServerFactory.listSnapshots(server2.getOrg(), 
                server2, null, null);
        assertContains(list, snap);
        assertContains(snap.getGroups(), grp);
    }
    
    public void testLookupSnapshotById() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server2 = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server2);
        TestUtils.saveAndFlush(snap);
        
        ServerSnapshot snap2 = ServerFactory.lookupSnapshotById(snap.getId().intValue());
        assertEquals(snap, snap2);
    }
    
    
    public void testDeleteSnapshot() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server2 = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server2);
        TestUtils.saveAndFlush(snap);
        ServerFactory.deleteSnapshot(snap);
        boolean lost = false;
        ServerSnapshot snap2 = ServerFactory.lookupSnapshotById(
            snap.getId().intValue());
        assertNull(snap2);
    }
    
    
    public void testGetSnapshotTags() throws Exception {
        User admin = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server2 = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server2);
        
        SnapshotTag tag = new SnapshotTag();
        SnapshotTagName name = new SnapshotTagName();
        name.setName("blah");
        tag.setName(name);
        tag.setOrg(server2.getOrg());
        
        ServerSnapshotTagLink link = new ServerSnapshotTagLink();
        link.setServer(server2);
        link.setSnapshot(snap);
        link.setTag(tag);
        
        TestUtils.saveAndFlush(tag);
        TestUtils.saveAndFlush(snap);
        TestUtils.saveAndFlush(link);

        List<SnapshotTag> tags = ServerFactory.getSnapshotTags(snap);
        assertContains(tags, tag);
        
    }
    
}

