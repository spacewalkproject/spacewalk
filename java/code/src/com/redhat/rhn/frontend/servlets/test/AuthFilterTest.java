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

import com.redhat.rhn.frontend.security.AuthenticationService;
import com.redhat.rhn.frontend.servlets.AuthFilter;

import org.jmock.Mock;
import org.jmock.MockObjectTestCase;
import org.jmock.core.Constraint;

import java.util.Vector;

import javax.servlet.FilterChain;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AuthFilterTest
 * @version $Rev$
 */
public class AuthFilterTest extends MockObjectTestCase {

    private class AuthFilterStub extends AuthFilter {
        public void setAuthenticationService(AuthenticationService service) {
            super.setAuthenticationService(service);
        }
    }

    private AuthFilterStub filter;

    private Mock mockRequest;
    private Mock mockResponse;
    private Mock mockFilterChain;
    private Mock mockDispatcher;

    private Constraint[] requestResponseArgs;

    private Mock mockAuthService;

    protected void setUp() throws Exception {
        super.setUp();

        filter = new AuthFilterStub();

        mockRequest = mock(HttpServletRequest.class);
        mockResponse = mock(HttpServletResponse.class);
        mockFilterChain = mock(FilterChain.class);

        requestResponseArgs = new Constraint[] {
                isA(HttpServletRequest.class),
                isA(HttpServletResponse.class)
        };

        mockAuthService = mock(AuthenticationService.class);

        mockDispatcher = mock(RequestDispatcher.class);

        filter.setAuthenticationService((AuthenticationService)mockAuthService.proxy());

        setDefaultStubs();
    }

    private void setDefaultStubs() {
        mockRequest.stubs().method("getRequestURI").will(returnValue("/rhn/YourRhn.do"));

        mockRequest.stubs().method("getRequestDispatcher").withAnyArguments().will(
                returnValue((RequestDispatcher)mockDispatcher.proxy()));
        mockRequest.stubs().method("getHeaders").will(returnValue(new Vector().elements()));

        filter.setAuthenticationService((AuthenticationService)mockAuthService.proxy());
    }

    private HttpServletRequest getRequest() {
        return (HttpServletRequest)mockRequest.proxy();
    }

    private HttpServletResponse getResponse() {
        return (HttpServletResponse)mockResponse.proxy();
    }

    private FilterChain getFilterChain() {
        return (FilterChain)mockFilterChain.proxy();
    }

    public final void testDoFilterWhenAuthenticationSucceeds() throws Exception {
        mockAuthService.expects(atLeastOnce()).method("validate").with(requestResponseArgs)
            .will(returnValue(true));

        mockFilterChain.expects(once()).method("doFilter").with(requestResponseArgs);

        filter.doFilter(getRequest(), getResponse(), getFilterChain());
    }

    public final void testDoFilterWhenAuthenticationFails() throws Exception {
        mockAuthService.expects(atLeastOnce()).method("validate").with(requestResponseArgs)
            .will(returnValue(false));

        mockAuthService.expects(once()).method("redirectToLogin").with(requestResponseArgs);

        filter.doFilter(getRequest(), getResponse(), getFilterChain());
    }

    public final void testDoFilterWhenAuthServiceThrowsException() throws Exception {
        mockAuthService.expects(atLeastOnce()).method("validate").with(requestResponseArgs)
            .will(throwException(new ServletException()));

        try {
            filter.doFilter(getRequest(), getResponse(), getFilterChain());
            fail();
        }
        catch (ServletException e) {
            //should throw same exception.
            //AuthFilter should not be eating the exception
        }
    }
}
