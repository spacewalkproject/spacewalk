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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteHelper;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuitesRemoveSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import org.apache.struts.action.Action;

/**
 * ProbeSuiteListSetupActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuitesRemoveSetupActionTest extends RhnBaseTestCase {
    private Action action = null;

    public void setUp() {
        action = new ProbeSuitesRemoveSetupAction();
    }

    public void testExecute() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        // Use the User created by the Helper
        User user = sah.getUser();
        RhnSet set = RhnSetDecl.PROBE_SUITES_TO_DELETE.get(user);
        // Add some ProbeSuites so the list will do something
        for (int i = 0; i < 5; i++) {
            ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(user);
            set.addElement(suite.getId());
        }
        RhnSetManager.store(set);
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.getRequest().setupAddParameter("submitted", "false");
        sah.executeAction();

        RhnMockHttpServletRequest request = sah.getRequest();

        RequestContext requestContext = new RequestContext(request);

        user = requestContext.getLoggedInUser();
        set = (RhnSet) request.getAttribute("set");

        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertNotNull(set);
        assertEquals(ProbeSuiteHelper.DELETE_SUITES_LIST_NAME, set.getLabel());
    }
}
