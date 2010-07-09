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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteSystemsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.Globals;
import org.apache.struts.action.ActionForward;

/**
 * ProbeSuiteSystemsActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuiteSystemsActionTest extends RhnBaseTestCase {
    private ProbeSuiteSystemsAction action = null;
    private ActionHelper sah;
    private ProbeSuite suite;

    public void setUp() throws Exception {
        super.setUp();
        action = new ProbeSuiteSystemsAction();
    }

    /**
     * Make sure when the delete button is hit we go to the proper
     * place.  No DB action occurs.
     * @throws Exception if test fails
     */
    public void testRemoveFromSuite() throws Exception {
        ActionForward testForward = testExecute("deleteFromSuite");
        assertEquals("path?lower=10&" + RequestContext.SUITE_ID + "=" + suite.getId()
                , testForward.getPath());
        assertNotNull(sah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
        assertTrue(suite.getServersInSuite().size() == 4);
        RhnSetActionTest.verifyRhnSetData(sah.getUser().getId(),
                RhnSetDecl.PROBE_SUITE_SYSTEMS.getLabel(), 0);

    }

    /**
     * Make sure when the delete button is hit we go to the proper
     * place.  No DB action occurs.
     * @throws Exception if test fails
     */
    public void testDetachFromSuite() throws Exception {
        ActionForward testForward = testExecute("detachFromSuite");
        assertEquals("path?lower=10&" + RequestContext.SUITE_ID + "=" + suite.getId()
                , testForward.getPath());
        assertNotNull(sah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
        RhnSetActionTest.verifyRhnSetData(sah.getUser().getId(),
                RhnSetDecl.PROBE_SUITE_SYSTEMS.getLabel(), 0);

    }

    public void testSelectAll() throws Exception {
        testExecute("selectall");
        RhnSetActionTest.verifyRhnSetData(sah.getUser().getId(),
                RhnSetDecl.PROBE_SUITE_SYSTEMS.getLabel(), 5);
    }


    private ActionForward testExecute(String methodName) throws Exception {
        sah = new ActionHelper();
        sah.setUpAction(action);
        User user = sah.getUser();
        suite = ProbeSuiteTest.createTestProbeSuite(user);
        ProbeSuiteTest.addTestServersToSuite(suite, user);
        assertTrue(suite.getServersInSuite().size() == 5);
        Server removeMe = (Server) suite.getServersInSuite().iterator().next();
        // Gotta do this twice
        sah.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                suite.getId().toString());
        sah.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                suite.getId().toString());
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("items_selected",
            new String[] {removeMe.getId().toString()});
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);

        ActionForward testforward = sah.executeAction(methodName);
        return testforward;
    }


}
