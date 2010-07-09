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
package com.redhat.rhn.frontend.action.systems.monitoring.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ProbeState;
import com.redhat.rhn.domain.monitoring.command.Metric;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeDetailsAction;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.manager.monitoring.test.MonitoringManagerTest;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

/**
 * ProbeDetailsActionTest
 * @version $Rev: 53047 $
 */
public class ProbeDetailsActionTest extends RhnBaseTestCase {

    private User user;
    private Server s;
    private Probe probe;
    private ActionHelper ah;
    private Calendar entryCal;

    public void setUp() throws Exception {

        ProbeDetailsAction action = new ProbeDetailsAction();
        ah = new ActionHelper();
        ah.setUpAction(action);

        user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        s = ServerFactoryTest.createTestServer(user, true);
        probe = MonitoringFactoryTest.createTestProbe(user);
        ProbeState newState = new ProbeState((SatCluster)
                user.getOrg().getMonitoringScouts().iterator().next());
        newState.setLastCheck(new Date());
        newState.setOutput("Something is hozed\n");
        newState.setProbe(probe);
        SatCluster sc = (SatCluster)
            user.getOrg().getMonitoringScouts().iterator().next();
        newState.setScoutId(sc.getId());
        newState.setState(MonitoringConstants.PROBE_STATE_CRITICAL);
        probe.setState(newState);

        entryCal = MonitoringManagerTest.addStateChangeToProbe(probe);

        ah.getForm().set(ProbeDetailsAction.SHOW_GRAPH, new Boolean(true));
        ah.getForm().set(ProbeDetailsAction.SHOW_LOG, new Boolean(true));
        ah.getForm().set(RhnAction.SUBMITTED, new Boolean(true));
        Metric metric = (Metric) probe.getCommand().getMetrics().toArray()[0];
        String[] mids = new String[1];
        mids[0] = metric.getMetricId();

        ah.getForm().set(ProbeDetailsAction.METRICS, mids);
        ah.getForm().set(ProbeDetailsAction.SELECTED_METRICS, mids);

        ah.getRequest().setupAddParameter(ProbeDetailsAction.PROBEID,
                probe.getId().toString());
        ah.getRequest().setupAddParameter(ProbeDetailsAction.SID,
                s.getId().toString());

        // Setup the context
        Context c = Context.getCurrentContext();
        c.setLocale(Locale.getDefault());
        c.setTimezone(TimeZone.getDefault());


    }


    public void testExecute() throws Exception {

        // setup the date fields:
        setupDatePicker(ah.getForm().getMap(), "start",
                new Timestamp(entryCal.getTimeInMillis()));
        setupDatePicker(ah.getForm().getMap(), "end",
                new Timestamp(System.currentTimeMillis()));
        ah.getRequest().setupGetParameterMap(ah.getForm().getMap());

        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("probe"));
        assertNotNull(ah.getRequest().getAttribute("system"));
        assertNotNull(ah.getRequest().getAttribute("status_class"));
        assertNotNull(ah.getRequest().getAttribute("start"));
        assertNotNull(ah.getRequest().getAttribute("end"));
        assertNotNull(ah.getRequest().getAttribute(ProbeDetailsAction.IS_SUITE_PROBE));

        //Test status field
        assertNotNull(ah.getRequest().getAttribute("status"));
        String status = (String) ah.getRequest().getAttribute("status");
        assertEquals("CRITICAL, Something is hozed<br/>", status);


        DatePicker start = (DatePicker) ah.getRequest().getAttribute("start");
        DatePicker end = (DatePicker) ah.getRequest().getAttribute("end");
        assertTrue(start.getDay() != end.getDay());

        String metricsString = (String)
            ah.getRequest().getAttribute(ProbeDetailsAction.SELECTED_METRICS_STRING);
        String l10metricsString = (String)
            ah.getRequest().
                getAttribute(ProbeDetailsAction.L10NED_SELECTED_METRICS_STRING);
        assertEquals(metricsString, "metrics=latency&");
        assertEquals(l10metricsString, "l10nmetric_latency=Latency&");

        assertNotNull(ah.getRequest().getAttribute(ProbeDetailsAction.STARTTS));
        assertNotNull(ah.getRequest().getAttribute(ProbeDetailsAction.ENDTS));
        assertNotNull(ah.getForm().get(ProbeDetailsAction.SELECTED_METRICS));
        assertNotNull(ah.getForm().get(ProbeDetailsAction.METRICS));

        // Graph and Event log
        assertNotNull(ah.getRequest().getAttribute(ListHelper.LIST));
        DataResult dr = (DataResult) ah.getRequest().getAttribute(ListHelper.LIST);
        assertTrue(dr.size() > 0);
        assertTrue(dr.getTotalSize() > 0);
        assertEquals(1, dr.getStart());

    }

    // Test to make sure that we dont get a stacktrace
    // if the user selects a date/day that is invalid.
    // This can happen if they choose something like Feb 31st.
    public void testExecuteBadDates() throws Exception {

        setupBadDatePicker(ah.getForm().getMap(), "start");
        setupBadDatePicker(ah.getForm().getMap(), "end");

        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        DatePicker start = (DatePicker) ah.getRequest().getAttribute("start");
        DatePicker end = (DatePicker) ah.getRequest().getAttribute("end");
        assertNotNull(start.getDate());
        assertNotNull(end.getDate());
    }

    public void setupBadDatePicker(Map form, String name) {
        DatePicker dp = new DatePicker(name, TimeZone.getDefault(), Locale.ENGLISH,
                DatePicker.YEAR_RANGE_NEGATIVE);
        // There isn't the 31 of February, so lets force it as
        // if the User specified this date.
        dp.setYear(new Integer(2000));
        dp.setMonth(new Integer(1));
        dp.setDay(new Integer(31));
        dp.setHour(new Integer(0));
        dp.setMinute(new Integer(0));
        dp.setAmPm(new Integer(0));
        dp.writeToMap(form);

    }

    public static void setupDatePicker(Map map, String name, Date initDate) {
        DatePicker dp = new DatePicker(name, TimeZone.getDefault(), Locale.ENGLISH,
                DatePicker.YEAR_RANGE_NEGATIVE);
        dp.setDate(initDate);
        dp.writeToMap(map);
    }

}
