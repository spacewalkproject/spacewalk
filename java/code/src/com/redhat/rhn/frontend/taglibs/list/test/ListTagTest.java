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
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.frontend.taglibs.list.ListCommand;
import com.redhat.rhn.frontend.taglibs.list.ListSetTag;
import com.redhat.rhn.frontend.taglibs.list.ListTag;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockJspWriter;
import java.io.Writer;

import org.jmock.Expectations;
import org.jmock.api.Action;
import org.jmock.integration.junit3.MockObjectTestCase;
import org.jmock.lib.legacy.ClassImposteriser;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.BodyTagSupport;

import static org.hamcrest.Matchers.containsString;
import static org.jmock.Expectations.returnValue;


public class ListTagTest extends MockObjectTestCase {
    private ListSetTag lst;
    private ListTag lt;

    private HttpServletRequest req;
    private WebSession webSess;
    private PageContext pageContext;
    private RhnMockJspWriter writer;

    private String listName = "testDataListName";

    public void setUp() throws Exception {
        super.setUp();
        setImposteriser(ClassImposteriser.INSTANCE);
        RhnBaseTestCase.disableLocalizationServiceLogging();
        List dataList = CSVWriterTest.getTestListOfMaps();

        req = mock(HttpServletRequest.class);
        pageContext = mock(PageContext.class);
        webSess = mock(WebSession.class);

        writer = new RhnMockJspWriter();

        context().checking(new Expectations() { {
            atLeast(1).of(pageContext).getAttribute(listName);
            will(returnValue(dataList));
            atLeast(1).of(pageContext).getRequest();
            will(returnValue(req));
        } });

        lt = new ListTag();
        lt.setName("testIsMyName");
        lst = new ListSetTag();
        lt.setPageContext(pageContext);
        lt.setParent(lst);
        lt.setDataset(listName);
    }

    /**
     * Tests normal conditions for ListTag.
     * @throws Exception
     */
    public void testRegularRun() throws Exception {
        context().checking(new Expectations() { {
            atLeast(1).of(req).getRequestURI();
            will(returnValue("UTF-8"));

            atLeast(1).of(req).getAttribute("session");
            will(returnValue(webSess));

            atLeast(1).of(webSess).getWebUserId();
            will(returnValue(null));

            atLeast(1).of(req).getParameter(with(containsString("list_")));
            will(returnValue(null));

            atLeast(1).of(req).setAttribute(
                    with(equal("pageNum")),
                    with(any(String.class)));

            atLeast(1).of(req).setAttribute(
                    with(equal("dataSize")),
                    with(any(String.class)));

            atLeast(1).of(pageContext).getOut();
            will(returnValue(writer));

            atLeast(1).of(pageContext).setAttribute(
                    with(containsString("_cmd")),
                    with(any(Object.class)));

            atLeast(1).of(pageContext).setAttribute(
                    with(equal("current")),
                    with(any(Object.class)));

            atLeast(1).of(pageContext).getAttribute("current");
            will(returnValue(null));

            atLeast(1).of(pageContext).pushBody(with(any(Writer.class)));

            atLeast(1).of(pageContext).popBody();

            atLeast(1).of(req)
                    .getParameter(with(containsString("PAGE_SIZE_LABEL_SELECTED")));
            will(returnValue(null));
        } });

        Action[] cmdValues = {
                returnValue(ListCommand.ENUMERATE), // listtag asking
                returnValue(ListCommand.ENUMERATE), // columntag asking
                returnValue(ListCommand.TBL_HEADING), // listtag asking
                returnValue(ListCommand.TBL_HEADING), // columntag asking
                returnValue(ListCommand.TBL_ADDONS), // listtag asking
                returnValue(ListCommand.TBL_ADDONS), // columntag asking
                returnValue(ListCommand.COL_HEADER), // listtag asking
                returnValue(ListCommand.COL_HEADER), // columntag asking
                returnValue(ListCommand.BEFORE_RENDER), // listtag asking
                returnValue(ListCommand.BEFORE_RENDER), // columntag asking
                returnValue(ListCommand.RENDER),    // listtag asking
                returnValue(ListCommand.RENDER),    // columntag asking
                returnValue(ListCommand.AFTER_RENDER), // listtag asking
                returnValue(ListCommand.AFTER_RENDER), // columntag asking
                returnValue(ListCommand.TBL_FOOTER), // listtag asking
                returnValue(ListCommand.TBL_FOOTER) // columntag asking
        };

        context().checking(new Expectations() { {
            atLeast(1).of(pageContext).getAttribute(with(containsString("_cmd")));
            will(onConsecutiveCalls(cmdValues));
        } });

        int tagval = lt.doStartTag();

        assertEquals(BodyTagSupport.EVAL_BODY_INCLUDE, tagval);
        do {
            tagval = lt.doAfterBody();
        } while (tagval == BodyTagSupport.EVAL_BODY_AGAIN);
        tagval = lt.doEndTag();
        assertEquals(BodyTagSupport.EVAL_PAGE, tagval);
    }
}
