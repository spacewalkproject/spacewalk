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
package com.redhat.rhn.manager.channel.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelVersion;
import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.domain.channel.ProductName;
import com.redhat.rhn.domain.channel.ReleaseChannelMap;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.common.CommonConstants;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.EssentialChannelDto;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.dto.SystemsPerChannelDto;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.manager.channel.ChannelEntitlementCounter;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.EusReleaseComparator;
import com.redhat.rhn.manager.channel.MultipleChannelsWithPackageException;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ChannelManagerTest
 * @version $Rev$
 */
public class ChannelManagerTest extends BaseTestCaseWithUser {
    
    private static final String TEST_OS = "TEST RHEL AS";
    private static final String MAP_RELEASE = "4AS";
    
    public void testAllDownloadsTree() throws Exception {
    }

    public void testListDownloadCategories() {
    }
    
    public void testListDownloadImages() {
    }
    
    public void testAddRemoveSubscribeRole() throws Exception {
        User admin = UserTestUtils.findNewUser("testuser", "testorg");
        User regularUser = UserTestUtils.createUser("regularuser", admin.getOrg().getId());
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        channel.setGloballySubscribable(false, admin.getOrg());
        assertFalse(channel.isGloballySubscribable(admin.getOrg()));

        assertFalse(ChannelManager.verifyChannelSubscribe(regularUser, channel.getId()));
        
        ChannelManager.addSubscribeRole(regularUser, channel);
        assertTrue(ChannelManager.verifyChannelSubscribe(regularUser, channel.getId()));
        
        ChannelManager.removeSubscribeRole(regularUser, channel);
        assertFalse(ChannelManager.verifyChannelSubscribe(regularUser, channel.getId()));
    }

    public void testChannelsInOrg() throws Exception {
        // get an org
        Org org = OrgFactory.lookupById(UserTestUtils.createOrg("channelTestOrg"));
        //put a channel in the org
        Channel channel = ChannelFactoryTest.createTestChannel();
        org.addOwnedChannel(channel);
        //save the org
        OrgFactory.save(org);
        //inspect the data result
        DataResult dr = ChannelManager.channelsOwnedByOrg(org.getId(), null);
        assertNotNull(dr); //should be at least one item in there
    }
    
    public void testChannelsForUser() throws Exception {
        ChannelFactoryTest.createTestChannel();
        List channels = ChannelManager.channelsForUser(user);

        //make sure we got a list out
        assertNotNull(channels);
        
    }
    
    public void testEntitlements() throws Exception {
        ChannelFactoryTest.createTestChannel(user);

        OrgFactory.save(user.getOrg());
        
        DataResult dr = ChannelManager.entitlements(user.getOrg().getId(), null);
        assertNotEmpty(dr);
    }
    
    public void testGetEntitlement() throws Exception {
        Channel channel = ChannelFactoryTest.createTestChannel(user);

        OrgFactory.save(user.getOrg());
        
        ChannelOverview co = ChannelManager.getEntitlement(user.getOrg().getId(), 
                                                   channel.getChannelFamily().getId());
        assertNotNull(co);
        
    }
    
    public void testGetEntitlementAllOrgs() throws Exception {
        Channel channel = ChannelFactoryTest.createTestChannel(user);

        OrgFactory.save(user.getOrg());
        
        List<ChannelOverview> co = ChannelManager.getEntitlementForAllOrgs(
                channel.getChannelFamily().getId());
        assertNotNull(co);
        assertTrue(co.size() > 0);
        
    }
    
    public void testRedHatChannelTree() throws Exception {
        
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        channel.setOrg(null);
        
        OrgFactory.save(user.getOrg());
        ChannelFactory.save(channel);
        DataResult dr = ChannelManager.redHatChannelTree(user, null);
        assertNotEmpty(dr);
    }    
    
   public void testMyChannelTree() throws Exception {
        
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        user.getOrg().addOwnedChannel(channel);
        
        OrgFactory.save(user.getOrg());
        ChannelFactory.save(channel);
        DataResult dr = ChannelManager.myChannelTree(user, null);
        assertNotEmpty(dr);
    }
   
   
   public void testPopularChannelTree() throws Exception {
       Server server = ServerFactoryTest.createTestServer(user, true);
       ServerFactory.save(server);
       Channel channel = ChannelFactoryTest.createTestChannel(user);
       ChannelFactory.save(channel);
       user.getOrg().addOwnedChannel(channel);
       OrgFactory.save(user.getOrg());
       
       DataResult dr = ChannelManager.popularChannelTree(user, 1L, null);
       
       assertTrue(dr.isEmpty());
       SystemManager.unsubscribeServerFromChannel(user, server, server.getBaseChannel());
       server = SystemManager.subscribeServerToChannel(user, server, channel);
       
       dr = ChannelManager.popularChannelTree(user, 1L, null);
       
       assertFalse(dr.isEmpty());
   }       
   
    
    public void testAllChannelTree() throws Exception {
        
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        channel.setEndOfLife(new Date(System.currentTimeMillis() + Integer.MAX_VALUE));
        user.getOrg().addOwnedChannel(channel);
        
        OrgFactory.save(user.getOrg());
        ChannelFactory.save(channel);
        DataResult dr = ChannelManager.allChannelTree(user, null);
        assertNotEmpty(dr);
    }
    
    public void testOrphanedChannelTree() throws Exception {
        user = UserTestUtils.createUserInOrgOne();
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        channel.setEndOfLife(new Date(System.currentTimeMillis() + 10000000L));
        user.getOrg().addOwnedChannel(channel);
        
        Channel childChannel = ChannelFactoryTest.createTestChannel(user);
        childChannel.setParentChannel(channel);
        
        OrgFactory.save(user.getOrg());
        ChannelFactory.save(channel);
        ChannelFactory.save(childChannel);
        flushAndEvict(channel);
        flushAndEvict(childChannel);
        
        DataResult dr = ChannelManager.allChannelTree(user, null);
        assertNotEmpty(dr);
    }

    
    public void testRetiredChannelTree() throws Exception {
        //User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        channel.setEndOfLife(new Date(System.currentTimeMillis() - 1000000));
        user.getOrg().addOwnedChannel(channel);
        channel.setGloballySubscribable(true, user.getOrg());
        
        OrgFactory.save(user.getOrg());
        ChannelFactory.save(channel);
        
        DataResult dr = ChannelManager.retiredChannelTree(user, null);
        assertNotEmpty(dr);
    }
    
    public void testAccessibleChannels() throws Exception {
        //User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel parent = ChannelFactoryTest.createBaseChannel(user);
        Channel child = ChannelFactoryTest.createTestChannel(user);
        child.setParentChannel(parent);
        TestUtils.saveAndFlush(child);
        TestUtils.saveAndFlush(parent);
        
        List dr = ChannelManager.userAccessibleChildChannels(user.getOrg().getId(), 
                parent.getId());
        
        assertFalse(dr.isEmpty());
    }
    
    public void testChannelArches() {
        // for a more detailed test see ChannelFactoryTest
        assertNotNull(ChannelManager.getChannelArchitectures());
    }
    
    public void testDeleteChannel() throws Exception {
        // thanks mmccune for the tip
        user.getOrg().addRole(RoleFactory.CHANNEL_ADMIN);
        user.addRole(RoleFactory.CHANNEL_ADMIN);
        TestUtils.saveAndFlush(user);
        
        Channel c = ChannelFactoryTest.createTestChannel(user);
        c = (Channel) reload(c);
        ChannelManager.deleteChannel(user, c.getLabel());
        assertNull(reload(c));
    }
    
    public void testDeleteChannelException() throws Exception {
        try {
            ChannelManager.deleteChannel(user, "jesusr-channel-test");
        }
        catch (NoSuchChannelException e) {
            assertTrue(true);
        }
    }
    
    public void testLatestPackages() {
    }
    
    public void testListErrata() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        ErrataFactory.publishToChannel(e, c, user);

        e = (Errata) TestUtils.saveAndReload(e);

        List<ErrataOverview> errata = ChannelManager.listErrata(c, null, null, user);
        boolean found = false;
        for (ErrataOverview eo : errata) {
            if (eo.getId().equals(e.getId())) {
                found = true;
            }
        }
        assertTrue(found);


        found = false;
        Date date = new Date();
        errata = ChannelManager.listErrata(c, new Date(date.getTime() - 100000),
                null, user);
        for (ErrataOverview eo : errata) {
            if (eo.getId().equals(e.getId())) {
                found = true;
            }
        }
        assertTrue(found);

        found = false;
        errata = ChannelManager.listErrata(c, new Date(date.getTime() - 100000),
                                    new Date(date.getTime() + 5000000), user);
        for (ErrataOverview eo : errata) {
            if (eo.getId().equals(e.getId())) {
                found = true;
            }
        }
        assertTrue(found);
    }
    
    public void testPackagesLike() throws Exception {
        Server s = ServerFactoryTest.createTestServer(user);
        Channel c = ChannelFactoryTest.createTestChannel(user);
        PackageManagerTest.addPackageToSystemAndChannel("some-test-package", s, c);
        assertEquals(1, ChannelManager.listLatestPackagesEqual(c.getId(),
                "some-test-package").size());
        assertEquals(1, ChannelManager.listLatestPackagesLike(c.getId(), 
                "some-test-").size());
        assertNotNull(ChannelManager.getLatestPackageEqual(c.getId(),  
                "some-test-package"));
    }
    
    public void testBaseChannelsForSystem() throws Exception {
        Server s = ServerTestUtils.createTestSystem(user);
        
        ChannelTestUtils.createTestChannel(user);
        ChannelTestUtils.createTestChannel(user);
        List<EssentialChannelDto> channels = ChannelManager.listBaseChannelsForSystem(
                user, s);
        
        assertTrue(channels.size() >= 2);
    }
    
    public static void createReleaseChannelMap(Channel channel, String product, 
            String version, String release) {

        ReleaseChannelMap rcm = new ReleaseChannelMap();
        rcm.setChannel(channel);
        rcm.setChannelArch(channel.getChannelArch());
        rcm.setProduct(product);
        rcm.setVersion(version);
        rcm.setRelease(release);
        TestUtils.saveAndReload(rcm);
    }
    
    public void testLookupDefaultReleaseChannelMap() throws Exception {
        Channel base1 = ChannelFactoryTest.createBaseChannel(user);
        String version = "5Server";
        String release = "5.0.0";
        ChannelManagerTest.createReleaseChannelMap(base1, "MAP_OS", version, 
                release);
        
        ReleaseChannelMap rcm = ChannelManager.lookupDefaultReleaseChannelMapForChannel(
                base1);
        assertEquals(version, rcm.getVersion());
        assertEquals(release, rcm.getRelease());
    }

    public void testBaseChannelsForSystemIncludesEus() throws Exception {
        Server s = ServerTestUtils.createTestSystem(user);
        String version = "5Server";
        String release = "5.0.0";
        s = ServerTestUtils.addRedhatReleasePackageToServer(user, s, version, release);

        String release2 = "5.2.0";
        String release3 = "5.3.0";
        // Create some base channels and corresponding entries in rhnReleaseChannelMap:
        Channel base1 = ChannelFactoryTest.createBaseChannel(user);
        Channel base2 = ChannelFactoryTest.createBaseChannel(user);
        // not sure why we create this third one, but I'll leave it here.
        // jesusr 2007/11/15
        // making sure it's not included in the final results
        // -- dgoodwin
        ChannelFactoryTest.createBaseChannel(user);
        
        ChannelManagerTest.createReleaseChannelMap(base1, 
                ChannelManager.RHEL_PRODUCT_NAME, version, release2);
        ChannelManagerTest.createReleaseChannelMap(base2, 
                ChannelManager.RHEL_PRODUCT_NAME, version, release3);
        
        List<EssentialChannelDto> channels = ChannelManager.listBaseChannelsForSystem(
                user, s);
        
        assertTrue(channels.size() >= 2);
    }
    
    public void testListBaseEusChannelsByVersionReleaseAndChannelArch() throws Exception {
        String version = "5Server";
        
        // Create some base channels and corresponding entries in rhnReleaseChannelMap:
        Channel rhel50 = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel51 = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel52 = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel53 = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel6 = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel4 = ChannelFactoryTest.createBaseChannel(user);
        ChannelFactoryTest.createBaseChannel(user);
        
        ChannelManagerTest.createReleaseChannelMap(rhel50,
                ChannelManager.RHEL_PRODUCT_NAME, version, "5.0.0.0");
        ChannelManagerTest.createReleaseChannelMap(rhel51,
                ChannelManager.RHEL_PRODUCT_NAME, version, "5.1.0.1");
        ChannelManagerTest.createReleaseChannelMap(rhel52,
                ChannelManager.RHEL_PRODUCT_NAME, version, "5.2.0.2");
        ChannelManagerTest.createReleaseChannelMap(rhel53,
                ChannelManager.RHEL_PRODUCT_NAME, version, "5.3.0.3");
        ChannelManagerTest.createReleaseChannelMap(rhel6,
                ChannelManager.RHEL_PRODUCT_NAME, "6Server", "6.0.0.0");
        ChannelManagerTest.createReleaseChannelMap(rhel4,
                ChannelManager.RHEL_PRODUCT_NAME, "4AS", "4.6.0");

        // For a system with 5.0 already, they should only see RHEL 5 EUS channels
        // with a higher or equal release.
        List<EssentialChannelDto> channels = ChannelManager.
            listBaseEusChannelsByVersionReleaseAndChannelArch(user, version, "5.1.0.1",
                    rhel51.getChannelArch().getId());
        assertTrue(channels.size() >= 2);

        Set<Long> returnedIds = new HashSet<Long>();
        for (EssentialChannelDto c : channels) {
            returnedIds.add(c.getId());
        }

        assertFalse(returnedIds.contains(rhel50.getId()));
        assertFalse(returnedIds.contains(rhel51.getId()));
        assertTrue(returnedIds.contains(rhel52.getId()));
        assertTrue(returnedIds.contains(rhel53.getId()));
        assertFalse(returnedIds.contains(rhel6.getId()));
        assertFalse(returnedIds.contains(rhel4.getId()));
    }
    
    public void testLookupLatestEusChannelForRhel5() throws Exception {
        String el5version = "5Server";
        String release500 = "5.0.0";
        String release520 = "5.2.0.2";
        String release530 = "5.3.0.3";
        
        // Create some base channels and corresponding entries in rhnReleaseChannelMap:
        Channel rhel500Chan = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel530Chan = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel520Chan = ChannelFactoryTest.createBaseChannel(user);

        // Creating these in a random order to make sure most recent isn't also
        // most recently created and accidentally getting returned.
        ChannelManagerTest.createReleaseChannelMap(rhel500Chan,
                ChannelManager.RHEL_PRODUCT_NAME, el5version, release500);
        ChannelManagerTest.createReleaseChannelMap(rhel530Chan,
                ChannelManager.RHEL_PRODUCT_NAME, el5version, release530);
        ChannelManagerTest.createReleaseChannelMap(rhel520Chan,
                ChannelManager.RHEL_PRODUCT_NAME, el5version, release520);
        
        EssentialChannelDto channel = ChannelManager.
            lookupLatestEusChannelForRhelVersion(user, el5version,
                    rhel500Chan.getChannelArch().getId());
        assertEquals(rhel530Chan.getId().longValue(), channel.getId().longValue());
    }
    
    // Test the problem with string version comparisons is being handled:
    public void testLookupLatestEusChannelForRhel5WeirdVersionCompare() throws Exception {
        String el5version = "5Server";
        String release5310 = "5.3.10.0"; // should appear as most recent
        String release539 = "5.3.9.0";
        
        // Create some base channels and corresponding entries in rhnReleaseChannelMap:
        Channel rhel5310Chan = ChannelFactoryTest.createBaseChannel(user);
        Channel rhel539Chan = ChannelFactoryTest.createBaseChannel(user);

        // Creating these in a random order to make sure most recent isn't also
        // most recently created and accidentally getting returned.
        ChannelManagerTest.createReleaseChannelMap(rhel5310Chan,
                ChannelManager.RHEL_PRODUCT_NAME, el5version, release5310);
        ChannelManagerTest.createReleaseChannelMap(rhel539Chan,
                ChannelManager.RHEL_PRODUCT_NAME, el5version, release539);
        
        EssentialChannelDto channel = ChannelManager.
            lookupLatestEusChannelForRhelVersion(user, el5version,
                    rhel5310Chan.getChannelArch().getId());
        assertEquals(rhel5310Chan.getId().longValue(), channel.getId().longValue());
    }

    public void testLookupLatestEusChannelForRhelVersionNoneFound() throws Exception {
        // Create some base channels and corresponding entries in rhnReleaseChannelMap:
        Channel base1 = ChannelFactoryTest.createBaseChannel(user);
        Channel base2 = ChannelFactoryTest.createBaseChannel(user);
        // Fake some EUS channels for RHEL 6, which should not appear in results:
        ChannelManagerTest.createReleaseChannelMap(base1, TEST_OS, "6Server",
                "6.0.0.0");
        ChannelManagerTest.createReleaseChannelMap(base2, TEST_OS, "6Server",
                "6.1.0.1");
        
        // Should find nothing:
        EssentialChannelDto channel = ChannelManager.
            lookupLatestEusChannelForRhelVersion(user, "5Server",
                    base1.getChannelArch().getId());
        assertNull(channel);
    }

    public void testEusReleaseCmpRhel4() {
        EusReleaseComparator comparator = new EusReleaseComparator("4AS");
        assertEquals(0, comparator.compare("4.6", "4"));
        assertEquals(0, comparator.compare("4.6", "4.2"));
        assertEquals(1, comparator.compare("9", "8"));
        assertEquals(-1, comparator.compare("8", "9"));
        assertEquals(-1, comparator.compare("8.7", "9.5"));
        assertEquals(-1, comparator.compare("8.7", "10.10"));
    }

    public void testEusReleaseCmpRhel5() {
        EusReleaseComparator comparator = new EusReleaseComparator("5Server");
        assertEquals(0, comparator.compare("5.3.0.1", "5.3.0.5"));
        assertEquals(0, comparator.compare("5.3.0.1", "5.3.0.10"));
        assertEquals(0, comparator.compare("5.3.0", "5.3.0"));
        assertEquals(1, comparator.compare("5.3.1.1", "5.3.0.10"));
        assertEquals(1, comparator.compare("5.4.1", "5.3.0.10"));
        assertEquals(-1, comparator.compare("5.0.0.0", "5.3.0.3"));
        assertEquals(-1, comparator.compare("5.0.9.0", "5.0.10.0"));
        assertEquals(-1, comparator.compare("5.0.9.0", "5.0.10.0"));
    }
    
    public void testIsChannelFree() throws Exception {
        
        Server s = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest = ((VirtualInstance) s.getGuests().iterator().next()).getGuestSystem();
        Channel b1 = ChannelTestUtils.createTestChannel(user);
        Channel b2 = ChannelTestUtils.createTestChannel(user);
        assertFalse(ChannelManager.isChannelFreeForSubscription(s, b1));
        assertFalse(ChannelManager.isChannelFreeForSubscription(s, b2));
        
        b1.getChannelFamily().addVirtSubscriptionLevel(
                CommonConstants.getVirtSubscriptionLevelFree());
        assertTrue(ChannelManager.isChannelFreeForSubscription(guest, b1));
        
        b2.getChannelFamily().addVirtSubscriptionLevel(
                CommonConstants.getVirtSubscriptionLevelPlatformFree());
        
        // Check virt-plat
        UserTestUtils.addVirtualizationPlatform(user.getOrg());
        SystemManager.removeServerEntitlement(s.getId(), 
                EntitlementManager.VIRTUALIZATION);
        SystemManager.entitleServer(s, EntitlementManager.VIRTUALIZATION_PLATFORM);
        
        assertTrue(ChannelManager.isChannelFreeForSubscription(guest, b2));
        
        // Check guest without host
        guest.getVirtualInstance().setHostSystem(null);
        assertFalse(ChannelManager.isChannelFreeForSubscription(guest, b1));

    }
    
    public void testGetToolsChannel() throws Exception {
        Channel base = ChannelTestUtils.createTestChannel(user);
        Channel tools = ChannelTestUtils.createChildChannel(user, base);
        PackageManagerTest.addKickstartPackageToChannel(
                ConfigDefaults.get().getKickstartPackageName(), tools);
        
        Channel lookup = ChannelManager.getToolsChannel(base, user);
        assertEquals(tools.getId(), lookup.getId());
    }
    
    public void testGetToolsChannelNoneFound() throws Exception {
        Channel base = ChannelTestUtils.createTestChannel(user);
        
        Channel lookup = ChannelManager.getToolsChannel(base, user);
        assertNull(lookup);
    }
    
    public void testChildrenAvailableToSet() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        TestUtils.saveAndFlush(user);
        
        DataResult childChannels = ChannelManager.childrenAvailableToSet(user);
        assertNotNull(childChannels);
        assertTrue(childChannels.size() == 0);
    } 
    
    public void testGetChannelVersion() throws Exception {
        Channel c = ChannelTestUtils.createTestChannel(user);
        ChannelTestUtils.addDistMapToChannel(c);
        Set versions = ChannelManager.getChannelVersions(c);
        assertEquals(1, versions.size());
        assertEquals(ChannelVersion.LEGACY, versions.iterator().next());
    }
    
    public void testSubscribeToChildChannelWithPackageName() throws Exception {
        UserTestUtils.addVirtualization(user.getOrg()); 
        Server s = ServerTestUtils.createTestSystem(user);
        Channel[] chans = ChannelTestUtils.
            setupBaseChannelForVirtualization(s.getCreator(), s.getBaseChannel());
        Config.get().setString(ChannelEntitlementCounter.class.getName(), 
                TestChannelCounter.class.getName());
        
        s.addChannel(chans[0]);
        s.addChannel(chans[1]);
        TestUtils.saveAndReload(s);
        
        assertNotNull(ChannelManager.subscribeToChildChannelWithPackageName(user, 
                s, ChannelManager.TOOLS_CHANNEL_PACKAGE_NAME));
        
        Config.get().setString(ChannelEntitlementCounter.class.getName(), 
                ChannelEntitlementCounter.class.getName());

    }
    
    public void testSubscribeToChildChannelWithPackageNameMultipleResults()
        throws Exception {

        UserTestUtils.addVirtualization(user.getOrg());
        Server s = ServerTestUtils.createTestSystem(user);
        Channel[] chans = ChannelTestUtils.
            setupBaseChannelForVirtualization(s.getCreator(), s.getBaseChannel());
        // Repeat to ensure there's multiple child channels created:
        chans = ChannelTestUtils.
            setupBaseChannelForVirtualization(s.getCreator(), s.getBaseChannel());
        Config.get().setString(ChannelEntitlementCounter.class.getName(),
                TestChannelCounter.class.getName());

        int channelCountBefore = s.getChannels().size();
        try {
            ChannelManager.subscribeToChildChannelWithPackageName(user,
                s, ChannelManager.TOOLS_CHANNEL_PACKAGE_NAME);
            fail();
        }
        catch (MultipleChannelsWithPackageException e) {
            // expected
        }
        assertEquals(channelCountBefore, s.getChannels().size());

        Config.get().setString(ChannelEntitlementCounter.class.getName(),
                ChannelEntitlementCounter.class.getName());

    }

    public void testSubscribeToChildChannelWithPackageNameMultipleResultsAlreadySubbed()
        throws Exception {

        UserTestUtils.addVirtualization(user.getOrg());
        Server s = ServerTestUtils.createTestSystem(user);
        Channel[] chans = ChannelTestUtils.
        setupBaseChannelForVirtualization(s.getCreator(), s.getBaseChannel());
        // Repeat to ensure there's multiple child channels created:
        chans = ChannelTestUtils.
        setupBaseChannelForVirtualization(s.getCreator(), s.getBaseChannel());
        Config.get().setString(ChannelEntitlementCounter.class.getName(),
                TestChannelCounter.class.getName());

        // Subscribe to one set of the child channels but not the other, this should *not*
        // generate the multiple channels with package exception:
        s.addChannel(chans[0]);
        s.addChannel(chans[1]);
        TestUtils.saveAndReload(s);

        int channelCountBefore = s.getChannels().size();
        assertNotNull(ChannelManager.subscribeToChildChannelWithPackageName(user,
                    s, ChannelManager.TOOLS_CHANNEL_PACKAGE_NAME));
        assertEquals(channelCountBefore, s.getChannels().size());

        Config.get().setString(ChannelEntitlementCounter.class.getName(),
                ChannelEntitlementCounter.class.getName());

    }

    public void testsubscribeToChildChannelByOSProduct() throws Exception {
        UserTestUtils.addVirtualization(user.getOrg()); 
        Server s = ServerTestUtils.createTestSystem(user);
        ChannelTestUtils.setupBaseChannelForVirtualization(s.getCreator(), 
                s.getBaseChannel());
        Config.get().setString(ChannelEntitlementCounter.class.getName(), 
                TestChannelCounter.class.getName());
        
        assertNotNull(ChannelManager.subscribeToChildChannelByOSProduct(user, 
                s, ChannelManager.VT_OS_PRODUCT));
        
        Config.get().setString(ChannelEntitlementCounter.class.getName(), 
                ChannelEntitlementCounter.class.getName());

    }

    public void testBaseChannelsInSet() throws Exception {
        // Get ourselves a system
        Server s = ServerTestUtils.createTestSystem(user);
        
        // insert sys into system-set
        RhnSetDecl.SYSTEMS.clear(user);
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        set.addElement(s.getId());
        RhnSetManager.store(set);
        
        // ask for the base channels of all systems in the system-set for the test user
        DataResult dr = ChannelManager.baseChannelsInSet(user);
        
        // should be one, with one system, and its name should be == the name of the 
        // base-channel for the system we just created
        assertTrue(dr.size() == 1);
        assertTrue(dr.get(0) instanceof SystemsPerChannelDto);
        SystemsPerChannelDto spc = (SystemsPerChannelDto)dr.get(0);
        assertTrue(spc.getName().equals(s.getBaseChannel().getName()));
        assertTrue(spc.getSystemCount() == 1);
    }
    
    public void testListCompatibleBaseChannels() throws Exception {
        // Testing this is going to be a pain with our existing infrastructure
        
        // Create a server
        Server s = ServerTestUtils.createTestSystem(user);
        
        // Get its current base-channel
        Channel c = s.getBaseChannel();
        
        // Create a custom base channel
        Channel custom = ChannelTestUtils.createBaseChannel(user);
        custom.setOrg(user.getOrg());
        
        // Ask for channels compatible with the new server's base
        List<EssentialChannelDto> compatibles = 
            ChannelManager.listCompatibleBaseChannelsForChannel(user, c);
        
        // There should be one for the custom channel
        assertNotNull(compatibles);
        assertTrue(compatibles.size() == 1);
        
        boolean foundBase = false;
        boolean foundCustom = false;
        
        for (EssentialChannelDto ecd : compatibles) {
            foundBase |= c.getId().equals(ecd.getId().longValue());
            foundCustom |= custom.getId().equals(ecd.getId().longValue());
        }
        assertFalse(foundBase);
        assertTrue(foundCustom);
    }
    
    public void testNormalizeRhelReleaseForMapping() {
        assertEquals("4", ChannelManager.normalizeRhelReleaseForMapping("4AS", "4.6"));
        assertEquals("4", ChannelManager.normalizeRhelReleaseForMapping("4AS", "4.6.9"));
        assertEquals("3", ChannelManager.normalizeRhelReleaseForMapping("4AS", "3"));

        assertEquals("4.6.9", ChannelManager.normalizeRhelReleaseForMapping("5Server",
                "4.6.9"));
        assertEquals("5.0.0", ChannelManager.normalizeRhelReleaseForMapping("5Server",
        "5.0.0.9"));
    }
    
    public void testPackageSearch() {
        List ids = new ArrayList();
        ids.add(824L); // firefox
        ids.add(497L); // kernel
        ids.add(545L); // gcc
        List archlabels = new ArrayList();
        archlabels.add("channel-ia32");
        List<PackageOverview> pkgs = ChannelManager.packageSearch(ids, archlabels);
        assertNotNull(pkgs);
    }
    
    public void testFindCompatibleChildren() throws Exception {
        ProductName pn = ChannelFactoryTest.createProductName();        
        Channel parent = ChannelFactoryTest.createBaseChannel(user);
        Channel child = ChannelFactoryTest.createTestChannel(user);
        
        child.setParentChannel(parent);
        child.setProductName(pn);
        
        TestUtils.saveAndFlush(child);
        TestUtils.saveAndFlush(parent);
        TestUtils.flushAndEvict(child);
        
        Channel parent1 = ChannelFactoryTest.createBaseChannel(user);
        Channel child1 = ChannelFactoryTest.createTestChannel(user);
        
        child1.setParentChannel(parent1);
        child1.setProductName(pn);
        
        TestUtils.saveAndFlush(child1);
        TestUtils.saveAndFlush(parent1);
        TestUtils.flushAndEvict(child1);

        
        Map <Channel, Channel> children = ChannelManager.
                                findCompatibleChildren(parent, parent1, user);
        
        assertNotEmpty(children.keySet());
        assertEquals(child, children.keySet().iterator().next());
        assertEquals(child1, children.values().iterator().next());
     
    }
    
    public void testLookupDistChannelMap() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        ProductName pn = new ProductName();
        pn.setLabel(TEST_OS);
        pn.setName(TEST_OS);
        HibernateFactory.getSession().save(pn);
        c.setProductName(pn);
        HibernateFactory.getSession().save(c);
        
        String release = MAP_RELEASE + TestUtils.randomString();
        ChannelTestUtils.addDistMapToChannel(c, TEST_OS, release);
        DistChannelMap dcm = ChannelManager.lookupDistChannelMap(TEST_OS, release, 
                c.getChannelArch());
        assertNotNull(dcm);
        assertEquals(c.getId(), dcm.getChannel().getId());
    }
    
    public void testListCompatiblePackageArches() {
        String[] arches = {"channel-ia32", "channel-x86_64"};
        List<String> parches = ChannelManager.listCompatiblePackageArches(arches);
        assertTrue(parches.contains("i386"));
    }
    

    public void testRemoveErrata() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        ErrataFactory.publishToChannel(e, c, user);

        e = (Errata) TestUtils.saveAndReload(e);

        assertTrue(e.getChannels().contains(c));

        Set eids = new HashSet();
        eids.add(e.getId());

        ChannelManager.removeErrata(c, eids, user);
        e = (Errata) TestUtils.saveAndReload(e);
        assertFalse(e.getChannels().contains(c));
        c = ChannelManager.lookupByLabel(user.getOrg(), c.getLabel());
        assertFalse(c.getErratas().contains(eids));
    }

    public void testListErrataPackages() throws Exception {

        Channel c = ChannelFactoryTest.createBaseChannel(user);
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        Package bothP = PackageTest.createTestPackage();
        Package channelP = PackageTest.createTestPackage();
        Package errataP = PackageTest.createTestPackage();


        c.addPackage(bothP);
        e.addPackage(bothP);

        c.addPackage(channelP);
        e.addPackage(errataP);

        c.addErrata(e);

        c = (Channel) TestUtils.saveAndReload(c);
        e = (Errata) TestUtils.saveAndReload(e);

        bothP = (Package) TestUtils.saveAndReload(bothP);


        List<PackageDto> list = ChannelManager.listErrataPackages(c, e);
        assertEquals(list.size(), 1);
        assertEquals(list.get(0).getId(), (bothP.getId()));


    }

    public void testListErrataNeedingResync() throws Exception {

        user.addRole(RoleFactory.CHANNEL_ADMIN);

        Channel ochan = ChannelFactoryTest.createTestChannel();
        Channel cchan = ChannelFactoryTest.createTestClonedChannel(ochan, user);

        Errata oe = ErrataFactoryTest.createTestErrata(null);
        ochan.addErrata(oe);

        List list = new ArrayList();
        list.add(cchan.getId());

         Errata ce = ErrataManager.createClone(user, oe);
         ce = ErrataManager.publish(ce, list, user);

         Package testPackage = PackageTest.createTestPackage();
         oe.addPackage(testPackage);
         ochan.addPackage(testPackage);

         List<ErrataOverview> result = ChannelManager.listErrataNeedingResync(cchan, user);
         assertTrue(result.size() == 1);
         assertEquals(result.get(0).getId(), ce.getId());

    }

    public void testListErrataPackagesForResync() throws Exception {

        user.addRole(RoleFactory.CHANNEL_ADMIN);

        Channel ochan = ChannelFactoryTest.createTestChannel();
        Channel cchan = ChannelFactoryTest.createTestClonedChannel(ochan, user);

        Errata oe = ErrataFactoryTest.createTestErrata(null);
        ochan.addErrata(oe);

        List list = new ArrayList();
        list.add(cchan.getId());

         Errata ce = ErrataManager.createClone(user, oe);
         ce = ErrataManager.publish(ce, list, user);

         Package testPackage = PackageTest.createTestPackage();
         oe.addPackage(testPackage);
         ochan.addPackage(testPackage);

         RhnSet set = RhnSetDecl.ERRATA_TO_SYNC.get(user);
         set.clear();
         set.add(ce.getId());
         RhnSetManager.store(set);

         List<PackageOverview> result = ChannelManager.listErrataPackagesForResync(
                                                 cchan, user, set.getLabel());
         assertTrue(result.size() == 1);

         assertEquals(result.get(0).getId(), testPackage.getId());

    }


}
