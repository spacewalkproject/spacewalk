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

import com.redhat.rhn.frontend.taglibs.NavDialogMenuTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockExceptionJspWriter;
import com.redhat.rhn.testing.TagTestUtils;
import com.redhat.rhn.testing.TestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockHttpServletRequest;
import com.mockobjects.servlet.MockJspWriter;

import java.net.URL;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * NavDialogMenuTagTest
 * @version $Rev$
 */
public class NavDialogMenuTagTest extends RhnBaseTestCase {

    private final String NAV_XML = "sitenav-test.xml";
    private URL url;
    private final String DIALOG_NAV = "com.redhat.rhn.frontend.nav.DialognavRenderer";
    private NavDialogMenuTag nmt;

    public void setUp() throws Exception {
        nmt = new NavDialogMenuTag();
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
        TagTestHelper tth = TagTestUtils.setupTagTest(nmt, url);

        boolean exceptionNotThrown = false;

        try {
            // need to override the JspWriter
            RhnMockExceptionJspWriter out = new RhnMockExceptionJspWriter();
            tth.getPageContext().setJspWriter(out);

            // ok let's test the tag
            setupTag(nmt, 10, 4, NAV_XML, DIALOG_NAV);
            tth.assertDoStartTag(Tag.SKIP_BODY);
            exceptionNotThrown = true;
        }
        catch (JspException e) {
            assertFalse(exceptionNotThrown);
        }
    }

    public void testTagOutput() {
        TagTestHelper tth = TagTestUtils.setupTagTest(nmt, url);

        try {
            // setup mock objects
            MockJspWriter out = (MockJspWriter) tth.getPageContext().getOut();
            out.setExpectedData(getReturnValue());

            // ok let's test the tag
            setupTag(nmt, 0, 4, NAV_XML, DIALOG_NAV);
            MockHttpServletRequest req = tth.getRequest();
            req.addExpectedSetAttribute("innernavtitle", " - Sign In");
            tth.assertDoStartTag(Tag.SKIP_BODY);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }

    private void setupTag(NavDialogMenuTag ndmt, int mindepth, int maxdepth,
                          String def, String renderer) {
        ndmt.setMindepth(mindepth);
        ndmt.setMaxdepth(maxdepth);
        ndmt.setDefinition(def);
        ndmt.setRenderer(renderer);
    }

    private String getReturnValue() {
        return "<div class=\"content-nav\"><ul class=\"content-nav-rowone\">" +
               "<li class=\"content-nav-selected\"><a class=\"" +
               "content-nav-selected-link\" href=\"/index.pxt\">Sign In</a></li>\n" +
               "<li><a href=\"/help/about.pxt\">About</a></li>\n" +
               "</ul>\n" +
               "</div>\n";
    }

    public void testSetMaxdepth() {
        nmt.setMaxdepth(10);
        assertEquals(10, nmt.getMaxdepth());
    }

    public void testsetMindepth() {
        nmt.setMindepth(10);
        assertEquals(10, nmt.getMindepth());
    }

    public void testSetDefinition() {
        nmt.setDefinition("foo");
        assertEquals("foo", nmt.getDefinition());
    }

    public void testSetRenderer() {
        nmt.setRenderer("foo");
        assertEquals("foo", nmt.getRenderer());
    }

    public void testDefaultMaxDepth() {
        assertEquals(Integer.MAX_VALUE, nmt.getMaxdepth());
    }
}
