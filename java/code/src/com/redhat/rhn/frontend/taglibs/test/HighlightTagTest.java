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

import com.redhat.rhn.frontend.taglibs.HighlightTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockJspWriter;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * HighlightTagTest
 * @version $Rev$
 */
public class HighlightTagTest extends RhnBaseTestCase {

    public void testDoEndTag() throws Exception {

        HighlightTag ht = new HighlightTag();
        TagTestHelper tth = TagTestUtils.setupTagTest(ht, null);
        ht.setPageContext(tth.getPageContext());

        RhnMockBodyContent bc = new RhnMockBodyContent("some test text");
        ht.setBodyContent(bc);

        MockJspWriter out = (MockJspWriter) tth.getPageContext().getOut();

        /*
         * <rhn:highlight tag="foo" text="test">
         *     some test text
         * </rhn:highlight>
         */
        ht.setTag("foo");
        ht.setText("test");
        out.setExpectedData("some <foo>test</foo> text");

        try {
            tth.assertDoEndTag(Tag.EVAL_PAGE);
        }
        catch (JspException e) {
            fail(e.toString());
        }

        /*
         * <rhn:highlight tag="foo" startTag="<foo bar=1>" text="test">
         *     some test text
         * </rhn:highlight>
         */
        ht.setTag("foo");
        ht.setStartTag("<foo bar=1>");
        out.setExpectedData("some <foo bar=1>test</foo> text");
        try {
            tth.assertDoEndTag(Tag.EVAL_PAGE);
        }
        catch (JspException e) {
            fail(e.toString());
        }

        /*
         * <rhn:highlight startTag="<foo>" endTag="</foo>" text="test">
         *     some test text
         * </rhn:highlight>
         */
        ht.setTag(null);
        ht.setStartTag("<foo>");
        ht.setEndTag("</foo>");
        out.setExpectedData("some <foo>test</foo> text");
        try {
            tth.assertDoEndTag(Tag.EVAL_PAGE);
        }
        catch (JspException e) {
            fail(e.toString());
        }

        // Make sure it fails correctly
        /*
         * <rhn:highlight endTag="</foo>" text="test">
         * -- missing startTag or tag
         */
        ht.setTag(null);
        ht.setStartTag(null);
        try {
            tth.assertDoEndTag(Tag.EVAL_PAGE);
            fail(); //Shouldn't get here
        }
        catch (JspException e) {
            //Success
        }

        /*
         * <rhn:highlight tag="foo" text="test"></rhn:highlight>
         */
        ht.setBodyContent(null);
        ht.setTag("foo");
        try {
            tth.assertDoEndTag(Tag.SKIP_BODY);
        }
        catch (JspException e) {
            fail(e.toString());
        }

        RhnMockBodyContent bc2 = new RhnMockBodyContent("some test text " +
                                                        "to Test in a TEST");
        ht.setBodyContent(bc2);
        ht.setTag("foo");
        ht.setText("test");
        out.setExpectedData("some <foo>test</foo> text to <foo>Test</foo> " +
                            "in a <foo>TEST</foo>");
        try {
            tth.assertDoEndTag(Tag.EVAL_PAGE);
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
}
