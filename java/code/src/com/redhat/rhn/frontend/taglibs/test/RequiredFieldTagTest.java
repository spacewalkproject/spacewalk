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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.taglibs.RequiredFieldTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;

import java.net.URL;

import javax.servlet.jsp.tagext.Tag;


/**
 * RequiredFieldTagTest
 * @version $Rev$
 */
public class RequiredFieldTagTest extends RhnBaseTestCase {
    public void testRender() throws Exception {
        RequiredFieldTag tag = new RequiredFieldTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest(); 
        TagTestHelper tth = TagTestUtils.setupTagTest(tag, 
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        String key = "getMessage"; 
        tag.setKey(key);
        // ok let's test the tag
        tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
        tth.assertDoEndTag(Tag.SKIP_BODY);        
        
        RhnMockJspWriter rout = (RhnMockJspWriter) tth.getPageContext().getOut();
        assertTrue(rout.toString().indexOf("<span class") > -1);
        assertTrue(rout.toString().indexOf("</span>") > -1);
        assertTrue(rout.toString().indexOf("*") > -1);
        assertTrue(rout.toString().indexOf("\"" + 
                    RequiredFieldTag.REQUIRED_FIELD_CSS + "\"") > -1);
        LocalizationService ls = LocalizationService.getInstance(); 
        assertTrue(rout.toString().startsWith(ls.getMessage(key)));
    }
}
