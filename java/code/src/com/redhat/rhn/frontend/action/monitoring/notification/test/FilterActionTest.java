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
package com.redhat.rhn.frontend.action.monitoring.notification.test;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.notification.Criteria;
import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.MatchType;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.monitoring.notification.test.FilterTest;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.notification.FilterCreateAction;
import com.redhat.rhn.frontend.action.monitoring.notification.FilterEditAction;
import com.redhat.rhn.frontend.action.systems.monitoring.test.ProbeDetailsActionTest;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.satellite.ConfigureSatelliteCommand;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.Globals;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Locale;
import java.util.TimeZone;

/**
 * FilterActionTest - test the create/edit Actions
 * @version $Rev: 53047 $
 */
public class FilterActionTest extends RhnBaseTestCase {

    private static final String TEST_DURATION = "6";

    private User user;
    private Filter filter;
    private Action action;
    private ActionHelper ah;

    public void enableMonitoring() throws Exception {
        ConfigureSatelliteCommand cmd = new ConfigureSatelliteCommand(user);
        cmd.updateBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, true);
        cmd.updateBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, true);
        
    }
    
    // Not used directly by JUnit, instead we just want
    // to re-use ALL this stuff in this class twice for
    // each Action: Create and Edit.
    private void setUpAction(Action actionIn, String forwardName) throws Exception {
        super.setUp();
        user = UserTestUtils.createUserInOrgOne();
        user.addRole(RoleFactory.ORG_ADMIN);
        filter = FilterTest.createTestFilter(user,
                "filter" + TestUtils.randomString());
        // Create a test probe
        ServerProbe p = (ServerProbe) MonitoringFactoryTest.createTestProbe(user);
        Server s = ServerFactoryTest.createTestServer(user, true);
        SatCluster sc = (SatCluster) user.getOrg().getMonitoringScouts().iterator().next();
        p.addProbeToSatCluster(sc, s);
        MonitoringFactory.save(p, user);

        action = actionIn;
        ah = new ActionHelper();
        ah.setUpAction(action, forwardName);
        ah.getForm().setFormName("filterCreateForm");
        ah.getRequest().setupAddParameter(RequestContext.FILTER_ID,
                filter.getId().toString());
        ah.getForm().set("recurring", Boolean.FALSE);
        ah.getForm().set("scope", "org");
        // Set the recurring_duration to
        ah.getForm().set(FilterCreateAction.RECURRING_DURATION, "");
        // Setup the context
        Context c = Context.getCurrentContext();
        c.setLocale(Locale.getDefault());
        c.setTimezone(TimeZone.getDefault());
        // setup the date fields:
        Calendar nowCal = Calendar.getInstance();
        nowCal.setTime(new Date());
        ProbeDetailsActionTest.setupDatePicker(ah.getForm().getMap(), "start",
                new Timestamp(nowCal.getTimeInMillis()));
        ProbeDetailsActionTest.setupDatePicker(ah.getForm().getMap(), "end",
                new Timestamp(nowCal.getTimeInMillis() + 60000000));
        ah.getRequest().setupGetParameterMap(ah.getForm().getMap());


    }

    protected void tearDown() throws Exception {
        user = null;
        filter = null;
        action = null;
        ah = null;
        super.tearDown();
    }

    public void testCreateExecute() throws Exception {
       
        setUpAction(new FilterCreateAction(), "default");
        executeNonSubmit();
    }

    public void testCreateSubmitExecuteRegular() throws Exception {
        action = new FilterCreateAction();
        setUpAction(action, "success");
        executeSubmit();
        assertFalse(filter.getRecurring().booleanValue());
        Calendar now = Calendar.getInstance();
        now.setTime(new Date());
        Calendar expires = Calendar.getInstance();
        expires.setTime(filter.getExpiration());

        long hoursbtwn = getHoursBetween(now.getTimeInMillis(),
                expires.getTimeInMillis());
        // Make sure we are at or above 5 hours, since we are doing
        // some floating point math below, we want to make sure its
        // coming 'close' to the right answer.
        assertTrue(hoursbtwn >= 16);

    }


    public void testCreateSubmitFailValidation() throws Exception {

        action = new FilterCreateAction();
        setUpAction(action, "default");
        ah.getForm().set(RhnAction.SUBMITTED, new Boolean(true));
        ah.getForm().set(FilterCreateAction.DESCRIPTION, "");
        ah.getForm().set(FilterCreateAction.RECURRING_DURATION, "");
        ah.executeAction();
        assertNotNull(ah.getRequest().getSession().getAttribute(Globals.ERROR_KEY));
        ActionMessages messages = (ActionMessages)
            ah.getRequest().getSession().getAttribute(Globals.ERROR_KEY);
        assertEquals(1, messages.size());
        assertEquals("", ah.getForm().get(FilterCreateAction.DESCRIPTION));

        // Test requiredIf
        ah.getForm().set(FilterCreateAction.RECURRING, Boolean.TRUE);
        ah.executeAction();
        messages = (ActionMessages)
            ah.getRequest().getSession().getAttribute(Globals.ERROR_KEY);
        assertEquals(2, messages.size());


    }

    public void testCreateSubmitExecuteRecurring() throws Exception {
        action = new FilterCreateAction();
        setUpAction(action, "success");
        ah.getForm().set(FilterCreateAction.RECURRING, Boolean.TRUE);
        ah.getForm().set(FilterCreateAction.RECURRING_DURATION, TEST_DURATION);
        ah.getForm().set(FilterCreateAction.RECURRING_FREQUENCY,
                new Long(Calendar.WEEK_OF_YEAR));
        ah.getForm().set(FilterCreateAction.DURATION_TYPE,
                         new Long(Calendar.HOUR_OF_DAY));
        executeSubmit();
        assertTrue(filter.getRecurring().booleanValue());
        assertEquals(new Long(Calendar.WEEK_OF_YEAR), filter.getRecurringFrequency());
        assertEquals(new Long(360), filter.getRecurringDuration());
        assertEquals(new Long(Calendar.HOUR_OF_DAY), filter.getRecurringDurationType());
    }

    public void testCreateSubmitScopeProbe() throws Exception {
        action = new FilterCreateAction();
        setUpAction(action, "success");
        String scope = MatchType.PROBE.getScope();
        ah.getForm().set("scope", scope);
        String[] values = new String[] { "1", "2" };
        ah.getForm().set(scope, values);
        executeSubmit();
        checkCriteria(MatchType.PROBE, values);
    }

    public void testEditExecute() throws Exception {
        
        setUpAction(new FilterEditAction(), "default");
        filter.setRecurringDuration(new Long(TEST_DURATION));
        filter.setRecurringFrequency(new Long(Calendar.MONTH));
        filter.setRecurringDurationType(new Long(Calendar.MINUTE));
        executeNonSubmit();
        assertNotNull(ah.getForm().get(FilterCreateAction.DESCRIPTION));

        DynaActionForm form = ah.getForm();
        assertEquals(form.get(FilterEditAction.RECURRING),
                filter.getRecurring());
        assertEquals(form.get(FilterEditAction.RECURRING_DURATION),
                filter.getRecurringDuration().toString());
        assertEquals(form.get(FilterEditAction.RECURRING_FREQUENCY),
                filter.getRecurringFrequency());
        assertEquals(form.get(FilterEditAction.DURATION_TYPE),
                filter.getRecurringDurationType());
    }

    public void testLongRecurDuration() throws Exception {
        setUpAction(new FilterEditAction(), "default");
        filter.setRecurringDuration(new Long(364240800));
        filter.setRecurringDurationType(new Long(Calendar.YEAR));
        executeNonSubmit();


        DynaActionForm form = ah.getForm();
        assertEquals("99", form.get(FilterEditAction.RECURRING_DURATION));
    }



    public void testEditSubmitExecute() throws Exception {
        action = new FilterEditAction();
        setUpAction(action, "success");
        executeSubmit();
    }

    // Test to flip a Filter from recurring back to
    // standard filter. BZ: 163700
    public void testEditSubmitExecuteUnRecurring() throws Exception {

        action = new FilterEditAction();
        setUpAction(action, "success");
        filter.setRecurring(Boolean.TRUE);
        MonitoringManager.getInstance().storeFilter(filter, user);
        ah.getForm().set(FilterCreateAction.RECURRING, Boolean.FALSE);
        executeSubmit();
        assertFalse(filter.getRecurring().booleanValue());
        assertNull(filter.getRecurringDuration());
        assertNull(filter.getRecurringDurationType());
    }


    public void testEditSubmitScope() throws Exception {
        action = new FilterEditAction();
        setUpAction(action, "success");
        // Modify the filter
        filter.addCriteria(MatchType.PROBE, "1");
        filter.addCriteria(MatchType.PROBE, "2");
        filter.addCriteria(MatchType.PROBE, "3");
        NotificationFactory.saveFilter(filter, user);

        String scope = MatchType.SCOUT.getScope();
        ah.getForm().set("scope", scope);
        String[] values = new String[] { "4" };
        ah.getForm().set(scope, values);
        executeSubmit();
        checkCriteria(MatchType.SCOUT, values);
    }

    public void testEditSubmitState() throws Exception {
        action = new FilterEditAction();
        setUpAction(action, "success");
        // Modify the filter
        filter.addCriteria(MatchType.STATE, "OK");
        filter.addCriteria(MatchType.STATE, "WARN");
        filter.addCriteria(MatchType.STATE, "CRITICAL");
        NotificationFactory.saveFilter(filter, user);

        String[] values = new String[] { "OK", "UNKNOWN" };
        ah.getForm().set("states", values);
        executeSubmit();
        checkCriteria(MatchType.STATE, values);
    }

    private void executeNonSubmit() throws Exception {
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("filter"));
        assertNotNull(ah.getRequest().getAttribute("start"));
        assertNotNull(ah.getRequest().getAttribute("filterTypes"));
        assertNotNull(ah.getRequest().getAttribute("scopes"));
        assertNotNull(ah.getRequest().getAttribute("org"));
        assertNotNull(ah.getRequest().getAttribute("scout"));
        assertNotNull(ah.getRequest().getAttribute("probe"));
        assertFalse(((Boolean) ah.getForm().get(
                FilterCreateAction.RECURRING)).booleanValue());
        assertTrue(((DataResult) ah.getRequest().getAttribute("probe")).size() > 0);
        assertNotNull(ah.getForm().get(FilterCreateAction.FILTER_TYPE));
        assertNotNull(ah.getRequest().getAttribute(FilterCreateAction.DURATION_TYPES));
        assertNotNull(ah.getRequest().getAttribute(FilterCreateAction.FREQUENCY_TYPES));
        String[] orgs = ah.getForm().getStrings(FilterCreateAction.ORG);
        assertNotNull(orgs);
        assertEquals(1, orgs.length);
        assertEquals(ah.getUser().getOrg().getId().toString(), orgs[0]);
        String[] scouts = ah.getForm().getStrings(FilterCreateAction.SCOUT);
        assertNotNull(scouts);
        assertEquals(1, scouts.length);
    }

    private void executeSubmit() throws Exception {

        ah.getForm().set(RhnAction.SUBMITTED, new Boolean(true));
        String newDesc = "testNewDesc" + TestUtils.randomString();
        ah.getForm().set("description", newDesc);
        ah.getForm().set("description", newDesc);
        ah.getForm().set("filterType", NotificationFactory.FILTER_TYPE_ACK.getName());
        ah.getForm().set("destination", "addr1@example.com,addr2@example.com");
        ActionForward af = ah.executeAction();
        assertEquals("success", af.getName());
        assertNotNull(ah.getRequest().getAttribute("start"));
        assertNotNull(ah.getRequest().getAttribute("end"));
        filter = (Filter) ah.getRequest().getAttribute("filter");
        assertNotNull(filter);
        filter = (Filter) reload(filter);
        assertEquals(newDesc, filter.getDescription());
        assertEquals(2, filter.getEmailAddresses().size());
    }

    private void checkCriteria(MatchType matchType, String[] strValues) {
        assertNotNull(filter.getCriteria());
        assertEquals(strValues.length, filter.getCriteria().size());
        HashSet values = new HashSet();
        HashSet types = new HashSet();
        for (Iterator i = filter.getCriteria().iterator(); i.hasNext();) {
            Criteria c = (Criteria) i.next();
            values.add(c.getValue());
            types.add(c.getMatchType());
        }
        for (int i = 0; i < strValues.length; i++) {
            assertContains(values, strValues[i]);
        }
        assertEquals(1, types.size());
        assertContains(types, matchType);
    }

    private long getHoursBetween(long first, long second) {

        long milliElapsed = second - first;
        double hoursElapsed = (milliElapsed / 3600F / 1000F);
        float rounded = (Math.round(hoursElapsed * 100F) / 100F);
        return new Float(rounded).longValue();
    }

}

