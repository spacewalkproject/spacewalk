/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.frontend.servlets.ResourceReloadServlet;

import com.mockobjects.servlet.MockServletOutputStream;

import org.jmock.Expectations;
import org.jmock.integration.junit3.MockObjectTestCase;

import java.io.IOException;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SessionFilterTest
 * @version $Rev: 51260 $
 */
public class ResourceReloadServletTest extends MockObjectTestCase {

    private HttpServletRequest request;
    private HttpServletResponse response;
    private ServletOutputStream output;

    public void setUp() throws IOException {
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        output = new MockServletOutputStream();

        context().checking(new Expectations() { {
            atLeast(1).of(response).setContentLength(31);
            atLeast(1).of(response).getOutputStream();
            will(returnValue(output));
            atLeast(1).of(response).setContentType("text/plain");
        } });
    }

    public void testDoGet() throws Exception {
        ResourceReloadServlet servlet = new ResourceReloadServlet();
        boolean orig = Config.get().getBoolean("java.development_environment");
        Config.get().setBoolean("java.development_environment", "true");
        servlet.doGet(request, response);
        MockServletOutputStream ms = (MockServletOutputStream) output;
        assertEquals("Reloaded resource files: [true]", ms.getContents());
        Config.get().setBoolean("java.development_environment",
                new Boolean(orig).toString());
    }

    public void tearDown() {
        request = null;
        response = null;
    }
}
