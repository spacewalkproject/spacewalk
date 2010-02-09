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
package com.redhat.rhn.frontend.xmlrpc.auth;

import com.redhat.rhn.domain.session.InvalidSessionDurationException;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.integration.IntegrationService;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.UserLoginException;
import com.redhat.rhn.manager.session.SessionManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;

import javax.security.auth.login.LoginException;

/**
 * AuthHandler
 * Corresponds to Auth.pm in old perl code.
 * @version $Rev$
 * @xmlrpc.namespace auth
 * @xmlrpc.doc This namespace provides methods to authenticate with the system's 
 * management server.
 */
public class AuthHandler extends BaseHandler {

    private static Logger log = Logger.getLogger(AuthHandler.class);
    
    /**
     * Logout user with sessionKey
     * @param sessionKey The sessionKey for the loggedInUser
     * @return Returns 1 on success, exception otherwise.
     * 
     * @xmlrpc.doc Logout the user with the given session key.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype #return_int_success()
     */
    public int logout(String sessionKey) {
        SessionManager.killSession(sessionKey);
        return 1;
    }
    
    /**
     * Login using a username and password only. Creates a session containing the userId
     * and returns the key for the session.
     * @param username The username to check
     * @param password The password to check
     * @return Returns the key for the session created
     * @throws LoginException Throws a LoginException if the user can't be logged in.
     * 
     * @xmlrpc.doc Login using a username and password. Returns the session key
     * used by most other API methods.
     * @xmlrpc.param #param("string", "username")
     * @xmlrpc.param #param("string", "password")
     * @xmlrpc.returntype 
     *     #param("string", "sessionKey")
     */
    public String login(String username, String password) 
                      throws LoginException {
        //If we didn't get a duration value, use the one from the configs
        long duration = SessionManager.lifetimeValue();
        return login(username, password, new Integer((int)duration));
    }
    
    /**
     * Login using a username and password only. Creates a session containing the userId
     * and returns the key for the session.
     * @param username Username to check
     * @param password Password to check
     * @param durationIn The session duration
     * @return Returns the key for the session
     * @throws LoginException Throws a LoginException if the user can't be logged in.
     * 
     * @xmlrpc.doc Login using a username and password. Returns the session key
     * used by other methods.
     * @xmlrpc.param #param("string", "username")
     * @xmlrpc.param #param("string", "password")
     * @xmlrpc.param #param_desc("int", "duration", "Length of session.")
     * @xmlrpc.returntype 
     *     #param("string", "sessionKey")
     */
    public String login(String username, String password, Integer durationIn) 
                      throws LoginException {
        //Log in the user (handles authentication and active/disabled logic)
        User user = null;
        try {
            user = UserManager.loginUser(username, password);
        }
        catch (LoginException e) {
            // Convert to fault exception
            throw new UserLoginException(e.getMessage());
        }
        
        long duration = getDuration(durationIn);
        //Create a new session with the user
        WebSession session = SessionManager.makeSession(user.getId(), duration);
        return session.getKey();
    }
    
    /**
     * This method is used to see if an external service is handing back an authorized
     * token indicating that the server trusts the requester in some manner.  This is 
     * currently used in the integration with Cobbler; however, it may be used for other
     * services in the future.  
     * 
     * @param login login of the user to check against token
     * @param token token to validate
     * @return 1 if the token is valid with this username, 0 otherwise.
     * 
     * @xmlrpc.ignore Since this API is for internal integration between services and
     * is not useful to external users of the API, the typical XMLRPC API documentation
     * is not being included.
     */
    public int checkAuthToken(String login, String token) {
        int retval = 0;
        
        boolean valid = IntegrationService.get().
            checkRandomToken(login, token);
        if (valid) {
            retval = 1; 
        }
        else {
            retval = 0;
        }
        log.debug("checkAuthToken :: Returning: " + retval);
        return retval;
    }

    /**
     * Takes in a String duration value from the user, checks it, and returns the 
     * long value or throws a runtime exception.
     * @param durationIn The duration to check
     * @return Returns the long value of durationIn
     */
    private long getDuration(Integer durationIn) {

        //parse into long
        long expires = durationIn.longValue();
        //Get the default session lifetime from the configs
        long dbLifetime = SessionManager.lifetimeValue();
        
        //Make sure the durationIn isn't greater than what the database allows
        if (expires > dbLifetime) {
            throw new InvalidSessionDurationException("The session duration cannot exceed" +
                          " the maximum duration allowed by the database (currently " + 
                          dbLifetime + ")");
        }
        
        //If we made it this far, expires is valid
        return expires;
    }
}
