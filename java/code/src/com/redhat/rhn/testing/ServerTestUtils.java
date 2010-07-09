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
package com.redhat.rhn.testing;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.server.test.VirtualInstanceManufacturer;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.hibernate.Session;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;


/**
 * SystemTestUtils
 * @version $Rev$
 */
public class ServerTestUtils {

    private static final String REDHAT_RELEASE = "redhat-release";
    private static final Long I386_PACKAGE_ARCH_ID = new Long(101);

    private ServerTestUtils() {
    }

    /**
     * Create a test system that has a base channel
     *
     * @param creator who owns the server
     * @return Server created
     * @throws Exception if error
     */
    public static Server createTestSystem(User creator) throws Exception {
        Server retval = ServerFactoryTest.createTestServer(creator, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        Channel baseChannel = ChannelTestUtils.createBaseChannel(creator);
        retval.addChannel(baseChannel);
        ServerFactory.save(retval);
        retval = (Server) TestUtils.reload(retval);
        return retval;
    }

    /**
     * Adds a simulated redhat-release rpm to the given server.
     * @param user User performing the action.
     * @param addTo Server to add to.
     * @param version redhat-release version. (i.e. 5Server)
     * @param release redhat-release release. (i.e. 5.1.0)
     * @return Reloaded server object.
     * @throws Exception Um, if something goes wrong. :)
     */
    public static Server addRedhatReleasePackageToServer(User user, Server addTo,
            String version, String release)
        throws Exception {

        InstalledPackage testInstPack = new InstalledPackage();
        String epoch = "idontcare";
        PackageEvr evr = PackageEvrFactory.createPackageEvr(epoch, version, release);
        testInstPack.setEvr(evr);

        PackageArch parch = (PackageArch) TestUtils.lookupFromCacheById(
                I386_PACKAGE_ARCH_ID, "PackageArch.findById");
        testInstPack.setArch(parch);

        PackageName redhatRelease = PackageManager.lookupPackageName(REDHAT_RELEASE);
        if (redhatRelease == null) {
            redhatRelease = new PackageName();
            redhatRelease.setName(REDHAT_RELEASE);
            TestUtils.saveAndFlush(redhatRelease);
        }

        testInstPack.setName(redhatRelease);
        testInstPack.setServer(addTo);
        Set<InstalledPackage> serverPackages = new HashSet<InstalledPackage>();
        serverPackages.add(testInstPack);
        addTo.setPackages(serverPackages);

        ServerFactory.save(addTo);
        return (Server) TestUtils.reload(addTo);
    }

    /**
     * Create a test System with a new user/org as well.
     * @return Server created
     * @throws Exception if error
     */
    public static Server createTestSystem() throws Exception {
        return createTestSystem(UserTestUtils.findNewUser());
    }

    /**
     * Create a system with associated guest systems associated with it.
     *
     * @param user to own system
     * @param numberOfGuests number of guests to create
     * @return Server with guest.
     * @throws Exception if error
     */
    public static Server createVirtHostWithGuests(User user, int numberOfGuests)
        throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        TestUtils.saveAndFlush(user);
        Server s = createTestSystem(user);

        // Lets give the org/server virt.
        UserTestUtils.addVirtualization(user.getOrg());
        ServerTestUtils.addVirtualization(user, s);
        SystemManager.entitleServer(s, EntitlementManager.VIRTUALIZATION);

        for (int i = 0; i < numberOfGuests; i++) {
            VirtualInstance vi = new VirtualInstanceManufacturer(user).
                newRegisteredGuestWithoutHost();

            s.addGuest(vi);
        }

        return s;
    }

    /**
     *
     * Create a sytem with the virtualization platform entitlement and  with 1 guest system
     * associated with it.
     *
     * @param user to own system
     * @return Server with guest.
     * @throws Exception if error
     */
    public static Server createVirtPlatformHostWithGuest(User user) throws Exception {
        Server s = createTestSystem(user);
        user.addRole(RoleFactory.ORG_ADMIN);
        // Lets give the org/server virt.
        UserTestUtils.addVirtualizationPlatform(user.getOrg());
        ServerTestUtils.addVirtualization(user, s);
        SystemManager.entitleServer(s, EntitlementManager.VIRTUALIZATION_PLATFORM);

        VirtualInstance vi = new VirtualInstanceManufacturer(user).
            newRegisteredGuestWithoutHost();

        s.addGuest(vi);

        return s;
    }

    /**
     * Add a new Server as a guest of the passed in Server.
     * @param user adding
     * @param server to add too
     * @throws Exception if err
     */
    public static void addGuestToServer(User user, Server server) throws Exception {
        VirtualInstance vi = new VirtualInstanceManufacturer(user).
            newRegisteredGuestWithoutHost();

        server.addGuest(vi);
    }


    /**
     * Add virtualization to the server passed in.  Will setup the base channel and child
     * channels with the right packages.
     * @param user user
     * @param s server
     * @throws Exception fi error
     */
    public static void addVirtualization(User user, Server s) throws Exception {
        ChannelTestUtils.setupBaseChannelForVirtualization(user, s.getBaseChannel());
    }

    /**
     * Create virthostwithguest
     * @return Server with a guest
     * @throws Exception if error
     */
    public static Server createVirtHostWithGuest() throws Exception {
        return createVirtHostWithGuests(UserTestUtils.findNewUser(), 1);
    }

    /**
     * Create virt host with guests.
     * @param numberOfGuests Number of guests to create on this host.
     * @return Server with a guest
     * @throws Exception if error
     */
    public static Server createVirtHostWithGuests(int numberOfGuests) throws Exception {
        return createVirtHostWithGuests(UserTestUtils.findNewUser(), numberOfGuests);
    }

    /**
     * Associates the given package with the given server.
     * @param serverId  identifies the server
     * @param packageIn identifies the package; must already be saved
     */
    public static  void addServerPackageMapping(Long serverId, Package packageIn) {
        WriteMode wm = ModeFactory.getWriteMode("test_queries",
            "insert_into_rhnServerPackage_with_arch");

        Map<String, Long> params = new HashMap<String, Long>(4);
        params.put("server_id", serverId);
        params.put("pn_id", packageIn.getPackageName().getId());
        params.put("evr_id", packageIn.getPackageEvr().getId());
        params.put("arch_id", packageIn.getPackageArch().getId());

        int result = wm.executeUpdate(params);

        assert result == 1;
    }

    /**
     * Creates two packages and errata agains the specified server. An installed package
     * with the default EVR is created and installed to the server. The newer package
     * is created with the given EVR and is the package associated with the errata.
     *
     * @param org user's organization
     * @param server wher the packages will be installed
     * @param upgradedPackageEvr used as the EVR for the errata package
     * @param errataType type of errata to create
     * @return the original installed package (i.e. not the upgraded version)
     * @throws Exception if anything goes wrong writing to the DB
     */
    public static Package populateServerErrataPackages(Org org, Server server,
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

        return installedPackage;
    }

    /**
     * Adds the servers identified by the given server IDs to the SSM.
     *
     * @param user      represents the logged in user
     * @param serverIds list of servers to add to the SSM
     */
    public static void addServersToSsm(User user, Long... serverIds) {
        RhnSet ssmSet = RhnSetManager.findByLabel(user.getId(),
        RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);

        if (ssmSet == null) {
            ssmSet = RhnSetManager.createSet(user.getId(),
                RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        }

        assert ssmSet != null;

        for (Long serverId : serverIds) {
            ssmSet.addElement(serverId);
        }

        RhnSetManager.store(ssmSet);

        ssmSet = RhnSetManager.findByLabel(user.getId(),
            RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        assert ssmSet != null;
    }

}
