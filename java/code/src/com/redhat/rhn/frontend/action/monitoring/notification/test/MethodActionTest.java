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
package com.redhat.rhn.frontend.action.monitoring.notification.test;

import com.redhat.rhn.domain.monitoring.notification.Method;
import com.redhat.rhn.domain.monitoring.notification.MethodType;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.monitoring.notification.test.MethodTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.notification.BaseMethodEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.monitoring.ModifyMethodCommand;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

public class MethodActionTest extends RhnMockStrutsTestCase {
    
    private String expectedName = "Expected Method Name";
    
    public void testEditNonSubmit() throws Exception {
        setRequestPathInfo("/monitoring/config/notification/MethodEdit");
        ModifyMethodCommand mc = MethodTest.createTestMethodCommand(user);
        addRequestParameter(RequestContext.METHOD_ID, mc.getMethod().getId().toString());
        executeNonSubmit("/WEB-INF/pages/admin/monitoring" +
                "/config/notification/method-edit.jsp");
    }
    
    public void testExecuteEditSubmit() throws Exception {
 
        setRequestPathInfo("/monitoring/config/notification/MethodEdit");
        // Create a different user to use as the owner of the Method (not same
        // as person creating the Method).
        User differentUser = UserTestUtils.createUser("adifferentUser", 
                user.getOrg().getId());
        ModifyMethodCommand mc = MethodTest.createTestMethodCommand(differentUser);
        addRequestParameter(RequestContext.USER_ID, differentUser.getId().toString());
        addRequestParameter(RequestContext.METHOD_ID, mc.getMethod().getId().toString());
        executeSubmit("/monitoring/config/notification/Methods.do");
        assertTrue(mc.getMethod().getUser().getLogin().startsWith("adifferentUser"));
    }
    
    public void testCreateSubmit() throws Exception {
        setRequestPathInfo("/monitoring/config/notification/MethodCreate");
        Method m = executeSubmit("/monitoring/config/notification/Methods.do");
        assertNotNull(m.getId());
    }
    
    public void testCreateNonSubmit() throws Exception {
        setRequestPathInfo("/monitoring/config/notification/MethodCreate");
        executeNonSubmit("/WEB-INF/pages/admin/monitoring" +
                "/config/notification/method-create.jsp");
    }

    public void testCreateDuplicate() throws Exception {
        // Create a Method with the expected name already
        // and verify that the Action fails with the proper
        // error message.
        ModifyMethodCommand mmc = MethodTest.createTestMethodCommand(user);
        mmc.setMethodName(expectedName);
        mmc.storeMethod(user);
        setRequestPathInfo("/monitoring/config/notification/MethodCreate");
        addRequestParameter(RhnAction.SUBMITTED, "true");
        executeSubmit("/WEB-INF/pages/admin/" +
                "monitoring/config/notification/method-create.jsp");
        verifyActionErrors(new String[] {"method.nametaken"});
    }    
    
    public Method executeSubmit(String expectedFwd) throws Exception {
        String expectedEmail = "MethodActionTest@redhat.com";
        MethodType expectedType = NotificationFactory.TYPE_PAGER;
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(BaseMethodEditAction.EMAIL, expectedEmail);
        addRequestParameter(BaseMethodEditAction.NAME, expectedName);
        addRequestParameter(BaseMethodEditAction.TYPE, 
                expectedType.getMethodTypeName());
        actionPerform();
        assertTrue(getActualForward().startsWith(expectedFwd));
        assertNotNull(request.getAttribute(BaseMethodEditAction.METHOD));
        assertNotNull(request.getAttribute(RhnHelper.TARGET_USER));

        Method m = (Method) request.getAttribute(BaseMethodEditAction.METHOD);
        
        assertEquals(expectedEmail, m.getPagerEmail());
        assertEquals(expectedName, m.getMethodName());
        assertEquals(expectedType, m.getType());
        assertEquals("0", m.getPagerSplitLongMessages());
        TestUtils.flushAndEvict(m);
        return m;
    }
    
    public void executeNonSubmit(String expectedForward) throws Exception {
        actionPerform();
        Method m = (Method) request.getAttribute(BaseMethodEditAction.METHOD);
        assertNotNull(m);
        assertNotNull(request.getAttribute(BaseMethodEditAction.METHOD_TYPES));
        assertNotNull(request.getAttribute(RhnHelper.TARGET_USER));
        assertTrue(getActualForward().startsWith(expectedForward));
    }
    
}
