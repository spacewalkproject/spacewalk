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
package com.redhat.rhn.testing;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.context.Context;
import com.redhat.rhn.frontend.servlets.PxtCookieManager;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.struts.action.DynaActionForm;
import org.hibernate.HibernateException;

import java.util.Locale;
import java.util.TimeZone;

import javax.servlet.http.Cookie;

import servletunit.HttpServletRequestSimulator;
import servletunit.ServletContextSimulator;
import servletunit.struts.MockStrutsTestCase;

/**
 * RhnMockStrutsTestCase - simple base class that adds a User to the test since all our
 * Struts Actions use a User.
 * @version $Rev$
 */
public class RhnMockStrutsTestCase extends MockStrutsTestCase {

    protected User user;

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();

        RequestContext requestContext = new RequestContext(request);
        Context ctx = Context.getCurrentContext();
        ctx.setLocale(Locale.getDefault());
        ctx.setTimezone(TimeZone.getDefault());
        PxtCookieManager pxtCookieManager = new PxtCookieManager();

        request.setServerName("localhost");
        request.setMethod(HttpServletRequestSimulator.GET);
        user = UserTestUtils.findNewUser(TestStatics.TESTUSER, TestStatics.TESTORG);
        user.addRole(RoleFactory.ORG_ADMIN);
        addRequestParameter(RequestContext.USER_ID, user.getId().toString());
        WebSession s = requestContext.getWebSession();
        Cookie[] cookies = new Cookie[1];
        cookies[0] = pxtCookieManager.createPxtCookie(s.getId(), request, 0);
        request.setCookies(cookies);
        request.setAttribute("session", s);
        request.setRequestURI("http://localhost.redhat.com");
        request.setRequestURL("http://localhost.redhat.com/");

        PxtSessionDelegateFactory pxtDelegateFactory =
            PxtSessionDelegateFactory.getInstance();

        PxtSessionDelegate pxtDelegate = pxtDelegateFactory.newPxtSessionDelegate();

        pxtDelegate.updateWebUserId(request, response, user.getId());
        KickstartDataTest.setupTestConfiguration();
    }

    /**
     * Tears down the fixture, and closes the HibernateSession.
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        TestCaseHelper.tearDownHelper();
    }


    protected ServletContextSimulator getContext() {
        return this.context;
    }

    /**
     * Check the Form to make sure it contains a value
     * @param name of parameter
     * @param expectedValue expected
     */
    protected void verifyFormValue(String name, Object expectedValue) {
        DynaActionForm form = (DynaActionForm) getActionForm();
        Object formval = form.get(name);
        if (expectedValue != null && formval != null) {
            assertEquals(expectedValue, formval);
        }
    }

    /**
     * Util method to add an "ID" to be selected on a list page.
     * Usefull for testing list selection code.
     * @param id you want to add
     */
    protected void addSelectedItem(Long id) {
        addRequestParameter("items_selected", id.toString());
    }

    /**
     * Add a request param to simulate a button click on one
     * of your dispatch actions.  See your processMethodKeys()
     *
     * @param key to the button.  See your Struts Action method: processMethodKeys()
     */
    protected void addDispatchCall(String key) {
        addRequestParameter("dispatch",
                LocalizationService.getInstance().getMessage(key));

    }

    /**
     * Verify that the attribute "pageList" is setup properly:
     *
     * 1) not null
     * 2) size > 0
     * 3) first item in list is instance of classIn
     * @param attribName name of list in Request attributes
     * @param classIn to check first item against.
     */
    protected void verifyList(String attribName, Class classIn) {
        DataResult dr = (DataResult) request.getAttribute(attribName);
        assertNotNull("Your list: " + attribName + " is null", dr);
        assertTrue("Your list: " + attribName + " is empty", dr.size() > 0);
        assertEquals("Your list: " + attribName + " is the wrong class",
                classIn, dr.iterator().next().getClass());
    }

    /**
     * Verify that the attribute "pageList" is setup properly:
     *
     * 1) not null
     * 2) size > 0
     * 3) first item in list is instance of classIn
     * @param classIn to check first item against.
     */
    protected void verifyPageList(Class classIn) {
        verifyList(RequestContext.PAGE_LIST, classIn);
    }


    /**
     * Verify that the attribute "pageList" is setup properly:
     *
     * 1) not null
     * 2) size > 0
     * 3) first item in list is instance of classIn
     * @param attribName name of list in Request attributes
     * @param classIn to check first item against.
     */
    protected void verifyFormList(String attribName, Class classIn) {
        DynaActionForm form = (DynaActionForm) getActionForm();
        DataResult dr = (DataResult) form.get(attribName);
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertEquals(classIn, dr.iterator().next().getClass());
    }



    /**
     * Util to check to see that a message is in the response.  Like
     * verifyActionMessages() but doesn't require a string array.
     *
     * @param key to the message.
     */
    protected void verifyActionMessage(String key) {
        String[] messageNames = new String[1];
        messageNames[0] = key;
        verifyActionMessages(messageNames);
    }

    protected void addSubmitted() {
        request.addParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
    }

    protected void assertBadParamException() {
        assertTrue(getActualForward().indexOf("errors/badparam.jsp") > 0);
    }

    protected void assertLookupException() {
        assertTrue(getActualForward().indexOf("errors/lookup.jsp") > 0);
    }

    protected void assertPermissionException() {
        assertTrue(getActualForward().indexOf("errors/Permission.do") > 0);
    }

    protected void assertException() {
        assertTrue(getActualForward().indexOf("/errors") > 0);
    }

    /**
     * PLEASE Refrain from using this unless you really have to.
     *
     * Try clearSession() instead
     * @throws HibernateException
     */
    protected void commitAndCloseSession() throws HibernateException {
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }


}
