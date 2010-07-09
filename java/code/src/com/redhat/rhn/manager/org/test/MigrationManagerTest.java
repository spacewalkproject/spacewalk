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
package com.redhat.rhn.manager.org.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.SystemMigration;
import com.redhat.rhn.domain.org.SystemMigrationFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerHistoryEvent;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.org.MigrationManager;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * MigrationManagerTest
 * @version $Rev$
 */
public class MigrationManagerTest extends RhnBaseTestCase {

    private Set<User> origOrgAdmins = new HashSet<User>();
    private Set<User> destOrgAdmins = new HashSet<User>();
    private Org origOrg;
    private Org destOrg;
    private Server server;  // virt host w/guests
    private Server server2; // server w/provisioning ent

    public void setUp() throws Exception {
        super.setUp();

        // Create 2 orgs, each with multiple org admins
        origOrgAdmins.add(UserTestUtils.findNewUser("origAdmin", "origOrg", true));
        origOrg = origOrgAdmins.iterator().next().getOrg();
        for (Integer i = 0; i < 2; i++) {
            User user = UserTestUtils.createUser("origAdmin", origOrg.getId());
            user.addRole(RoleFactory.ORG_ADMIN);
            UserFactory.save(user);
            origOrgAdmins.add(user);
        }

        destOrgAdmins.add(UserTestUtils.findNewUser("destAdmin", "destOrg", true));
        destOrg = destOrgAdmins.iterator().next().getOrg();
        for (Integer i = 0; i < 2; i++) {
            User user = UserTestUtils.createUser("destAdmin", destOrg.getId());
            user.addRole(RoleFactory.ORG_ADMIN);
            UserFactory.save(user);
            destOrgAdmins.add(user);
        }

        // Create a virtual host with guests and a server with provisioning entitlements
        // and associate the first org's admins with them both
        server = ServerTestUtils.createVirtHostWithGuests(
                origOrgAdmins.iterator().next(), 2);
        server2 = ServerFactoryTest.createTestServer(origOrgAdmins.iterator().next(), true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());
        for (User origOrgAdmin : origOrgAdmins) {
            origOrgAdmin.addServer(server);
            origOrgAdmin.addServer(server2);
        }

        ServerFactory.save(server);
        ServerFactory.save(server2);
        HibernateFactory.getSession().flush();
    }

    public void testMigrateSystemNotSatAdmin() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        try {
            MigrationManager.removeOrgRelationships(user, server);
            fail();
        }
        catch (PermissionException e) {
            // expected
        }
    }

    public void testRemoveEntitlements() throws Exception {
        assertTrue(server.getEntitlements().size() > 0);

        MigrationManager.removeOrgRelationships(origOrgAdmins.iterator().next(), server);
        server = ServerFactory.lookupById(server.getId());

        assertEquals(0, server.getEntitlements().size());
    }

    public void testRemoveSystemGroups() throws Exception {
        assertTrue(server.getGuests().size() > 0);
        assertEquals(1, server.getManagedGroups().size());
        ManagedServerGroup serverGroup1 = server.getManagedGroups().get(0);

        MigrationManager.removeOrgRelationships(origOrgAdmins.iterator().next(), server);
        server = ServerFactory.lookupById(server.getId());

        //serverGroup1 = (ManagedServerGroup) reload(serverGroup1);
        assertEquals(0, serverGroup1.getCurrentMembers().intValue());

        assertEquals(0, server.getManagedGroups().size());
    }

    public void testRemoveChannels() throws Exception {

        // verify that server was initially created w/channels
        assertTrue(server.getChannels().size() > 0);

        MigrationManager.removeOrgRelationships(origOrgAdmins.iterator().next(), server);

        assertEquals(0, server.getChannels().size());
    }

    public void testRemoveConfigChannels() throws Exception {

        ConfigChannel configChannel = ConfigTestUtils.createConfigChannel(origOrg);
        ConfigChannel configChannel2 = ConfigTestUtils.createConfigChannel(origOrg);

        server2.getConfigChannels().add(configChannel);
        server2.getConfigChannels().add(configChannel2);

        assertEquals(2, server2.getConfigChannelCount());

        MigrationManager.removeOrgRelationships(origOrgAdmins.iterator().next(), server2);

        assertEquals(0, server2.getConfigChannelCount());
    }

    public void testRemoveVirtualGuestAssociations() throws Exception {
        assertTrue(server.getGuests().size() > 0);

        MigrationManager.removeOrgRelationships(origOrgAdmins.iterator().next(), server);
        server = (Server) reload(server);

        assertEquals(0, server.getGuests().size());
    }

    public void testRemoveMonitoringProbeSuites() throws Exception {

        User origOrgAdmin = origOrgAdmins.iterator().next();
        ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(origOrgAdmin);
        SatCluster sc = (SatCluster)origOrgAdmin.getOrg().getMonitoringScouts()
            .iterator().next();
        for (int i = 0; i < 5; i++) {
            TemplateProbe probe = (TemplateProbe)
                MonitoringFactoryTest.createTestProbe(origOrgAdmin,
                    MonitoringConstants.getProbeTypeSuite());
            suite.addProbe(probe, origOrgAdmin);
        }
        suite.addServerToSuite(sc, server, origOrgAdmin);
        MonitoringManager.getInstance().storeProbeSuite(suite, origOrgAdmin);

        // verify that the above probes were added to the system
        assertEquals(5, MonitoringManager.getInstance().probesForSystem(origOrgAdmin,
                server, null).size());

        MigrationManager.removeOrgRelationships(origOrgAdmin, server);

        // verify that the probes were removed from the system
        assertEquals(0, MonitoringManager.getInstance().probesForSystem(origOrgAdmin,
                server, null).size());
    }

    public void testRemoveMonitoringProbes() throws Exception {

        // Setup

        User origOrgAdmin = origOrgAdmins.iterator().next();

        // Currently for testing we don't have a way to create a test probe and associate
        // it with an existing server; however, the MonitoringFactoryTest.createTestProbe
        // will create a server, satCluster and probe and associate the probe with the
        // server it created.
        Probe probe = MonitoringFactoryTest.createTestProbe(origOrgAdmin);

        ServerProbe serverProbe = (ServerProbe) probe;
        serverProbe.setPendingState((SatCluster) origOrgAdmin.getOrg().
                getMonitoringScouts().iterator().next());
        Server monitoredServer = serverProbe.getServer();

        // verify that the probe was added
        assertEquals(1, MonitoringManager.getInstance().probesForSystem(origOrgAdmin,
                monitoredServer, null).size());

        MigrationManager.removeOrgRelationships(origOrgAdmin, monitoredServer);

        // verify that the probe was removed from the system
        assertEquals(0, MonitoringManager.getInstance().probesForSystem(origOrgAdmin,
                server, null).size());
    }

    public void testUpdateAdminRelationships() throws Exception {
        for (User origOrgAdmin : origOrgAdmins) {
            assertTrue(origOrgAdmin.getServers().contains(server));
        }
        for (User destOrgAdmin : destOrgAdmins) {
            assertFalse(destOrgAdmin.getServers().contains(server));
        }

        MigrationManager.updateAdminRelationships(origOrg, destOrg, server);

        for (User origOrgAdmin : origOrgAdmins) {
            assertFalse(origOrgAdmin.getServers().contains(server));
        }
        for (User destOrgAdmin : destOrgAdmins) {
            assertTrue(destOrgAdmin.getServers().contains(server));
        }
    }

    public void testMigrateServers() throws Exception {

        assertEquals(server.getOrg(), origOrg);
        assertEquals(server2.getOrg(), origOrg);

        List<Server> servers = new ArrayList<Server>();
        servers.add(server);
        servers.add(server2);
        User origOrgAdmin = origOrgAdmins.iterator().next();
        MigrationManager.migrateServers(origOrgAdmin, destOrg, servers);

        assertEquals(server.getOrg(), destOrg);
        assertEquals(server2.getOrg(), destOrg);

        assertNotNull(server.getHistory());
        assertTrue(server.getHistory().size() > 0);
        boolean migrationRecorded = false;
        for (ServerHistoryEvent event : (Set<ServerHistoryEvent>) server.getHistory()) {
            if (event.getSummary().equals("System migration") &&
                event.getDetails().contains("From organization: " + origOrg.getName()) &&
                event.getDetails().contains("To organization: " + destOrg.getName()) &&
                (event.getCreated() != null)) {
                migrationRecorded = true;
            }
        }
        assertTrue(migrationRecorded);

        List<SystemMigration> s1Migrations = SystemMigrationFactory.lookupByServer(server);
        List<SystemMigration> s2Migrations = SystemMigrationFactory.lookupByServer(
                server2);
        assertNotNull(s1Migrations);
        assertNotNull(s2Migrations);
        assertEquals(1, s1Migrations.size());
        assertEquals(1, s2Migrations.size());
    }
}
