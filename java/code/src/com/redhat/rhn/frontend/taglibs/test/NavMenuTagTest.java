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
package com.redhat.rhn.frontend.taglibs.test;

import com.redhat.rhn.frontend.taglibs.NavMenuTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockExceptionJspWriter;
import com.redhat.rhn.testing.TagTestUtils;
import com.redhat.rhn.testing.TestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockJspWriter;

import java.net.URL;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * NavMenuTagTest
 * @version $Rev$
 */
public class NavMenuTagTest extends RhnBaseTestCase {
    
    private final String NAV_XML = "sitenav-test.xml";
    private URL url;
    private final String TOP_NAV = "com.redhat.rhn.frontend.nav.TopnavRenderer";

    public void setUp() throws Exception {
        try {
            url = TestUtils.findTestData(NAV_XML);
            if (url == null) {
                fail("could not find sitenav-test.xml");
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            fail(e.toString());
        }
    }

    public void testExceptionHandling() {
        NavMenuTag nmt = new NavMenuTag();
        TagTestHelper tth = TagTestUtils.setupTagTest(nmt, url);

        boolean exceptionNotThrown = false;

        try {
            // ok let's test the tag
            setupTag(nmt, 10, 4, NAV_XML, "throw.class.not.found.exception");
            tth.assertDoStartTag(Tag.SKIP_BODY);
            exceptionNotThrown = true;
        }
        catch (JspException e) {
            assertFalse(exceptionNotThrown);
        }
    }
    
    public void testIOExceptionHandling() {
        NavMenuTag nmt = new NavMenuTag();
        TagTestHelper tth = TagTestUtils.setupTagTest(nmt, url);

        boolean exceptionNotThrown = false;

        try {
            // need to override the JspWriter
            RhnMockExceptionJspWriter out = new RhnMockExceptionJspWriter();
            tth.getPageContext().setJspWriter(out);
            
            // ok let's test the tag
            setupTag(nmt, 10, 4, NAV_XML, TOP_NAV);
            tth.assertDoStartTag(Tag.SKIP_BODY);
            
            exceptionNotThrown = true;
        }
        catch (JspException e) {
            assertFalse(exceptionNotThrown);
        }
    }
   
    public void testTagOutput() {
        NavMenuTag nmt = new NavMenuTag();
        TagTestHelper tth = TagTestUtils.setupTagTest(nmt, url);
        
        try {
            // setup mock objects
            MockJspWriter out = (MockJspWriter) tth.getPageContext().getOut();
            out.setExpectedData(getReturnValue());
            
            // ok let's test the tag
            setupTag(nmt, 0, 4, NAV_XML, TOP_NAV);
            tth.assertDoStartTag(Tag.SKIP_BODY);
            out.verify();
            HttpServletRequest req = (HttpServletRequest) tth.getPageContext().getRequest();
            //  Check the sitenav session var
            assertNotNull(req.getSession().getAttribute("sitenav_unauthnavi_location"));
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
    
    public void testDoStartTagReturnValue() {
        NavMenuTag nmt = new NavMenuTag();
        TagTestHelper tth = TagTestUtils.setupTagTest(nmt, url);
        
        try {

            // ok let's test the tag
            setupTag(nmt, 4, 10, NAV_XML, TOP_NAV);
            tth.assertDoStartTag(Tag.SKIP_BODY);
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
    
    private void setupTag(NavMenuTag nmt, int mindepth, int maxdepth,
                          String def, String renderer) {
        nmt.setMindepth(mindepth);
        nmt.setMaxdepth(maxdepth);
        nmt.setDefinition(def);
        nmt.setRenderer(renderer);
    }
    
    private String getReturnValue() {
        return "<ul id=\"mainNav\"><li id=\"mainFirst-active\"><a href=\"/index.pxt\" " +
               "class=\"mainFirstLink\">Sign In</a>" + 
               "</li>\n<li id=\"mainLast\"><a href=\"/help/about.pxt\" " +
               "class=\"mainLastLink\">About</a></li>\n</ul>";
    }
    
    public void testSetMaxdepth() {
        NavMenuTag nmt = new NavMenuTag();
        nmt.setMaxdepth(10);
        assertEquals(10, nmt.getMaxdepth());
    }
    
    public void testsetMindepth() {
        NavMenuTag nmt = new NavMenuTag();
        nmt.setMindepth(10);
        assertEquals(10, nmt.getMindepth());
    }
    
    public void testSetDefinition() {
        NavMenuTag nmt = new NavMenuTag();
        nmt.setDefinition("foo");
        assertEquals("foo", nmt.getDefinition());
    }
    
    public void testSetRenderer() {
        NavMenuTag nmt = new NavMenuTag();
        nmt.setRenderer("foo");
        assertEquals("foo", nmt.getRenderer());
    }
    
    public void testDefaultMaxDepth() {
        NavMenuTag nmt = new NavMenuTag();
        assertEquals(Integer.MAX_VALUE, nmt.getMaxdepth());
    }
}
