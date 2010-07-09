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

import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteSystemsSetupAction;
import com.redhat.rhn.frontend.dto.monitoring.MonitoredServerDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import org.apache.struts.action.Action;

import java.util.List;

/**
 * ProbeSuiteSystemsSetupActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuiteSystemsSetupActionTest extends RhnBaseTestCase {
    private Action action;

    protected void setUp() throws Exception {
        super.setUp();
        action = new ProbeSuiteSystemsSetupAction();
    }

    protected void tearDown() throws Exception {
        action = null;
        super.tearDown();
    }

    public void testExecute() throws Exception {

        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        // Use the User created by the Helper
        User user = sah.getUser();
        ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(user);
        ProbeSuiteTest.addTestServersToSuite(suite, user);
        String suiteId = suite.getId().toString();
        sah.getRequest().setupAddParameter(RequestContext.SUITE_ID, suiteId);
        sah.getRequest().setupAddParameter(RequestContext.SUITE_ID, suiteId);
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.getRequest().setupAddParameter("submitted", "false");
        sah.executeAction();

        RhnMockHttpServletRequest request = sah.getRequest();

        RequestContext requestContext = new RequestContext(request);

        assertNotNull(request.getAttribute("probeSuite"));
        user = requestContext.getLoggedInUser();
        RhnSet set = (RhnSet) request.getAttribute("set");

        List dr = (List) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertTrue(dr.get(0) instanceof MonitoredServerDto);
        MonitoredServerDto msd = (MonitoredServerDto) dr.get(0);
        assertNotNull(msd.getId());
        assertNotNull(msd.getName());
        assertNotNull(msd.getStatus());
        assertNotNull(set);
        assertEquals("probe_suite_systems_list", set.getLabel());
    }
}
