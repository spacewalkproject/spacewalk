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

import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.SubmittedTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;

import java.net.URL;

import javax.servlet.jsp.tagext.Tag;


/**
 * SubmittedTagTest
 * @version $Rev$
 */
public class SubmittedTagTest extends RhnBaseTestCase {

    public void testRender() throws Exception {
        SubmittedTag tag = new SubmittedTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest(); 
        TagTestHelper tth = TagTestUtils.setupTagTest(tag, 
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        
        // ok let's test the tag
        tth.assertDoStartTag(Tag.SKIP_BODY);
        tth.assertDoEndTag(Tag.SKIP_BODY);
        
        RhnMockJspWriter rout = (RhnMockJspWriter) tth.getPageContext().getOut();

        assertTrue(rout.toString().indexOf(RhnAction.SUBMITTED) > -1);
        assertTrue(rout.toString().indexOf(SubmittedTag.HIDDEN) > -1);
        assertTrue(rout.toString().indexOf(SubmittedTag.TRUE) > -1);
    }
}
