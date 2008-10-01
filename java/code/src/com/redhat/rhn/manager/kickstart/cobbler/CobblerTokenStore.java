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
package com.redhat.rhn.manager.kickstart.cobbler;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;


/**
 * Class that has an in memory ConcurrentMap of logins -> cobbler xmlrpc tokens
 * @version $Rev$
 */
public class CobblerTokenStore {

    // private instance of the service.
    private static CobblerTokenStore instance = new CobblerTokenStore();
    private ConcurrentMap<String, String> tokenStore;

    private CobblerTokenStore() {
        tokenStore = new ConcurrentHashMap<String, String>();
    }
    
    /**
     * Get the running instance of the CobblerTokenStore
     * 
     * @return The CobblerTokenStore singleton
     */
    public static CobblerTokenStore get() {
        return instance;
    }

    
    /**
     * Get the associated cobbler xmlrpc token 
     * for the associated login.  
     * 
     * @param login to lookup Cobbler xmlrpc token
     * @return String xmlrpc token - null if not defined
     */
    public String getToken(String login) {
        return (String) tokenStore.get(login);
    }
 
    /**
     * Set the xmlrpc token for the associated login
     * 
     * @param login to set token for
     * @param token to set
     */
    public void setToken(String login, String token) {
        tokenStore.putIfAbsent(login, token);
    }
}
