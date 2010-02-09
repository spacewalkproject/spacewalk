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
package com.redhat.rhn.domain.monitoring.satcluster.test;

import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.satcluster.SatClusterFactory;
import com.redhat.rhn.domain.monitoring.satcluster.SatNode;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.Set;

/**
 * SatClusterTest
 * @version $Rev: 52080 $
 */
public class SatClusterTest extends BaseTestCaseWithUser {

    /**
     * Test fetching a ServerProbe 
     * @throws Exception in case of error
     */
    public void testLookup() throws Exception {
        
        Set scouts = user.getOrg().getMonitoringScouts();
        assertNotNull(scouts);
        assertTrue(scouts.size() > 0);
        assertTrue(scouts.toArray()[0] instanceof SatCluster);
        SatCluster cluster = (SatCluster) scouts.toArray()[0];
        assertNotNull(cluster.getPhysicalLocation());
        assertNotNull(cluster.getOrg());
    }
   
    public void testSatClusterForProbe() throws Exception {
        ServerProbe probe = (ServerProbe) MonitoringFactoryTest.
            createTestProbe(user);
        Server server = ServerFactoryTest.createTestServer(user, false);
        
        Set scouts = user.getOrg().getMonitoringScouts();
        assertNotNull(scouts);
        SatCluster cluster = (SatCluster) scouts.toArray()[0];
        probe.addProbeToSatCluster(cluster, server);
        MonitoringFactory.save(probe, user);
        probe = (ServerProbe) reload(probe);
        SatCluster pc = probe.getSatCluster();
        assertNotNull(pc);
    }
    
    public void testCreateSatCluster() {
        SatCluster sc = SatClusterFactory.createSatCluster(user);
        sc.setDescription("Test Monitoring Scout");
        SatClusterFactory.saveSatCluster(sc);
        
        sc = (SatCluster) reload(sc);
        assertNotNull(sc.getOrg());
        assertNotNull(sc.getDescription());
        assertNotNull(sc.getPhysicalLocation());
        assertNotNull(sc.getLastUpdateDate());
        assertNotNull(sc.getLastUpdateUser());
        assertNotNull(sc.getDeployed());
        assertNotNull(sc.getTargetType());
    }
    
    public void testCreateSatNode() {
        SatCluster sc = SatClusterFactory.createSatCluster(user);
        sc.setDescription("Test Monitoring Scout");
        SatNode sn = SatClusterFactory.createSatNode(user, sc);
        SatClusterFactory.saveSatCluster(sc);
        SatClusterFactory.saveSatNode(sn);
        
        sn = (SatNode) reload(sn);
        assertNotNull(sn.getSatCluster());
        assertEquals(sn.getIp(), sc.getVip());
        assertNotNull(sn.getTargetType());
        assertNotNull(sn.getMaxConcurrentChecks());
        assertNotNull(sn.getMacAddress());
        assertNotNull(sn.getDqLogLevel());
        assertNotNull(sn.getSchedLogLevel());
        assertNotNull(sn.getSputLogLevel());
        assertNotNull(sn.getScoutSharedKey());
        assertEquals(12, sn.getScoutSharedKey().length());
    }
    
    public void testLookupSatNode() {
        
        SatCluster sc = (SatCluster) user.getOrg().
            getMonitoringScouts().iterator().next();
        SatNode sn = SatClusterFactory.lookupSatNodeByCluster(sc);
        assertNotNull(sn);
    }
 
}



