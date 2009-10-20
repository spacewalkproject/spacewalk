/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteHelper;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteListProbesAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.Globals;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;

/**
 * ProbeSuiteListActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuiteListProbesActionTest extends RhnBaseTestCase {
    private Action action = null;
    private ActionHelper sah;
    private Long probeId;
    private ProbeSuite ps;

    public void setUp() throws Exception {
        super.setUp();
        action = new ProbeSuiteListProbesAction();
        sah = new ActionHelper();
        sah.setUpAction(action, "default");
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        ps = ProbeSuiteTest.createTestProbeSuite(sah.getUser());
        sah.getRequest().
            setupAddParameter(RequestContext.SUITE_ID, ps.getId().toString());
        sah.getRequest().
            setupAddParameter(RequestContext.SUITE_ID, ps.getId().toString());
        TemplateProbe probe = (TemplateProbe)
            MonitoringFactoryTest.createTestProbe(sah.getUser(),
                MonitoringConstants.getProbeTypeSuite());
        ps.addProbe(probe, sah.getUser());
        probeId = probe.getId();
        sah.getRequest().setupAddParameter("items_selected",
                new String[] {probeId.toString()});

    }

    /**
     * Make sure when the delete button is hit we go to the proper
     * place.  No DB action occurs.
     * @throws Exception if test fails
     */
    public void testDelete() throws Exception {
        //Execute it!
        ActionForward testforward = sah.executeAction("deleteProbes");
        assertEquals("path?lower=10&" + RequestContext.SUITE_ID + "=" + ps.getId(),
                testforward.getPath());
        assertNotNull(sah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
        assertNull(MonitoringManager.getInstance().
                lookupProbe(sah.getUser(), probeId));
    }

    public void testSelectAll() throws Exception {
        //Execute it!
        sah.executeAction("selectall");
        RhnSetActionTest.verifyRhnSetData(sah.getUser().getId(),
                ProbeSuiteHelper.DELETE_PROBES_LIST_NAME, 1);
    }
}
