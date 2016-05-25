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
package com.redhat.rhn.frontend.servlets.test;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.TransformerUtils;
import org.hamcrest.Description;
import org.hamcrest.Factory;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;
import org.jmock.Expectations;
import org.jmock.integration.junit3.MockObjectTestCase;

import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.frontend.servlets.PxtCookieManager;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateImpl;

/**
 * PxtSessionDelegateImplTest
 * @version $Rev$
 */
public class PxtSessionDelegateImplTest extends MockObjectTestCase {

    private class PxtSessionDelegateImplStub extends PxtSessionDelegateImpl {
        private Transformer findPxtSessionByIdCallback;
        private Transformer createPxtSessionCallback;

        private int savePxtSessionCounter;

        private boolean isLoadPxtSessionStubbed;

        public PxtSessionDelegateImplStub() {
            findPxtSessionByIdCallback = TransformerUtils.nullTransformer();
            createPxtSessionCallback = TransformerUtils.nullTransformer();
        }

        public void setFindPxtSessionByIdCallback(Transformer callback) {
            findPxtSessionByIdCallback = callback;
        }

        public WebSession findPxtSessionById(Long id) {
            return (WebSession)findPxtSessionByIdCallback.transform(id);
        }

        public void setCreatePxtSessionCallback(Transformer callback) {
            createPxtSessionCallback = callback;
        }

        public WebSession createPxtSession() {
            return (WebSession)createPxtSessionCallback.transform(null);
        }

        public void loadPxtSession(HttpServletRequest request) {
            if (!isLoadPxtSessionStubbed) {
                super.loadPxtSession(request);
            }
        }

        public void stubLoadPxtSession(boolean isStubbed) {
            isLoadPxtSessionStubbed = isStubbed;
        }

        public Long getPxtSessionId(HttpServletRequest request) {
            return super.getPxtSessionId(request);
        }

        protected void savePxtSession(WebSession pxtSession) {
            ++savePxtSessionCounter;
        }

        public int getSavePxtSessionCounter() {
            return savePxtSessionCounter;
        }
    }

    private static final Long PXT_SESSION_ID = new Long(2658447890L);

    private HttpServletRequest mockRequest;
    private HttpServletResponse mockResponse;
    private WebSession mockPxtSession;
    private HttpSession mockHttpSession;

    private PxtSessionDelegateImplStub pxtSessionDelegate;

    private PxtCookieManager pxtCookieManager;

    /**
     * @param name test name
     */
    public PxtSessionDelegateImplTest(String name) {
        super(name);
    }

    private HttpServletRequest getRequest() {
        return mockRequest;
    }

    private HttpServletResponse getResponse() {
        return mockResponse;
    }

    private WebSession getPxtSession() {
        return mockPxtSession;
    }

    private HttpSession getSession() {
        return mockHttpSession;
    }

    private Cookie getPxtCookie() {
        return pxtCookieManager.createPxtCookie(PXT_SESSION_ID, getRequest(), 3600);
    }

    private Cookie getPxtCookieWithInvalidSessionKey() {
        Cookie pxtCookie = getPxtCookie();
        String key = pxtCookie.getValue();

        key = key.replace('x', ':');

        pxtCookie.setValue(key);

        return pxtCookie;
    }

    /**
     * {@inheritDoc}
     */
    protected void setUp() throws Exception {
        super.setUp();

        mockRequest = mock(HttpServletRequest.class);
        mockResponse = mock(HttpServletResponse.class);
        mockPxtSession = mock(WebSession.class);
        mockHttpSession = mock(HttpSession.class);
        pxtSessionDelegate = new PxtSessionDelegateImplStub();
        pxtCookieManager = new PxtCookieManager();

        context().checking(new Expectations() { {
            allowing(mockRequest).getServerName();
            will(returnValue("somehost.redhat.com"));
            allowing(mockRequest).getHeader("User-Agent");
            will(returnValue(null));
        } });
    }

    private void setUpLoadPxtSession() {
        context().checking(new Expectations() { {
            allowing(mockRequest).getAttribute("session");
            will(returnValue(null));
            atLeast(1).of(mockRequest).setAttribute(with(equal("session")),
                    with(any(WebSession.class)));
        } });
    }

    public final void testLoadPxtSessionWhenPxtSessionIdIsNull() {
        setUpLoadPxtSession();

        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(null));
        } });

        pxtSessionDelegate.setCreatePxtSessionCallback(
                TransformerUtils.constantTransformer(getPxtSession()));

        pxtSessionDelegate.loadPxtSession(getRequest());
    }

    public final void testLoadPxtSessionWhenPxtSessionIdIsNotNull() {
        setUpLoadPxtSession();

        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(new Cookie[] {getPxtCookie()}));
        } });

        pxtSessionDelegate.setFindPxtSessionByIdCallback(new Transformer() {
            public Object transform(Object arg) {
                if (PXT_SESSION_ID.equals(arg)) {
                    return getPxtSession();
                }
                return null;
            }
        });

        pxtSessionDelegate.loadPxtSession(getRequest());
    }

    public final void testLoadPxtSessionWhenPxtSessionIdIsInvalid() {
        setUpLoadPxtSession();

        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(new Cookie[] {getPxtCookie()}));
        } });

        pxtSessionDelegate.setCreatePxtSessionCallback(
                TransformerUtils.constantTransformer(getPxtSession()));

        pxtSessionDelegate.loadPxtSession(getRequest());
    }

    public final void testIsPxtSessionKeyValidWhenPxtCookieNotFound() {
        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(null));
        } });

        assertFalse(pxtSessionDelegate.isPxtSessionKeyValid(getRequest()));
    }

    public final void testIsPxtSessionKeyVaidWhenSessionKeyInvalid() {
        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(new Cookie[] {getPxtCookieWithInvalidSessionKey()}));
        } });

        assertFalse(pxtSessionDelegate.isPxtSessionKeyValid(getRequest()));
    }

    public final void testIsPxtSessionKeyValidWhenPxtCookieFound() {
        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(new Cookie[] {getPxtCookie()}));
        } });

        assertTrue(pxtSessionDelegate.isPxtSessionKeyValid(getRequest()));
    }

    public final void testGetPxtSessionId() {
        Cookie[] cookies = new Cookie[] {getPxtCookie()};
        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(cookies));
        } });

        assertEquals(PXT_SESSION_ID, pxtSessionDelegate.getPxtSessionId(getRequest()));
    }

    public final void testGetPxtSessionIdWhenPxtCookieIsInvalid() {
        Cookie[] cookies = new Cookie[] {getPxtCookieWithInvalidSessionKey()};

        context().checking(new Expectations() { {
            allowing(mockRequest).getCookies();
            will(returnValue(cookies));
        } });

        assertNull(pxtSessionDelegate.getPxtSessionId(getRequest()));
    }

    private void setUpInvalidatePxtSession() {
        pxtSessionDelegate.stubLoadPxtSession(true);

        context().checking(new Expectations() { {
            allowing(mockRequest).getAttribute("session");
            will(returnValue(getPxtSession()));
            allowing(mockRequest).getSession();
            will(returnValue(getSession()));
            allowing(mockPxtSession).getId();
            will(returnValue(PXT_SESSION_ID));
            allowing(mockPxtSession).setExpires(with(any(Long.class)));
            allowing(mockHttpSession).setAttribute(with(any(String.class)),
                    with(any(Object.class)));
            allowing(mockHttpSession).setAttribute(with(any(String.class)),
                    with(aNull(Object.class)));
        } });
    }

    public final void testInvalidatePxtSessionSetsWebUserIdToNull() {
        setUpInvalidatePxtSession();

        context().checking(new Expectations() { {
            oneOf(mockPxtSession).setWebUserId(null);
            allowing(mockResponse).addCookie(with(any(Cookie.class)));
        } });

        pxtSessionDelegate.invalidatePxtSession(getRequest(), getResponse());
    }

    public final void testInvalidatePxtSessionSavesPxtSession() {
        setUpInvalidatePxtSession();

        context().checking(new Expectations() { {
            allowing(mockPxtSession).setWebUserId(null);
            allowing(mockResponse).addCookie(with(any(Cookie.class)));
        } });

        pxtSessionDelegate.invalidatePxtSession(getRequest(), getResponse());

        assertEquals(1, pxtSessionDelegate.getSavePxtSessionCounter());
    }

    private static class ZeroMaxAgeCookieMatcher extends TypeSafeMatcher<Cookie> {

        @Override
        protected boolean matchesSafely(Cookie cookie) {
            return cookie.getMaxAge() == 0;
        }

        @Override
        public void describeTo(Description description) {
            description.appendText("a cookie with max age = 0");
        }
    }

    @Factory
    private static Matcher<Cookie> zeroMaxAgeCookieMatcher() {
        return new ZeroMaxAgeCookieMatcher();
    }

    public final void testInvalidatePxtSessionDeletesPxtCookie() {
        setUpInvalidatePxtSession();

        context().checking(new Expectations() { {
            allowing(mockPxtSession).setWebUserId(null);
            oneOf(mockResponse).addCookie(with(zeroMaxAgeCookieMatcher()));
        } });

        pxtSessionDelegate.invalidatePxtSession(getRequest(), getResponse());
    }
}
