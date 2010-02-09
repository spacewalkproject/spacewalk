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
package com.redhat.rhn.manager.session;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.security.HMAC;
import com.redhat.rhn.common.util.TimeUtils;
import com.redhat.rhn.domain.session.InvalidSessionIdException;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.BaseManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Calendar;

/**
 * SessionManager is the helper class used to fetch configuration 
 * about com.redhat.rhn.domain.session.Session objects.
 * @version $Rev$ 
 */
public class SessionManager extends BaseManager {
    
    /**
     * Logger for this class
     */
    private static Logger logger = 
        Logger.getLogger(SessionManager.class);
    
    public static final String SEC_PARM_TOKENIZER_CHAR = ":";
    // Timeout value 900,000 = 15 min
    public static final long TIMEOUT_VAL = 900000;
    
    protected SessionManager() {
    }
    
    /**
     * Return the lifetime in seconds of the Session.  This differs
     * from the timeoutValue() above which is the time from now
     * the Session should finish. It's a subtle difference but
     * needed since the PXTSession table expects the time the session
     * should expire while the cookie in Tomcat expects the lifetime
     * of the session in seconds, it will calculate the time for you.
     * @return the lifetime in seconds of the Session.
     */
    public static long lifetimeValue() {
        return Long.parseLong(Config.get().getString(ConfigDefaults.
                WEB_SESSION_DATABASE_LIFETIME));
    }

    /**
     * Create a new Session from scratch with the specified attributes.
     * This session will already be in the database, and will thus have
     * a session ID.
     * @param uid User Id associated with this WebSession
     * @param duration duration of WebSession, in ms.
     * @return the Session created
     */
    public static WebSession makeSession(Long uid, long duration) {
        WebSession s = WebSessionFactory.createSession();
        if (uid != null) {
            s.setWebUserId(uid);
        }
        else {
            s.setWebUserId(null);
        }

        s.setExpires(TimeUtils.currentTimeSeconds() + duration);
        WebSessionFactory.save(s);
        return s;
    }
    
    /**
     * Removes the given session.
     * @param s WebSession to remove.
     * @return number of sessions removed (typically 1 or 0).
     */
    public static int removeSession(WebSession s) {
        return WebSessionFactory.remove(s);
    }

    /**
     * Returns the session identified by sessionKey
     * @param sessionKey The key for the session that is requested
     * @return Returns the WebSession identified by the sessionKey
     */
    public static WebSession loadSession(String sessionKey) {
        return SessionManager.lookupByKey(sessionKey);
    }
    
    /**
     * Removes the session specified by sessionKey from the database.
     * @param sessionKey Key for the session you want to remove.
     */
    public static void killSession(String sessionKey) {
        WebSession session = loadSession(sessionKey);
        removeSession(session);
    }
    
    /**
     * Generates a session key for usage in passing sensitive
     * url based parameters around in a safe way.
     * 
     * @param data String data to generate key on
     * @return String MD5 hash (with "salt") of passed in data.
     */
    public static String generateSessionKey(String data) {
        Config c = Config.get();
        MessageDigest msgDigest = null;

        try {
            msgDigest = MessageDigest.getInstance("MD5");
        }
        catch (NoSuchAlgorithmException nsae) {
            // this really shouldn't happen.  really. 
            throw new IllegalArgumentException("Unable to instantiate MD5 " +
                                               "MessageDigest object");
        }

        msgDigest.update(c.getString(ConfigDefaults.WEB_SESSION_SECRET_1).getBytes());
        msgDigest.update(":".getBytes());
        msgDigest.update(c.getString(ConfigDefaults.WEB_SESSION_SECRET_2).getBytes());
        msgDigest.update(":".getBytes());
        msgDigest.update(data.getBytes());
        msgDigest.update(":".getBytes());
        msgDigest.update(c.getString(ConfigDefaults.WEB_SESSION_SECRET_3).getBytes());
        msgDigest.update(":".getBytes());
        msgDigest.update(c.getString(ConfigDefaults.WEB_SESSION_SECRET_4).getBytes());

        return HMAC.byteArrayToHex(msgDigest.digest());
    }
    
    /**
     * Create a secure param string without timestamp
     * 
     * @param data param to be secured
     * @return String secure param string (no timestamp)
     */
    public static String makeSecureParamNoTimestamp(String data) {
        String secparm = "";
        if (data != null) {
            secparm = data +
            SEC_PARM_TOKENIZER_CHAR +
            generateSessionKey(data);
        }
        return secparm;
    }
    
    /**
     * Create a secure param string with a timestamp for the current time.
     * 
     * @param data param to be secured.
     * @return String secure param string (timestamped)
     */
    public static String makeSecureParamTimestamped(String data) {
        String secparm = "";
        if (data != null) {
            secparm = data +
                SEC_PARM_TOKENIZER_CHAR +
                Calendar.getInstance().getTimeInMillis();
            secparm = secparm +
                SEC_PARM_TOKENIZER_CHAR +
                generateSessionKey(secparm);
        }
        return secparm;
    }
    
    /**
     * Determine if this is a secure param as created by the other
     * methods on this class. The string parameter "data" should
     * be of the form <param>:<encoded> or <param>:<timestamp>:<encoded>.
     * If it is of the 1st form, then the <param> value is re-encoded
     * and it is compared to the <encoded> value. If it is of the 2nd
     * form, then first the timeout value is compared against the
     * <timestamp> value. If that is in range, then the <param>:<timestamp>
     * combined value is re-encoded and compared against the <encoded>
     * value.
     * 
     * @param data potentially secure param string
     * @return boolean true if it is, otherwise false
     */
    public static boolean isValidSecureParam(String data) {
        if (logger.isDebugEnabled()) {
            logger.debug("isValidSecureParam(String data=" + 
                    data + ") - start");
        }

        if (data != null && !data.equals("") &&
                data.indexOf(SEC_PARM_TOKENIZER_CHAR) > 0) {
            String[] vals = StringUtils.split(data, SEC_PARM_TOKENIZER_CHAR);
            if (isNonTimestampedParamString(vals)) {
                boolean returnboolean = isValidNonTimestampedParamString(vals);
                if (logger.isDebugEnabled()) {
                    logger.debug("isValidSecureParam(String)" +
                            " - end 1 - return value=" + returnboolean);
                }
                return returnboolean;
            }
            else if (isTimestampedParamString(vals)) {
                boolean returnboolean = isValidTimestampedParamString(vals);
                if (logger.isDebugEnabled()) {
                    logger.debug("isValidSecureParam(String) - end 2 - return value=" + 
                            returnboolean);
                }
                return returnboolean;
            }
        }
        

        if (logger.isDebugEnabled()) {
            logger.debug("isValidSecureParam(String) - end 3 - return value=" + false);
        }
        return false;
    }
    
    /**
     * If this is a valid secure param string, then extract the secure
     * param and return it. Otherwise return an empty string.
     * 
     * @param data secure param string
     * @return String secure param or empty string
     */
    public static String extractSecureParam(String data) {
        if (logger.isDebugEnabled()) {
            logger.debug("extractSecureParam(String data=" + 
                    data + ") - start");
        }

        String parm = "";
        
        if (isValidSecureParam(data)) {
            parm = data.substring(0, data.indexOf(SEC_PARM_TOKENIZER_CHAR));
        }
        

        if (logger.isDebugEnabled()) {
            logger.debug("extractSecureParam(String) - end - return value=" + parm);
        }
        return parm;
    }
    
    private static boolean isTimestampedParamString(String[] vals) {
        if (logger.isDebugEnabled()) {
            logger.debug("isTimestampedParamString(String[] vals=" + 
                    vals + ") - start");
        }

        boolean returnboolean = vals.length == 3;
        if (logger.isDebugEnabled()) {
            logger.debug("isTimestampedParamString(String[]) - end - return value=" + 
                    returnboolean);
        }
        return returnboolean;
    }
    
    private static boolean isNonTimestampedParamString(String[] vals) {
        if (logger.isDebugEnabled()) {
            logger.debug("isNonTimestampedParamString(String[] vals=" + vals + ") - start");
        }

        boolean returnboolean = vals.length == 2;
        if (logger.isDebugEnabled()) {
            logger.debug("isNonTimestampedParamString(String[]) - end - return value=" + 
                    returnboolean);
        }
        return returnboolean;
    }
    
    private static boolean isValidTimestampedParamString(String[] vals) {
        if (logger.isDebugEnabled()) {
            logger.debug("isValidTimestampedParamString(String[] vals=" + 
                    vals + ") - start");
        }

        String newEncoded = generateSessionKey(vals[0] +
                                               SEC_PARM_TOKENIZER_CHAR + vals[1]);
        long currTime = Calendar.getInstance().getTimeInMillis();
        long timeStamped = Long.parseLong(vals[1]);
        if ((currTime - timeStamped) <= TIMEOUT_VAL &&
                newEncoded.equals(vals[2])) {
            if (logger.isDebugEnabled()) {
                logger.debug("isValidTimestampedParamString(String[])" +
                        " - end 1 - return value=" + true);
            }
            return true;
        }

        if (logger.isDebugEnabled()) {
            logger.debug("isValidTimestampedParamString(String[])" +
                            " - end 2 - return value=" + false);
        }
        return false;
    }
    
    private static boolean isValidNonTimestampedParamString(String[] vals) {
        if (logger.isDebugEnabled()) {
            logger.debug("isValidNonTimestampedParamString(String[] vals=" + 
                    vals + ") - start");
        }

        String newEncoded = generateSessionKey(vals[0]);
        if (newEncoded.equals(vals[1])) {
            if (logger.isDebugEnabled()) {
                logger.debug("isValidNonTimestampedParamString(String[])" +
                            " - end 1 - return value=" + true);
            }
            return true;
        }

        if (logger.isDebugEnabled()) {
            logger.debug("isValidNonTimestampedParamString(String[])" +
                    " - end -  2 return value=" + false);
        }
        return false;
    }
    
    /**
     * Verifies that the specified string is a valid pxt session key.
     * 
     * @param key The session key to be validated
     * 
     * @return <code>true</code> if the key is valid. Note that <code>null</code> is
     * acceptable input and will result in <code>false</code> being returned.
     */
    public static boolean isPxtSessionKeyValid(String key) {
        String[] data = StringUtils.split(key, 'x');
    
        if (data != null && data.length == 2) {
            String recomputedkey = generateSessionKey(data[0]);
            logger.debug("recomputed [" + recomputedkey +
                      "] cookiekey [" + data[1] + "]");
            return recomputedkey.equals(data[1]);
        }
    
        return false;
    }

    /**
     * Lookup a Session by it's key
     * @param key The key containing the session id and hash
     * @return Returns the session if the key is valid.
     */
    public static WebSession lookupByKey(String key) {
        //Make sure we didn't get null for a key
        if (key == null || key.equals("")) {
            throw new InvalidSessionIdException("Session key cannot be empty null.");
        }
        
        //Get the id
        String[] keyParts = StringUtils.split(key, 'x');
    
        //make sure the id is numeric and can be made into a Long
        if (!StringUtils.isNumeric(keyParts[0])) {
            throw new InvalidSessionIdException("Session id: " + keyParts[0] + 
                          " is not valid. Session ids must be numeric.");
        }
        
        //Load the session
        Long sessionId = new Long(keyParts[0]);
        WebSession session = WebSessionFactory.lookupById(sessionId);
        
        //Make sure we found a session
        if (session == null) {
            throw new LookupException("Could not find session with id: " + sessionId);
        }
        
        //Verify the key
        if (!isPxtSessionKeyValid(key)) {
            throw new InvalidSessionIdException("Session id: " + sessionId +
                           " is not valid.");
        }
        
        //If we made it this far, the key was ok and the sesion valid.
        return session;
    }
    
    /**
     * Removes all the sessions of a user. This action is useful
     * especially when we disable/deactivate a user. We donot want
     * a deactivated user's sessions to be alive..  
     * @param user the user whose sessions are to be purged.
     */
    public static void purgeUserSessions(User user) {
        WebSessionFactory.purgeUserSessions(user);
    }    
}

