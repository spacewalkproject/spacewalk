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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.kickstart.KickstartAction;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.profile.ProfileFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.kickstart.KickstartChannelDto;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.kickstart.KickstartScheduleCommand;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * KickstartScheduleCommandTest
 * @version $Rev$
 */
public class KickstartScheduleCommandTest extends BaseKickstartCommandTestCase {

    private Server server;
    private Long otherServerId;
    private Long profileId;
    private String profileType;
    
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        
        user.addRole(RoleFactory.ORG_ADMIN);
        server = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        Channel c = ChannelFactoryTest.createTestChannel(server.getCreator());
        server.addChannel(c);
        
        KickstartDataTest.addKickstartPackagesToChannel(c, false);
        ksdata.setKernelParams("someparam=asdf");
        ksdata.getTree().setChannel(server.getBaseChannel());
        KickstartSession ksession = KickstartSessionTest.
            createKickstartSession(ksdata, user);
        ksession.setNewServer(server);
        ksession.setOldServer(server);
        TestUtils.saveAndFlush(ksession);
    }

    private static void assertCmdSuccess(KickstartScheduleCommand cmd) {
        ValidatorError err = cmd.store();
        if (err != null) {
            fail("Got this error instead of success, key: " + err.getKey() + " msg: " +
                    LocalizationService.getInstance().
                        getMessage(err.getKey(), err.getValues()));
        }
        assertNotNull(cmd.getKickstartSession());
    }
    
    public void testCommandActKey() throws Exception {
        Server otherServer = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        otherServer.addChannel(ChannelFactoryTest.createTestChannel(user));
        otherServerId = otherServer.getId();
        profileType = KickstartScheduleCommand.TARGET_PROFILE_TYPE_SYSTEM;
        KickstartScheduleCommand cmd = testCommandExecution(
                server, ksdata, profileType, otherServerId, profileId);
        assertNotNull(cmd.getCreatedProfile());
    }
    

    
    /**
     * Big test to make sure we include x86_64 ks profiles if the 
     * box has an i386 basechannel but seems to be 64bit hardware.
     * @throws Exception
     */
    public void testProfileArches() throws Exception {
        KickstartData x86ks = KickstartDataTest.
            createKickstartWithChannel(user.getOrg());
        x86ks.getChannel().setChannelArch(ChannelFactory.lookupArchByName("x86_64"));
        TestUtils.saveAndFlush(x86ks.getChannel());
        TestUtils.saveAndFlush(x86ks);
        
        
        server.setServerArch(ServerConstants.getArchI686());
        Channel bc = server.getBaseChannel();
        bc.setChannelArch(ChannelFactory.lookupArchByName("IA-32"));
        KickstartScheduleCommand cmd = new KickstartScheduleCommand(server.getId(), user);
        List dr = cmd.getKickstartProfiles();
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        Iterator i = dr.iterator();
        boolean found = false;
        while (i.hasNext()) {
            Object dto = i.next();
            if (dto instanceof KickstartChannelDto) {
                KickstartChannelDto kdto = (KickstartChannelDto) dto;
                Channel lookedUp = ChannelFactory.lookupByLabel(user.getOrg(), 
                        kdto.getChannelLabel());
                assertNotNull(lookedUp);
                if (lookedUp.getChannelArch().getName().equals("x86_64")) {
                    found = true;
                }
            }
        }
        assertTrue(found);
        
    }
    
    public void testCommandExisting() throws Exception {
        profileType = KickstartScheduleCommand.TARGET_PROFILE_TYPE_EXISTING;
        KickstartScheduleCommand cmd = testCommandExecution(
                                server, ksdata, profileType, 
                otherServerId, profileId);
        assertNotNull(cmd.getCreatedProfile());
    }
    
    public void testCommandNoProfileSynch() throws Exception {
        testCommandExecution(server, ksdata, profileType, otherServerId, profileId);
    }

    public void testCommandProxyKs() throws Exception {
        KickstartScheduleCommand cmd = testCommandExecution(server,
                ksdata, profileType, otherServerId, profileId);
        Server proxy = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        cmd.setProxy(proxy);
        assertNull(cmd.store());
    }

    public void testGetProxies() throws Exception {
        KickstartScheduleCommand cmd = testCommandExecution(server,
                ksdata, profileType, otherServerId, profileId);
        assertNull(cmd.store());
        assertNotNull(SystemManager.listProxies(user.getOrg()));
        assertEquals(0, SystemManager.listProxies(user.getOrg()).size());
    }

    public void testCommandPackageProfile() throws Exception {
        profileType = KickstartScheduleCommand.TARGET_PROFILE_TYPE_PACKAGE;
        String desc = "test profile " + TestUtils.randomString();
        profileId = ProfileManager.createProfile(ProfileFactory.TYPE_SYNC_PROFILE,
                user, ChannelFactoryTest.createTestChannel(user), desc , desc).getId();
        KickstartScheduleCommand cmd = testCommandExecution(server,
                ksdata, profileType, otherServerId, profileId);
        assertNotNull(cmd.getCreatedProfile());
        assertNotNull(cmd.getKickstartSession().getServerProfile());
        assertEquals(profileId, cmd.getKickstartSession().getServerProfile().getId());
        
        // Test condition found in BZ 193279
        cmd.setProfileId(null);
        try {
            cmd.store();
            fail("We should have thrown an exception");
        }
        catch (UnsupportedOperationException ue) {
            // Noop
        }
    }

    public void testScheduleKs() throws Exception {
        
        FileList list1 = KickstartDataTest.createFileList1(user.getOrg());
        CommonFactory.saveFileList(list1);
        list1 = (FileList) reload(list1);
        ksdata.addPreserveFileList(list1);
        KickstartFactory.saveKickstartData(ksdata);
        
        KickstartAction kickstartAction = (KickstartAction) ActionManager.
            scheduleKickstartAction(this.ksdata, this.user, 
            server, new Date(), "extraoptions", "localhost");
        ActionFactory.save(kickstartAction);
        flushAndEvict(kickstartAction);
        assertNotNull(kickstartAction.getId());
        assertNotNull(kickstartAction.getKickstartActionDetails().
                getFileLists());
        assertTrue(kickstartAction.getKickstartActionDetails().
                getFileLists().size() == 1);
    }
    
    public void testKickstartProfiles() throws Exception {
        KickstartScheduleCommand cmd = new 
            KickstartScheduleCommand(this.server.getId(), this.user);
        assertNotNull(cmd.getKickstartProfiles());
    }
    
    public void testKickstartPackageName() {
        ksdata.getKickstartDefaults().getKstree().setInstallType(KickstartFactory.
                lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_4));
        
        assertEquals("spacewalk-koan", 
                ksdata.getKickstartPackageName());
        ksdata.getKickstartDefaults().getKstree().setInstallType(KickstartFactory.
                lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_5));
        
        assertEquals("spacewalk-koan", 
                ksdata.getKickstartPackageName());

    }
    
    public void testSameChannels() throws Exception {
        for (int i = 0; i < 5; i++) {
            Channel c = ChannelFactoryTest.createTestChannel(server.getCreator());
            c.setParentChannel(server.getBaseChannel());
            server.addChannel(c);
        }
        
        profileType = KickstartScheduleCommand.TARGET_PROFILE_TYPE_EXISTING;
        KickstartScheduleCommand cmd = testCommandExecution(
                server, ksdata, profileType, otherServerId, profileId);
        ActivationKey key = ActivationKeyFactory.
            lookupByKickstartSession(cmd.getKickstartSession());
        assertEquals(1, 1);
    }
    
    public void xDifferentBaseChannel() throws Exception {
        Channel oldBaseChannel = ChannelFactoryTest.createBaseChannel(server.getCreator());
        oldBaseChannel.setLabel("oldBaseChannel" + TestUtils.randomString());
        server.getChannels().clear();
        server.addChannel(oldBaseChannel);
        // TestUtils.saveAndFlush(oldBaseChannel);
        // TestUtils.saveAndFlush(server);
        // server = (Server) reload(server);
        // oldBaseChannel = (Server) reload(oldBaseChannel);
        Channel newBaseChannel = ChannelFactoryTest.createBaseChannel(server.getCreator());
        newBaseChannel.setLabel("newBaseChannel" + TestUtils.randomString());
        ksdata.getTree().setChannel(newBaseChannel);
        TestUtils.saveAndFlush(newBaseChannel);
        TestUtils.saveAndFlush(ksdata.getTree());
        TestUtils.saveAndFlush(ksdata);
        // ksdata = (KickstartData) reload(ksdata);
        
        setupChannelForKickstarting(newBaseChannel, user);
        
        for (int i = 0; i < 5; i++) {
            Channel c = ChannelFactoryTest.createTestChannel(server.getCreator());
            c.setParentChannel(server.getBaseChannel());
            server.addChannel(c);
        }
        
        profileType = KickstartScheduleCommand.TARGET_PROFILE_TYPE_EXISTING;

        KickstartScheduleCommand cmd = testCommandExecution(
                server, ksdata, profileType, otherServerId, profileId);
        ActivationKey key = ActivationKeyFactory.
            lookupByKickstartSession(cmd.getKickstartSession());
        assertTrue(key.getChannels().size() == 2);
        Iterator i = key.getChannels().iterator();
        boolean found = false;
        while (i.hasNext()) {
            Channel c = (Channel) i.next();
            if (c.getLabel().startsWith("newBaseChannel")) {
                found = true;
            }
        }
        assertTrue(found);
        
    }
    
    /** 
     * Util method to schedule a Kickstart.
     * @param activationType KickstartScheduleCommand.ACTIVATION_TYPE_KEY/EXISTING
     * @param user who schedules
     * @param server to schedule against
     * @param ksdata to use
     * @param profileType KickstartScheduleCommand.TARGET_PROFILE_TYPE_*
     * @return KickstartScheduleCommand used
     * @throws Exception
     */
    public static KickstartScheduleCommand scheduleAKickstart(Server server, 
            KickstartData ksdata) throws Exception {
        ksdata.getTree().setChannel(server.getBaseChannel());
        return testCommandExecution(server, ksdata, null, null, null);
    }

    public static void setupChannelForKickstarting(Channel c, User user) throws Exception {
        
        PackageManagerTest.addPackageToChannel("auto-kickstart-TestBootImage", c);
        Package p = PackageManagerTest.
        addPackageToChannel("up2date", c);
        PackageEvr pevr = p.getPackageEvr();
        pevr.setEpoch("0");
        pevr.setVersion(KickstartScheduleCommand.UP2DATE_VERSION);
        pevr.setRelease("0");
        TestUtils.saveAndFlush(p);
        TestUtils.saveAndFlush(pevr);

    }
    
    // Like the number of params on this one?  Nice eh?  At least its private and
    // in test code :-)
    private static KickstartScheduleCommand testCommandExecution(
            Server server, KickstartData ksdata, String profileType, 
            Long otherServerId, Long profileId) 
        throws Exception {
        User user = server.getCreator();
        user.addRole(RoleFactory.ORG_ADMIN);
        Channel c = server.getBaseChannel();

        KickstartScheduleCommand cmd = new 
            KickstartScheduleCommand(server.getId(), ksdata.getId(), 
                user, new Date(), "rhn.webdev.redhat.com");

        PackageManagerTest.addPackageToSystemAndChannel(
                ConfigDefaults.get().getKickstartPackageName(), server, c);
        // ksdata.getKsdefault().getKstree().setChannel(c);
        cmd.setProfileType(profileType);
        cmd.setServerProfileId(otherServerId);
        cmd.setProfileId(profileId);
        ValidatorError ve = cmd.store();
        assertEquals(ve.getKey(), "kickstart.schedule.noup2date");
        PackageManagerTest.
            addUp2dateToSystemAndChannel(user, server, 
                    KickstartScheduleCommand.UP2DATE_VERSION, c);
        assertCmdSuccess(cmd);
        assertCmdSuccess(cmd);

        // verify that the kickstart session has an activation key
        // with provisioning entitlement
        ActivationKey key = ActivationKeyFactory.lookupByKickstartSession(
                cmd.getKickstartSession());
        Set<ServerGroupType> entitlements = key.getEntitlements();
        assertTrue(entitlements.contains(
                ServerConstants.getServerGroupTypeProvisioningEntitled()));
        
        TestUtils.flushAndEvict(ksdata);
        assertNotNull(KickstartFactory.
                lookupKickstartSessionByServer(server.getId()));
        return cmd;
    }
    
}
