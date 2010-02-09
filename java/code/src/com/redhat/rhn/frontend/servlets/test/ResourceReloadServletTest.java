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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.frontend.servlets.ResourceReloadServlet;

import com.mockobjects.servlet.MockServletOutputStream;

import org.jmock.Mock;
import org.jmock.MockObjectTestCase;

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
    private Mock mreq;
    private Mock mresp;
    
    public void setUp() {
        mreq = mock(HttpServletRequest.class);
        mresp = mock(HttpServletResponse.class);
        
        request = (HttpServletRequest) mreq.proxy();
        response = (HttpServletResponse) mresp.proxy();
        output = new MockServletOutputStream();

        mresp.expects(atLeastOnce())
        .method("setContentLength").with(eq(31));
        
        mresp.expects(atLeastOnce())
        .method("getOutputStream").will(returnValue(output));

        mresp.expects(atLeastOnce())
        .method("setContentType")
        .with(eq("text/plain"));

    }
    
    public void testDoGet() throws Exception {
        ResourceReloadServlet servlet = new ResourceReloadServlet();
        boolean orig = Config.get().getBoolean("web.development_environment");
        Config.get().setBoolean("web.development_environment", "true");
        servlet.doGet(request, response);
        MockServletOutputStream ms = (MockServletOutputStream) output;
        assertEquals("Reloaded resource files: [true]", ms.getContents());
        Config.get().setBoolean("web.development_environment", 
                new Boolean(orig).toString());
    }
    
    public void tearDown() {
        request = null;
        response = null;
    }
}
