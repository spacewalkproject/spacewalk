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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteListSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import org.apache.struts.action.Action;

/**
 * ProbeSuiteListSetupActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuiteListSetupActionTest extends RhnBaseTestCase {
    private Action action = null;
    
    public void setUp() {
        action = new ProbeSuiteListSetupAction();
    }
    
    public void testExecute() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        // Use the User created by the Helper
        User user = sah.getUser();
        // Add some ProbeSuites so the list will do something
        for (int i = 0; i < 5; i++) {
            ProbeSuiteTest.createTestProbeSuite(user);
        }
        sah.getRequest().setupAddParameter("submitted", "false");
        sah.setupClampListBounds();
        sah.executeAction();
        RhnMockHttpServletRequest request = sah.getRequest();
        
        RequestContext requestContext = new RequestContext(request);
        
        user = requestContext.getLoggedInUser();
        RhnSet set = (RhnSet) request.getAttribute("set");
        
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertNotNull(set);
        assertEquals("probe_suite_delete_list", set.getLabel());
    }
}
