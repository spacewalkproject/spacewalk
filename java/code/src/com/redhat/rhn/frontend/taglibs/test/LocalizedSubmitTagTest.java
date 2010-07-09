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

import com.redhat.rhn.frontend.taglibs.LocalizedSubmitTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockJspWriter;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * NavMenuTagTest
 * @version $Rev: 694 $
 */
public class LocalizedSubmitTagTest extends RhnBaseTestCase {

    // TODO : Fix this so the build isnt broken
    public void testTagOutput() {
        LocalizedSubmitTag ltag = new LocalizedSubmitTag();
        ltag.setValueKey("none.message");
        ltag.setTabindex("3");
        try {
            TagTestHelper tth = TagTestUtils.setupTagTest(ltag, null);
            tth.getPageContext().getRequest();
            // setup mock objects
            MockJspWriter out = (MockJspWriter)tth.getPageContext().getOut();
            out.setExpectedData("<input type=\"submit\"" +
                " tabindex=\"3\" value=\"(none)\">");
            // ok let's test the tag
            tth.assertDoStartTag(Tag.SKIP_BODY);
            tth.assertDoEndTag(Tag.EVAL_PAGE);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
        catch (Exception e1) {
            e1.printStackTrace();
            fail(e1.toString());
        }
    }
}
