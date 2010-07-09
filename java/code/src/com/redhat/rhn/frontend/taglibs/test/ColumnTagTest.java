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

import com.redhat.rhn.frontend.taglibs.ColumnTag;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.frontend.taglibs.NavMenuTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockHttpServletRequest;
import com.mockobjects.servlet.MockJspWriter;
import com.mockobjects.servlet.MockPageContext;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * ColumnTagTest
 * @version $Rev$
 */
public class ColumnTagTest extends RhnBaseTestCase {

    public void testConstructor() {
        ColumnTag ct = new ColumnTag();
        assertNotNull(ct);
        assertNull(ct.getHeader());
        assertNotNull(ct.getStyle());
        assertNull(ct.getCssClass());
        assertNull(ct.getUrl());
        assertNull(ct.getWidth());
        assertNull(ct.getParent());
        assertNull(ct.getNowrap());
        assertTrue(ct.isRenderUrl());
        assertNull(ct.getArg0());
    }

    public void testCopyConstructor() {
        ColumnTag ct = new ColumnTag();
        ct.setHeader("header");
        ct.setStyle("text-align: center;");
        ct.setCssClass("first-column");
        ct.setUrl("http://www.hostname.com");
        ct.setWidth("10%");
        ct.setNowrap("false");
        ct.setRenderUrl(false);
        ct.setArg0("system");
        ColumnTag copy = new ColumnTag(ct);
        assertEquals(ct, copy);
    }

    public void testEquals() {
        ColumnTag ct = new ColumnTag();
        ct.setHeader("header");
        ct.setStyle("text-align: center;");
        ct.setCssClass("first-column");
        ct.setUrl("http://www.hostname.com");
        ct.setWidth("10%");
        ct.setNowrap("false");

        ColumnTag ct1 = new ColumnTag();
        ct1.setHeader("header");
        ct1.setStyle("text-align: center;");
        ct1.setCssClass("first-column");
        ct1.setUrl("http://www.hostname.com");
        ct1.setWidth("10%");
        ct1.setNowrap("false");

        assertTrue(ct.equals(ct1));
        assertTrue(ct1.equals(ct));

        ct1.setUrl("http://www.hostname.com?sgid=1234");
        assertTrue(ct.equals(ct1));
        assertTrue(ct1.equals(ct));
    }

    public void testSettersGetters() {
        ColumnTag ct = new ColumnTag();
        ct.setHeader("header");
        ct.setStyle("text-align: center;");
        ct.setCssClass("first-column");
        ct.setUrl("http://www.hostname.com");
        ct.setWidth("10%");
        ct.setRenderUrl(true);
        ct.setNowrap("true");
        ct.setArg0("foo");

        assertEquals("header", ct.getHeader());
        assertEquals("foo", ct.getArg0());
        assertEquals("text-align: center;", ct.getStyle());
        assertEquals("first-column", ct.getCssClass());
        assertEquals("http://www.hostname.com", ct.getUrl());
        assertEquals("10%", ct.getWidth());
        assertEquals("true", ct.getNowrap());
        assertTrue(ct.isRenderUrl());
        assertNull(ct.getParent());
    }

    public void testFindListDisplay() {
        ColumnTag ct = new ColumnTag();
        ct.setParent(new ListDisplayTag());
        assertNotNull(ct.findListDisplay());

        ColumnTag ct2 = new ColumnTag();
        NavMenuTag middle = new NavMenuTag();
        middle.setParent(new ListDisplayTag());
        ct2.setParent(middle);
        assertNotNull(ct2.findListDisplay());

        ColumnTag ct3 = new ColumnTag();
        ct3.setParent(new NavMenuTag());
        assertNull(ct3.findListDisplay());
    }

    public void testDoStartTag() throws JspException {
        disableLocalizationServiceLogging();
        ListDisplayTag ldt = new ListDisplayTag();
        ColumnTag ct = new ColumnTag();
        ct.setSortProperty("sortProp");
        assertNull(ct.getParent());

        ct.setParent(ldt);
        ct.setHeader("headervalue");
        assertEquals(ldt, ct.getParent());

        TagTestHelper tth = TagTestUtils.setupTagTest(ct, null);
        MockHttpServletRequest mockRequest = (MockHttpServletRequest)
                tth.getPageContext().getRequest();
        // Dumb, dumb, dumb
        // Mock request doesn't parse the query string!
        // I've had salads with more intelligence
        mockRequest.setupAddParameter("order", "asc");
        // And we STILL have to set the query string
        // otherwise MockObjects complains bitterly....
        mockRequest.setupQueryString("this=stupid&library=needs_this");
        // setup mock objects
        MockJspWriter out = (MockJspWriter)tth.getPageContext().getOut();

        out.setExpectedData("<th>" +
                "<a title=\"Sort By This Column\" " +
                "href=\"http://localhost:8080/rhnjava/index.jsp?order=desc" +
                "&sort=sortProp\">**headervalue**</a></th>");
        MockPageContext mpc = tth.getPageContext();
        mpc.setAttribute("current", new Object());
        ct.setPageContext(mpc);
        tth.assertDoStartTag(Tag.SKIP_BODY);
        tth.assertDoEndTag(Tag.EVAL_BODY_INCLUDE);
        //TODO: verify if this test is needed, followup with bug 458688
        //out.verify();
        enableLocalizationServiceLogging();

    }

}
