/**
 * Copyright (c) 2016 Red Hat, Inc.
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

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockJspWriter;
import com.redhat.rhn.frontend.taglibs.RhnHiddenTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockJspWriter;

/**
 * RhnHiddenTagTest
 */

public class RhnHiddenTagTest extends RhnBaseTestCase {

    private TagTestHelper tth;
    private RhnHiddenTag ht;
    private MockJspWriter out;

    @Override
    public void setUp() {
        ht = new RhnHiddenTag();
        tth = new TagTestHelper(ht);
        tth.getPageContext().setJspWriter(new RhnMockJspWriter());
        out = (MockJspWriter) tth.getPageContext().getOut();
    }

    @Override
    public void tearDown() {
        ht = null;
        tth = null;
        out = null;
    }

    public void verifyTag(String output) throws JspException {
        out.setExpectedData(output);
        tth.assertDoStartTag(Tag.SKIP_BODY);
        out.verify();
    }

    public void testBasicTag() {
        String expected = "<input type=\"hidden\"" +
                          " name=\"test\"" +
                          " value=\"foo\"" +
                          " />";
        ht.setName("test");
        ht.setValue("foo\"><script>alert(1);</script>");
        ht.setValue("foo");
        try {
            verifyTag(expected);
        }
        catch (JspException je) {
            fail(je.toString());
        }
    }

    public void testScriptInValue() {
        String expected = "<input type=\"hidden\"" +
                     " name=\"test\"" +
                     " value=\"foo&quot;&gt;&lt;script&gt;alert(1);&lt;/script&gt;\" />";
      ht.setName("test");
      ht.setValue("foo\"><script>alert(1);</script>");
      try {
          verifyTag(expected);
      }
      catch (JspException je) {
          fail(je.toString());
      }
    }
}
