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
package com.redhat.rhn.frontend.xmlrpc.channel.software.test;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ClonedChannel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchUserException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.channel.software.ChannelSoftwareHandler;
import com.redhat.rhn.frontend.xmlrpc.errata.ErrataHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ChannelSoftwareHandlerTest
 * @version $Rev$
 */
public class ChannelSoftwareHandlerTest extends BaseHandlerTestCase {

    private ChannelSoftwareHandler handler = new ChannelSoftwareHandler();
    private ErrataHandler errataHandler = new ErrataHandler();
    
    public void testAddRemovePackages() throws Exception {
        
        // TODO : GET THIS WORKING
        // TODO : GET THIS WORKING
        // TODO : GET THIS WORKING
        if (true) {
            return;
        }
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        Package pkg1 = PackageTest.createTestPackage(admin.getOrg());
        Package pkg2 = PackageTest.createTestPackage(admin.getOrg());
        
        List packages2add = new ArrayList();
        packages2add.add(pkg1.getId());
        packages2add.add(pkg2.getId());
        
        assertEquals(0, channel.getPackages().size());
        handler.addPackages(adminKey, channel.getLabel(), packages2add);
        assertEquals(2, channel.getPackages().size());

        Long bogusId = new Long(System.currentTimeMillis());
        packages2add.add(bogusId);
        
        try {
            handler.addPackages(adminKey, channel.getLabel(), packages2add);
            fail("should have gotten a permission check failure since admin wouldn't " +
                 "have access to a package that doesn't exist.");
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        
        //Test remove packages
        assertEquals(2, channel.getPackages().size());
        try {
            handler.removePackages(adminKey, channel.getLabel(), packages2add);
            fail("should have gotten a permission check failure.");
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        
        packages2add.remove(bogusId);
        packages2add.remove(pkg2.getId());
        packages2add.add(pkg1.getId());
        assertEquals(2, packages2add.size()); // should have 2 entries for pkg1
        handler.removePackages(adminKey, channel.getLabel(), packages2add);
        assertEquals(1, channel.getPackages().size());
        
        
        // test for invalid package arches
        packages2add.clear();
        assertEquals(0, packages2add.size());
        
        PackageArch pa = PackageFactory.lookupPackageArchByLabel("x86_64");
        assertNotNull(pa);
        pkg1.setPackageArch(pa);
        TestUtils.saveAndFlush(pkg1);
        packages2add.add(pkg1.getId());
        
        try {
            handler.addPackages(adminKey, channel.getLabel(), packages2add);
            fail("incompatible package was added to channel");
        }
        catch (FaultException e) {
            assertEquals(1202, e.getErrorCode());
        }
    }
    
    public void testSetGloballySubscribable() throws Exception {
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        assertTrue(channel.isGloballySubscribable(admin.getOrg()));
        handler.setGloballySubscribable(adminKey, channel.getLabel(), false);
        assertFalse(channel.isGloballySubscribable(admin.getOrg()));
        handler.setGloballySubscribable(adminKey, channel.getLabel(), true);
        assertTrue(channel.isGloballySubscribable(admin.getOrg()));
        
        assertFalse(regular.hasRole(RoleFactory.CHANNEL_ADMIN));
        try {
            handler.setGloballySubscribable(regularKey, channel.getLabel(), false);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        assertTrue(channel.isGloballySubscribable(admin.getOrg()));
        
        try {
            handler.setGloballySubscribable(adminKey, TestUtils.randomString(), 
                                            false);
            fail();
        }
        catch (NoSuchChannelException e) {
            //success
        }
        assertTrue(channel.isGloballySubscribable(admin.getOrg()));
    }
    
    public void testSetUserSubscribable() throws Exception {
        Channel c1 = ChannelFactoryTest.createTestChannel(admin);
        c1.setGloballySubscribable(false, admin.getOrg());
        User user = UserTestUtils.createUser("foouser", admin.getOrg().getId());
        
        assertFalse(ChannelManager.verifyChannelSubscribe(user, c1.getId()));
        handler.setUserSubscribable(adminKey, c1.getLabel(), user.getLogin(), true);
        assertTrue(ChannelManager.verifyChannelSubscribe(user, c1.getId()));
        
        handler.setUserSubscribable(adminKey, c1.getLabel(), user.getLogin(), false);
        assertFalse(ChannelManager.verifyChannelSubscribe(user, c1.getId()));
        
        try {
            handler.setUserSubscribable(
                    regularKey, c1.getLabel(), user.getLogin(), true);
            fail("should have gotten a permission exception.");
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        
        try {
            handler.setUserSubscribable(adminKey, c1.getLabel(), 
                        "asfd" + TestUtils.randomString(), true);
            fail("should have gotten a permission exception.");
        }
        catch (NoSuchUserException e) {
            //success
        }
    }
    
    public void testIsUserSubscribable() throws Exception {
        Channel c1 = ChannelFactoryTest.createTestChannel(admin);
        c1.setGloballySubscribable(false, admin.getOrg());
        User user = UserTestUtils.createUser("foouser", admin.getOrg().getId());
        
        assertEquals(0, handler.isUserSubscribable(
                adminKey, c1.getLabel(), user.getLogin()));
        handler.setUserSubscribable(
                adminKey, c1.getLabel(), user.getLogin(), true);
        assertEquals(1, handler.isUserSubscribable(
                adminKey, c1.getLabel(), user.getLogin()));
        
        handler.setUserSubscribable(
                adminKey, c1.getLabel(), user.getLogin(), false);
        assertEquals(0, handler.isUserSubscribable(
                adminKey, c1.getLabel(), user.getLogin()));
    }
    
    public void testSetSystemChannelsBaseChannel() throws Exception {
        
        Channel base = ChannelFactoryTest.createTestChannel(admin);
        assertTrue(base.isBaseChannel());
        Server server = ServerFactoryTest.createTestServer(admin, true);
        Channel child = ChannelFactoryTest.createTestChannel(admin);
        child.setParentChannel(base);
        ChannelFactory.save(child);
        assertFalse(child.isBaseChannel());

        Channel child2 = ChannelFactoryTest.createTestChannel(admin);
        child2.setParentChannel(base);
        ChannelFactory.save(child2);
        assertFalse(child2.isBaseChannel());

        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        List labels = new ArrayList();
        labels.add(child.getLabel());
        // adding base last to make sure the handler does the right
        // thing regardless of where the base channel is.
        labels.add(base.getLabel());
        
        Integer sid = new Integer(server.getId().intValue());
        int rc = csh.setSystemChannels(adminKey, sid, labels);
        
        server = (Server) reload(server);
        
        // now verify
        assertEquals(1, rc);
        assertEquals(2, server.getChannels().size());
        Channel newBase = server.getBaseChannel();
        assertNotNull(newBase);
        assertEquals(newBase.getLabel(), base.getLabel());
        
        List nobase = new ArrayList();
        nobase.add(child.getLabel());
        nobase.add(child2.getLabel());
        
        try {
            rc = csh.setSystemChannels(adminKey, sid, nobase);
            fail("setSystemChannels didn't complain when given no base channel");
        }
        catch (InvalidChannelException ice) {
            // ice ice baby
        }

    }
    
    public void testSetSystemChannels() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        
        Channel c1 = ChannelFactoryTest.createTestChannel(admin);
        Server server = ServerFactoryTest.createTestServer(admin, true);
        
        List channelsToSubscribe = new ArrayList();
        channelsToSubscribe.add(c1.getLabel());
        
        assertEquals(0, server.getChannels().size());
        int result = csh.setSystemChannels(adminKey,
                             new Integer(server.getId().intValue()), channelsToSubscribe);
        
        server = (Server) reload(server);
        
        assertEquals(1, result);
        assertEquals(1, server.getChannels().size());
        
        Channel c2 = ChannelFactoryTest.createTestChannel(admin);
        assertFalse(c1.getLabel().equals(c2.getLabel()));
        channelsToSubscribe = new ArrayList();
        channelsToSubscribe.add(c2.getLabel());
        assertEquals(1, channelsToSubscribe.size());
        result = csh.setSystemChannels(adminKey,
                         new Integer(server.getId().intValue()), channelsToSubscribe);
        
        server = (Server) reload(server);
        
        assertEquals(1, result);
        Channel subscribed = (Channel) server.getChannels().iterator().next();
        assertTrue(server.getChannels().contains(c2));
        
        //try to make it break
        channelsToSubscribe = new ArrayList();
        channelsToSubscribe.add(TestUtils.randomString());
        try {
            csh.setSystemChannels(adminKey,
                         new Integer(server.getId().intValue()), channelsToSubscribe);
            fail("subscribed system to invalid channel.");
        }
        catch (Exception e) {
            //success
        }

        server = (Server) reload(server);
        //make sure servers channel subscriptions weren't changed
        assertEquals(1, result);
        subscribed = (Channel) server.getChannels().iterator().next();
        assertEquals(c2.getLabel(), subscribed.getLabel());
        
        // try setting the base channel of an s390 server to 
        // IA-32.
        try {
            
            Channel c3 = ChannelFactoryTest.createTestChannel(admin);
            List channels = new ArrayList();
            channels.add(c3.getLabel());
            assertEquals(1, channels.size());

            // change the arch of the server
            server.setServerArch(
                    ServerFactory.lookupServerArchByLabel("s390-redhat-linux"));
            ServerFactory.save(server);

            int rc = csh.setSystemChannels(adminKey,
                    new Integer(server.getId().intValue()), channels);
            
            fail("allowed incompatible channel arch to be set, returned: " + rc);
        }
        catch (InvalidChannelException e) {
            // success
        }
    }
    
    public void testListSystemChannels() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        
        Channel c = ChannelFactoryTest.createTestChannel(admin);
        Server s = ServerFactoryTest.createTestServer(admin, true);
        
        //Server shouldn't have any channels yet
        Object[] result = csh.listSystemChannels(adminKey, 
                                  new Integer(s.getId().intValue()));
        assertEquals(0, result.length);
        
        SystemManager.subscribeServerToChannel(admin, s, c);
        
        //should be subscribed to 1 channel
        result = csh.listSystemChannels(adminKey,
                         new Integer(s.getId().intValue()));
        assertEquals(1, result.length);
        
        //try no_such_system fault exception
        try {
            csh.listSystemChannels(adminKey, new Integer(-2390));
            fail("ChannelSoftwareHandler.listSystemChannels didn't throw an exception " +
                 "for invalid system id");
        }
        catch (FaultException e) {
            //success
        }
    }
    
    public void testListSubscribedSystems() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        
        Channel c = ChannelFactoryTest.createTestChannel(admin);
        Server s = ServerFactoryTest.createTestServer(admin);
        SystemManager.subscribeServerToChannel(admin, s, c);
        flushAndEvict(c);
        flushAndEvict(s);
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        
        Object[] result = csh.listSubscribedSystems(adminKey, c.getLabel());
        assertTrue(result.length > 0);
        
        //NoSuchChannel
        try {
            result = csh.listSubscribedSystems(adminKey, TestUtils.randomString());
            fail("ChannelSoftwareHandler.listSubscribedSystemd didn't throw " +
                 "NoSuchChannelException.");
        }
        catch (NoSuchChannelException e) {
            //success
        }
        
        //Permission
        try {
            result = csh.listSubscribedSystems(regularKey, c.getLabel());
            fail("Regular user allowed access to channel system list.");
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
    }
    
    public void testListArches() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        Object[] arches = csh.listArches(adminKey);
        assertNotNull(arches);
        assertTrue(arches.length > 0);
        for (int i = 0; i < arches.length; i++) {
            assertEquals(ChannelArch.class, arches[i].getClass());
        }
    }
    
    public void testListArchesPermissionError() {
        try {
            ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
            Object[] arches = csh.listArches(adminKey);
            assertNotNull(arches);
            assertTrue(arches.length > 0);
            for (int i = 0; i < arches.length; i++) {
                assertEquals(ChannelArch.class, arches[i].getClass());
            }
        }
        catch (PermissionCheckFailureException e) {
            assertTrue(true);
        }
    }
    
    public void testDeleteChannel() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        Channel c = ChannelFactoryTest.createTestChannel(admin);
        String label = c.getLabel();
        c = (Channel) reload(c);
        assertEquals(1, csh.delete(adminKey, label));
        // should be assertTrue
        assertNull(reload(c));
    }
    
    public void testIsGloballySubscribable() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        Channel c = ChannelFactoryTest.createTestChannel(admin);
        assertEquals(1, csh.isGloballySubscribable(adminKey, c.getLabel()));
        // should be assertTrue
    }

    public void testIsGloballySubscribableNoSuchChannel() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        try {
            csh.isGloballySubscribable(adminKey, "notareallabel");
            fail();
        }
        catch (NoSuchChannelException e) {
            // expected
        }
    }
    
    public void testGetDetails() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        Channel c = ChannelFactoryTest.createTestChannel(admin);
        assertNotNull(c);
        assertNull(c.getParentChannel());
        
        Channel  result = csh.getDetails(adminKey, c.getLabel());
        channelDetailsEquality(c, result);       
        
        result = csh.getDetails(adminKey, c.getId().intValue());
        channelDetailsEquality(c, result);
    }

    private void channelDetailsEquality(Channel original, Channel result) {
        assertNotNull(result);
        assertEquals(original.getId(), result.getId());
        assertEquals(original.getLabel(), result.getLabel());
        assertEquals(original.getName(), result.getName());
        assertEquals(original.getChannelArch().getName(), 
                result.getChannelArch().getName());
        assertEquals(original.getSummary(), result.getSummary());
        assertEquals(original.getDescription(), result.getDescription());
        
        assertEquals(original.getMaintainerName(), result.getMaintainerName());
        assertEquals(original.getMaintainerEmail(), result.getMaintainerEmail());
        assertEquals(original.getMaintainerPhone(), result.getMaintainerPhone());
        assertEquals(original.getSupportPolicy(), result.getSupportPolicy());
        
        assertEquals(original.getGPGKeyUrl(), result.getGPGKeyUrl());
        assertEquals(original.getGPGKeyId(), result.getGPGKeyId());
        assertEquals(original.getGPGKeyFp(), result.getGPGKeyFp());
        if (original.getEndOfLife() != null) {
            assertEquals(original.getEndOfLife().toString(), 
                    result.getEndOfLife().toString());
        }
        else {
            assertEquals(null, result.getEndOfLife());
        }
        
        assertEquals(null, result.getParentChannel());
    }
    
        
    public void testCreate() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        int i = csh.create(adminKey, "api-test-chan-label",
                "apiTestChanName", "apiTestSummary", "channel-x86_64", null);
        assertEquals(1, i);
        Channel c = ChannelFactory.lookupByLabel(admin.getOrg(), "api-test-chan-label");
        assertNotNull(c);
        assertEquals("apiTestChanName", c.getName());
        assertEquals("apiTestSummary", c.getSummary());
        ChannelArch ca = ChannelFactory.findArchByLabel("channel-x86_64");
        assertNotNull(ca);
        assertNotNull(c.getChannelArch());
        assertEquals(ca.getLabel(), c.getChannelArch().getLabel());
        assertEquals(c.getChecksumTypeLabel(), "sha1");
    }
    
    public void testCreateWithChecksum() throws Exception {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        int i = csh.create(adminKey, "api-test-checksum-chan-label",
                "apiTestCSChanName", "apiTestSummary", "channel-ia32", null, "sha256");
        assertEquals(1, i);
        Channel c = ChannelFactory.lookupByLabel(admin.getOrg(), 
                                   "api-test-checksum-chan-label");
        assertNotNull(c);
        assertEquals("apiTestCSChanName", c.getName());
        assertEquals("apiTestSummary", c.getSummary());
        ChannelArch ca = ChannelFactory.findArchByLabel("channel-ia32");
        assertNotNull(ca);
        assertNotNull(c.getChannelArch());
        assertEquals(ca.getLabel(), c.getChannelArch().getLabel());
        assertEquals(c.getChecksumTypeLabel(), "sha256");
    }
    
    public void testCreateUnauthUser() {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        try {
            csh.create(regularKey, "api-test-chan-label",
                   "apiTestChanName", "apiTestSummary", "channel-x86_64", null);
            fail("create did NOT throw an exception");

        }
        catch (PermissionCheckFailureException e) {
            // expected
        }
        catch (InvalidChannelLabelException e) {
            fail("Wasn't expecting this in this test.");
        }
        catch (InvalidChannelNameException e) {
            fail("Wasn't expecting this in this test.");
        }
        catch (InvalidParentChannelException e) {
            fail("Wasn't expecting this in this test.");
        }
    }
    
    public void testCreateNullRequiredParams() {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        // null label
        try {
            csh.create(adminKey, null, "api-test-nonnull", "api test summary",
                    "channel-x86_64", null);
            fail("create did not throw exception when given a null label");
        }
        catch (IllegalArgumentException iae) {
            fail("Wasn't expecting this in this test.");
        }
        catch (PermissionCheckFailureException e) {
            fail("We're not looking for this exception right now");
        }
        catch (InvalidChannelLabelException expected) {
            // expected
        }
        catch (InvalidChannelNameException e) {
            fail("Wasn't expecting this in this test.");
        }
        catch (InvalidParentChannelException e) {
            fail("Wasn't expecting this in this test.");
        }
        
        try {
            csh.create(adminKey, "api-test-nonnull", null, "api test summary",
                    "channel-x86_64", null);
            fail("create did not throw exception when given a null label");
        }
        catch (IllegalArgumentException iae) {
            fail("Wasn't expecting this in this test.");
        }
        catch (PermissionCheckFailureException e) {
            fail("We're not looking for this exception right now");
        }
        catch (InvalidChannelLabelException e) {
            fail("Wasn't expecting this in this test.");
        }
        catch (InvalidChannelNameException expected) {
            // expected
        }
        catch (InvalidParentChannelException e) {
            fail("Wasn't expecting this in this test.");
        }
    }
    
    public void testInvalidChannelNameAndLabel() {
        ChannelSoftwareHandler csh = new ChannelSoftwareHandler();
        addRole(admin, RoleFactory.CHANNEL_ADMIN);
        int i;
        try {
            i = csh.create(adminKey, "api-test-chan-label",
                    "apiTestChanName", "apiTestSummary", "channel-x86_64", null);
            assertEquals(1, i);
        }
        catch (Exception e) {
            fail("Not looking for this");
        }

        // ok now for the real test.
        
        try {
            csh.create(adminKey, "api-test-chan-label",
                    "apiTestChanName", "apiTestSummary", "channel-x86_64", null);
        }
        catch (PermissionCheckFailureException e) {
            fail("Not looking for this");
        }
        catch (InvalidChannelLabelException e) {
            fail("Not looking for this");
        }
        catch (InvalidChannelNameException e) {
            // do nothing, this we expect
        }
        catch (InvalidParentChannelException e) {
            fail("Wasn't expecting this in this test.");
        }
        
        try {
            csh.create(adminKey, "api-test-chan-label",
                    "apiTestChanName1010101", "apiTestSummary", "channel-x86_64", null);
        }
        catch (PermissionCheckFailureException e) {
            fail("Not looking for this");
        }
        catch (InvalidChannelLabelException e) {
            // do nothing, this we expect
        }
        catch (InvalidChannelNameException e) {
            fail("Not looking for this");
        }
        catch (InvalidParentChannelException e) {
            fail("Wasn't expecting this in this test.");
        }
    }
    
    public void testSetContactDetails() throws Exception {

        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);
        
        assertNull(channel.getMaintainerName());
        assertNull(channel.getMaintainerEmail());
        assertNull(channel.getMaintainerPhone());
        assertNull(channel.getSupportPolicy());

        // execute
        int result = handler.setContactDetails(adminKey, channel.getLabel(), 
                "John Doe", "jdoe@somewhere.com", "9765551212", "No Policy");
        
        // verify
        assertEquals(1, result);

        channel = ChannelFactory.lookupByLabelAndUser(channel.getLabel(), admin);
        
        assertEquals("John Doe", channel.getMaintainerName());
        assertEquals("jdoe@somewhere.com", channel.getMaintainerEmail());
        assertEquals("9765551212", channel.getMaintainerPhone());
        assertEquals("No Policy", channel.getSupportPolicy());
    }

    public void testAllPackages() throws Exception {
    }
    
    public void testListErrata() throws NoSuchChannelException {
    }
    
    public void testBadChannelLabelAllPackages() {
    }
    
    public void testBadChannelLabelLatestPackages() {
    }
    
    public void testBadChannelLabelAllPackagesByDate() {
    }
    
//    public void testClone() {
//        assertEquals(1,
//            handler.clone(adminKey, "rhel-i386-server-5", "api-clone-rhel5"));
//    }
    
    
    public void testListPackagesWithoutChannel() throws Exception {
        
        
        Object[] iniailList = handler.listPackagesWithoutChannel(adminKey);
        
        PackageTest.createTestPackage(admin.getOrg());
        Package nonOrphan = PackageTest.createTestPackage(admin.getOrg());
        Channel testChan = ChannelFactoryTest.createTestChannel(admin);
        testChan.addPackage(nonOrphan);
        
        Object[] secondList = handler.listPackagesWithoutChannel(adminKey);
        
        assertEquals(1, secondList.length - iniailList.length);
    }
    
    public void testSubscribeSystem() throws Exception {
        Server server = ServerFactoryTest.createTestServer(admin);
        Channel baseChan = ChannelFactoryTest.createBaseChannel(admin);
        Channel childChan = ChannelFactoryTest.createTestChannel(admin);
        childChan.setParentChannel(baseChan);
        
        
        List labels = new ArrayList();
        labels.add(baseChan.getLabel());
        labels.add(childChan.getLabel());
        
        int returned = handler.subscribeSystem(adminKey, 
                new Integer(server.getId().intValue()), labels);
        
        assertEquals(1, returned);
        server = (Server)HibernateFactory.reload(server);
        assertEquals(2, server.getChannels().size());
        assertTrue(server.getChannels().contains(baseChan));
        assertTrue(server.getChannels().contains(childChan));
        
        labels.clear();
        returned = handler.subscribeSystem(adminKey, 
                new Integer(server.getId().intValue()), labels);
        assertEquals(1, returned);
        server = (Server)HibernateFactory.reload(server);
        assertEquals(0, server.getChannels().size());
    }
    
    
    public void testCloneAll() throws Exception {
        Channel original = ChannelFactoryTest.createTestChannel(admin);
        Package pack = PackageTest.createTestPackage();
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(
                admin.getOrg().getId());
        original.addPackage(pack);
        original.addErrata(errata);

        String label = "test-clone-label";
        Map details = new HashMap();
        details.put("name", "test-clone");
        details.put("summary", "summary");
        details.put("label", label);
        
        int id = handler.clone(adminKey, original.getLabel(), details, false);
        Channel chan = ChannelFactory.lookupById(new Long(id));
        chan = (Channel) TestUtils.reload(chan);
        assertNotNull(chan);
        assertEquals(label, chan.getLabel());
        assertEquals(1, chan.getPackages().size());
        assertEquals(1, chan.getErratas().size());
        
        // Test that we're actually creating a cloned channel:
        ClonedChannel clone = (ClonedChannel)chan;
    }
    
    /*
     * Had to make 2 testClone methods because of some hibernate oddities. 
     * (The 2nd time it looks up the roles within handler.clone, it gets a 
     *  shared resource error).
     */
    public void testCloneOriginal() throws Exception {   
        Channel original = ChannelFactoryTest.createTestChannel(admin);
        Package pack = PackageTest.createTestPackage(admin.getOrg());
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(
                admin.getOrg().getId());
        original.addPackage(pack);
        original.addErrata(errata);
        
        String label = "test-clone-label-2";
        Map details = new HashMap();
        details.put("name", "test-clone2");
        details.put("summary", "summary2");
        details.put("label", label);
        
        int id = handler.clone(adminKey, original.getLabel(), details, true);
        Channel chan = ChannelFactory.lookupById(new Long(id));
        chan = (Channel) TestUtils.reload(chan);
        
        
        assertNotNull(chan);
        assertEquals(label, chan.getLabel());
        assertEquals(1, chan.getPackages().size());
        assertEquals(0, chan.getErratas().size());
    }
    
    
    public void testMergeTo() throws Exception {
       
        Channel mergeFrom = ChannelFactoryTest.createTestChannel(admin);
        Channel mergeTo = ChannelFactoryTest.createTestChannel(admin);
        
        Package packOne = PackageTest.createTestPackage(admin.getOrg());
        Package packTwo = PackageTest.createTestPackage(admin.getOrg());
        
        mergeFrom.setOrg(null);
        mergeTo.setOrg(admin.getOrg());
        
        mergeFrom.addPackage(packOne);
        mergeFrom.addPackage(packTwo);
        mergeTo.addPackage(packOne);
        
        mergeFrom = (Channel) TestUtils.saveAndReload(mergeFrom);
        mergeTo = (Channel) TestUtils.saveAndReload(mergeTo);
        
        Object[] list =  handler.mergePackages(adminKey, mergeFrom.getLabel(), 
                mergeTo.getLabel());

        assertEquals(1, list.length);
        assertEquals(packTwo, (Package) list[0]);
    }
    
    public void testMergeErrata() throws Exception {
        Channel mergeFrom = ChannelFactoryTest.createTestChannel(admin);
        Channel mergeTo = ChannelFactoryTest.createTestChannel(admin);
        
        List fromList = handler.listErrata(adminKey, mergeFrom.getLabel());
        assertEquals(fromList.size(), 0);
        List toList = handler.listErrata(adminKey, mergeTo.getLabel());
        assertEquals(toList.size(), 0);

        Map errataInfo = new HashMap();
        String advisoryName = TestUtils.randomString();
        errataInfo.put("synopsis", TestUtils.randomString());
        errataInfo.put("advisory_name", advisoryName);
        errataInfo.put("advisory_release", new Integer(2));
        errataInfo.put("advisory_type", "Bug Fix Advisory");
        errataInfo.put("product", TestUtils.randomString());
        errataInfo.put("topic", TestUtils.randomString());
        errataInfo.put("description", TestUtils.randomString());
        errataInfo.put("solution", TestUtils.randomString());
        errataInfo.put("references", TestUtils.randomString());
        errataInfo.put("notes", TestUtils.randomString());
                
        ArrayList packages = new ArrayList();
        ArrayList bugs = new ArrayList();
        ArrayList keywords = new ArrayList();
        ArrayList channels = new ArrayList();
        channels.add(mergeFrom.getLabel());
        
        Errata errata = errataHandler.create(adminKey, errataInfo, 
                bugs, keywords, packages, true, channels);      
        TestUtils.flushAndEvict(errata);

        fromList = handler.listErrata(adminKey, mergeFrom.getLabel());
        assertEquals(fromList.size(), 1);
        
        Object[] mergeResult = handler.mergeErrata(adminKey, mergeFrom.getLabel(), 
                mergeTo.getLabel());
        assertEquals(mergeResult.length, fromList.size());
        
        toList = handler.listErrata(adminKey, mergeTo.getLabel());
        assertEquals(mergeResult.length, fromList.size());
    }
    
    public void testMergeErrataByDate() throws Exception {
        Channel mergeFrom = ChannelFactoryTest.createTestChannel(admin);
        Channel mergeTo = ChannelFactoryTest.createTestChannel(admin);
        
        List fromList = handler.listErrata(adminKey, mergeFrom.getLabel());
        assertEquals(fromList.size(), 0);
        List toList = handler.listErrata(adminKey, mergeTo.getLabel());
        assertEquals(toList.size(), 0);

        Map errataInfo = new HashMap();
        String advisoryName = TestUtils.randomString();
        errataInfo.put("synopsis", TestUtils.randomString());
        errataInfo.put("advisory_name", advisoryName);
        errataInfo.put("advisory_release", new Integer(2));
        errataInfo.put("advisory_type", "Bug Fix Advisory");
        errataInfo.put("product", TestUtils.randomString());
        errataInfo.put("topic", TestUtils.randomString());
        errataInfo.put("description", TestUtils.randomString());
        errataInfo.put("solution", TestUtils.randomString());
        errataInfo.put("references", TestUtils.randomString());
        errataInfo.put("notes", TestUtils.randomString());
                
        ArrayList packages = new ArrayList();
        ArrayList bugs = new ArrayList();
        ArrayList keywords = new ArrayList();
        ArrayList channels = new ArrayList();
        channels.add(mergeFrom.getLabel());
        
        Errata errata = errataHandler.create(adminKey, errataInfo, 
                bugs, keywords, packages, true, channels);      
        TestUtils.flushAndEvict(errata);
        
        fromList = handler.listErrata(adminKey, mergeFrom.getLabel());
        assertEquals(fromList.size(), 1);
        
        Object[] mergeResult = handler.mergeErrata(adminKey, mergeFrom.getLabel(), 
                mergeTo.getLabel(), "2008-09-30", "2030-09-30");
        assertEquals(mergeResult.length, fromList.size());
        
        toList = handler.listErrata(adminKey, mergeTo.getLabel());
        assertEquals(mergeResult.length, fromList.size());
        
        // perform a second merge on an interval where we know we don't have any 
        // errata and verify the result
        mergeResult = handler.mergeErrata(adminKey, mergeFrom.getLabel(), 
                mergeTo.getLabel(), "2006-09-30", "2007-10-30");
        assertEquals(mergeResult.length, 0);
        
        toList = handler.listErrata(adminKey, mergeTo.getLabel());
        assertEquals(toList.size(), fromList.size());
    }
    
    
    public void testListLatestPackages() throws Exception {
        Channel chan = ChannelFactoryTest.createTestChannel(admin);
        Package pack = PackageTest.createTestPackage();
        chan.addPackage(pack);
        
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, -5);

        String startDateStr = "2004-08-20 08:00:00";
        String endDateStr = "3004-08-20 08:00:00";
        
        Object[] list = handler.listAllPackages(adminKey, chan.getLabel(), 
                startDateStr);
        assertTrue(list.length == 1);
        
        list = handler.listAllPackages(adminKey, chan.getLabel(), startDateStr,
                endDateStr); 
        assertTrue(list.length == 1);
        
        list = handler.listAllPackages(adminKey, chan.getLabel());
        assertTrue(list.length == 1);
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date startDate = sdf.parse(startDateStr);
        Date endDate = sdf.parse(endDateStr);
        
        list = handler.listAllPackages(adminKey, chan.getLabel(), startDate);
        assertTrue(list.length == 1);
        
        list = handler.listAllPackages(adminKey, chan.getLabel(), startDate,
                endDate);
        assertTrue(list.length == 1);
    }
}
