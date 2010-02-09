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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.frontend.taglibs.ListTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.TagTestUtils;

import com.mockobjects.helpers.TagTestHelper;
import com.mockobjects.servlet.MockJspWriter;
import com.mockobjects.servlet.MockPageContext;

import java.net.URL;
import java.util.HashMap;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.Tag;

/**
 * ColumnTagTest
 * @version $Rev$
 */
public class ListTagTest extends RhnBaseTestCase {
    
    public void testConstructor() {
        ListTag lt = new ListTag();
        assertNotNull(lt);
        assertNull(lt.getPageList());
    }

    public void testLegends() throws Exception {
        ListTag lt = new ListTag();
        
        TagTestHelper tth = TagTestUtils.setupTagTest(lt, new URL("http://localhost/"));
        MockPageContext pc = tth.getPageContext();
        RhnMockHttpServletRequest request = new RhnMockHttpServletRequest();
       
        pc.setRequest(request);
        lt.setPageContext(pc);
        
        //test null
        lt.setLegend(null);
        lt.setNoDataText("none.message");
        pc.getRequest().setAttribute("legends", null);
        lt.doStartTag();
        assertNull(pc.getRequest().getAttribute("legends"));
        
        //test 1
        lt.setLegend("yankee");
        lt.setNoDataText("none.message");
        pc.getRequest().setAttribute("legends", "");
        lt.doStartTag();
        assertEquals("yankee", pc.getRequest().getAttribute("legends"));
        
        //test > 1
        lt.setLegend("foxtrot");
        lt.setNoDataText("none.message");
        pc.getRequest().setAttribute("legends", "yankee,hotel");
        lt.doStartTag();
        assertEquals("yankee,hotel,foxtrot", pc.getRequest().getAttribute("legends"));
    }
    
    public void testTagNoOutput() throws Exception {
        ListTag lt = new ListTag();
        // This is a hack, but I just need an empty list, and this works.
        SelectMode m = ModeFactory.getMode("test_queries", "user_tables");
        DataResult dr = m.execute(new HashMap());
        dr = (DataResult)dr.subList(0, 0);
        
        lt.setPageList(dr);
        lt.setNoDataText("cant have spaces");
        TagTestHelper tth = TagTestUtils.setupTagTest(lt, new URL("http://localhost/"));
        
        try {
            // setup mock objects
            MockJspWriter out = (MockJspWriter) tth.getPageContext().getOut();
            out.setExpectedData("<div class=\"list-empty-message\">do spaces work?</div>");
            
            // ok let's test the tag
            tth.assertDoStartTag(Tag.SKIP_BODY);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }

    public void testTagOutput() throws Exception {
        ListTag lt = new ListTag();
        // This is a hack, but I just need an empty list, and this works.
        SelectMode m = ModeFactory.getMode("test_queries", "user_tables");
        DataResult dr = m.execute(new HashMap());
        dr = (DataResult)dr.subList(0, 1);
        
        lt.setPageList(dr);
        lt.setNoDataText("No Data.");
        TagTestHelper tth = TagTestUtils.setupTagTest(lt, new URL("http://localhost/"));
        
        try {
            // setup mock objects
            MockJspWriter out = (MockJspWriter) tth.getPageContext().getOut();
            out.setExpectedData("");
            
            // ok let's test the tag
            tth.assertDoStartTag(Tag.EVAL_BODY_INCLUDE);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
    
    public void testNullPageList() throws Exception {
        ListTag lt = new ListTag();
      
        lt.setPageList(null);
        lt.setNoDataText("No Data.");
        TagTestHelper tth = TagTestUtils.setupTagTest(lt, new URL("http://localhost/"));
        
        try {
            // setup mock objects
            MockJspWriter out = (MockJspWriter) tth.getPageContext().getOut();
            out.setExpectedData("<div class=\"list-empty-message\">**No Data.**</div>");
            
            // ok let's test the tag
            tth.assertDoStartTag(Tag.SKIP_BODY);
            out.verify();
        }
        catch (JspException e) {
            fail(e.toString());
        }
    }
}
