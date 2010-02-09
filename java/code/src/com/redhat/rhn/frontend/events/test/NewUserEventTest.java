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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.events.NewUserAction;
import com.redhat.rhn.frontend.events.NewUserEvent;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import com.mockobjects.servlet.MockHttpServletRequest;
import com.mockobjects.servlet.MockHttpSession;

import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Vector;

/**
 * Test for NewUserEvent
 * @version $Rev: 59477 $
 */

public class NewUserEventTest extends RhnBaseTestCase {
    
    private MockMail mailer;
    
    public void setUp() {
        mailer = new MockMail();
    }
    
    /**
     * test that makes sure we can instantiate the service
     */
    public void testToText() {
        NewUserEvent evt = createTestEvent();
        String eventText = evt.toText();
        assertNotNull(eventText);
        assertContains(eventText, "A Red Hat login has been created for you");
        assertContains(eventText, 
                "Red Hat login, in combination with an active Red Hat subscription,");
        assertContains(eventText, "e-mail: redhatJavaTest@redhat.com");
        
    }

    public void testAction() {
        NewUserEvent evt = createTestEvent();
        mailer.setExpectedSendCount(2);
        NewUserAction action = new NewUserAction() {
            protected Mail getMail() {
                return mailer;
            }
        };
        action.execute(evt);
        mailer.verify();
        assertContains(mailer.getSubject(), "Spacewalk User Created: testUser");
        assertContains(mailer.getBody(), 
                "someserver.rhndev.redhat.com/rhn/users/ActiveList.do");

        assertTrue(mailer.getBody().contains("Your Spacewalk login:         testUser") ||
                   mailer.getBody().contains("Your RHN login:         testUser"));
        assertTrue(mailer.getBody().contains("Your Spacewalk email address: " +
                    "redhatJavaTest@redhat.com") ||
                   mailer.getBody().contains("Your RHN email address: " +
                "redhatJavaTest@redhat.com"));
    }

    private NewUserEvent createTestEvent() {
        NewUserEvent evt = new NewUserEvent();
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
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        
        evt.setUser(usr);
        evt.setDomain("someserver.rhndev.redhat.com");
        evt.setAdmins(createAdmins());
        evt.setRequest(request);
        return evt;    
    }

    private List<User> createAdmins() {
        User adminOne = UserTestUtils.findNewUser("testUserOne", "testOrgOne", true);
        User adminTwo = UserTestUtils.findNewUser("testUserTwo", "testOrgTwo", true); 
        List<User> admins = new ArrayList<User>();
        admins.add(adminOne);
        admins.add(adminTwo);
        return admins;
    }

}
