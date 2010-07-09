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
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ProbeState;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandGroup;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.MonitoredServer;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.dto.monitoring.ProbeSuiteDto;
import com.redhat.rhn.frontend.dto.monitoring.ServerProbeDto;
import com.redhat.rhn.frontend.dto.monitoring.StateChangeData;
import com.redhat.rhn.frontend.dto.monitoring.TimeSeriesData;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

/**
 * JUnit test case for the SessionManagerTest.
 * @version $Rev: 49711 $
 */

public class MonitoringManagerTest extends RhnBaseTestCase {

    public static final String TEST_METRIC = "latency";
    public static final String TEST_METRIC2 = "pctfree";

    private User user;
    private ServerProbe probe;

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        user = UserTestUtils.findNewUser("testUser", "testOrg");
        if (ConfigDefaults.get().isMonitoringBackend()) {
            probe = (ServerProbe) MonitoringFactoryTest.createTestProbe(user);
        }
    }

    public void testGetTimeSeriesData() throws Exception {

        // If this is in HOSTED, dont run the test
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }

        Timestamp etime = addTimeSeriesDataToProbe(user, probe);

        // Now look up the data
        TimeSeriesData[] tsd = MonitoringManager.getInstance().getProbeData(
                probe, TEST_METRIC, new Timestamp(etime.getTime() - 6000),
                etime);

        assertNotNull(tsd);
        assertTrue(tsd.length > 0);
        Calendar cal = Calendar.getInstance();
        cal.setTime(tsd[0].getTime());
        assertTrue(cal.get(Calendar.YEAR) > 2000); // 1115775099

        tsd = MonitoringManager.getInstance().getProbeData(probe,
                "NONEXISTINGMETRIC", new Timestamp(etime.getTime() - 6000),
                etime);
        assertNull(tsd);

    }

    public void testGetTimeSeriesList() throws Exception {
        // If this is in HOSTED, dont run the test
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        Timestamp etime = addTimeSeriesDataToProbe(user, probe);

        // Its OK to add two of the same metrics, we just want to
        // the ability to get back a list.
        String[] metrics = new String[2];
        metrics[0] = TEST_METRIC;
        metrics[1] = TEST_METRIC;
        List tsdList = MonitoringManager.getInstance().getProbeDataList(probe,
                metrics, new Timestamp(etime.getTime() - 6000), etime);
        assertNotNull(tsdList);
        assertTrue(tsdList.size() == 2);
        assertTrue(tsdList.get(0) instanceof TimeSeriesData[]);
        TimeSeriesData[] tsd = (TimeSeriesData[]) tsdList.get(0);
        assertTrue(tsd[0].getMetric().equals(TEST_METRIC));
        metrics[0] = "NOTVALID1";
        metrics[1] = "NOTVALID2";
        tsdList = MonitoringManager.getInstance().getProbeDataList(probe,
                metrics, new Timestamp(etime.getTime() - 6000), etime);
        assertTrue(tsdList.size() == 0);
        // Test NULL Metrics
        metrics = null;
        tsdList = MonitoringManager.getInstance().getProbeDataList(probe,
                metrics, new Timestamp(etime.getTime() - 6000), etime);
        assertTrue(tsdList.size() == 0);

    }

    /**
     * Add some test data to the probe
     * @param probeIn to add data to
     */
    public static Timestamp addTimeSeriesDataToProbe(User userIn, Probe probeIn) {
        return addTimeSeriesDataToProbe(userIn, probeIn, 2);
    }
    /**
     * Add some test data to the probe
     * @param probeIn to add data to
     */
    public static Timestamp addTimeSeriesDataToProbe(User userIn,
            Probe probeIn, int number) {
        return addTimeSeriesDataToProbe(userIn, probeIn, number, TEST_METRIC);
    }

    /**
     * Add some test data to the probe
     * @param probeIn to add data to
     */
    public static Timestamp addTimeSeriesDataToProbe(User userIn,
            Probe probeIn, int number, String metric) {
        Timestamp entryTime = null;
        for (int i = 0; i < number; i++) {
            Calendar start = Calendar.getInstance();
            start.roll(Calendar.HOUR, -3);
            start.add(Calendar.MINUTE, (i * 5));
            Float rnd = new Float(Math.random() * 10);
            entryTime = new Timestamp(start.getTimeInMillis());
            insertTimeSeriesData(entryTime,
                    userIn.getOrg().getId(),
                    probeIn.getId(), rnd.toString(), metric);
         }
        // Insert a blank number, since some probe data has NULL data.
        Timestamp laterTime = new Timestamp(System.currentTimeMillis());
        insertTimeSeriesData(laterTime, userIn.getOrg().getId(), probeIn
                .getId(), "", metric);
        return entryTime;
    }

    private static void insertTimeSeriesData(Timestamp entryTime, Long orgId,
            Long probeId, String data, String metric) {

        WriteMode m = ModeFactory.getWriteMode("test_queries",
                "insert_into_time_series");
        Map params = new HashMap();
        // oid, entry_time, data
        // 1-3-pctfree
        String oid = orgId + "-" + probeId + "-" + metric;
        params.put("oid", oid);
        // Divide by 1000 to convert to minutes
        params.put("entry_time", new Long(entryTime.getTime() / 1000));
        params.put("data", data);
        m.executeUpdate(params);
    }

    /**
     * Add an entry in the state_change table for this probe
     * @param probeIn probe we want to add it to
     * @return the Calendar containing the entry time
     * @throws Exception
     */
    public static Calendar addStateChangeToProbe(Probe probeIn)
        throws Exception {
        String dateString = "Nov 1, 2000 6:00 PM";
        return addStateChangeToProbe(probeIn, dateString);
    }

    /**
     * Add an entry in the state_change table for this probe
     * @param probeIn probe we want to add it to
     * @param dateString the date we want to use for the entry
     * @return the Calendar containing the entry time
     * @throws Exception
     */
    public static Calendar addStateChangeToProbe(Probe probeIn, String dateString)
        throws Exception {
        WriteMode m = ModeFactory.getWriteMode("test_queries",
                "insert_into_state_change");
        Map params = new HashMap();
        // oid == probe id
        params.put("oid", probeIn.getId());
        // Get the default MEDIUM/SHORT DateFormat
        DateFormat format = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,
                DateFormat.SHORT);

        // Set TZ to GMT so this test will work in any timezone.
        Context ctx = Context.getCurrentContext();
        ctx.setTimezone(TimeZone.getTimeZone("GMT"));
        format.setTimeZone(Context.getCurrentContext().getTimezone());

        Date startDate = format.parse(dateString);
        Calendar cal = Calendar.getInstance();
        cal.setTime(startDate);
        Long startTime = new Long(cal.getTimeInMillis() / 1000);
        params.put("entry_time", startTime);
        params.put("data", "UNKNOWN Test state change from unit tests");
        m.executeUpdate(params);
        return cal;

    }

    public void testStateChange() throws Exception {
        // If this is in HOSTED, dont run the test
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        String dateString1 = "Nov 1, 2000 6:00 PM";
        addStateChangeToProbe(probe, dateString1);
        String dateString2 = "Nov 1, 2001 6:00 PM";
        Calendar cal = addStateChangeToProbe(probe, dateString2);

        // Now look up the data
        DataResult scd = MonitoringManager.getInstance().getProbeStateChangeData(
                probe, new Timestamp(cal.getTimeInMillis() - 6000),
                new Timestamp(cal.getTimeInMillis()));
        assertNotNull(scd);
        assertTrue(scd.size() > 0);
        assertTrue(scd.getTotalSize() > 0);
        // Make sure we get back an actual DTO object
        assertTrue(scd.get(0) instanceof StateChangeData);
        StateChangeData sc = (StateChangeData) scd.get(0);
        // Test to make sure we get 2001 because we want the
        // most recent entry first, see BZ: 161950
        assertEquals(sc.getEntryDate(), "11/1/01 6:00:00 PM GMT");
    }

    public void testStateChangeStatusString() throws Exception {
        StateChangeData sc = new StateChangeData();
        sc.setData("UNKNOWN Test state change from unit tests");
        assertEquals(sc.getMessage(), "Test state change from unit tests");
        assertEquals(sc.getState(), "UNKNOWN");

    }

    public void testStoreProbe() throws Exception {
        // If this is in HOSTED, dont run the test
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        String changeDesc = probe.getDescription() + TestUtils.randomString();
        probe.setDescription(changeDesc);
        Long id = probe.getId();
        MonitoringManager.getInstance().storeProbe(probe, user);
        flushAndEvict(probe);
        Probe p2 = MonitoringManager.getInstance().lookupProbe(user, id);
        assertEquals(p2.getDescription(), changeDesc);
    }

    public void testGetConfigMacros() {
        // If this is in HOSTED, dont run the test
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }

        user.addRole(RoleFactory.ORG_ADMIN);
        assertTrue(MonitoringManager.getInstance()
                .getEditableConfigMacros(user).size() > 0);
        user.removeRole(RoleFactory.ORG_ADMIN);
        assertTrue(MonitoringManager.getInstance()
                .getEditableConfigMacros(user).size() == 0);
        user.addRole(RoleFactory.MONITORING_ADMIN);
        assertTrue(MonitoringManager.getInstance()
                .getEditableConfigMacros(user).size() > 0);


    }

    public void testRestartMonitoringServices() throws Exception {
        // We don't want to actually restart the services
        MonitoringManager man = new MonitoringManager() {

            protected void restartService(String serviceName) {
                return;
            }
        };
        user.removeRole(RoleFactory.ORG_ADMIN);
        assertFalse(man.restartMonitoringServices(user));
        user.getOrg().addRole(RoleFactory.MONITORING_ADMIN);
        user.addRole(RoleFactory.MONITORING_ADMIN);
        assertTrue(man.restartMonitoringServices(user));
        user.removeRole(RoleFactory.MONITORING_ADMIN);
        user.addRole(RoleFactory.ORG_ADMIN);
        assertTrue(man.restartMonitoringServices(user));
    }

    public void testDeleteProbe() throws Exception {
        // If this is in HOSTED, dont run the test
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        Long id = probe.getId();
        MonitoringManager.getInstance().deleteProbe(probe, user);
        flushAndEvict(probe);
        assertNull(MonitoringManager.getInstance().lookupProbe(user, id));
    }

    public void testProbeSuitesInOrg() throws Exception {

        for (int i = 0; i < 5; i++) {
            ProbeSuiteTest.createTestProbeSuite(user);
        }
        DataResult dr = MonitoringManager.getInstance().listProbeSuites(user, null);
        assertTrue(dr.size() > 4);
        ProbeSuiteDto row = (ProbeSuiteDto) dr.get(0);
        assertNotNull(row.getSuiteId());
        assertNotNull(row.getSuiteName());
        assertNotNull(row.getSystemCount());
    }

    public void testAddServerToSuite() throws Exception {
        // If this is in HOSTED, dont run the test
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(user);
        Server s = ServerFactoryTest.createTestServer(user);
        TemplateProbe tprobe = (TemplateProbe) MonitoringFactoryTest.
            createTestProbe(user, MonitoringConstants.getProbeTypeSuite());
        suite.addProbe(tprobe, user);
        // TODO: Add sat cluster as a param
        SatCluster satCluster = (SatCluster)
            user.getOrg().getMonitoringScouts().iterator().next();
        MonitoringManager.getInstance().addSystemToProbeSuite(suite, s, satCluster, user);
    }

    public void testServersToSuite() throws Exception {

        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        ProbeSuite probeSuite = ProbeSuiteTest.createTestProbeSuite(user);
        ProbeSuiteTest.addTestServersToSuite(probeSuite, user);
        Long psId = probeSuite.getId();
        Long orgId = probeSuite.getOrg().getId();
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        flushAndEvict(probeSuite);
        probeSuite = MonitoringFactory.lookupProbeSuiteByIdAndOrg(psId,
                OrgFactory.lookupById(orgId));
        assertTrue(probeSuite.getProbes().size() == 5);

        assertEquals("Servers in Suite is not == 5",
                    5, probeSuite.getServersInSuite().size());

        Iterator i = probeSuite.getProbes().iterator();
        while (i.hasNext()) {
            TemplateProbe p = (TemplateProbe) i.next();
            assertEquals("Servers using ServerProbe not equal 5",
                    5, p.getServersUsingProbe().size());
        }

        // Test removing a system.
        Server s = (Server) probeSuite.getServersInSuite().iterator().next();
        MonitoringManager.getInstance().removeServerFromSuite(probeSuite, s, user);
        // assertTrue(probeSuite.getServersInSuite().size() == 4);
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        flushAndEvict(probeSuite);

        probeSuite = MonitoringFactory.lookupProbeSuiteByIdAndOrg(psId,
                OrgFactory.lookupById(orgId));
        assertTrue(probeSuite.getServersInSuite().size() == 4);

        // Check that deleting still works
        Long id = probeSuite.getId();
        MonitoringFactory.deleteProbeSuite(probeSuite);
        flushAndEvict(probeSuite);
        assertNull(MonitoringFactory.lookupProbeSuiteByIdAndOrg(id, user.getOrg()));

    }

    public void testDetachProbes() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        ProbeSuite probeSuite = ProbeSuiteTest.createTestProbeSuite(user);
        TemplateProbe tprobe = (TemplateProbe) MonitoringFactoryTest.createTestProbe(user,
                MonitoringConstants.getProbeTypeSuite());
        probeSuite.addProbe(tprobe, user);
        // Add some servers and their probes
        ProbeSuiteTest.addTestServersToSuite(probeSuite, user);
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        probeSuite = (ProbeSuite) reload(probeSuite);

        assertTrue(probeSuite.getServersInSuite().size() == 5);
        Server s = (Server) probeSuite.getServersInSuite().iterator().next();
        MonitoringManager.getInstance().
            detatchServerFromSuite(probeSuite, s, user);

        assertTrue(probeSuite.getServersInSuite().size() == 4);
        MonitoringFactory.saveProbeSuite(probeSuite, user);

        probeSuite = (ProbeSuite) reload(probeSuite);
        assertTrue(probeSuite.getServersInSuite().size() == 4);

        MonitoredServer monS = (MonitoredServer) reload(s);
        assertEquals(6, monS.getProbes().size());
    }



    public void testGetCommands() {
        List commandGroups = MonitoringFactory.loadAllCommandGroups();
        HashSet allGroupNames = groupsToGroupNames(commandGroups);
        for (int i = 0; i < commandGroups.size(); i++) {
            CommandGroup g = (CommandGroup) commandGroups.get(i);
            Iterator commands = MonitoringManager.
                getInstance().listCommands(g).iterator();
            HashSet groupNames = commandsToGroupNames(commands);
            if (CommandGroup.ALL_GROUP_NAME.equals(g.getGroupName())) {
                assertEquals(allGroupNames, groupNames);
            }
            else {
                assertEquals(1, groupNames.size());
                assertEquals(g.getGroupName(), groupNames.iterator().next());
            }
        }
    }

    public void testGetProbeCountsByState() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        for (int i = 0; i < 5; i++) {
            createProbeWithState(user, MonitoringConstants.PROBE_STATE_CRITICAL);
        }
        List critProbes = MonitoringManager.getInstance().
            listProbeCountsByState(user, MonitoringConstants.PROBE_STATE_CRITICAL, null);
        assertTrue("not enough returned: " + critProbes.size(), critProbes.size() >= 1);

    }

    public void testGetProbesByState() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        for (int i = 0; i < 5; i++) {
            createProbeWithState(user, MonitoringConstants.PROBE_STATE_CRITICAL);
        }
        List allprobes = MonitoringManager.getInstance().
            listProbesByState(user, null, null);
        assertTrue("not enough returned: " + allprobes.size(), allprobes.size() >= 1);
        List critprobes = MonitoringManager.getInstance().
            listProbesByState(user, MonitoringConstants.PROBE_STATE_CRITICAL, null);
        assertTrue("not enough returned: " + critprobes.size(), critprobes.size() >= 1);
        ServerProbeDto row = (ServerProbeDto) allprobes.get(0);
        assertNotNull(row.getStateString());
    }

    public void testListProbeStateSummary() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        for (int i = 0; i < 5; i++) {
            createProbeWithState(user, MonitoringConstants.PROBE_STATE_CRITICAL);
        }
        List states = MonitoringManager.getInstance().
            listProbeStateSummary(user);
        assertTrue("not enough returned: " + states.size(), states.size() >= 1);
    }


    public static Probe createProbeWithState(User userIn, String stateIn) {

        SatCluster sc = (SatCluster)
            userIn.getOrg().getMonitoringScouts().iterator().next();
        Probe p = MonitoringFactoryTest.createTestProbe(userIn);
        ProbeState ps = new ProbeState(sc);
        ps.setState(stateIn);
        ps.setOutput("Test State from Unit Tests");
        ps.setProbe(p);
        p.setState(ps);
        MonitoringFactory.save(p, userIn);
        TestUtils.flushAndEvict(p);
        TestUtils.flushAndEvict(ps);
        return p;
    }

    private HashSet commandsToGroupNames(Iterator commands) {
        HashSet groupNames = new HashSet();
        while (commands.hasNext()) {
            Command c = (Command) commands.next();
            groupNames.add(c.getCommandGroup().getGroupName());
        }
        return groupNames;
    }

    private HashSet groupsToGroupNames(List commandGroups) {
        HashSet allGroupNames = new HashSet();
        for (int j = 0; j < commandGroups.size(); j++) {
            allGroupNames.add(((CommandGroup) commandGroups.get(j))
                    .getGroupName());
        }
        assertContains(allGroupNames, CommandGroup.ALL_GROUP_NAME);
        allGroupNames.remove(CommandGroup.ALL_GROUP_NAME);
        return allGroupNames;
    }
}
