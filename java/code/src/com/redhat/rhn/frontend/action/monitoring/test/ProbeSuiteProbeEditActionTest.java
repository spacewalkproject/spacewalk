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
package com.redhat.rhn.frontend.action.monitoring.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringTestUtils;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteProbeEditAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeDetailsAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.action.ActionForward;

import java.util.List;

/**
 * ProbeDetailsActionTest
 * @version $Rev: 53047 $
 */
public class ProbeSuiteProbeEditActionTest extends RhnBaseTestCase {

    private User user;
    private TemplateProbe probe;
    private ProbeSuiteProbeEditAction action;
    private ProbeSuite probeSuite;

    protected void setUp() throws Exception {
        super.setUp();
        user = UserTestUtils.createUserInOrgOne();
        UserTestUtils.addMonitoring(user.getOrg());
        probeSuite = ProbeSuiteTest.createTestProbeSuite(user);
        probe = (TemplateProbe) MonitoringFactoryTest.createTestProbe(user,
                MonitoringConstants.getProbeTypeSuite());
        probeSuite.addProbe(probe, user);
        MonitoringFactory.saveProbeSuite(probeSuite, user);
        probeSuite = (ProbeSuite) reload(probeSuite);
        action = new ProbeSuiteProbeEditAction();
    }

    protected void tearDown() throws Exception {
        user = null;
        probe = null;
        action = null;
        probeSuite = null;
        super.tearDown();
    }
    public void testExecute() throws Exception {

        ActionHelper ah = createActionHelper("default");
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("probe"));
        assertNotNull(ah.getRequest().getAttribute("probeSuite"));
        assertNotNull(ah.getRequest().getAttribute("intervals"));
        assertNotNull(ah.getRequest().getAttribute("contactGroups"));
        assertNotNull(ah.getRequest().getAttribute("paramValueList"));
        List pvalues = (List) ah.getRequest().getAttribute("paramValueList");
        assertTrue(pvalues.size() > 0);

    }

    public void testSubmitExecute() throws Exception {

        ActionHelper ah = createActionHelper("success");
        ah.getForm().set(ProbeEditAction.SUBMITTED, new Boolean(true));
        ah.getForm().set("description", probe.getDescription());
        ah.getForm().set("notification", new Boolean(true));
        Long intv = new Long(probe.getCheckIntervalMinutes().longValue());
        ah.getForm().set("check_interval_min", intv);
        ah.getForm().set("notification_interval_min",
                probe.getNotificationIntervalMinutes());

        MonitoringTestUtils.setupParamValues(ah, probe.getCommand(), 3);

        ActionForward af = ah.executeAction();
        assertEquals("success", af.getName());

        Probe edited = (Probe) reload(probe);
        assertTrue(edited.getNotifyCritical().booleanValue());
        MonitoringTestUtils.verifyParameters(edited, probe.getCommand());
        assertEquals(intv, edited.getCheckIntervalMinutes());
    }

    private ActionHelper createActionHelper(String forwardName) throws Exception {
        ActionHelper result = new ActionHelper();
        result.setUpAction(action, forwardName);
        result.getForm().setFormName("probeEditForm");
        result.getRequest().setupAddParameter(ProbeDetailsAction.PROBEID,
                probe.getId().toString());
        String id = probeSuite.getId().toString();
        result.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                id);
        result.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                id);
        return result;
    }


}

