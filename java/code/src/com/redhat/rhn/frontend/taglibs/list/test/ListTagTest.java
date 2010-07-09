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
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.frontend.taglibs.list.ListCommand;
import com.redhat.rhn.frontend.taglibs.list.ListSetTag;
import com.redhat.rhn.frontend.taglibs.list.ListTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockJspWriter;

import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;
import org.jmock.core.Stub;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.BodyTagSupport;


public class ListTagTest extends MockObjectTestCase {
    private ListSetTag lst;
    private ListTag lt;

    private HttpServletRequest req;
    private WebSession webSess;
    private PageContext context;
    private RhnMockJspWriter writer;

    private Mock mreq;
    private Mock mwebSess;
    private Mock mcontext;
    private String listName = "testDataListName";



    public void setUp() throws Exception {
        super.setUp();
        RhnBaseTestCase.disableLocalizationServiceLogging();
        List dataList = CSVWriterTest.getTestListOfMaps();

        mreq = mock(HttpServletRequest.class);
        mcontext = mock(PageContext.class);
        mwebSess = mock(WebSession.class);

        req = (HttpServletRequest) mreq.proxy();
        context = (PageContext) mcontext.proxy();
        webSess = (WebSession) mwebSess.proxy();

        writer = new RhnMockJspWriter();

        mcontext.expects(atLeastOnce()).method("getAttribute").
            with(eq(listName)).will(returnValue(dataList));
        mcontext.expects(atLeastOnce()).method("getRequest").
            withNoArguments().will(returnValue(req));

        lt = new ListTag();
        lt.setName("testIsMyName");
        lst = new ListSetTag();
        lt.setPageContext(context);
        lt.setParent(lst);
        lt.setDataset(listName);
    }

    /**
     * Tests normal conditions for ListTag.
     * @throws Exception
     */
    public void testRegularRun() throws Exception {
        mreq.expects(atLeastOnce()).method("getRequestURI")
            .withNoArguments().will(returnValue("UTF-8"));
        mreq.expects(atLeastOnce()).method("getAttribute")
            .with(eq("session")).will(returnValue(webSess));
        mwebSess.expects(atLeastOnce()).method("getUser")
            .withNoArguments().will(returnValue(null));
        mreq.expects(atLeastOnce()).method("getParameter")
            .with(stringContains("list_")).will(returnValue(null));
        mreq.expects(atLeastOnce()).method("setAttribute")
            .with(eq("pageNum"), isA(String.class));
        mreq.expects(atLeastOnce()).method("setAttribute")
            .with(eq("dataSize"), isA(String.class));
        mcontext.expects(atLeastOnce()).method("getOut")
            .withNoArguments().will(returnValue(writer));
        mcontext.expects(atLeastOnce()).method("setAttribute")
            .with(stringContains("_cmd"), isA(Object.class));
        mcontext.expects(atLeastOnce()).method("setAttribute")
            .with(eq("current"), isA(Object.class));
        mcontext.expects(atLeastOnce()).method("getAttribute")
            .with(eq("current")).will(returnValue(null));
        mreq.expects(atLeastOnce()).method("getParameter")
            .with(stringContains("PAGE_SIZE_LABEL_SELECTED")).will(returnValue(null));
        Stub[] cmdValues = {
                returnValue(ListCommand.ENUMERATE), // listtag asking
                returnValue(ListCommand.ENUMERATE), // columntag asking
                returnValue(ListCommand.TBL_HEADER), // listtag asking
                returnValue(ListCommand.TBL_HEADER), // columntag asking
                returnValue(ListCommand.COL_HEADER), // listtag asking
                returnValue(ListCommand.COL_HEADER), // columntag asking
                returnValue(ListCommand.RENDER),    // listtag asking
                returnValue(ListCommand.RENDER),    // columntag asking
                returnValue(ListCommand.TBL_FOOTER), // listtag asking
                returnValue(ListCommand.TBL_FOOTER) // columntag asking
                };
        mcontext.expects(atLeastOnce()).method("getAttribute")
            .with(stringContains("_cmd")).will(onConsecutiveCalls(cmdValues));

        int tagval = lt.doStartTag();

        assertEquals(BodyTagSupport.EVAL_BODY_INCLUDE, tagval);
        do {
            tagval = lt.doAfterBody();
        } while (tagval == BodyTagSupport.EVAL_BODY_AGAIN);
        tagval = lt.doEndTag();
        assertEquals(BodyTagSupport.EVAL_PAGE, tagval);
    }
}
