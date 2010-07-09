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

import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeDetailsAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeGraphAction;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.test.MonitoringManagerTest;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.sql.Timestamp;
import java.util.Locale;
import java.util.TimeZone;

/**
 * ProbeDetailsActionTest
 * @version $Rev: 53047 $
 */
public class ProbeGraphActionTest extends RhnBaseTestCase {

    private User user;
    private Probe probe;
    private ProbeGraphAction action;
    private ActionHelper ah;
    private Server server;
    private Timestamp testTime;


    public void setUp() throws Exception {
        super.setUp();
        testTime = new Timestamp(System.currentTimeMillis());
        user = UserTestUtils.createUserInOrgOne();
        server = ServerFactoryTest.createTestServer(user, false);
        probe = MonitoringFactoryTest.createTestProbe(user);

        action = new ProbeGraphAction();
        ah = new ActionHelper();
        ah.setUpAction(action);
        ah.getRequest().setupAddParameter(RequestContext.LIST_DISPLAY_EXPORT, "0");
        ah.getRequest().setupAddParameter(ProbeDetailsAction.PROBEID,
                probe.getId().toString());
        ah.getRequest().setupAddParameter(ProbeDetailsAction.SID,
                server.getId().toString());
        ah.getRequest().setupAddParameter(
                ProbeDetailsAction.L10NKEY + MonitoringManagerTest.TEST_METRIC,
                "l10ned" + MonitoringManagerTest.TEST_METRIC);
        ah.getRequest().setupAddParameter(
                ProbeDetailsAction.L10NKEY + MonitoringManagerTest.TEST_METRIC2,
                "l10ned" + MonitoringManagerTest.TEST_METRIC2);
        Context ctx = Context.getCurrentContext();
        ctx.setTimezone(TimeZone.getDefault());
        ctx.setLocale(Locale.getDefault());
    }

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        Context.freeCurrentContext();
    }


    public void testExecute() throws Exception {
        ah.getResponse().setExpectedContentType(ProbeGraphAction.MIME_TYPE);

        testTime = MonitoringManagerTest.addTimeSeriesDataToProbe(user, probe, 20);

        ah.getRequest().setupAddParameter(ProbeGraphAction.STARTTS,
                new Long(testTime.getTime() - 60000000).toString());
        ah.getRequest().setupAddParameter(ProbeGraphAction.ENDTS,
                new Long(testTime.getTime()).toString());
        String[] metrics = new String[2];
        metrics[0] = MonitoringManagerTest.TEST_METRIC;
        metrics[1] = MonitoringManagerTest.TEST_METRIC2;
        ah.getRequest().setupAddParameter(ProbeDetailsAction.L10NKEY, "localized m2");
        ah.getRequest().setupAddParameter(ProbeGraphAction.METRICS, metrics);
        ah.executeAction("execute", false);
        assertNotNull(ah.getResponse().getOutputStreamContents());
        ah.getResponse().verify();
    }


    public void testExecuteNoData() throws Exception {

        ah.getRequest().setupAddParameter(ProbeGraphAction.STARTTS,
                new Long(testTime.getTime() - 6000).toString());
        ah.getRequest().setupAddParameter(ProbeGraphAction.ENDTS,
                new Long(testTime.getTime()).toString());
        String[] metrics = new String[2];
        metrics[0] = MonitoringManagerTest.TEST_METRIC;
        metrics[1] = MonitoringManagerTest.TEST_METRIC2;
        ah.getRequest().setupAddParameter(ProbeGraphAction.METRICS, metrics);
        ah.executeAction("execute", false);
        assertNotNull(ah.getResponse().getOutputStreamContents());
        ah.getResponse().verify();
    }

    // Some Probes have no metrics (General: Check Nothing)
    public void testExecuteNoMetrics() throws Exception {
        ah.getRequest().setupAddParameter(ProbeGraphAction.STARTTS,
                new Long(testTime.getTime() - 6000).toString());
        ah.getRequest().setupAddParameter(ProbeGraphAction.ENDTS,
                new Long(testTime.getTime()).toString());
        // This is the KEY part of the test, set the Metrics array to NULL.
        ah.getRequest().setupAddParameter(ProbeGraphAction.METRICS, (String[]) null);
        ah.executeAction("execute", false);
        assertNotNull(ah.getResponse().getOutputStreamContents());
        ah.getResponse().verify();


    }

}


