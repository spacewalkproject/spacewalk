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
package com.redhat.rhn.frontend.servlets.test;

import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.servlets.CreateRedirectURI;

import org.apache.commons.lang.StringUtils;
import org.jmock.Mock;
import org.jmock.MockObjectTestCase;

import java.net.URLEncoder;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;

/**
 * CreateRedirectURITest
 * @version $Rev$
 */
public class CreateRedirectURITest extends MockObjectTestCase {
    
    private Mock mockRequest;
    
    /**
     * 
     * @param name TestCase name
     */
    public CreateRedirectURITest(String name) {
        super(name);
    }
    
    protected void setUp() throws Exception {
        super.setUp();
        
        mockRequest = mock(HttpServletRequest.class);
        
        mockRequest.stubs().method("getParameterNames").will(returnValue(
                new Vector().elements()));
        mockRequest.stubs().method("getRequestURI").will(returnValue("/YourRhn.do"));
    }
    
    private HttpServletRequest getMockRequest() {
        return (HttpServletRequest)mockRequest.proxy();
    }

    /**
     * 
     */
    public final void testExecuteWhenRequestHasNoParams() throws Exception {
        mockRequest.stubs().method("getParameterNames").will(
                returnValue(new Vector().elements()));
        
        CreateRedirectURI command = new CreateRedirectURI();
        String redirectUrl = command.execute(getMockRequest());
        
        assertEquals("/YourRhn.do?", redirectUrl);
    }
    
    /**
     * 
     */
    public final void testExecuteWhenRequestHasParams() throws Exception {
        String paramName = "foo";
        String paramValue = "param value = bar#$%!";
        
        String expected = "/YourRhn.do?foo=" + URLEncoder.encode(paramValue, "UTF-8") + "&";
        
        Vector paramNames = new Vector();
        paramNames.add(paramName);
        
        mockRequest.stubs().method("getParameterNames").will(
                returnValue(paramNames.elements()));
        mockRequest.stubs().method("getParameter").with(eq(paramName)).will(
                returnValue(paramValue));
        
        CreateRedirectURI command = new CreateRedirectURI();
        String redirectURI = command.execute(getMockRequest());
        
        assertEquals(expected, redirectURI);
    }
    
    public final void testExecuteWhenRedirectURIExceedsMaxLength() throws Exception {
        String url = StringUtils.rightPad("/YourRhn.do", 
                (int)CreateRedirectURI.MAX_URL_LENGTH + 1, "x");
        
        mockRequest.stubs().method("getRequestURI").will(returnValue(url));
        
        CreateRedirectURI command = new CreateRedirectURI();
        String redirectUrl = command.execute(getMockRequest());
        
        assertEquals(LoginAction.DEFAULT_URL_BOUNCE, redirectUrl);
    }
    
}
