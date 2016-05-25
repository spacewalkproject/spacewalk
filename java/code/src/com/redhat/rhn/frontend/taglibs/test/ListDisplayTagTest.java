/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockJspWriter;
import com.redhat.rhn.testing.RhnMockServletOutputStream;
import org.jmock.Expectations;
import org.jmock.integration.junit3.MockObjectTestCase;
import org.jmock.lib.legacy.ClassImposteriser;

import java.io.Writer;
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
    private PageContext pageContext;
    private RhnMockJspWriter writer;

    public void setUp() throws Exception {
        super.setUp();
        setImposteriser(ClassImposteriser.INSTANCE);
        RhnBaseTestCase.disableLocalizationServiceLogging();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        pageContext = mock(PageContext.class);
        writer = new RhnMockJspWriter();

        ldt = new ListDisplayTag();
        lt = new ListTag();
        ldt.setPageContext(pageContext);
        ldt.setParent(lt);

        lt.setPageList(new DataResult(CSVWriterTest.getTestListOfMaps()));

        context().checking(new Expectations() { {
            atLeast(1).of(pageContext).getOut();
            will(returnValue(writer));

            atLeast(1).of(pageContext).getRequest();
            will(returnValue(request));

            atLeast(1).of(pageContext).setAttribute("current", null);
        } });
    }

    public void testTitle() throws JspException {
        context().checking(new Expectations() { {
            atLeast(1).of(pageContext).popBody();
            atLeast(1).of(pageContext).pushBody();
            atLeast(1).of(pageContext).pushBody(with(any(Writer.class)));

            atLeast(1).of(request).getParameter(RequestContext.LIST_DISPLAY_EXPORT);
            will(returnValue(null));

            atLeast(1).of(request).getParameter(RequestContext.LIST_SORT);
            will(returnValue(null));
        } });

        ldt.setTitle("Inactive Systems");
        int tagval = ldt.doStartTag();
        assertEquals(Tag.EVAL_BODY_INCLUDE, tagval);
        tagval = ldt.doEndTag();
        ldt.release();
        assertEquals(Tag.EVAL_PAGE, tagval);
        writer.verify();
        String htmlOut = writer.toString();
        assertPaginationControls(htmlOut);
    }

    /**
     * @param htmlOut the html output
     */
    private void assertPaginationControls(String htmlOut) {
        for (RequestContext.Pagination pagination : RequestContext.Pagination.values()) {
            String att = pagination.getLowerAttributeName();
            assertTrue(htmlOut.indexOf("name=\"" + att) > -1);
        }
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
        context().checking(new Expectations() { {
            atLeast(1).of(pageContext).popBody();
            atLeast(1).of(pageContext).pushBody();
            atLeast(1).of(pageContext).pushBody(with(any(Writer.class)));

            atLeast(1).of(request).getAttribute("requestedUri");
            will(returnValue("/rhn/somePage.do"));

            atLeast(1).of(request).getQueryString();
            will(returnValue("sid=12355345"));

            atLeast(1).of(request).getParameter(RequestContext.LIST_DISPLAY_EXPORT);
            will(returnValue("2"));

            atLeast(1).of(request).getParameter(RequestContext.LIST_SORT);
            will(returnValue("column2"));

            atLeast(1).of(request).getParameter(RequestContext.SORT_ORDER);
            will(returnValue(RequestContext.SORT_ASC));
        } });

        int tagval = ldt.doStartTag();
        assertEquals(tagval, Tag.EVAL_BODY_INCLUDE);
        tagval = ldt.doEndTag();
        ldt.release();
        assertEquals(tagval, Tag.EVAL_PAGE);
        writer.verify();
        String htmlOut = writer.toString();
        assertPaginationControls(htmlOut);
        assertTrue(htmlOut.indexOf("Download CSV") > -1);
    }

    public void testExport() throws Exception {
        RhnMockServletOutputStream out = new RhnMockServletOutputStream();
        ldt.setExportColumns("column1,column2,column3");

        context().checking(new Expectations() { {
            atLeast(1).of(request).getParameter(RequestContext.LIST_DISPLAY_EXPORT);
            will(returnValue("1"));

            atLeast(1).of(pageContext).getResponse();
            will(returnValue(response));
        } });

        context().checking(CSVMockTestHelper.getCsvExportParameterExpectations(response,
                out));

        context().checking(new Expectations() { {
            atLeast(1).of(response).reset();
        } });
        int tagval = ldt.doStartTag();
        assertEquals(tagval, Tag.SKIP_PAGE);
        tagval = ldt.doEndTag();
        ldt.release();
        assertEquals(tagval, Tag.SKIP_PAGE);
        assertEquals(EXPECTED_CSV_OUT, out.getContents());
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
