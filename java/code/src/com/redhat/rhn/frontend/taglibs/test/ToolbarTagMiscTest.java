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

/**
 * ToolbarTagMiscTest
 * @version $Rev$
 */
public class ToolbarTagMiscTest extends BaseTestToolbarTag {
    
    public ToolbarTagMiscTest() {
        super();
    }
    
    private void setupMiscTag(String base, String url, String acl, String alt,
                              String text, String img) {
        tt.setBase(base);
        tt.setMiscUrl(url);
        tt.setMiscAcl(acl);
        tt.setMiscAlt(alt);
        tt.setMiscText(text);
        tt.setMiscImg(img);
        tt.setAclMixins(BooleanAclHandler.class.getName());
    }
    
    public void testMiscNoAcl() {
        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" + 
                "toolbar\"><span class=\"toolbar\"><a href=\"misc-url\">" +
                "<img src=\"/img/foo.gif\" alt=\"ignore me\" title=\"ignore me\" />" +
                "ignore me</a></span></div></div>";
            
            setupMiscTag("h1", "misc-url", "", "jsp.testMessage", 
                         "jsp.testMessage", "foo.gif");
            
            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        } 
    }
    
    public void testMiscWithMissingText() {
        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"></div></div>";

            setupMiscTag("h1", "misc-url", "true_test()", 
                "alt", "", "foo.gif");
            
            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        } 
    }
    
    public void testCreateAclMultipleMixinsMultipleAcls() {
        try {
            String output = "<div class=\"toolbar-h1\"><div class=\"" + 
                "toolbar\"><span class=\"toolbar\"><a href=\"misc-url\">" +
                "<img src=\"/img/foo.gif\" alt=\"ignore me\" title=\"ignore me\" />" +
                "ignore me</a></span></div></div>";

            setupMiscTag("h1", "misc-url",
                    "first_true_acl(); second_true_acl(); is_foo(foo)",
                    "jsp.testMessage", "jsp.testMessage", "foo.gif");
            
            tt.setAclMixins(MockOneAclHandler.class.getName() + "," +
                    MockTwoAclHandler.class.getName());

            verifyTag(output);
        }
        catch (JspException je) {
            fail(je.toString());
        }
        catch (Exception e) {
            fail(e.toString());
        }
    }

    public void testCreateAclMultipleAclsSingleMixin() {
        try {
            String output = "<div class=\"toolbar-h1\"><div class=\"" + 
                "toolbar\"><span class=\"toolbar\"><a href=\"misc-url\">" +
                "<img src=\"/img/foo.gif\" alt=\"ignore me\" title=\"ignore me\" />" +
                "ignore me</a></span></div></div>";
            
            setupMiscTag("h1", "misc-url",
                    "first_true_acl(); second_true_acl()", "jsp.testMessage",
                    "jsp.testMessage", "foo.gif");

            tt.setAclMixins(MockOneAclHandler.class.getName());

            verifyTag(output);
        }
        catch (JspException je) {
            fail(je.toString());
        }
        catch (Exception e) {
            fail(e.toString());
        }
    }

    public void testCreateAclValidAclInvalidMixin() {
        boolean flag = false;
        try {
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"></div></div>";

            setupMiscTag("h1", "misc-url",
                    "true_test()", "alt", "text", "foo.gif");
            
            tt.setAclMixins("throws.class.not.found.exception");

            verifyTag(output);
            flag = true;
        }
        catch (JspException je) {
            assertFalse(flag);
        }
        catch (Exception e) {
            fail(e.toString());
        }
    }
    
    public void testMiscAcl() {

        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" + 
                "toolbar\"><span class=\"toolbar\"><a href=\"misc-url\">" +
                "<img src=\"/img/foo.gif\" alt=\"ignore me\" title=\"ignore me\" />" +
                "ignore me</a></span></div></div>";
            
            setupMiscTag("h1", "misc-url", "true_test()", "jsp.testMessage", 
                         "jsp.testMessage", "foo.gif");

            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
    
    public void testMiscWithMissingUrl() {
        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"></div></div>";
            
            setupMiscTag("h1", null, "true_test()", "alt", "text", 
                "foo.gif");
            
            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        } 
    }

    public void testMiscWithMissingImg() {
        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"></div></div>";
            
            setupMiscTag("h1", "misc-url", "true_test()", "alt", "text", 
                null); 
            
            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        } 
    }
}
