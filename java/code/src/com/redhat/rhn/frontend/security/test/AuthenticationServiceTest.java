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
package com.redhat.rhn.frontend.security.test;

import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;

import org.jmock.Mock;
import org.jmock.MockObjectTestCase;
import org.jmock.core.Constraint;
import org.jmock.core.Invocation;
import org.jmock.core.stub.CustomStub;

import java.util.Enumeration;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AuthenticationServiceTest is a base test class for testing AuthenticationService
 * implementations.
 * 
 * @version $Rev$
 */
public abstract class AuthenticationServiceTest extends MockObjectTestCase {

    protected Mock mockRequest;
    protected Mock mockResponse;
    protected Constraint[] requestResponseArgs;
    protected Mock mockPxtDelegate;
    protected String[] requestParamNames;
    protected String[] requestParamValues;
    private String requestUrl;

    /**
     * @param name The test case name
     */
    public AuthenticationServiceTest(String name) {
        super(name);
    }
    
    
    public AuthenticationServiceTest() {
    }

    /**
     * {@inheritDoc}
     */
    protected void setUp() throws Exception {
        super.setUp();
        
        mockRequest = mock(HttpServletRequest.class);
        mockResponse = mock(HttpServletResponse.class);
        mockPxtDelegate = mock(PxtSessionDelegate.class);
        
        requestResponseArgs = new Constraint[] {
                isA(HttpServletRequest.class),
                isA(HttpServletResponse.class)
        };
        
        requestParamNames = new String[] {"question", "answer"};
        requestParamValues = new String[] {
                "param 1 = 'Who is the one?'",
                "param 2 = 'Neo is the one!'"
        };
        
        requestUrl = "https://rhn.redhat.com/rhn/YourRhn.do";
    }


    protected HttpServletRequest getRequest() {
        return (HttpServletRequest)mockRequest.proxy();
    }


    protected HttpServletResponse getResponse() {
        return (HttpServletResponse)mockResponse.proxy();
    }

    protected PxtSessionDelegate getPxtDelegate() {
        return (PxtSessionDelegate)mockPxtDelegate.proxy();
    }


    protected Enumeration getParameterNames() {
        Vector vector = new Vector();
        vector.add(requestParamNames[0]);
        vector.add(requestParamNames[1]);
        
        return vector.elements();
    }
    
    protected String getRequestURL() {
        return requestUrl;
    }


    protected void setUpRedirectToLogin() {
        mockRequest.stubs().method("getParameterNames").will(
                new CustomStub("Returns parameter names enumeration.") {
                    public Object invoke(Invocation arg0) throws Throwable {
                        return getParameterNames();
                    }
                });
        
        mockRequest.stubs().method("getParameter").with(eq(requestParamNames[0])).will(
                returnValue(requestParamValues[0]));
        
        mockRequest.stubs().method("getParameter").with(eq(requestParamNames[1])).will(
                returnValue(requestParamValues[1]));
        
        mockRequest.stubs().method("getRequestURL").will(returnValue(
                new StringBuffer(getRequestURL())));
        
        mockRequest.stubs().method("getQueryString").will(returnValue(null));
    }

}
