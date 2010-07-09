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

import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringTestUtils;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteProbeCreateAction;
import com.redhat.rhn.frontend.action.systems.monitoring.BaseProbeAction;
import com.redhat.rhn.frontend.action.systems.monitoring.test.ProbeCreateTestCase;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.ForwardWrapper;

/**
 * ProbeCreateActionTest
 * @version $Rev$
 */
public class ProbeSuiteProbeCreateActionTest extends ProbeCreateTestCase {

    private static final String REQ_ATTRS = "probeSuite," + BASE_REQ_ATTRS;

    private ProbeSuite probeSuite;

    protected void setUp() throws Exception {
        super.setUp();
        probeSuite = ProbeSuiteTest.createTestProbeSuite(user);
        assertEquals(0, probeSuite.getProbes().size());
    }

    protected void tearDown() throws Exception {
        probeSuite = null;
        super.tearDown();
    }

    public void testSubmitExecute() throws Exception {

        ServerProbe orig = (ServerProbe) MonitoringFactoryTest.createTestProbe(user);

        modifyActionHelper("success");
        ah.getForm().set(RhnAction.SUBMITTED, Boolean.TRUE);
        setupCommand(ah, orig);
        setupProbeFields(ah, orig);

        MonitoringTestUtils.setupParamValues(ah, orig.getCommand(), 3);

        ForwardWrapper af = ah.executeAction();
        assertEquals("success", af.getName());
        assertEquals(1, probeSuite.getProbes().size());
        assertNoRequestAttributes(ah, REQ_ATTRS);
        Long probeID = firstProbeID(probeSuite);

        probeSuite = (ProbeSuite) reload(probeSuite);
        TemplateProbe created =
            (TemplateProbe) verifyProbe(orig, TemplateProbe.class, probeID);
        assertEquals(1, probeSuite.getProbes().size());
        assertEquals(probeID, firstProbeID(probeSuite));
        MonitoringTestUtils.verifyParameters(created, orig.getCommand());
    }

    private static Long firstProbeID(ProbeSuite ps) {
        return ((Probe) ps.getProbes().iterator().next()).getId();
    }

    protected void modifyActionHelper(String forwardName) throws Exception {
        ah.setExpectedForward(forwardName);
        String id = probeSuite.getId().toString();
        ah.getRequest().setupAddParameter(RequestContext.SUITE_ID, id);
        ah.getRequest().setupAddParameter(RequestContext.SUITE_ID, id);
    }

    protected BaseProbeAction createProbeAction() {
        return new ProbeSuiteProbeCreateAction();
    }

    protected String requestAttributes() {
        return REQ_ATTRS;
    }

}
