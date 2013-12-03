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

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * ToolbarTagBasicTest
 * @version $Rev$
 */
public class ToolbarTagBasicTest extends BaseTestToolbarTag {

    public void testHelpUrl() {

        try {
            // setup mock objects
            String output = "<div class=\"spacewalk-toolbar-h1\">" +
               "<div class=\"spacewalk-toolbar\"></div>" +
               "<h1>" +
               "<img src=\"/img/rhn-icon-preferences.gif\" alt=\"Home Icon\" />" +
               "<a href=\"/help/provisioning/" +
               "s1-sm-your-rhn.html#S2-SM-YOUR-RHN-PREFS\" target=\"_blank\">" +
               "<span class=\"fa-stack\">" +
               "<i class=\"fa fa-circle fa-stack-1x\"></i>" +
               "<i class=\"fa fa-question fa-stack-1x fa-inverse\"></i>" +
               "</span></a></h1></div>";
            out.setExpectedData(output);

            tt.setBase("h1");
            tt.setImg("/img/rhn-icon-preferences.gif");
            tt.setImgAlt("yourrhn.jsp.toolbar.img.alt");
            tt.setHelpUrl("/help/provisioning/s1-sm-your-rhn.html#S2-SM-YOUR-RHN-PREFS");

            // ok let's test the tag
            tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
            tth.assertDoEndTag(Tag.EVAL_PAGE);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }

    public void testNoImgUrl() {
        try {
            String output = "<div class=\"spacewalk-toolbar-h1\"><div class=\"" +
                            "spacewalk-toolbar\"></div><h1></h1></div>";
            out.setExpectedData(output);

            tt.setBase("h1");
            tt.setImg("");

            // ok let's test the tag
            tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
            tth.assertDoEndTag(Tag.EVAL_PAGE);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }

    public void testImgUrl() {
        try {
            String output = "<div class=\"spacewalk-toolbar-h1\"><div class=\"" +
                            "spacewalk-toolbar\"></div><h1><img src=\"" +
                            "/img/rhn-icon-preferences.gif\" /></h1></div>";
            out.setExpectedData(output);

            tt.setBase("h1");
            tt.setImg("/img/rhn-icon-preferences.gif");

            // ok let's test the tag
            tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
            tth.assertDoEndTag(Tag.EVAL_PAGE);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }

    public void testNoBase() {
        try {
            tt.setImg("/img/rhn-icon-preferences.gif");

            // ok let's test the tag
            tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
            tth.assertDoEndTag(Tag.EVAL_PAGE);
            fail("Should've thrown exceptions");
        }
        catch (JspException e) {
            assertTrue(true);
        }
    }

    public void testNoHelpUrl() {
        try {
            // make sure we don't generate a messed up help url if
            // none was specified
            String output = "<div class=\"spacewalk-toolbar-h1\"><div class=\"" +
                            "spacewalk-toolbar\"></div><h1><img src=\"" +
                            "/img/rhn-icon-preferences.gif\" /></h1></div>";

            out.setExpectedData(output);

            tt.setBase("h1");
            tt.setImg("/img/rhn-icon-preferences.gif");

            // ok let's test the tag
            tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
            tth.assertDoEndTag(Tag.EVAL_PAGE);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
}
