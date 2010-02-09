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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteCreateAction;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.Globals;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMessages;

/**
 * ProbeSuiteEditActionTest
 * @version $Rev: 53047 $
 */
public class ProbeSuiteActionTest extends RhnBaseTestCase {
    
    private User user;
    private ProbeSuite suite;
    private Action action;
    private ActionHelper ah;

    // Not used directly by JUnit, instead we just want
    // to re-use ALL this stuff in this class twice for
    // each Action: Create and Edit.
    private void setUpAction(Action actionIn, String forwardName) throws Exception {
        super.setUp();
        user = UserTestUtils.createUserInOrgOne();
        UserTestUtils.addMonitoring(user.getOrg());
        suite = ProbeSuiteTest.createTestProbeSuite(user);
        suite.setDescription("testDesc");
        
        action = actionIn;
        ah = new ActionHelper();
        ah.setUpAction(action, forwardName);
        ah.getForm().setFormName("probeSuiteEditForm");
        ah.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                suite.getId().toString());
    }
    
    protected void tearDown() throws Exception {
        user = null;
        suite = null;
        action = null;
        ah = null;
        super.tearDown();
    }

    public void testCreateExecute() throws Exception {
        executeNonSubmit(new ProbeSuiteCreateAction());
    }
    
    public void testCreateSubmitExecute() throws Exception {
        executeSubmit(new ProbeSuiteCreateAction());
    }
    
    public void testEditExecute() throws Exception {
        executeNonSubmit(new ProbeSuiteEditAction());
    }
    
    public void testEditSubmitExecute() throws Exception {
        executeSubmit(new ProbeSuiteEditAction());
    }
    
    public void testSubmitFailValidation() throws Exception {
        
        setUpAction(new ProbeSuiteCreateAction(), "default");
        ah.getForm().set(RhnAction.SUBMITTED, new Boolean(true));
        ah.getForm().set("suite_name", "");
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        ActionMessages messages = (ActionMessages) 
            ah.getRequest().getSession().getAttribute(Globals.ERROR_KEY);
        assertEquals(1, messages.size());
        
    }
    
    private void executeNonSubmit(Action actionIn) throws Exception {
        setUpAction(actionIn, "default");
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("probeSuite"));
    }
    
    private void executeSubmit(Action actionIn) throws Exception {
        setUpAction(actionIn, "saved");
        ah.getForm().set(RhnAction.SUBMITTED, new Boolean(true));
        String newDesc = "testNewDesc" + TestUtils.randomString();
        String newName = "testNewName" + TestUtils.randomString();
        ah.getForm().set("description", newDesc);
        ah.getForm().set("suite_name", newName);
        
        ActionForward af = ah.executeAction();
        assertEquals("saved", af.getName());
        assertNotNull(ah.getRequest().getAttribute("probeSuite"));
        suite = (ProbeSuite) ah.getRequest().getAttribute("probeSuite");
        assertEquals(newName, suite.getSuiteName());
        assertEquals(newDesc, suite.getDescription());
        assertEquals(newDesc, ah.getForm().get("description"));
        assertEquals(newName, ah.getForm().get("suite_name"));
        
    }

}

