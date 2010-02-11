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
package com.redhat.rhn.frontend.action.test;

import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.integration.IntegrationService;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.UserTestUtils;

import com.mockobjects.servlet.MockHttpSession;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;

/**
 * LoginActionTest
 * @version $Rev$
 */
public class LoginActionTest extends RhnBaseTestCase {
    

    public void testPerformNoUserName() {

        LoginAction action = new LoginAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward failure = new ActionForward("failure", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("loginForm");
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        
        request.setSession(new MockHttpSession());
        request.setupServerName("mymachine.rhndev.redhat.com");
        WebSession s = requestContext.getWebSession();
        request.addCookie(requestContext.createWebSessionCookie(s.getId(), 10));
        
        mapping.addForwardConfig(failure);
        form.set("username", "");
        form.set("password", "somepassword");

        ActionForward rc = action.execute(mapping, form, request, response);

        assertEquals(rc, failure);
    }

    public void testPerformNoPasswordName() {

        LoginAction action = new LoginAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward failure = new ActionForward("failure", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("loginForm");
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        
        request.setSession(new MockHttpSession());
        request.setupServerName("mymachine.rhndev.redhat.com");
        WebSession s = requestContext.getWebSession();
        request.addCookie(requestContext.createWebSessionCookie(s.getId(), 10));
        
        mapping.addForwardConfig(failure);
        form.set("username", "someusername");
        form.set("password", "");

        ActionForward rc = action.execute(mapping, form, request, response);

        assertEquals(rc, failure);
    }
    
    /** 
    * Wrap a call to loginUserIntoSessionTest
    * since we want that method to return a value and
    * JUnit only calls methods with void return types
     * @throws Exception 
    */
    public void testPerformValidUsername() throws Exception {
        HttpServletRequest request = loginUserIntoSessionTest();
        RequestContext requestContext = new RequestContext(request);
        
        assertNotNull(IntegrationService.get().getAuthToken(
                requestContext.getCurrentUser().getLogin()));
    }

    /**
    * In this test we actually return an HttpServletRequest so
    * this code can be reused by other tests to Login a user
    * and get the Request (with session) that appears logged
    * in.
    * In order for this test to be executed by JUnit we have to 
    * wrap its call in the above method with a void return type.
     * @throws Exception 
    */
    public HttpServletRequest loginUserIntoSessionTest() throws Exception {
        LoginAction action = new LoginAction();
        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        ActionMapping mapping = new ActionMapping();
        mapping.addForwardConfig(new ActionForward("loggedin", "path", false));
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("loginForm");
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        
        request.setSession(new MockHttpSession());
        request.setupServerName("mymachine.rhndev.redhat.com");
        WebSession s = requestContext.getWebSession();
        request.addCookie(requestContext.createWebSessionCookie(s.getId(), 10));
        
        form.set("username", u.getLogin());
        /**
         * Since we know testUser's password is "password", just set that here.
         * using u.getPassword() will fail when we're using encrypted passwords.
         */
        form.set("password", "password");
        
        ActionForward rc = action.execute(mapping, form, request, response);

        assertNull(rc);
        return request;
    }

    public void testPerformInvalidUsername() {
        LoginAction action = new LoginAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward success = new ActionForward(null, "login_failed", false);
        ActionForward failure = new ActionForward("failure", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("loginForm");
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        request.setSession(new MockHttpSession());
        request.setupServerName("mymachine.rhndev.redhat.com");
        
        WebSession s = requestContext.getWebSession();
        request.addCookie(requestContext.createWebSessionCookie(s.getId(), 10));
        
        mapping.setInput("login_failed");
        mapping.addForwardConfig(success);
        mapping.addForwardConfig(failure);
        form.set("username", "017324193274913741974");
        form.set("password", "017324193274913741974");

        ActionForward rc = action.execute(mapping, form, request, response);

        assertEquals(rc, failure);
    }
    
    public void testDisabledUser() {
        LoginAction action = new LoginAction();
        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        UserManager.disableUser(u, u);

        ActionMapping mapping = new ActionMapping();
        mapping.addForwardConfig(new ActionForward("failure", "path", false));
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("loginForm");
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        
        request.setSession(new MockHttpSession());
        request.setupServerName("mymachine.rhndev.redhat.com");
        WebSession s = requestContext.getWebSession();
        request.addCookie(requestContext.createWebSessionCookie(s.getId(), 10));
        
        form.set("username", u.getLogin());
        /**
         * Since we know testUser's password is "password", just set that here.
         * using u.getPassword() will fail when we're using encrypted passwords.
         */
        form.set("password", "password");
        
        ActionForward rc = action.execute(mapping, form, request, response);

        assertEquals("failure", rc.getName());
    }
    
}
