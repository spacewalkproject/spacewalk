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
package com.redhat.rhn.manager.profile.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.NoBaseChannelFoundException;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.PackageMetadata;
import com.redhat.rhn.frontend.dto.ProfileDto;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * ProfileManagerTest
 * @version $Rev$
 */
public class ProfileManagerTest extends RhnBaseTestCase {

    public void testSyncSystems() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        UserTestUtils.addManagement(user.getOrg());

        Channel testChannel = ChannelFactoryTest.createTestChannel(user);

        Package p1 = PackageTest.createTestPackage(user.getOrg());
        Package p2 = PackageTest.createTestPackage(user.getOrg());

        testChannel.addPackage(p1);
        testChannel.addPackage(p2);
        ChannelFactory.save(testChannel);

        Server s1 = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        Server s2 = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());

        s1.addChannel(testChannel);
        s2.addChannel(testChannel);

        PackageManagerTest.associateSystemToPackageWithArch(s1, p1);
        PackageManagerTest.associateSystemToPackageWithArch(s2, p2);

        ServerFactory.save(s1);
        ServerFactory.save(s2);

        StringBuilder idCombo = new StringBuilder();
        idCombo.append(p1.getPackageName().getId()).append("|");
        idCombo.append(p1.getPackageEvr().getId()).append("|");
        idCombo.append(p1.getPackageArch().getId());
        Set idCombos = new HashSet();
        idCombos.add(idCombo.toString());

        // This call has an embedded transaction in the stored procedure:
        // lookup_transaction_package(:operation, :n, :e, :v, :r, :a)
        // which can cause deadlocks.  We are forced to call commitAndCloseTransaction()
        commitAndCloseSession();
        PackageAction action = ProfileManager.syncToSystem(
                user, s1.getId(), s2.getId(), idCombos,
                ProfileManager.OPTION_REMOVE, new Date());
        assertNotNull(action);
        assertNotNull(action.getPrerequisite());
    }


    public void testCreateProfileFails() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");

        user.addRole(RoleFactory.ORG_ADMIN);

        Server server = ServerFactoryTest.createTestServer(user, true);

        try {
            ProfileManager.createProfile(user, server,
                    "Profile test name" + TestUtils.randomString(),
                    "Profile test description");
            fail("Should not be able to create a profile for a server which " +
                 "has no basechannel");
        }
        catch (NoBaseChannelFoundException nbcfe) {
            assertTrue(true);
        }
    }

    public void testCreateProfile() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");

        user.addRole(RoleFactory.ORG_ADMIN);

        Server server = ServerFactoryTest.createTestServer(user, true);
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        server.addChannel(channel);
        TestUtils.saveAndFlush(server);

        Profile p = ProfileManager.createProfile(user, server,
                "Profile test name" + TestUtils.randomString(),
                "Profile test description");
        assertNotNull("Profile is null", p);
        assertNotNull("Profile has no id", p.getId());
    }

    public void testCopyFrom() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);

        Server server = ServerFactoryTest.createTestServer(user, true);
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        server.addChannel(channel);
        TestUtils.saveAndFlush(server);

        Profile p = ProfileManager.createProfile(user, server,
                "Profile test name" + TestUtils.randomString(),
                "Profile test description");
        assertNotNull("Profile is null", p);
        assertNotNull("Profile has no id", p.getId());

        ProfileManager.copyFrom(server, p);
    }

    public void testCompatibleWithServer() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);

        Server server = ServerFactoryTest.createTestServer(user, true);
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        server.addChannel(channel);
        TestUtils.saveAndFlush(server);
        Profile p = ProfileManager.createProfile(user, server,
                "Profile test name" + TestUtils.randomString(),
                "Profile test description");
        assertNotNull("Profile is null", p);
        assertNotNull("Profile has no id", p.getId());

        List list = ProfileManager.compatibleWithServer(server, user.getOrg());
        assertNotNull("List is null", list);
        assertFalse("List is empty", list.isEmpty());
        for (Iterator itr = list.iterator(); itr.hasNext();) {
            Object o = itr.next();
            assertEquals("List contains something other than Profiles",
                    Profile.class, o.getClass());
        }
    }

    public void testCompareServerToProfile() {
        Long sid = new Long(1005385254);
        Long prid = new Long(4908);
        Long orgid = new Long(4116748);
        DataResult dr = ProfileManager.compareServerToProfile(sid, prid, orgid, null);
        assertNotNull("DataResult was null", dr);
    }

    public void testCompatibleWithChannel() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Profile p = createProfileWithServer(user);
        DataResult dr = ProfileManager.compatibleWithChannel(p.getBaseChannel(),
                user.getOrg(), null);
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertTrue(dr.iterator().next() instanceof ProfileDto);

    }

    public static Profile createProfileWithServer(User userIn) throws Exception {
        Server server = ServerFactoryTest.createTestServer(userIn, true);
        Channel channel = ChannelFactoryTest.createTestChannel(userIn);
        server.addChannel(channel);
        TestUtils.saveAndFlush(server);

        return ProfileManager.createProfile(userIn, server,
                "Profile test name" + TestUtils.randomString(),
        "Profile test description");
    }

    public void testTwoVsOneKernelPackages()  {
        /*
         *     public static List comparePackageLists(DataResult profiles,
            DataResult systems, String param) {
         */

        List a = new ArrayList();
        PackageListItem pli = new PackageListItem();
        pli.setIdCombo("500000341|258204");
        pli.setEvrId(new Long(258204));
        pli.setName("kernel");
        pli.setRelease("27.EL");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.21-27.EL");
        pli.setVersion("2.4.21");
        pli.setEpoch(null);
        a.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo("500000341|000000");
        pli.setEvrId(new Long(000000));
        pli.setName("kernel");
        pli.setRelease("27.EL-bretm");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.22-27.EL-bretm");
        pli.setVersion("2.4.22");
        pli.setEpoch(null);
        a.add(pli);

        List b = new ArrayList();
        pli = new PackageListItem();
        pli.setIdCombo("500000341|258204");
        pli.setEvrId(new Long(258204));
        pli.setName("kernel");
        pli.setRelease("27.EL");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.21-27.EL");
        pli.setVersion("2.4.21");
        pli.setEpoch(null);
        b.add(pli);

        List diff = ProfileManager.comparePackageLists(new DataResult(a),
                new DataResult(b), "foo");

        assertEquals(1, diff.size());
        PackageMetadata pm = (PackageMetadata) diff.get(0);
        assertNotNull(pm);
        // assertEquals(PackageMetadata.KEY_OTHER_NEWER, pm.getComparisonAsInt());
        // Changed this to KEY_OTHER_ONLY because for systems with multiple revs of
        // same package we are now
        assertEquals(PackageMetadata.KEY_OTHER_ONLY, pm.getComparisonAsInt());
        assertEquals("kernel-2.4.22-27.EL-bretm", pm.getOther().getEvr());
    }

    public void testDifferingVersionsofSamePackage() {
        List a = new ArrayList();
        PackageListItem pli = new PackageListItem();
        pli.setIdCombo("500000341|000000");
        pli.setEvrId(new Long(000000));
        pli.setName("kernel");
        pli.setRelease("27.EL-bretm");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.22-27.EL-bretm");
        pli.setVersion("2.4.22");
        pli.setEpoch(null);
        a.add(pli);

        List b = new ArrayList();
        pli = new PackageListItem();
        pli.setIdCombo("500000341|258204");
        pli.setEvrId(new Long(258204));
        pli.setName("kernel");
        pli.setRelease("27.EL");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.21-27.EL");
        pli.setVersion("2.4.21");
        pli.setEpoch(null);
        b.add(pli);

        List diff = ProfileManager.comparePackageLists(new DataResult(a),
                new DataResult(b), "foo");
        assertEquals(1, diff.size());
        PackageMetadata pm = (PackageMetadata) diff.get(0);
        assertNotNull(pm);
        assertEquals(PackageMetadata.KEY_OTHER_NEWER, pm.getComparisonAsInt());
        assertEquals("kernel-2.4.22-27.EL-bretm", pm.getOther().getEvr());
        assertEquals("kernel-2.4.21-27.EL", pm.getSystem().getEvr());
    }

    public void testDifferentVersionsOfSamePackageReverseOrder() {
        List b = new ArrayList();
        PackageListItem pli = new PackageListItem();
        pli.setIdCombo("500000341|000000");
        pli.setEvrId(new Long(000000));
        pli.setName("kernel");
        pli.setRelease("27.EL-bretm");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.22-27.EL-bretm");
        pli.setVersion("2.4.22");
        pli.setEpoch(null);
        b.add(pli);

        List a = new ArrayList();
        pli = new PackageListItem();
        pli.setIdCombo("500000341|258204");
        pli.setEvrId(new Long(258204));
        pli.setName("kernel");
        pli.setRelease("27.EL");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.21-27.EL");
        pli.setVersion("2.4.21");
        pli.setEpoch(null);
        a.add(pli);

        List diff = ProfileManager.comparePackageLists(new DataResult(a),
                new DataResult(b), "foo");
        assertEquals(1, diff.size());
        PackageMetadata pm = (PackageMetadata) diff.get(0);
        assertNotNull(pm);
        assertEquals(PackageMetadata.KEY_THIS_NEWER, pm.getComparisonAsInt());
        assertEquals("kernel-2.4.22-27.EL-bretm", pm.getSystem().getEvr());
        assertEquals("kernel-2.4.21-27.EL", pm.getOther().getEvr());
    }

    public void testDifferingEpochsofSamePackage() {
        // this test will perform a package comparison between 2 packages where
        // the epochs in those packages vary, including null values

        String[] pkg1Epochs = {null, "0", null, "0"};
        String[] pkg2Epochs = {null, null, "0", "0"};

        List<PackageListItem> a = new ArrayList<PackageListItem>();
        PackageListItem pli1 = new PackageListItem();
        pli1.setIdCombo("500000341|000000");
        pli1.setEvrId(new Long(000000));
        pli1.setName("kernel");
        pli1.setRelease("27.EL-bretm");
        pli1.setNameId(new Long(500000341));
        pli1.setEvr("kernel-2.4.22-27.EL-bretm");
        pli1.setVersion("2.4.22");

        List<PackageListItem> b = new ArrayList<PackageListItem>();
        PackageListItem pli2 = new PackageListItem();
        pli2.setIdCombo("500000341|258204");
        pli2.setEvrId(new Long(258204));
        pli2.setName("kernel");
        pli2.setRelease("27.EL");
        pli2.setNameId(new Long(500000341));
        pli2.setEvr("kernel-2.4.21-27.EL");
        pli2.setVersion("2.4.21");

        for (int i = 0; i < pkg1Epochs.length; i++) {
            pli1.setEpoch(pkg1Epochs[i]);
            pli2.setEpoch(pkg2Epochs[i]);

            a.clear();
            a.add(pli1);
            b.clear();
            b.add(pli2);

            List diff = ProfileManager.comparePackageLists(
                new DataResult(a), new DataResult(b), "foo");
            assertEquals(1, diff.size());
            PackageMetadata pm = (PackageMetadata) diff.get(0);
            assertNotNull(pm);
            assertEquals(PackageMetadata.KEY_OTHER_NEWER, pm.getComparisonAsInt());
            assertEquals("kernel-2.4.22-27.EL-bretm", pm.getOther().getEvr());
            assertEquals(pkg1Epochs[i], pm.getOther().getEpoch());
            assertEquals("kernel-2.4.21-27.EL", pm.getSystem().getEvr());
            assertEquals(pkg2Epochs[i], pm.getSystem().getEpoch());
        }
    }

    public static PackageListItem createItem(String evrString, int nameId) {
        PackageListItem pli = new PackageListItem();
        String[] evr = StringUtils.split(evrString, "-");
        pli.setName(evr[0]);
        pli.setVersion(evr[1]);
        pli.setRelease(evr[2]);
        pli.setEvrId(new Long(evrString.hashCode()));
        pli.setIdCombo(nameId + "|" + evrString.hashCode());
        pli.setEvr(evrString);
        pli.setNameId(new Long(nameId));
        return pli;
    }

    public void testMorePackagesInProfile() {
        List profileList = new ArrayList();
        profileList.add(createItem("kernel-2.4.21-EL-mmccune", 500341));
        profileList.add(createItem("kernel-2.4.22-EL-mmccune", 500341));
        profileList.add(createItem("kernel-2.4.23-EL-mmccune", 500341));
        profileList.add(createItem("other-2.4.23-EL-mmccune", 500400));

        List systemList = new ArrayList();
        systemList.add(createItem("kernel-2.4.23-EL-mmccune", 500341));

        List diff = ProfileManager.comparePackageLists(new DataResult(profileList),
                new DataResult(systemList), "system");
        assertEquals(3, diff.size());

    }

    public void testMorePackagesInSystem() {
        List profileList = new ArrayList();
        profileList.add(createItem("kernel-2.4.23-EL-mmccune", 500341));

        List systemList = new ArrayList();
        systemList.add(createItem("kernel-2.4.21-EL-mmccune", 500341));
        systemList.add(createItem("kernel-2.4.22-EL-mmccune", 500341));
        systemList.add(createItem("kernel-2.4.23-EL-mmccune", 500341));

        List diff = ProfileManager.comparePackageLists(new DataResult(profileList),
                new DataResult(systemList), "system");
        assertEquals(2, diff.size());
    }

    public static PackageListItem createPackageListItem(String evrString, int nameId) {
        PackageListItem pli = new PackageListItem();
        String[] evr = StringUtils.split(evrString, "-");
        pli.setName(evr[0]);
        pli.setVersion(evr[1]);
        pli.setRelease(evr[2]);
        pli.setEvrId(new Long(evrString.hashCode()));
        pli.setIdCombo(nameId + "|" + evrString.hashCode());
        pli.setEvr(evrString);
        pli.setNameId(new Long(nameId));
        return pli;
    }

     public void testIdenticalPackages() {
        List a = new ArrayList();
        PackageListItem pli = new PackageListItem();
        pli.setIdCombo("500000341|000000");
        pli.setEvrId(new Long(000000));
        pli.setName("kernel");
        pli.setRelease("27.EL-bretm");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.22-27.EL-bretm");
        pli.setVersion("2.4.22");
        pli.setEpoch(null);
        a.add(pli);


        List b = new ArrayList();
        pli = new PackageListItem();
        pli.setIdCombo("500000341|000000");
        pli.setEvrId(new Long(000000));
        pli.setName("kernel");
        pli.setRelease("27.EL-bretm");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.4.22-27.EL-bretm");
        pli.setVersion("2.4.22");
        pli.setEpoch(null);
        b.add(pli);

        List diff = ProfileManager.comparePackageLists(new DataResult(a),
                new DataResult(b), "foo");
        assertEquals(0, diff.size());
    }

    public void testVzlatkinTest() {
        List a = new ArrayList();
        PackageListItem pli = new PackageListItem();
        pli.setIdCombo("390|2069");
        pli.setEvrId(new Long(2069));
        pli.setName("kernel");
        pli.setRelease("5.0.3.EL");
        pli.setNameId(new Long(390));
        pli.setEvr("pkg1");
        pli.setVersion("2.6.9");
        pli.setEpoch(null);
        pli.setArch(null);
        a.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo("390|1628");
        pli.setEvrId(new Long(1628));
        pli.setName("kernel");
        pli.setRelease("5.EL");
        pli.setNameId(new Long(390));
        pli.setEvr("pkg2");
        pli.setVersion("2.6.9");
        pli.setEpoch(null);
        pli.setArch(null);
        a.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo("1620|2069");
        pli.setEvrId(new Long(2069));
        pli.setName("kernel-devel");
        pli.setRelease("5.0.3.EL");
        pli.setNameId(new Long(1620));
        pli.setEvr("pkg3");
        pli.setVersion("2.6.9");
        pli.setEpoch(null);
        pli.setArch(null);
        a.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo("1620|1628");
        pli.setEvrId(new Long(1628));
        pli.setName("kernel-devel");
        pli.setRelease("5.EL");
        pli.setNameId(new Long(1620));
        pli.setEvr("pkg4");
        pli.setVersion("2.6.9");
        pli.setEpoch(null);
        pli.setArch(null);
        a.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo("398|1629");
        pli.setEvrId(new Long(1629));
        pli.setName("kernel-utils");
        pli.setRelease("13.1.48");
        pli.setNameId(new Long(398));
        pli.setEvr("pkg5");
        pli.setVersion("2.4");
        pli.setEpoch("1");
        pli.setArch(null);
        a.add(pli);

        // SETUP B
        List b = new ArrayList();
        pli = new PackageListItem();
        pli.setIdCombo(null);
        pli.setEvrId(new Long(1628));
        pli.setName("kernel");
        pli.setRelease("5.EL");
        pli.setNameId(new Long(390));
        pli.setEvr("pkg1b");
        pli.setVersion("2.6.9");
        pli.setEpoch(null);
        pli.setArch(null);
        b.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo(null);
        pli.setEvrId(new Long(1628));
        pli.setName("kernel-devel");
        pli.setRelease("5.EL");
        pli.setNameId(new Long(1620));
        pli.setEvr("pkg2b");
        pli.setVersion("2.6.9");
        pli.setEpoch(null);
        pli.setArch(null);
        b.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo(null);
        pli.setEvrId(new Long(1629));
        pli.setName("kernel-utils");
        pli.setRelease("13.1.48");
        pli.setNameId(new Long(398));
        pli.setEvr("pkg3b");
        pli.setVersion("2.4");
        pli.setEpoch("1");
        pli.setArch(null);
        b.add(pli);

        List diff = ProfileManager.comparePackageLists(new DataResult(a),
                new DataResult(b), "foo");
        // This used to assert: assertEquals(0, diff.size());
        // but we now support showing what older packages exist on a system
        assertEquals(2, diff.size());

    }

    public void testBz204345() throws Exception {
        // kernel-2.6.9-22.EL
        // kernel-2.6.9-42.0.2.EL

        List serverList = new ArrayList();
        PackageListItem pli3 = new PackageListItem();
        pli3.setIdCombo("500000341|000000");
        pli3.setEvrId(new Long(000000));
        pli3.setName("kernel");
        pli3.setRelease("42.0.2.EL");
        pli3.setNameId(new Long(500000341));
        pli3.setEvr("kernel-2.6.9-42.0.2.EL");
        pli3.setVersion("2.6.9");
        pli3.setEpoch(null);
        serverList.add(pli3);

        List otherServerList = new ArrayList();
        PackageListItem pli = new PackageListItem();
        pli.setIdCombo("500000341|000001");
        pli.setEvrId(new Long(000000));
        pli.setName("kernel");
        pli.setRelease("22.EL");
        pli.setNameId(new Long(500000341));
        pli.setEvr("kernel-2.6.9-22.EL");
        pli.setVersion("2.6.9");
        pli.setEpoch(null);
        otherServerList.add(pli);

        PackageListItem pli2 = new PackageListItem();
        pli2.setIdCombo("500000341|000000");
        pli2.setEvrId(new Long(000000));
        pli2.setName("kernel");
        pli2.setRelease("42.0.2.EL");
        pli2.setNameId(new Long(500000341));
        pli2.setEvr("kernel-2.6.9-42.0.2.EL");
        pli2.setVersion("2.6.9");
        pli2.setEpoch(null);
        otherServerList.add(pli2);


        List diff = ProfileManager.comparePackageLists(new DataResult(otherServerList),
                new DataResult(serverList), "foo");
        assertEquals(1, diff.size());

        PackageMetadata pm = (PackageMetadata) diff.get(0);
        assertNotNull(pm);
        assertEquals("kernel-2.6.9-22.EL", pm.getOther().getEvr());
        assertEquals(PackageMetadata.KEY_OTHER_ONLY, pm.getComparisonAsInt());
        // assertEquals("kernel-2.4.21-27.EL", pm.getSystem().getEvr());
    }

    public void testGetChildChannelsNeededForProfile() throws Exception {
        Server server = ServerTestUtils.createTestSystem();
        Channel childChannel1 = ChannelTestUtils.createChildChannel(server.getCreator(),
                server.getBaseChannel());

        PackageManagerTest.addPackageToSystemAndChannel("child1-package1", server,
                childChannel1);
        PackageManagerTest.addPackageToSystemAndChannel("child1-package2", server,
                childChannel1);

        Channel childChannel2 = ChannelTestUtils.createChildChannel(server.getCreator(),
                server.getBaseChannel());
        PackageManagerTest.addPackageToSystemAndChannel("child2-package1", server,
                childChannel2);
        PackageManagerTest.addPackageToSystemAndChannel("child2-package2", server,
                childChannel2);

        Profile p = ProfileManager.createProfile(server.getCreator(), server,
                "Profile test name" + TestUtils.randomString(), "test desc");
        ProfileManager.copyFrom(server, p);

        List channels = ProfileManager.getChildChannelsNeededForProfile(
                server.getCreator(),
                server.getBaseChannel(), p);
        commitAndCloseSession();
        assertEquals(2, channels.size());
        assertTrue(channels.contains(childChannel1));
        assertTrue(channels.contains(childChannel2));

        Profile p2 = ProfileManager.createProfile(server.getCreator(), server,
                "Profile test name" + TestUtils.randomString(), "test desc");

        channels = ProfileManager.getChildChannelsNeededForProfile(server.getCreator(),
                server.getBaseChannel(), p2);
        assertEquals(0, channels.size());


    }

    public void aTestPrepareSyncToProfile() {
        // don't want to break sat tests.
        User user = UserFactory.lookupById(new Long(3567268));
        Server srvr = ServerFactory.lookupById(new Long(1005385254));
        RhnSet set = RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC.get(user);
        assertFalse("packages_for_system_sync set is empty", set.isEmpty());
        DataResult dr = ProfileManager.prepareSyncToProfile(srvr.getId(),
                new Long(6110), user.getOrg().getId(), null, set.getElementValues());
        assertEquals("packages_for_system_sync set don't match, packages " +
                "prepared for sync", set.size(), dr.size());
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            PackageMetadata pm = (PackageMetadata) itr.next();
            System.out.println(pm.getName() + ", " + pm.getActionStatus() +
                    ", " + pm.getNameId());
        }
    }
}
