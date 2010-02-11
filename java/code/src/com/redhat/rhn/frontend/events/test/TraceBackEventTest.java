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

package com.redhat.rhn.frontend.events.test;

import com.redhat.rhn.common.messaging.Mail;
import com.redhat.rhn.common.messaging.test.MockMail;
import com.redhat.rhn.frontend.events.TraceBackAction;
import com.redhat.rhn.frontend.events.TraceBackEvent;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import com.mockobjects.servlet.MockHttpServletRequest;
import com.mockobjects.servlet.MockHttpSession;

import java.util.Enumeration;
import java.util.Vector;

/**
 * Test for {@link TraceBackEvent}.
 * @version $Rev$
 */

public class TraceBackEventTest extends RhnBaseTestCase {
    
    private static final String MSG_OUTER_EXC = "outer-exception";
    private static final String MSG_INNER_EXC = "inner-exception";
    
    private MockMail mailer;
    
    public void setUp() {
        mailer = new MockMail();
    }
    
    /**
     * test that makes sure we can instantiate the service
     */
    public void testToText() {
        TraceBackEvent evt = createTestEvent();
        String eventText = evt.toText();
        assertNotNull(eventText);
        assertContains(eventText, MSG_INNER_EXC);
        assertContains(eventText, MSG_OUTER_EXC);
        assertContains(eventText, "Request");
        assertContains(eventText, "User");
        assertContains(eventText, "Exception");
        //with null exception
        evt.setException(null);
        eventText = evt.toText();
        assertContains(eventText, "Request");
        assertContains(eventText, "User");
        assertContains(eventText, "Exception");
    }
    
    public void testProtectPassword() {
        TraceBackEvent evt = createTestEventWithValue("password", "no-secret");
        mailer.setExpectedSendCount(1);  
        TraceBackAction action = new TraceBackAction() {
            protected Mail getMail() {
                return mailer;
            }
        };
        action.execute(evt);
        mailer.verify();
        String body = mailer.getBody();        
        assertTrue(body.indexOf("password") > 0);
        assertTrue(body.indexOf("password: " + evt.getHashMarks()) > 0);                
    }
    
    public void testNoPassword() {
        TraceBackEvent evt = createTestEventWithValue("passsword", "no-secret");
        mailer.setExpectedSendCount(1);  
        TraceBackAction action = new TraceBackAction() {
            protected Mail getMail() {
                return mailer;
            }
        };
        action.execute(evt);
        mailer.verify();
        String body = mailer.getBody();                
        assertFalse(body.indexOf("passsword: " + evt.getHashMarks()) > 0);
    }
    
    public void testToTextWithNulls() {
        TraceBackEvent evt = new TraceBackEvent();
        evt.setRequest(null);
        evt.setUser(null);
        evt.setException(new RuntimeException(MSG_OUTER_EXC));
        String eventText = evt.toText();
        assertContains(eventText, MSG_OUTER_EXC);
        assertContains(eventText, "No User logged in");
        assertContains(eventText, "No request information");
    }

    public void testTraceBackAction() {
        TraceBackEvent evt = createTestEvent();
        mailer.setExpectedSendCount(1);
        TraceBackAction action = new TraceBackAction() {
            protected Mail getMail() {
                return mailer;
            }
        };
        action.execute(evt);
        mailer.verify();
        assertTrue(mailer.getSubject().indexOf("WEB TRACEBACK from ") == 0);
        assertTrue(mailer.getBody().indexOf("The following exception occurred") == 0);
        assertTrue(mailer.getBody().indexOf("Request:") > 0);
        assertTrue(mailer.getBody().indexOf("User Information:") > 0);
        assertTrue(mailer.getBody().indexOf("Exception:") > 0);
    }

    private TraceBackEvent createTestEvent() {
        TraceBackEvent evt = new TraceBackEvent();
        // In the implementation we use getHeaderNames so we override it with 
        // one that returns an empty implementation.
        MockHttpServletRequest request = new MockHttpServletRequest() {
            public Enumeration getHeaderNames() {
                return new Vector().elements();     
            }
        };
        request.setSession(new MockHttpSession());
        request.setupGetRequestURI("http://localhost:8080");
        request.setupGetMethod("POST");
        Vector v = new Vector();
        v.add("someparam");
        request.setupAddParameter("someparam", "somevalue");
        request.setupGetParameterNames(v.elements());
        evt.setUser(UserTestUtils.findNewUser("testUser", "testOrg"));
        evt.setRequest(request);
        Throwable e = new RuntimeException(MSG_OUTER_EXC);
        e.initCause(new RuntimeException(MSG_INNER_EXC));
        evt.setException(e);
        return evt;    
    }
    
    private TraceBackEvent createTestEventWithValue(String paramIn, String valueIn) {
        TraceBackEvent evt = new TraceBackEvent();
        // In the implementation we use getHeaderNames so we override it with 
        // one that returns an empty implementation.
        MockHttpServletRequest request = new MockHttpServletRequest() {
            public Enumeration getHeaderNames() {
                return new Vector().elements();     
            }
        };
        request.setSession(new MockHttpSession());
        request.setupGetRequestURI("http://localhost:8080");
        request.setupGetMethod("POST");
        Vector v = new Vector();
        v.add(paramIn);
        request.setupAddParameter(paramIn, valueIn);
        request.setupGetParameterNames(v.elements());
        evt.setUser(UserTestUtils.findNewUser("testUser", "testOrg"));
        evt.setRequest(request);
        Throwable e = new RuntimeException(MSG_OUTER_EXC);
        e.initCause(new RuntimeException(MSG_INNER_EXC));
        evt.setException(e);
        return evt;    
    }

}
