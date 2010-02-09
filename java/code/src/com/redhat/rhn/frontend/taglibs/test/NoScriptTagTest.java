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

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.NoScriptTag;
import com.redhat.rhn.frontend.taglibs.SubmittedTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;

import java.net.URL;

import javax.servlet.jsp.tagext.Tag;


/**
 * NoScriptTagTest
 * @version $Rev$
 */
public class NoScriptTagTest  extends RhnBaseTestCase {

    public void testRender() throws Exception {
        NoScriptTag tag = new NoScriptTag();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest(); 
        TagTestHelper tth = TagTestUtils.setupTagTest(tag, 
                                        new URL("http://localhost"),
                                        request);
        tag.setPageContext(tth.getPageContext());
        
        // ok let's test the tag
        tth.assertDoStartTag(Tag.SKIP_BODY);
        tth.assertDoEndTag(Tag.SKIP_BODY);
        
        RhnMockJspWriter rout = (RhnMockJspWriter) tth.getPageContext().getOut();
        assertTrue(rout.toString().indexOf("<noscript>") > -1);
        assertTrue(rout.toString().indexOf("</noscript>") > -1);
        assertTrue(rout.toString().
                            indexOf("\"" + RequestContext.NO_SCRIPT + "\"") > -1);
        assertTrue(rout.toString().indexOf(SubmittedTag.HIDDEN) > -1);
        assertTrue(rout.toString().indexOf(SubmittedTag.TRUE) > -1);
    }
}

