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
 * ToolbarTagDeletionTest
 * @version $Rev$
 */
public class ToolbarTagDeletionTest extends BaseTestToolbarTag {
    
    public ToolbarTagDeletionTest() {
        super();
    }
    
    private void setupDeletionTag(String base, String url, String acl, String type) {
        tt.setBase(base);
        tt.setDeletionUrl(url);
        tt.setDeletionAcl(acl);
        tt.setDeletionType(type);
        tt.setAclMixins(BooleanAclHandler.class.getName());
    }
    
    public void testDeletionNoAcl() {
        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"><span class=\"toolbar\"><a href=\"deletion-url\">" +
                "<img src=\"/img/action-del.gif\" alt=\"delete user\"" +
                " title=\"delete user\" />delete user</a></span>" +
                "</div></div>";

            
            setupDeletionTag("h1", "deletion-url", "", "user");
            
            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        } 
    }
    
    public void testDeletionWithMissingType() {
        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"></div></div>";

            setupDeletionTag("h1", "deletion-url", "true_test()", "");
            
            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        } 
    }
    
    public void testCreateAclMultipleMixinsMultipleAcls() {
        try {
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"><span class=\"toolbar\"><a href=\"deletion-url\">" +
            "<img src=\"/img/action-del.gif\" alt=\"delete user\"" +
            " title=\"delete user\" />delete user</a></span>" +
            "</div></div>";

            setupDeletionTag("h1", "deletion-url",
                    "first_true_acl(); second_true_acl(); is_foo(foo)",
                    "user");
            
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
            "toolbar\"><span class=\"toolbar\"><a href=\"deletion-url\">" +
            "<img src=\"/img/action-del.gif\" alt=\"delete user\"" +
            " title=\"delete user\" />delete user</a></span>" +
            "</div></div>";
            
            setupDeletionTag("h1", "deletion-url",
                    "first_true_acl(); second_true_acl()", "user");

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

            setupDeletionTag("h1", "deletion-url",
                    "true_test()", "user");
            
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
    
    public void testDeletionAcl() {

        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"><span class=\"toolbar\"><a href=\"deletion-url\">" +
                "<img src=\"/img/action-del.gif\" alt=\"delete user\"" +
                " title=\"delete user\" />delete user</a></span>" +
                "</div></div>";
            
            setupDeletionTag("h1", "deletion-url", "true_test()", "user");

            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
    
    public void testDeletionWithMissingUrl() {
        try {
            // setup mock objects
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"></div></div>";
            
            setupDeletionTag("h1", null, "true_test()", "user");
            
            verifyTag(output);
        }
        catch (JspException e) {
            fail(e.toString());
        } 
    }
}
