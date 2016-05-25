/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import org.jmock.integration.junit3.MockObjectTestCase;

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
public abstract class AuthenticationServiceAbstractTestCase extends MockObjectTestCase {

    protected HttpServletRequest mockRequest;
    protected HttpServletResponse mockResponse;
    protected PxtSessionDelegate mockPxtDelegate;
    protected String[] requestParamNames;
    protected String[] requestParamValues;
    private String requestUrl;

    /**
     * @param name The test case name
     */
    public AuthenticationServiceAbstractTestCase(String name) {
        super(name);
    }


    public AuthenticationServiceAbstractTestCase() {
    }

    /**
     * {@inheritDoc}
     */
    protected void setUp() throws Exception {
        super.setUp();

        mockRequest = mock(HttpServletRequest.class);
        mockResponse = mock(HttpServletResponse.class);
        mockPxtDelegate = mock(PxtSessionDelegate.class);

        requestParamNames = new String[] {"question", "answer"};
        requestParamValues = new String[] {
                "param 1 = 'Who is the one?'",
                "param 2 = 'Neo is the one!'"
        };

        requestUrl = "https://rhn.redhat.com/rhn/YourRhn.do";
    }


    protected HttpServletRequest getRequest() {
        return mockRequest;
    }


    protected HttpServletResponse getResponse() {
        return mockResponse;
    }

    protected PxtSessionDelegate getPxtDelegate() {
        return mockPxtDelegate;
    }

    protected Enumeration<String> getParameterNames() {
        Vector<String> vector = new Vector<String>();
        vector.add(requestParamNames[0]);
        vector.add(requestParamNames[1]);

        return vector.elements();
    }

    protected String getRequestURL() {
        return requestUrl;
    }

}
