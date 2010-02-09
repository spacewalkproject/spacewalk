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

package com.redhat.rhn.manager.session.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.util.TimeUtils;
import com.redhat.rhn.domain.session.InvalidSessionIdException;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.session.SessionManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/** JUnit test case for the SessionManagerTest.
 * @version $Rev$
 */

public class SessionManagerTest extends RhnBaseTestCase {

    public void testLifetimeValue() throws Exception {
        long lifetime = SessionManager.lifetimeValue();
        long duration = Long.parseLong(Config.get().getString(
                ConfigDefaults.WEB_SESSION_DATABASE_LIFETIME));
        assertEquals(lifetime, duration);
    }

    public void testMakeSession() throws Exception {
        long expTime = SessionManager.lifetimeValue();
        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        WebSession s = SessionManager.makeSession(u.getId(), expTime);

        assertNotNull(s);
        assertEquals(s.getExpires(), TimeUtils.currentTimeSeconds() + expTime);
    }

    public void testGenerateSessionKey() {
        String s = "12345678";
        String k1 = "";
        String k2 = "";
        k1 = SessionManager.generateSessionKey(s);
        k2 = SessionManager.generateSessionKey(s);
        assertTrue(k1.equals(k2));
    }
    
    public void testMakeSecureParamNoTimestamp() {
        String s = "12345678";
        String param = SessionManager.makeSecureParamNoTimestamp(s);
        assertTrue("param == null", param != null);
        assertTrue("param is empty", !param.equals(""));
        assertTrue("token not found", 
              param.indexOf(SessionManager.SEC_PARM_TOKENIZER_CHAR) > 0);
        assertTrue("s != param",
              s.equals(SessionManager.extractSecureParam(param)));
        assertTrue("not a valid secure param",
              SessionManager.isValidSecureParam(param));
    }
    
    public void testMakeSecureParamTimestamped() {
        String s = "12345678";
        String param = SessionManager.makeSecureParamTimestamped(s);
        assertTrue(param != null);
        assertTrue(!param.equals(""));
        assertTrue(param.indexOf(SessionManager.SEC_PARM_TOKENIZER_CHAR) > 0);
        assertTrue(s.equals(SessionManager.extractSecureParam(param)));
        assertTrue(SessionManager.isValidSecureParam(param));
    }
    
    public void testIsValidSecureParam() {
        String s = "12345678";
        String paramNTS = SessionManager.makeSecureParamNoTimestamp(s);
        String paramTS = SessionManager.makeSecureParamTimestamped(s);
        assertTrue(SessionManager.isValidSecureParam(paramTS));
        assertTrue(SessionManager.isValidSecureParam(paramNTS));
        assertFalse(SessionManager.isValidSecureParam(s));
    }
    
    public void testExtractSecureParam() {
        String s = "12345678";
        String paramTS = SessionManager.makeSecureParamTimestamped(s);
        String paramNTS = SessionManager.makeSecureParamNoTimestamp(s);
        assertTrue(SessionManager.extractSecureParam(s).equals(""));
        assertFalse(SessionManager.extractSecureParam(paramTS).equals(""));
        assertTrue(SessionManager.extractSecureParam(paramTS).equals(s));
        assertFalse(SessionManager.extractSecureParam(paramNTS).equals(""));
        assertTrue(SessionManager.extractSecureParam(paramNTS).equals(s));
    }
    
    public void testIsPxtSessionKeyValidWhenKeyIsNull() {
        assertFalse(SessionManager.isPxtSessionKeyValid(null));
    }
    
    public void testIsPxtSessionKeyValidWhenKeyIsValid() {
        String pxtSessionKey = generatePxtSessionKey();
        
        assertTrue(SessionManager.isPxtSessionKeyValid(pxtSessionKey));
    }
    
    /**
     * This test was created for 
     * https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=206558
     */
    public void testIsPxtSessionKeyValidWhenKeyIsInvalid() {
        String pxtSessionKey = generatePxtSessionKey();
        pxtSessionKey = pxtSessionKey.replace('x', ':');
        
        assertFalse(SessionManager.isPxtSessionKeyValid(pxtSessionKey));
    }
    
    public void testIsPxtSessionKeyValidWhenSessionIdHijacked() {
        String pxtSessionKey = generatePxtSessionKey();
        String[] keyParts = pxtSessionKey.split("x");
        String sessionId = keyParts[0];
        
        sessionId = sessionId.replaceAll("2", "3");
        sessionId = sessionId.replaceAll("5", "7");
        
        pxtSessionKey = sessionId + "x" + keyParts[1];
        
        assertFalse(SessionManager.isPxtSessionKeyValid(pxtSessionKey));
    }
    
    private String generatePxtSessionKey() {
        String id = "12345678";
        String generatedKey = SessionManager.generateSessionKey(id);
        String pxtSessionKey = id + "x" + generatedKey;
        
        return pxtSessionKey;
    }

    public void testLookupByEmptyKey() {
        try {
            SessionManager.lookupByKey("");
            fail();
        }
        catch (InvalidSessionIdException e) {
            // expected
        }
    }
    
    public void testLookupByKey() {
        WebSession s = WebSessionFactory.createSession();
        verifySession(s);
        assertNotNull(s);
        WebSessionFactory.save(s);
        assertNotNull(s.getId());
        
        String key = s.getKey();
        
        WebSession s2 = SessionManager.lookupByKey(key);
        assertEquals(s, s2);
        
        String invalidKey = s.getId() + "xfoobaredkeyhash";
        try {
            s2 = SessionManager.lookupByKey(invalidKey);
        }
        catch (InvalidSessionIdException e) {
            //success
        }
        
        try {
            s2 = SessionManager.lookupByKey(null);
        }
        catch (InvalidSessionIdException e) {
            //success
        }
        
        try {
            s2 = SessionManager.lookupByKey(s.getId() + "foobaredkeyhash");
        }
        catch (InvalidSessionIdException e) {
            //success
        }   
    }
    
    private void verifySession(WebSession s) {
        assertNull(s.getId());
        assertNull(s.getUser());
        assertEquals(" ", s.getValue());
        assertNull(s.getWebUserId());
        assertEquals(0, s.getExpires());
    }
    
    public void testPurgeSession() throws Exception {
        long duration = 3600L;
        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        WebSession s = SessionManager.makeSession(u.getId(), duration);
        assertNotNull(s);
        long actualDuration = s.getExpires() - TimeUtils.currentTimeSeconds();
        
        short tolerance = 2;
        // this works because it's in the same second.
        assertTrue(actualDuration > duration - tolerance);
        assertTrue(actualDuration < duration + tolerance);
        flushAndEvict(s);
        SessionManager.purgeUserSessions(u);
        
        try {
            SessionManager.lookupByKey(s.getKey());
            fail("Lookup exception not thrown for a null key even after purge");
        }
        catch (LookupException le) {
            //Cool this means it properly threw exception...
        }

    }    
}
