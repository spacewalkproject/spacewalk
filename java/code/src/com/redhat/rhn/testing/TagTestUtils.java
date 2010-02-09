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

package com.redhat.rhn.testing;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockPageContext;
import com.mockobjects.servlet.MockServletContext;

import java.net.URL;

import javax.servlet.jsp.tagext.Tag;

/**
 * A class that allows us to easily test jsp tags. 
 *
 * @version $Rev$
 */
public class TagTestUtils {
    // static class
    private TagTestUtils() { }

    /**
     * Setup the TagTestHelper class with the
     * appropriate infrastructure.
     * @param tag The Tag lib to test.
     * @param url URL to be passed into the Mock Servlet Context.
     * @param request The request that was created by the test to be used
     *        by this helper
     * @return TagTestHelper
     * @see com.mockobjects.helpers.TagTestHelper
     */
    public static TagTestHelper setupTagTest(Tag tag, URL url, 
                                             RhnMockHttpServletRequest request) {
    
        TagTestHelper tth = new TagTestHelper(tag);
        MockPageContext mpc = tth.getPageContext();
        MockServletContext ctx = (MockServletContext) mpc.getServletContext();
        if (request == null) {
            request = TestUtils.getRequestWithSessionAndUser();
        }
        request.setRequestURL("http://localhost:8080/rhnjava/index.jsp");
        request.addAttribute("requestedUri", "http://localhost:8080/rhnjava/index.jsp");
        request.setSession(new RhnMockHttpSession());
        mpc.setRequest(request);
        mpc.setJspWriter(new RhnMockJspWriter());
                
        if (url != null) {
            ctx.setupGetResource(url);
        }
        return tth;
    }

    /**
     * Setup the TagTestHelper class with the
     * appropriate infrastructure.
     * @param tag The Tag lib to test.
     * @param url URL to be passed into the Mock Servlet Context.
     * @return TagTestHelper
     * @see com.mockobjects.helpers.TagTestHelper
     */
    public static TagTestHelper setupTagTest(Tag tag, URL url) {
        return setupTagTest(tag, url, null);
    }
    
}

