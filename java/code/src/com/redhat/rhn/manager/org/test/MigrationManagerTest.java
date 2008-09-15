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
package com.redhat.rhn.manager.org.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import com.redhat.rhn.common.security.PermissionException;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.TemplateProbe;

import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;

import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;

import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;

import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;

import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.MonitoredServer;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;

import com.redhat.rhn.domain.user.User;

import com.redhat.rhn.manager.monitoring.MonitoringManager;

import com.redhat.rhn.manager.org.MigrationManager;

import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.UserTestUtils;


/**
 * MigrationManagerTest
 * @version $Rev$
 */
public class MigrationManagerTest extends RhnBaseTestCase {

    private User oldOrgAdmin;
    private Server server;

    public void setUp() throws Exception {
        super.setUp();

        oldOrgAdmin = UserTestUtils.findNewUser("oldAdmin", "oldOrg", true);

        server = ServerTestUtils.createVirtHostWithGuests(oldOrgAdmin, 2);
        ServerFactory.save(server);
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

        MigrationManager.removeOrgRelationships(oldOrgAdmin, server);
        server = (Server)reload(server);

        assertEquals(0, server.getEntitlements().size());
    }

    public void testRemoveSystemGroups() throws Exception {
        assertTrue(server.getGuests().size() > 0);
        assertEquals(1, server.getManagedGroups().size());
        ManagedServerGroup serverGroup1 = server.getManagedGroups().get(0);

        MigrationManager.removeOrgRelationships(oldOrgAdmin, server);
        server = (Server)reload(server);

        //serverGroup1 = (ManagedServerGroup) reload(serverGroup1);
        assertEquals(0, serverGroup1.getCurrentMembers().intValue());

        assertEquals(0, server.getManagedGroups().size());
    }

    public void testRemoveVirtualGuestAssociations() throws Exception {
        assertTrue(server.getGuests().size() > 0);

        MigrationManager.removeOrgRelationships(oldOrgAdmin, server);
        server = (Server)reload(server);

        assertEquals(0, server.getGuests().size());
    }

    public void testRemoveMonitoringProbeSuites() throws Exception {
        ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(oldOrgAdmin);
        SatCluster sc = (SatCluster)oldOrgAdmin.getOrg().getMonitoringScouts()
            .iterator().next();
        for (int i = 0; i < 5; i++) {
            TemplateProbe probe = (TemplateProbe)
                MonitoringFactoryTest.createTestProbe(oldOrgAdmin, 
                    MonitoringConstants.getProbeTypeSuite());
            suite.addProbe(probe, oldOrgAdmin);
        }
        suite.addServerToSuite(sc, server, oldOrgAdmin);
        MonitoringManager.getInstance().storeProbeSuite(suite, oldOrgAdmin);

        suite = (ProbeSuite) reload(suite);
        Object sobject = suite.getServersInSuite().iterator().next();
        // Gotta reload the server so the Action will get the MonitoredServer
        // instance instead of a regular Server object.
        reload(sobject);
        server = (Server) sobject;
        MonitoredServer server2 = (MonitoredServer)ServerFactory.lookupById(
                server.getId());
        assertEquals(5, server2.getProbes().size());

        MigrationManager.removeOrgRelationships(oldOrgAdmin, server);
        server2 = (MonitoredServer)reload(server2);

        // Aparently no probes results in a null MonitoredServer:
        assertNull(server2);
    }
}
