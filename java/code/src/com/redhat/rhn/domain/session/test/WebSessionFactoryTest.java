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

package com.redhat.rhn.domain.session.test;

import com.redhat.rhn.common.util.TimeUtils;
import com.redhat.rhn.domain.session.InvalidSessionIdException;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.session.SessionManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestCaseHelper;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.StringUtils;

/** JUnit test case for the Session class.
 * @version $Rev$
 */

public class WebSessionFactoryTest extends RhnBaseTestCase {

    // This is the number of milliseconds that
    // we use in this test to determine timeouts
    // If these testcases are being ran over a slow link
    // (MTV -> RDU) they can fail and this time value
    // can be tweaked accordingly.
    private static final int EXP_TIME = 5000;


    private void verifySession(WebSession s) {
        assertNull(s.getId());
        assertNull(s.getUser());
        assertEquals(" ", s.getValue());
        assertNull(s.getWebUserId());
        assertEquals(0, s.getExpires());
    }

    public void testId() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        assertNull(s.getId());
        WebSessionFactory.save(s);
        assertNotNull(s.getId());

    }

    public void testCreateSession() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);
    }

    public void testExpired() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);

        long currTime = -500;
        s.setExpires(currTime - EXP_TIME);
        assertTrue(s.isExpired());
    }

    public void testNotExpired() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);

        long currTime = TimeUtils.currentTimeSeconds();
        s.setExpires(currTime + EXP_TIME);
        assertFalse(s.isExpired());
    }

    public void testSetUserId() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);

        Long userId = UserTestUtils.createUser("sessionTest1", "SessionTestOrg");
        s.setWebUserId(userId);
        User u = s.getUser();
        assertNotNull(u);
        assertEquals(userId, u.getId());
        Long userId2 = UserTestUtils.createUser("sessionTest2", "SessionTestOrg");
        assertFalse(userId.equals(userId2));
        try {
            s.setWebUserId(userId2);
        }
        catch (IllegalArgumentException iae) {
            fail("setWebUserId should not throw an IllegalArgumentException");
        }
        s.setWebUserId(null);
        assertNull(s.getUser());
    }


    /**
     * Not ready for use yet.
     */
    public void xxxxUserOnSession() {
        WebSession s = WebSessionFactory.createSession();
        WebSessionFactory.save(s);
        s = (WebSession) reload(s);

        Long lastId = null;
        for (int i = 0; i < 50; i++) {
            Long userId = UserTestUtils.createUser("st" +
                    Math.random() + System.currentTimeMillis(), "SessionTestOrg");
            assertFalse(userId.equals(lastId));
            s.setWebUserId(userId);
            User u = s.getUser();
            assertNotNull(u);
            assertEquals(userId, u.getId());
            lastId = userId;
            // s.setWebUserId(null);
            WebSessionFactory.save(s);
            // flushAndEvict(s);
            s = (WebSession) reload(s);
            TestCaseHelper.tearDownHelper();
        }
    }

    public void testUnifiedCreate() throws Exception {
        User u = UserTestUtils.findNewUser("sessionTest", "SessionTestOrg");
        long expTime = EXP_TIME;
        WebSession s = SessionManager.makeSession(u.getId(), expTime);

        WebSession s2 = WebSessionFactory.lookupById(s.getId());
        assertNotNull(s2);
        assertEquals(s.getExpires(), s2.getExpires());
        assertEquals(u.getId(), s2.getUser().getId());
    }

    public void testCommitAndRetreive() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);
        Long userId = UserTestUtils.createUser("sessionTest", "SessionTestOrg");

        long expTime = TimeUtils.currentTimeSeconds() + EXP_TIME;
        s.setExpires(expTime);
        s.setWebUserId(userId);

        WebSessionFactory.save(s);

        WebSession s2 = WebSessionFactory.lookupById(s.getId());
        assertNotNull(s2);
        assertEquals(expTime, s2.getExpires());
        assertEquals(userId, s2.getUser().getId());
    }

    public void testCommitAndRetreiveNullUser() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);

        long expTime = TimeUtils.currentTimeSeconds() + EXP_TIME;
        s.setExpires(expTime);
        s.setWebUserId(null);

        WebSessionFactory.save(s);

        WebSession s2 = WebSessionFactory.lookupById(s.getId());
        assertNotNull(s2);
        assertNull(s2.getWebUserId());
        assertEquals(expTime, s2.getExpires());
    }

    public void testGetKey() {
        WebSession s = WebSessionFactory.createSession();
        //Try with an invalid session id (null)
        try {
            s.getKey();
            fail();
        }
        catch (InvalidSessionIdException e) {
            //Success!!!
        }
        long expTime = TimeUtils.currentTimeSeconds() + EXP_TIME;
        s.setExpires(expTime);
        s.setWebUserId(null);

        WebSessionFactory.save(s);

        //Make sure we get a key
        assertNotNull(s.getKey());
        String id = s.getKey().substring(0, s.getKey().indexOf('x'));
        assertTrue(StringUtils.isNumeric(id));
    }

    public void testLookupExpired() throws Exception {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);

        Long userId = UserTestUtils.createUser("sessionTest", "SessionTestOrg");
        long expTime = TimeUtils.currentTimeSeconds() - EXP_TIME;
        s.setExpires(expTime);
        s.setWebUserId(userId);

        WebSessionFactory.save(s);

        WebSession s2 = WebSessionFactory.lookupById(s.getId());
        assertNotNull(s2);
        assertNotNull(s2.getWebUserId());
        assertEquals(expTime, s2.getExpires());
    }

}
