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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.ProbeState;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.server.MonitoredServer;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * CPUTest
 * @version $Rev: 54534 $
 */
public class MonitoredServerTest extends BaseTestCaseWithUser {
    
    public void testMonitoredServer() throws Exception {
        ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(user);
        ProbeSuiteTest.addTestServersToSuite(suite, user);
        MonitoringFactory.saveProbeSuite(suite, user);
        Long psId = suite.getId();
        Iterator i = suite.getServersInSuite().iterator();
        // Have to flush all the Servers so they get reloaded as MonitoredServers
        // vs a standard Server
        while (i.hasNext()) {
            flushAndEvict(i.next());
        }
        flushAndEvict(suite);
        
        suite = MonitoringFactory.lookupProbeSuiteByIdAndOrg(psId, user.getOrg());
        Server s = (Server) suite.getServersInSuite().iterator().next();
        assertTrue(s instanceof MonitoredServer);
    }
    
    public void testProbeStateSummary() throws Exception {
        MonitoredServer ms = new MonitoredServer();
        assertTrue(ms.getProbeStateSummary().
                equals(MonitoringConstants.PROBE_STATE_PENDING));
        
        ProbeState critical = 
            new ProbeState(new SatCluster(), MonitoringConstants.PROBE_STATE_CRITICAL);
        ProbeState ok = 
            new ProbeState(new SatCluster(), MonitoringConstants.PROBE_STATE_OK);
        ProbeState unknown = 
            new ProbeState(new SatCluster(), MonitoringConstants.PROBE_STATE_UNKNOWN);
        ProbeState warn = 
            new ProbeState(new SatCluster(), MonitoringConstants.PROBE_STATE_WARN);

        ServerProbe okprobe = ServerProbe.newInstance();
        ServerProbe critprobe = ServerProbe.newInstance();
        ServerProbe unkprobe = ServerProbe.newInstance();
        ServerProbe warnprobe = ServerProbe.newInstance();
        okprobe.setState(ok);
        critprobe.setState(critical);
        unkprobe.setState(unknown);
        warnprobe.setState(warn);
        List probes = new LinkedList();
        probes.add(okprobe); // OK
        ms.setProbes(probes);
        assertTrue(ms.getProbeStateSummary().equals(
                MonitoringConstants.PROBE_STATE_OK));
        probes.add(unkprobe); // UNK
        ms.setProbes(probes);
        assertTrue(ms.getProbeStateSummary().equals(
                MonitoringConstants.PROBE_STATE_UNKNOWN));
        probes.add(warnprobe); // WARN
        ms.setProbes(probes);
        assertTrue(ms.getProbeStateSummary().equals(
                MonitoringConstants.PROBE_STATE_WARN));
        ms.setProbes(probes);
        probes.add(critprobe);
        assertTrue(ms.getProbeStateSummary().equals(
                MonitoringConstants.PROBE_STATE_CRITICAL));
        assertTrue(probes.size() == 4);
    
    }
    
    

}
