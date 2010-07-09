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
package com.redhat.rhn.frontend.action.systems.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.systems.SystemSearchSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.apache.struts.action.DynaActionForm;

/**
 * SystemSearchActionTest
 * @version $Rev: 1 $
 */
public class SystemSearchSetupActionTest extends RhnMockStrutsTestCase {

    private Server s;

    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/Search");
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementEnterprise());
        s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());

    }

    /**
     * This test tests multiple search results. The system search page, if
     * only one result is found, will forward you directly to that
     * system's SDC page instead of showing a list with one member
     * on the system search page. This test is expecting multiple systems to be found
     * and the user to be forwarded to the system search page with a list of systems
     * shown.
     * @throws Exception
     */
    public void skipTestQueryWithResults() throws Exception {
       /**
        * SystemSearch now talks to a Lucene search server.  This creates issues
        * for testing...you can't use a test util to create a system put it in the
        * DB and expect the search server to have the data indexed and ready to go.
        *
        * Will be marking this test to be skipped till a suitable test is implemented
        */
        s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(SystemSearchSetupAction.SEARCH_STRING, "redhat");
        addRequestParameter(SystemSearchSetupAction.WHERE_TO_SEARCH, "all");
        addRequestParameter(SystemSearchSetupAction.VIEW_MODE,
        "systemsearch_name_and_description");
        actionPerform();
        verifyForward("default");
        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);
        assertNotNull(dr);
        assertFalse(dr.isEmpty());
        assertNotNull(request.getAttribute(SystemSearchSetupAction.VIEW_MODE));
        assertNotNull(request.getAttribute(SystemSearchSetupAction.WHERE_TO_SEARCH));
        assertNotNull(request.getAttribute(SystemSearchSetupAction.SEARCH_STRING));
    }

    /**
     * This test is the case where only one system is found. It verfies
     * that the user is redirected to that system's SDC page.
     * @throws Exception
     */
    public void skipTestQueryWithOneResult() throws Exception {
        /**
         * SystemSearch now talks to a Lucene search server.  This creates issues
         * for testing...you can't use a test util to create a system put it in the
         * DB and expect the search server to have the data indexed and ready to go.
         *
         * Will be marking this test to be skipped till a suitable test is implemented
         */
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(SystemSearchSetupAction.SEARCH_STRING, s.getName());
        addRequestParameter(SystemSearchSetupAction.WHERE_TO_SEARCH, "all");
        addRequestParameter(SystemSearchSetupAction.VIEW_MODE,
        "systemsearch_name_and_description");
        actionPerform();
        System.err.println("getMockResponse() = " + getMockResponse());
        System.err.println("getMockResponse().getStatusCode() = " +
                getMockResponse().getStatusCode());
        assertTrue(getMockResponse().getStatusCode() == 302);
    }

    public void testQueryWithoutResults() throws Exception {
        return;
    }

    /**
     * This test verfies that if a bad view mode is passed in by the user,
     * the system search handles and catches any underlying exceptions
     * that might be caused by this, instead of allowing the exception to escalate
     * beyond the SystemSearchAction.
     * @throws Exception
     */
    public void testQueryWithBadParameter() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(SystemSearchSetupAction.SEARCH_STRING, s.getName());
        addRequestParameter(SystemSearchSetupAction.WHERE_TO_SEARCH, "all");
        addRequestParameter(SystemSearchSetupAction.VIEW_MODE,
        "all_your_systems_are_belong_to_us");
        actionPerform();
    }

    public void testNoSubmit() throws Exception {
        actionPerform();
        DynaActionForm formIn = (DynaActionForm) getActionForm();
        assertNotNull(formIn.get(SystemSearchSetupAction.WHERE_TO_SEARCH));
        assertNotNull(request.getAttribute(SystemSearchSetupAction.VIEW_MODE));
    }

    public void testAlphaSubmitForNumericField() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(SystemSearchSetupAction.SEARCH_STRING, "abc");
        addRequestParameter(SystemSearchSetupAction.WHERE_TO_SEARCH, "all");
        addRequestParameter(SystemSearchSetupAction.VIEW_MODE,
                            "systemsearch_cpu_mhz_lt");
        actionPerform();
        verifyActionErrors(new String[] { "systemsearch.errors.numeric" });
    }

    public void testSmallAlphaSubmitForNumericField() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(SystemSearchSetupAction.SEARCH_STRING, "a");
        addRequestParameter(SystemSearchSetupAction.WHERE_TO_SEARCH, "all");
        addRequestParameter(SystemSearchSetupAction.VIEW_MODE,
                            "systemsearch_cpu_mhz_lt");
        actionPerform();
        verifyActionErrors(new String[] {"systemsearch.errors.numeric"});
    }
}

