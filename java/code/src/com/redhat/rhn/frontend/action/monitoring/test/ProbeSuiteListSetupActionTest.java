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

import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.apache.struts.action.Action;

/**
 * ProbeSuiteListSetupActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuiteListSetupActionTest extends RhnMockStrutsTestCase {
    private Action action = null;
    
    
    public void testExecute() throws Exception {
        ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(user);
        String[] suites = new String[1];
        suites[0] = suite.getId().toString();
        addRequestParameter(RequestContext.SUITE_ID, suites);
        setRequestPathInfo("/monitoring/config/ProbeSuiteListProbes.do");
        actionPerform();
        verifyNoActionErrors();
    }
}
