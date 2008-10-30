/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.manager.kickstart.cobbler.CobblerLoginCommand;

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
    private ConcurrentMap<String, String> tokenStore;

    private IntegrationService() {
        tokenStore = new ConcurrentHashMap<String, String>();
    }

    /**
     * Get the instance of this Service
     * @return IntegrationService instance.
     */
    public static IntegrationService get() {
        return instance;
    }
    
    /**
     * Authorize Spacewalk to defined set of services.  If we need to
     * we can eventually make this pluggable to go through a list of 
     * things that need to setup authorization. 
     * 
     * @param username to authorize with
     * @param password to authorize with
     */
    public void authorize(String username, String password) {
        log.debug("Authorize called with username: " + username);
        // Get the cobbler ticket
        CobblerLoginCommand lcmd = new CobblerLoginCommand(username, password);
        String token =  lcmd.login();
        log.debug("Cobbler returned non-null token? :: " + (token == null));
        this.setAuthorizationToken(username, token);
    }
    
    /**
     * Get the associated cobbler xmlrpc token 
     * for the associated login.  
     * 
     * @param login to lookup Cobbler xmlrpc token
     * @return String xmlrpc token - null if not defined
     */
    public String getAuthToken(String login) {
        return (String) tokenStore.get(login);
    }
 
    /**
     * Set the xmlrpc token for the associated login
     * 
     * @param login to set token for
     * @param token to set
     */
    public void setAuthorizationToken(String login, String token) {
        tokenStore.putIfAbsent(login, token);
    }

}
