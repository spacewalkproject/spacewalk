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
package com.redhat.rhn.manager.monitoring.test;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.manager.monitoring.CreateServerProbeCommand;
import com.redhat.rhn.manager.monitoring.CreateTemplateProbeCommand;
import com.redhat.rhn.manager.monitoring.ModifyProbeCommand;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import org.hibernate.HibernateException;

import java.util.Date;
import java.util.Iterator;

/**
 * ModifyProbeCommandTest
 * @version $Rev$
 */
public class ModifyProbeCommandTest extends BaseTestCaseWithUser {


    public void testCreateForProbeSuite() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        ProbeSuite ps = ProbeSuiteTest.createTestProbeSuite(user);
        Date now = getNow();
        Probe probe = createTemplateProbe(ps);

        ps = (ProbeSuite) reload(ps);
        probe = (Probe) reload(probe);
        assertEquals(1, ps.getProbes().size());
        assertContains(ps.getProbes(), probe);
        assertNotBefore(now, probe.getLastUpdateDate());
        assertEquals(user.getLogin(), probe.getLastUpdateUser());

        // bz163562: add a system, then a probe, and make sure
        // that the probe shows up on the system
        addNewServer(ps);
        Probe probe2 = createTemplateProbe(ps);
        addNewServer(ps);

        ps = (ProbeSuite) reload(ps);
        probe = (Probe) reload(probe);
        probe2 = (Probe) reload(probe2);
        assertEquals(2, ps.getProbes().size());
        assertContains(ps.getProbes(), probe);
        assertContains(ps.getProbes(), probe2);
        assertEquals(2, ps.getServersInSuite().size());
        for (Iterator i = ps.getProbes().iterator(); i.hasNext();) {
            TemplateProbe tp = (TemplateProbe) i.next();
            assertEquals(2, tp.getServerProbes().size());
        }
    }

    private void addNewServer(ProbeSuite ps) throws Exception {
        Server s = ServerFactoryTest.createTestServer(user, false);
        Server serverToAdd = s;
        SatCluster sCluster = grabSatCluster();
        MonitoringManager.getInstance().
            addSystemToProbeSuite(ps, serverToAdd, sCluster, user);
    }

    private Probe createTemplateProbe(ProbeSuite ps) {
        Command c = MonitoringConstants.getCommandCheckTCP();
        ModifyProbeCommand cmd = new CreateTemplateProbeCommand(user, c, ps);
        cmd.setDescription("test description");
        cmd.setCheckIntervalMinutes(new Long(10));
        cmd.setNotificationIntervalMinutes(new Long(10));
        cmd.storeProbe();
        Probe probe = cmd.getProbe();
        return probe;
    }

    public void testCreateServerProbe() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        Command c = MonitoringConstants.getCommandCheckTCP();
        SatCluster scout = grabSatCluster();
        Server s = ServerFactoryTest.createTestServer(user, false);

        ModifyProbeCommand cmd = new CreateServerProbeCommand(user, c, s, scout);
        cmd.setDescription("test description");
        cmd.setCheckIntervalMinutes(new Long(10));
        cmd.storeProbe();
        Probe probe = cmd.getProbe();

        probe = (ServerProbe) reload(probe);
        assertEquals(scout.getId(), ((ServerProbe) probe).getSatCluster().getId());
        assertEquals(s.getId(), ((ServerProbe) probe).getServer().getId());
        assertNotNull(probe.getState());
        assertNotNull(probe.getState().getLastCheck());
        assertNotNull(probe.getState().getOutput());
        assertEquals(probe.getState().getOutput(), "Awaiting Update");
    }

    private SatCluster grabSatCluster() {
        return (SatCluster) user.getOrg().getMonitoringScouts()
                .iterator().next();
    }

    /**
     * Test that it is possible to abort probe creation
     * in mid-stream
     */
    public void testCreateEmptyProbeForSuite() throws HibernateException {
        ProbeSuite ps = ProbeSuiteTest.createTestProbeSuite(user);
        Command c = MonitoringConstants.getCommandCheckTCP();
        ModifyProbeCommand cmd = new CreateTemplateProbeCommand(user, c, ps);
        // If the test fails on flush, it is because the command added
        // the probe to the suite too early. It shouldn't do that until
        // it is told to store explicitly
        flushAndEvict(ps);
        ps = (ProbeSuite) reload(ps);
        assertEquals(0, ps.getProbes().size());
    }

    /**
     * Test that it is possible to abort probe creation
     * in mid-stream
     * @throws Exception
     */
    public void testCreateEmptyServerProbe() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        Command c = MonitoringConstants.getCommandCheckTCP();
        SatCluster scout = grabSatCluster();
        Server s = ServerFactoryTest.createTestServer(user, false);

        ModifyProbeCommand cmd = new CreateServerProbeCommand(user, c, s, scout);
        // If the test fails on flush, it is because the command added
        // the probe to the suite too early. It shouldn't do that until
        // it is told to store explicitly
        flushAndEvict(s);
        s = (Server) reload(s);
    }
}
