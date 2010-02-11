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
package com.redhat.rhn.domain.org.test;

import com.redhat.rhn.domain.org.SystemMigration;
import com.redhat.rhn.domain.org.SystemMigrationFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;

/**
 * SystemMigrationFactoryTest
 * @version $Rev$
 */
public class SystemMigrationFactoryTest extends RhnBaseTestCase {

    public void testSystemMigrationFactory() throws Exception {
        
        // Setup
        // Create org1 with 3 servers
        User orgAdmin1 = UserTestUtils.findNewUser("testUser", "org1", true);
        List<Server> servers = new LinkedList<Server>();
        for (int i = 0; i < 3; i++) {
            Server server = ServerFactoryTest.createTestServer(orgAdmin1);
            assertNotNull(server);
            servers.add(server);
        }
        
        // Create org2 & 3 w/0 servers
        User orgAdmin2 = UserTestUtils.findNewUser("orgAdmin2", "org2", true);
        User orgAdmin3 = UserTestUtils.findNewUser("orgAdmin3", "org3", true);
        
        assertEquals(3, SystemManager.systemList(orgAdmin1, null).size());
        assertEquals(0, SystemManager.systemList(orgAdmin2, null).size());
        assertEquals(0, SystemManager.systemList(orgAdmin3, null).size());

        // Test createSystemMigration
        
        // Migrate the first server from org1 to org2
        SystemMigration migration1 = SystemMigrationFactory.createSystemMigration();
        assertNotNull(migration1);
        migration1.setToOrg(orgAdmin2.getOrg());
        migration1.setFromOrg(servers.get(0).getOrg());
        migration1.setServer(servers.get(0));
        migration1.setMigrated(new Date());
        SystemMigrationFactory.save(migration1);
        
        // Migrate the second server from org1 to org3
        SystemMigration migration2 = SystemMigrationFactory.createSystemMigration();
        assertNotNull(migration2);
        migration2.setToOrg(orgAdmin3.getOrg());
        migration2.setFromOrg(servers.get(1).getOrg());
        migration2.setServer(servers.get(1));
        migration2.setMigrated(new Date());
        SystemMigrationFactory.save(migration2);
        
        // Migrate the third server from org1 to org2
        SystemMigration migration3 = SystemMigrationFactory.createSystemMigration();
        assertNotNull(migration3);
        migration3.setToOrg(orgAdmin2.getOrg());
        migration3.setFromOrg(servers.get(2).getOrg());
        migration3.setServer(servers.get(2));
        migration3.setMigrated(new Date());
        SystemMigrationFactory.save(migration3);

        // Test lookupByToOrg
        List<SystemMigration> migToOrg1 = SystemMigrationFactory.lookupByToOrg(
                orgAdmin1.getOrg());
        assertNotNull(migToOrg1);
        assertEquals(0, migToOrg1.size());       
        
        List<SystemMigration> migToOrg2 = SystemMigrationFactory.lookupByToOrg(
                orgAdmin2.getOrg());
        assertNotNull(migToOrg2);
        assertEquals(2, migToOrg2.size());

        List<SystemMigration> migToOrg3 = SystemMigrationFactory.lookupByToOrg(
                orgAdmin3.getOrg());
        assertNotNull(migToOrg3);
        assertEquals(1, migToOrg3.size());
        
        // Test lookupByFromOrg
        List<SystemMigration> migFromOrg1 = SystemMigrationFactory.lookupByFromOrg(
                orgAdmin1.getOrg());
        assertNotNull(migFromOrg1);
        assertEquals(3, migFromOrg1.size());       
        
        List<SystemMigration> migFromOrg2 = SystemMigrationFactory.lookupByFromOrg(
                orgAdmin2.getOrg());
        assertNotNull(migFromOrg2);
        assertEquals(0, migFromOrg2.size());

        List<SystemMigration> migFromOrg3 = SystemMigrationFactory.lookupByFromOrg(
                orgAdmin3.getOrg());
        assertNotNull(migFromOrg3);
        assertEquals(0, migFromOrg3.size());

        // Test lookupByServer
        for (Server server : servers) {
            List<SystemMigration> migrations = SystemMigrationFactory.lookupByServer(
                    server);
            assertNotNull(migrations);
            assertEquals(1, migrations.size());
        }
    }
}
