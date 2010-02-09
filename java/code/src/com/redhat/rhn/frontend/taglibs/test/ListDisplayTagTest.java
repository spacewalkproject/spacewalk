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
import com.redhat.rhn.common.util.test.CSVWriterTest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.ListDisplayTag;
import com.redhat.rhn.frontend.taglibs.ListTag;
import com.redhat.rhn.testing.JMockTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.RhnMockServletOutputStream;

import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.Tag;

/**
 * ColumnTagTest
 * @version $Rev: 59372 $
 */
public class ListDisplayTagTest extends MockObjectTestCase {

    private ListDisplayTag ldt;
    private ListTag lt;
    
    private HttpServletRequest request;
    private HttpServletResponse response;
    private PageContext context;
    private RhnMockJspWriter writer;
    private Mock mreq;
    private Mock mresp;
    private Mock mcontext;
    
    public void setUp() throws Exception {
        super.setUp();
        RhnBaseTestCase.disableLocalizationServiceLogging();
        mreq = mock(HttpServletRequest.class);
        mresp = mock(HttpServletResponse.class);
        mcontext = mock(PageContext.class);
        
        request = (HttpServletRequest) mreq.proxy();
        response = (HttpServletResponse) mresp.proxy();
        context = (PageContext) mcontext.proxy();
        writer = new RhnMockJspWriter();
        
        ldt = new ListDisplayTag();
        lt = new ListTag();
        ldt.setPageContext(context);
        ldt.setParent(lt);
        
        lt.setPageList(new DataResult(CSVWriterTest.getTestListOfMaps()));

        mcontext.expects(atLeastOnce()).method("getOut").
            withNoArguments().will(returnValue(writer));
        mcontext.expects(atLeastOnce()).method("getRequest").
            withNoArguments().will(returnValue(request));
        mcontext.expects(atLeastOnce()).method("setAttribute")
        .with(eq("current"), NULL);
    }
    
    public void testTitle() throws JspException {
        mcontext.expects(atLeastOnce()).method("popBody")
                .withNoArguments();
        mcontext.expects(atLeastOnce()).method("pushBody")
                .withNoArguments();
        mreq.expects(atLeastOnce()).method("getParameter")
            .with(eq(RequestContext.LIST_DISPLAY_EXPORT)).will(returnValue(null));
        mreq.stubs().method("getParameter").with(eq(RequestContext.LIST_SORT)).will(
                returnValue(null));
        mreq.stubs().method("getParameter").with(eq(RequestContext.SORT_DESC)).will(
                returnValue(null));
        mreq.stubs().method("getParameter").with(eq(RequestContext.SORT_ASC)).will(
                returnValue(null));
        
        ldt.setTitle("Inactive Systems");
        int tagval = ldt.doStartTag();
        assertEquals(Tag.EVAL_BODY_INCLUDE, tagval);
        tagval = ldt.doEndTag();
        ldt.release();
        assertEquals(Tag.EVAL_PAGE, tagval);
        writer.verify();
        mcontext.verify();
        mreq.verify();
        String htmlOut = writer.toString();
        assertPaginationControls(htmlOut);
    }

    /**
     * @param htmlOut the html output
     */
    private void assertPaginationControls(String htmlOut) {
        assertTrue(htmlOut.indexOf("name=\"first_lower") > -1);
        assertTrue(htmlOut.indexOf("name=\"prev_lower") > -1);
        assertTrue(htmlOut.indexOf("name=\"next_lower") > -1);
        assertTrue(htmlOut.indexOf("name=\"last_lower") > -1);
        assertTrue(htmlOut.indexOf("name=\"lower") > -1);
    }
    
   
    
    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        RhnBaseTestCase.enableLocalizationServiceLogging();
    }


    public void testTag() throws Exception {
        ldt.setExportColumns("column1,column2,column3");
        mcontext.expects(atLeastOnce()).method("popBody").
            withNoArguments();
        mcontext.expects(atLeastOnce()).method("pushBody").
            withNoArguments();
        mreq.expects(atLeastOnce()).method("getAttribute").
            with(eq("requestedUri")).will(returnValue("/rhn/somePage.do"));
        mreq.expects(atLeastOnce()).method("getQueryString").
            withNoArguments().will(returnValue("sid=12355345"));
        mreq.expects(atLeastOnce()).method("getParameter").
            with(eq(RequestContext.LIST_DISPLAY_EXPORT)).will(returnValue("2"));
        mreq.stubs().method("getParameter").with(eq(RequestContext.LIST_SORT)).will(
                returnValue("column2"));
        mreq.expects(atLeastOnce()).method("getParameter").with(
                eq(RequestContext.SORT_ORDER)).will(returnValue(RequestContext.SORT_ASC));
        int tagval = ldt.doStartTag();
        assertEquals(tagval, Tag.EVAL_BODY_INCLUDE);
        tagval = ldt.doEndTag();
        ldt.release();
        assertEquals(tagval, Tag.EVAL_PAGE);
        writer.verify();
        mcontext.verify();
        mreq.verify();
        String htmlOut = writer.toString();
        assertPaginationControls(htmlOut);
        assertTrue(htmlOut.indexOf("Download CSV") > -1);
    }

    public void testExport() throws Exception {
        RhnMockServletOutputStream out = new RhnMockServletOutputStream();
        ldt.setExportColumns("column1,column2,column3");
        mreq.expects(atLeastOnce()).method("getParameter").
            with(eq(RequestContext.LIST_DISPLAY_EXPORT)).will(returnValue("1"));
        mcontext.expects(atLeastOnce()).method("getResponse").
            withNoArguments().will(returnValue(response));
        JMockTestUtils.setupExportParameters(mresp, out);
        mresp.expects(atLeastOnce()).method("reset").withNoArguments();
        int tagval = ldt.doStartTag();
        assertEquals(tagval, Tag.SKIP_PAGE);
        tagval = ldt.doEndTag();
        ldt.release();
        assertEquals(tagval, Tag.SKIP_PAGE);
        assertEquals(EXPECTED_CSV_OUT, out.getContents());
        mresp.verify();
        mreq.verify();
        mcontext.verify();
    }

    private static final String EXPECTED_CSV_OUT = 
            "**column1**,**column2**,**column3**\n" + 
            "cval1-0,cval2-0,cval3-0\n" + 
            "cval1-1,cval2-1,cval3-1\n" +
            "cval1-2,cval2-2,cval3-2\n" +
            "cval1-3,cval2-3,cval3-3\n" +
            "cval1-4,cval2-4,cval3-4\n" +
            "cval1-5,cval2-5,cval3-5\n" +
            "cval1-6,cval2-6,cval3-6\n" +
            "cval1-7,cval2-7,cval3-7\n" +
            "cval1-8,cval2-8,cval3-8\n" +
            "cval1-9,cval2-9,cval3-9\n";
}
