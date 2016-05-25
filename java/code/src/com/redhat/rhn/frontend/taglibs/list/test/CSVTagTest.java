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
package com.redhat.rhn.frontend.taglibs.list.test;

import com.redhat.rhn.common.util.test.CSVWriterTest;
import com.redhat.rhn.frontend.action.CSVDownloadAction;
import com.redhat.rhn.frontend.taglibs.list.CSVTag;
import com.redhat.rhn.frontend.taglibs.list.ListSetTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockJspWriter;

import org.jmock.Expectations;
import org.jmock.integration.junit3.MockObjectTestCase;
import org.jmock.lib.legacy.ClassImposteriser;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
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

    private String listName = "testDataListName";

    public void setUp() throws Exception {
        super.setUp();
        setImposteriser(ClassImposteriser.INSTANCE);
        RhnBaseTestCase.disableLocalizationServiceLogging();

        req = mock(HttpServletRequest.class);
        session = mock(HttpSession.class);
        context = mock(PageContext.class);

        writer = new RhnMockJspWriter();

        csv = new CSVTag();
        csv.setName("testIsMyName");
        lst = new ListSetTag();
        csv.setPageContext(context);
        csv.setParent(lst);
        csv.setDataset(listName);

        context().checking(new Expectations() { {
            List dataList = CSVWriterTest.getTestListOfMaps();
            atLeast(1).of(context).getAttribute(listName);
            will(returnValue(dataList));
            atLeast(1).of(context).getRequest();
            will(returnValue(req));
            atLeast(1).of(req).getSession(true);
            will(returnValue(session));
            atLeast(1).of(session).setAttribute(
                    with(equal("exportColumns_" + csv.getUniqueName())),
                    with(any(String.class)));
            atLeast(1).of(session).setAttribute(
                    with(equal("pageList_" + csv.getUniqueName())),
                    with(any(List.class)));
        } });
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
        context().checking(new Expectations() { {
            atLeast(1).of(context).getOut();
            will(returnValue(writer));
        } });

        csv.setExportColumns("column1,column2,column3");

        int tagval = csv.doStartTag();
        assertEquals(Tag.EVAL_BODY_INCLUDE, tagval);
        tagval = csv.doEndTag();
        assertEquals(Tag.EVAL_PAGE, tagval);
    }

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        RhnBaseTestCase.enableLocalizationServiceLogging();
    }

}
