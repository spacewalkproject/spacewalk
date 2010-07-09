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

import com.redhat.rhn.frontend.servlets.RhnHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import com.mockobjects.servlet.MockHttpSession;

import org.jmock.MockObjectTestCase;

/**
 * RhnHttpServletRequestTest
 * @version $Rev$
 */
public class RhnHttpServletRequestTest extends MockObjectTestCase {
    private RhnMockHttpServletRequest mockRequest;
    private RhnHttpServletRequest request;

    protected void setUp() throws Exception {
        super.setUp();
        mockRequest = new RhnMockHttpServletRequest();
        mockRequest.setSession(new MockHttpSession());
        request = new RhnHttpServletRequest(mockRequest);
    }

    /**
     *
     * @throws Exception
     */
    public void testNoHeaders() throws Exception {
        mockRequest.setupServerName("localhost");
        mockRequest.setupGetServerPort(8080);
        assertEquals("localhost", request.getServerName());
        assertEquals(8080, request.getServerPort());
    }

    /**
     *
     * @throws Exception
     */
    public void testOverrideServerName() throws Exception {
        mockRequest.setupServerName("localhost");
        mockRequest.setupGetServerPort(8080);
        mockRequest.setupGetHeader("X-Server-Hostname", "testServer.redhat.com");
        assertEquals("testServer.redhat.com", request.getServerName());
        assertEquals(8080, request.getServerPort());
    }

    /**
     *
     * @throws Exception
     */
    public void testNoOverrideSecure() throws Exception {
        mockRequest.setupIsSecure(false);
        assertFalse(request.isSecure());
    }

    /**
     *
     * @throws Exception
     */
    public void testOverrideSecureHosted() throws Exception {

        mockRequest.setupIsSecure(false);
        mockRequest.setupGetHeader("X-ENV-HTTPS", "on");

        // We expect this to be false, because this isn't a satellite.
        assertFalse(request.isSecure());
    }

    /**
     *
     * @throws Exception
     */
    public void testOverrideSecureSat() throws Exception {
        return;
    }
}
