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

import com.redhat.rhn.common.security.acl.AclHandler;
import com.redhat.rhn.frontend.taglibs.ToolbarTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockHttpServletRequest;
import com.mockobjects.servlet.MockJspWriter;

import java.net.URL;
import java.util.HashMap;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * BaseTestToolbarTag
 * @version $Rev$
 */
public abstract class BaseTestToolbarTag extends RhnBaseTestCase {
    protected URL url = null;
    protected TagTestHelper tth;
    protected ToolbarTag tt;
    protected MockJspWriter out;
    
    public void setUp() {
        tt = new ToolbarTag();
        tth = TagTestUtils.setupTagTest(tt, null);
        out = (MockJspWriter) tth.getPageContext().getOut();
        MockHttpServletRequest req = tth.getRequest();
        req.setupGetAttribute(new HashMap());
    }
    
    public void tearDown() {
        tt = null;
        tth = null;
        out = null;
    }
    
    public void verifyTag(String output) throws JspException {
        out.setExpectedData(output);
        tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
        tth.assertDoEndTag(Tag.EVAL_PAGE);
        out.verify();
    }
    
    public static class MockTwoAclHandler implements AclHandler {

        public MockTwoAclHandler() {
            super();
        }

        public boolean aclIsFoo(Object ctx, String[] params) {
            return (params[0].equals("foo"));
        }
    }

    public static class MockOneAclHandler implements AclHandler {

        public MockOneAclHandler() {
            super();
        }

        public boolean aclFirstTrueAcl(Object ctx, String[] params) {
            return true;
        }

        public boolean aclFirstFalseAcl(Object ctx, String[] params) {
            return false;
        }

        public boolean aclSecondFalseAcl(Object ctx, String[] params) {
            return false;
        }

        public boolean aclSecondTrueAcl(Object ctx, String[] params) {
            return true;
        }
    }
    
    public static class BooleanAclHandler implements AclHandler {
        /**
         * Always returns true.
         * @param ctx ignored
         * @param params ignored
         * @return true
         */
        public boolean aclTrueTest(Object ctx, String[] params) {
            return true;
        }
        
        /**
         * Always returns false.
         * @param ctx ignored
         * @param params ignored
         * @return false
         */
        public boolean aclFalseTest(Object ctx, String[] params) {
            return false;
        }
    }
}
