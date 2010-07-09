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
package com.redhat.rhn.frontend.servlets.test;

import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.frontend.servlets.PxtCookieManager;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateImpl;

import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.TransformerUtils;
import org.jmock.Mock;
import org.jmock.MockObjectTestCase;
import org.jmock.core.Constraint;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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

    private Mock mockRequest;
    private Mock mockResponse;
    private Mock mockPxtSession;

    private PxtSessionDelegateImplStub pxtSessionDelegate;

    private PxtCookieManager pxtCookieManager;

    /**
     * @param name test name
     */
    public PxtSessionDelegateImplTest(String name) {
        super(name);
    }

    private HttpServletRequest getRequest() {
        return (HttpServletRequest)mockRequest.proxy();
    }

    private HttpServletResponse getResponse() {
        return (HttpServletResponse)mockResponse.proxy();
    }

    private WebSession getPxtSession() {
        return (WebSession)mockPxtSession.proxy();
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
        pxtSessionDelegate = new PxtSessionDelegateImplStub();
        pxtCookieManager = new PxtCookieManager();

        mockRequest.stubs().method("getServerName").will(
                returnValue("somehost.redhat.com"));
    }

    private void setUpLoadPxtSession() {
        mockRequest.stubs().method("getAttribute").with(eq("session")).will(
                returnValue(null));

        Constraint[] setAttributeArgs = new Constraint[] {
                eq("session"),
                isA(WebSession.class)
        };

        mockRequest.expects(atLeastOnce()).method("setAttribute").with(setAttributeArgs);
    }

    public final void testLoadPxtSessionWhenPxtSessionIdIsNull() {
        setUpLoadPxtSession();

        mockRequest.stubs().method("getCookies").will(returnValue(null));

        pxtSessionDelegate.setCreatePxtSessionCallback(
                TransformerUtils.constantTransformer(getPxtSession()));

        pxtSessionDelegate.loadPxtSession(getRequest());
    }

    public final void testLoadPxtSessionWhenPxtSessionIdIsNotNull() {
        setUpLoadPxtSession();

        mockRequest.stubs().method("getCookies").will(returnValue(
                new Cookie[] {getPxtCookie()}));

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

        mockRequest.stubs().method("getCookies").will(returnValue(
                new Cookie[] {getPxtCookie()}));

        pxtSessionDelegate.setCreatePxtSessionCallback(
                TransformerUtils.constantTransformer(getPxtSession()));

        pxtSessionDelegate.loadPxtSession(getRequest());
    }

    public final void testIsPxtSessionKeyValidWhenPxtCookieNotFound() {
        mockRequest.stubs().method("getCookies").will(returnValue(null));

        assertFalse(pxtSessionDelegate.isPxtSessionKeyValid(getRequest()));
    }

    public final void testIsPxtSessionKeyVaidWhenSessionKeyInvalid() {
        mockRequest.stubs().method("getCookies").will(returnValue(
                new Cookie[] {getPxtCookieWithInvalidSessionKey()}));

        assertFalse(pxtSessionDelegate.isPxtSessionKeyValid(getRequest()));
    }

    public final void testIsPxtSessionKeyValidWhenPxtCookieFound() {
        mockRequest.stubs().method("getCookies").will(returnValue(
                new Cookie[] {getPxtCookie()}));

        assertTrue(pxtSessionDelegate.isPxtSessionKeyValid(getRequest()));
    }

    public final void testRefreshPxtSessionSetsExpires() {
        //TODO Write unit test
    }

    public final void testGetPxtSessionId() {
        Cookie[] cookies = new Cookie[] {getPxtCookie()};

        mockRequest.stubs().method("getCookies").will(returnValue(cookies));

        assertEquals(PXT_SESSION_ID, pxtSessionDelegate.getPxtSessionId(getRequest()));
    }

    public final void testGetPxtSessionIdWhenPxtCookieIsInvalid() {
        Cookie[] cookies = new Cookie[] {getPxtCookieWithInvalidSessionKey()};

        mockRequest.stubs().method("getCookies").will(returnValue(cookies));

        assertNull(pxtSessionDelegate.getPxtSessionId(getRequest()));
    }

    private void setUpInvalidatePxtSession() {
        pxtSessionDelegate.stubLoadPxtSession(true);

        mockRequest.stubs().method("getAttribute").with(eq("session")).will(
                returnValue(getPxtSession()));

        mockPxtSession.stubs().method("getId").will(returnValue(PXT_SESSION_ID));

        mockPxtSession.stubs().method("setExpires");

        mockPxtSession.stubs().method("setWebUserId");

        mockResponse.stubs().method("addCookie");

    }

    public final void testInvalidatePxtSessionSetsWebUserIdToNull() {
        setUpInvalidatePxtSession();

        mockPxtSession.expects(once()).method("setWebUserId").with(NULL);

        pxtSessionDelegate.invalidatePxtSession(getRequest(), getResponse());
    }

    public final void testInvalidatePxtSessionSavesPxtSession() {
        setUpInvalidatePxtSession();

        pxtSessionDelegate.invalidatePxtSession(getRequest(), getResponse());

        assertEquals(1, pxtSessionDelegate.getSavePxtSessionCounter());
    }

    public final void testInvalidatePxtSessionDeletesPxtCookie() {
        setUpInvalidatePxtSession();

        Constraint deletePxtCookie = new Constraint() {
            public StringBuffer describeTo(StringBuffer description) {
                return description.append("cookie ").append("max age must = 0");
            }

            public boolean eval(Object arg) {
                Cookie pxtCookie = (Cookie)arg;

                return pxtCookie.getMaxAge() == 0;
            }
        };

        mockResponse.expects(once()).method("addCookie").with(deletePxtCookie);

        pxtSessionDelegate.invalidatePxtSession(getRequest(), getResponse());
    }
}
