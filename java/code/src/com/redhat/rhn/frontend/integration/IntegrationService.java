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
package com.redhat.rhn.frontend.integration;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerLoginCommand;

import org.apache.commons.lang.RandomStringUtils;
import org.apache.log4j.Logger;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;


/**
 * Class for managing integration from Spacewalk to other 
 * external systems.  Examples include logic for interacting 
 * between Spacewalk and Cobbler.
 *
 * @version $Rev$
 */
public class IntegrationService {
    
    private static Logger log = Logger.getLogger(IntegrationService.class);
    // private instance of the service.
    private static IntegrationService instance = new IntegrationService();
    private ConcurrentMap<String, String> cobblerAuthTokenStore;
    private ConcurrentMap<String, String> randomTokenStore;

    private IntegrationService() {
        cobblerAuthTokenStore = new ConcurrentHashMap<String, String>();
        randomTokenStore = new ConcurrentHashMap<String, String>();
    }

    /**
     * Get the instance of this Service
     * @return IntegrationService instance.
     */
    public static IntegrationService get() {
        return instance;
    }
    
    /**
     * Get the associated cobbler xmlrpc token 
     * for the associated login.  
     * 
     * @param login to lookup Cobbler xmlrpc token
     * @return String xmlrpc token - null if not defined
     */
    public String getAuthToken(String login) {        
        String token = cobblerAuthTokenStore.get(login);
        if (token == null) {
            token = this.authorize(login);
        } 
        else {
            // Need to re-check cobbler to make sure the token
            // is still valid.  If not valid, re-auth.
            CobblerLoginCommand cmd = new CobblerLoginCommand();
            if (!cmd.checkToken(token)) {
                token = this.authorize(login);
            }
        }
        return token;
    }

    /**
     * Authorize Spacewalk to defined set of services.  If we need to
     * we can eventually make this pluggable to go through a list of 
     * things that need to setup authorization. 
     * 
     * @param username to authorize with
     * @param password to authorize with
     * @return token created during authorization
     */
    private String authorize(String login) {
        
        String passwd;
        
        //Handle the taskomatic case (Where we can't rely on the tokenStore since it's
        //  a completely different VM)
        if (login.equals(Config.get().getString(ConfigDefaults.COBBLER_AUTOMATED_USER))) {
            
            passwd = Config.get().getString(ConfigDefaults.WEB_SESSION_SECRET_1);
        }
        else {
            String md5random = SessionSwap.computeMD5Hash(
                    RandomStringUtils.random(10, SessionSwap.HEX_CHARS));
            // Store the md5random number in our map 
            // and send over the encoded version of it.  
            // On the return checkRandomToken() call
            // we will decode the encoded data to make sure it is the
            // unaltered random number.
            randomTokenStore.put(login, md5random);
            passwd  = SessionSwap.encodeData(md5random);
        }

        log.debug("Authorize called with username: " + login);
        // Get the cobbler ticket
        CobblerLoginCommand lcmd = new CobblerLoginCommand();
        String token =  lcmd.login(login, passwd);
        log.debug("Cobbler returned non-null token? :: " + (token == null));
        if (token != null) {
            this.setAuthorizationToken(login, token);
        }
        return token;
    }
    
    /**
     * Set the xmlrpc token for the associated login
     * 
     * @param login to set token for
     * @param token to set
     */
    public void setAuthorizationToken(String login, String token) {
        cobblerAuthTokenStore.put(login, token);
    }

    /**
     * Check to see if the randomized token is valid for the 
     * passed in login.
     *   
     * @param login to check token against.
     * @param encodedRandom to check if valid
     * @return boolean if valid or not.
     */
    public boolean checkRandomToken(String login, String encodedRandom) {
        
        if (login.equals(Config.get().getString(ConfigDefaults.COBBLER_AUTOMATED_USER))) {
            log.debug("checkRandomToken called with taskomatic user!");
            return encodedRandom.equals(
                    Config.get().getString(ConfigDefaults.WEB_SESSION_SECRET_1));
        }
        
        log.debug("checkRandomToken called with username: " + login);
        if (!randomTokenStore.containsKey(login)) {
            log.debug("login not stored.  invalid check!");
            return false;
        }
        String[] decodedLogin = SessionSwap.extractData(encodedRandom);
        StringBuffer buff = new StringBuffer();
        for (int i = 0; i < decodedLogin.length; i++) {
            buff.append(decodedLogin[i]);
        }
        if (randomTokenStore.containsValue(buff.toString())) {
            log.debug("encodedRandom found. valid!");
            return true;
        }
        else {
            log.debug("encodedRandom not found.  invalid!");
            return false;
        }
    }

}
