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
 * ToolbarTagCloneTest
 * @version $Rev: 60021 $
 */
public class ToolbarTagCloneTest extends BaseTestToolbarTag {
    
    public ToolbarTagCloneTest() {
        super();
    }
    
    private void setupCloneTag(String base, String url, String acl, String type) {
        tt.setBase(base);
        tt.setCloneUrl(url);
        tt.setCloneAcl(acl);
        tt.setCloneType(type);
        tt.setAclMixins(BooleanAclHandler.class.getName());
    }
    
    public void testCloneNoAcl() throws Exception {
        // setup mock objects
        String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"><span class=\"toolbar\"><a href=\"Clone-url\">" +
            "<img src=\"/img/action-clone.gif\" alt=\"clone kickstart\"" +
            " title=\"clone kickstart\" />clone kickstart</a></span>" +
            "</div></div>";

            
        setupCloneTag("h1", "Clone-url", "", "kickstart");
            
        verifyTag(output);
    }
    
    public void testCloneWithMissingType() throws Exception {
        // setup mock objects
        String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"></div></div>";

        setupCloneTag("h1", "Clone-url", "true_test()", "");
            
        verifyTag(output);
    }
    
    public void testCreateAclMultipleMixinsMultipleAcls() throws Exception {
        String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"><span class=\"toolbar\"><a href=\"Clone-url\">" +
            "<img src=\"/img/action-clone.gif\" alt=\"clone kickstart\"" +
            " title=\"clone kickstart\" />clone kickstart</a></span>" +
            "</div></div>";

        setupCloneTag("h1", "Clone-url",
                         "first_true_acl(); second_true_acl(); is_foo(foo)",
                         "kickstart");
            
        tt.setAclMixins(MockOneAclHandler.class.getName() + "," +
                        MockTwoAclHandler.class.getName());

        verifyTag(output);
    }

    public void testCreateAclMultipleAclsSingleMixin() throws Exception {
        String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"><span class=\"toolbar\"><a href=\"Clone-url\">" +
            "<img src=\"/img/action-clone.gif\" alt=\"clone kickstart\"" +
            " title=\"clone kickstart\" />clone kickstart</a></span>" +
            "</div></div>";
            
        setupCloneTag("h1", "Clone-url",
                         "first_true_acl(); second_true_acl()", "kickstart");

        tt.setAclMixins(MockOneAclHandler.class.getName());

        verifyTag(output);
    }

    public void testCreateAclValidAclInvalidMixin() {
        boolean flag = false;
        try {
            String output = "<div class=\"toolbar-h1\"><div class=\"" +
                "toolbar\"></div></div>";
 
            setupCloneTag("h1", "Clone-url",
                             "true_test()", "kickstart");
             
            tt.setAclMixins("throws.class.not.found.exception");
 
            verifyTag(output);
            flag = true;
        }
        catch (JspException je) {
            // deep inside the tag, an IllegalArgumentException became
            // a JspException
            assertFalse(flag);
        }
    }
    
    public void testCloneAcl() throws Exception {
        // setup mock objects
        String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"><span class=\"toolbar\"><a href=\"Clone-url\">" +
            "<img src=\"/img/action-clone.gif\" alt=\"clone kickstart\"" +
            " title=\"clone kickstart\" />clone kickstart</a></span>" +
            "</div></div>";
            
        setupCloneTag("h1", "Clone-url", "true_test()", "kickstart");

        verifyTag(output);
    }
    
    public void testCloneWithMissingUrl() throws Exception {
        // setup mock objects
        String output = "<div class=\"toolbar-h1\"><div class=\"" +
            "toolbar\"></div></div>";
            
        setupCloneTag("h1", null, "true_test()", "kickstart");
            
        verifyTag(output);
    }
}
