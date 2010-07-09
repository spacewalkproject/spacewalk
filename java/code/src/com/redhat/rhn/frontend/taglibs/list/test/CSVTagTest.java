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
package com.redhat.rhn.frontend.taglibs.list.test;

import com.redhat.rhn.common.util.test.CSVWriterTest;
import com.redhat.rhn.frontend.action.CSVDownloadAction;
import com.redhat.rhn.frontend.taglibs.list.CSVTag;
import com.redhat.rhn.frontend.taglibs.list.ListSetTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockJspWriter;

import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.Tag;

public class CSVTagTest extends MockObjectTestCase {
    private ListSetTag lst;
    private CSVTag csv;

    private HttpServletRequest req;
    private HttpSession session;
    private PageContext context;
    private RhnMockJspWriter writer;


    private Mock mreq;
    private Mock mresp;
    private Mock msess;
    private Mock mcontext;
    private String listName = "testDataListName";

    public void setUp() throws Exception {
        super.setUp();
        RhnBaseTestCase.disableLocalizationServiceLogging();
        List dataList = CSVWriterTest.getTestListOfMaps();

        mreq = mock(HttpServletRequest.class);
        mresp = mock(HttpServletResponse.class);
        msess = mock(HttpSession.class);
        mcontext = mock(PageContext.class);

        req = (HttpServletRequest) mreq.proxy();
        session = (HttpSession) msess.proxy();
        context = (PageContext) mcontext.proxy();

        writer = new RhnMockJspWriter();

        mcontext.expects(atLeastOnce()).method("getAttribute").
            with(eq(listName)).will(returnValue(dataList));
        mcontext.expects(atLeastOnce()).method("getRequest").
            withNoArguments().will(returnValue(req));


        mreq.expects(atLeastOnce()).method("getSession").
            with(eq(true)).will(returnValue(session));

        csv = new CSVTag();
        csv.setName("testIsMyName");
        lst = new ListSetTag();
        csv.setPageContext(context);
        csv.setParent(lst);
        csv.setDataset(listName);

        msess.expects(atLeastOnce()).method("setAttribute").
            with(eq("exportColumns_" + csv.getUniqueName()), isA(String.class));
        msess.expects(atLeastOnce()).method("setAttribute").
            with(eq("pageList_" + csv.getUniqueName()), isA(List.class));
    }


    public void testCreateRequestParameters() throws Exception {
        boolean stat = false;
        csv.setExportColumns("column1,column2,column3");
        csv.setupPageData();
        String reqParams = csv.makeCSVRequestParams();
        stat = reqParams.contains(CSVDownloadAction.EXPORT_COLUMNS);
        assertTrue(stat);
        stat = reqParams.contains(CSVDownloadAction.PAGE_LIST_DATA);
        assertTrue(stat);
        stat = reqParams.contains(CSVDownloadAction.UNIQUE_NAME);
        assertTrue(stat);
    }

    /**
     * Creates a sample list and tests CSV functionality.
     * Requires a list of columns set under "exportColumns"
     * as well as a parameter "lde=1" to be present on the
     * requesting URL.
     * @throws Exception
     */
    public void testExport() throws Exception {

        mcontext.expects(atLeastOnce()).method("getOut").
            withNoArguments().will(returnValue(writer));
        csv.setExportColumns("column1,column2,column3");

        int tagval = csv.doStartTag();
        assertEquals(Tag.EVAL_BODY_INCLUDE, tagval);
        tagval = csv.doEndTag();
        assertEquals(Tag.EVAL_PAGE, tagval);

        mresp.verify();
        mreq.verify();
        mcontext.verify();
    }

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        RhnBaseTestCase.enableLocalizationServiceLogging();
    }

}
