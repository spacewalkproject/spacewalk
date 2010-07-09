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
package com.redhat.rhn.domain.monitoring.suite.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ProbeParameterValue;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringTestUtils;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.hibernate.HibernateException;

import java.util.Date;
import java.util.Iterator;
import java.util.Map;

/**
 * MonitoringConfigTest
 * @version $Rev: 52080 $
 */
public class ProbeSuiteTest extends BaseTestCaseWithUser {

    private ProbeSuite probeSuite;

    public void setUp() throws Exception {
        super.setUp();
        probeSuite = createTestProbeSuite(user);
    }

    public void testCreateNew() throws Exception {
        checkSuiteFields(probeSuite);
        probeSuite = (ProbeSuite) reload(probeSuite);
        checkSuiteFields(probeSuite);
    }

    public void testDelete() throws Exception {
        Long id = probeSuite.getId();
        MonitoringFactory.deleteProbeSuite(probeSuite);
        flushAndEvict(probeSuite);
        assertNull(MonitoringFactory.lookupProbeSuiteByIdAndOrg(id, user.getOrg()));
    }

    public void testAddRemoveProbes() throws Exception {
        TemplateProbe probe = createTemplateProbe();

        probeSuite.addProbe(probe, user);
        assertTrue(probeSuite.getProbes().size() == 1);
        probeSuite.removeProbe(probe);
        assertTrue(probeSuite.getProbes().size() == 0);
        probeSuite.addProbe(probe, user);
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        Long psId = probeSuite.getId();
        flushAndEvict(probeSuite);
        probeSuite = MonitoringFactory.lookupProbeSuiteByIdAndOrg(psId, user.getOrg());
        assertTrue(probeSuite.getProbes().size() == 1);
        Probe savedP = (Probe) probeSuite.getProbes().iterator().next();
        assertTrue(savedP instanceof TemplateProbe);
        assertNotNull(((TemplateProbe)savedP).getProbeSuite());
        // Make sure delete still works
        Long id = probeSuite.getId();
        MonitoringFactory.deleteProbeSuite(probeSuite);
        flushAndEvict(probeSuite);
        assertNull(MonitoringFactory.lookupProbeSuiteByIdAndOrg(id, user.getOrg()));

    }

    public void testDeleteProbe() throws HibernateException {
        // bugzilla 161405
        TemplateProbe probe = createTemplateProbe();
        TemplateProbe otherProbe = createTemplateProbe();

        probeSuite.addProbe(probe, user);
        probeSuite.addProbe(otherProbe, user);
        assertEquals(2, probeSuite.getProbes().size());
        flushAndEvict(probeSuite);

        probe = (TemplateProbe) reload(probe);
        MonitoringFactory.deleteProbe(probe);
        probeSuite = (ProbeSuite) reload(probeSuite);
        assertEquals(1, probeSuite.getProbes().size());
    }

    public void testCloning() {
        TemplateProbe probe = createTemplateProbe();
        Probe newProbe = probe.deepCopy(user);
        assertFalse(newProbe instanceof TemplateProbe);
        assertNull(newProbe.getId());
        assertEquals(newProbe.getType(), MonitoringConstants.getProbeTypeCheck());
        assertNotNull(probe.getLastUpdateDate());
        assertEquals(probe.getProbeParameterValues().size(),
                newProbe.getProbeParameterValues().size());
        checkProbeFields(probe, newProbe);
    }


    // Found bug where when you add a ServerProbe to the suite all
    // the Servers assigned to the Suite get removed.
    public void testAddingProbesAfterServers() throws Exception {

        addTestServersToSuite(probeSuite, user);
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        probeSuite = (ProbeSuite) reload(probeSuite);
        // Add a probe
        TemplateProbe tprobe = createTemplateProbe();
        probeSuite.addProbe(tprobe, user);
        assertEquals("Servers in Suite is not == 5",
                5, probeSuite.getServersInSuite().size());
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        probeSuite = (ProbeSuite) reload(probeSuite);
        // This actually failed before the fix which involved
        // switching from a <bag> for the Probes back to a
        // <set> since Hibernate was too dumb to figure out we needed
        // to just add one, it would delete *ALL* the records for the
        // bag and re-insert.  This would cause orphaned records.
        assertEquals("Servers in Suite is not == 5",
                5, probeSuite.getServersInSuite().size());
    }

    public void testUpdateProbeValues() throws Exception {
        // Add a probe
        TemplateProbe tprobe = createTemplateProbe();
        probeSuite.addProbe(tprobe, user);
        // Add some servers and their probes
        addTestServersToSuite(probeSuite, user);
        tprobe.setCheckIntervalMinutes(new Long(2112));
        tprobe.setDescription("somedesc changed");
        tprobe.setLastUpdateDate(new Date());
        tprobe.setLastUpdateUser("someUserChanged");
        tprobe.setMaxAttempts(new Long(7));
        tprobe.setNotificationIntervalMinutes(new Long(5150));
        tprobe.setNotifyCritical(new Boolean(!tprobe.getNotifyCritical().booleanValue()));
        tprobe.setNotifyRecovery(new Boolean(!tprobe.getNotifyRecovery().booleanValue()));
        tprobe.setNotifyUnknown(new Boolean(!tprobe.getNotifyUnknown().booleanValue()));
        tprobe.setNotifyWarning(new Boolean(!tprobe.getNotifyWarning().booleanValue()));
        tprobe.setRetryIntervalMinutes(new Long(42));

        ProbeParameterValue pval = (ProbeParameterValue)
            tprobe.getProbeParameterValues().iterator().next();
        tprobe.setParameterValue(pval, "changed");
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        flushAndEvict(probeSuite);
        tprobe = (TemplateProbe) MonitoringFactory.lookupProbeByIdAndOrg(tprobe.getId(),
                                                                        user.getOrg());
        assertNotNull(tprobe);
        Iterator i = tprobe.getServerProbes().iterator();
        while (i.hasNext()) {
            ServerProbe p = (ServerProbe) i.next();
            checkProbeFields(tprobe, p);
            assertEquals(MonitoringConstants.PROBE_STATE_PENDING,
                    p.getState().getState());
        }

    }

    /**
     * Add some test Systems to the ProbeSuite
     * @param probeSuite
     * @param user The user who will own the systems in this suite
     */
    public static void addTestServersToSuite(ProbeSuite probeSuite, User user)
        throws Exception {

        user.addRole(RoleFactory.ORG_ADMIN);
        Server[] svrs = new Server[5];
        for (int i  = 0; i < 5; i++) {
            Server s = ServerFactoryTest.createTestServer(user, true);
            svrs[i] = s;
        }

        // Just grab the 1st one for this test.
        SatCluster sc = (SatCluster)
            user.getOrg().getMonitoringScouts().iterator().next();


        // Add 5 probes to the Suite.
        for (int i = 0; i < 5; i++) {
            TemplateProbe probe = (TemplateProbe)
                MonitoringFactoryTest.createTestProbe(user,
                    MonitoringConstants.getProbeTypeSuite());
            probeSuite.addProbe(probe, user);

        }

        // Add the Servers to the Suite.
        for (int i = 0; i < 5; i++) {
            probeSuite.addServerToSuite(sc, svrs[i], user);
        }
    }

    private void checkProbeFields(Probe probeOne, Probe probeTwo) {
        assertEquals(probeOne.getCheckIntervalMinutes(),
                probeTwo.getCheckIntervalMinutes());
        assertEquals(probeOne.getDescription(), probeTwo.getDescription());
        assertEquals(probeOne.getLastUpdateUser(), probeTwo.getLastUpdateUser());
        assertEquals(probeOne.getLastUpdateDate(), probeTwo.getLastUpdateDate());

        assertEquals(probeOne.getCommand(), probeTwo.getCommand());
        assertEquals(probeOne.getContactGroup(), probeTwo.getContactGroup());

        assertEquals(probeOne.getMaxAttempts(), probeTwo.getMaxAttempts());
        assertEquals(probeOne.getNotificationIntervalMinutes(),
                probeTwo.getNotificationIntervalMinutes());
        assertEquals(probeOne.getNotifyCritical(), probeTwo.getNotifyCritical());
        assertEquals(probeOne.getNotifyRecovery(), probeTwo.getNotifyRecovery());
        assertEquals(probeOne.getNotifyUnknown(), probeTwo.getNotifyUnknown());
        assertEquals(probeOne.getNotifyWarning(), probeTwo.getNotifyWarning());
        assertEquals(probeOne.getOrg(), probeTwo.getOrg());

        // Create some temporary sets of just the actual
        // String values so we can make sure they all got copied
        // OK. Can't rely on the equals() in ProbeParameterValue
        // since the values are assigned to different Probes
        Map oldValues = MonitoringTestUtils.parameterValueMap(probeOne);
        Map newValues = MonitoringTestUtils.parameterValueMap(probeTwo);
        assertNotEmpty(oldValues.keySet());
        assertEquals(oldValues, newValues);
    }

    private void checkSuiteFields(ProbeSuite ps) {
        assertNotNull(ps);
        assertNotNull(ps.getOrg());
        assertNotNull(ps.getSuiteName());
        assertNotNull(ps.getLastUpdateDate());
        assertNotNull(ps.getLastUpdateUser());
    }

    /**
     * Create a test ProbeSuite
     * @param user
     * @return new ProbeSuite
     */
    public static ProbeSuite createTestProbeSuite(User user) {
        ProbeSuite ps = MonitoringFactory.createProbeSuite(user);
        ps.setSuiteName("testSuite" + TestUtils.randomString());
        MonitoringFactory.saveProbeSuite(ps, user);
        assertTrue(ps.getLastUpdateUser().equals(user.getLogin()));
        return ps;
    }

    private TemplateProbe createTemplateProbe() {
        return (TemplateProbe) MonitoringFactoryTest.createTestProbe(user,
                MonitoringConstants.getProbeTypeSuite());
    }

}

