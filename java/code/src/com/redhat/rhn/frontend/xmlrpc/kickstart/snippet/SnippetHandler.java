/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.kickstart.snippet;


import com.redhat.rhn.domain.kickstart.cobbler.CobblerSnippet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSnippetLister;

import java.util.List;


/**
 * KickstartSnippetHandler
 * @xmlrpc.namespace kickstart.snippet
 * @xmlrpc.doc Provides methods to create kickstart files
 * @version $Rev$
 */
public class SnippetHandler extends BaseHandler {

    
    private void verifyKSAdmin(User user) {
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionCheckFailureException(RoleFactory.CONFIG_ADMIN);
        }
    }
    
    /**
     * list all cobbler snippets for a user.  Includes default and custom snippets
     * @param sessionKey The sessionKey containing the logged in user
     * @return List of cobbler snippet objects
     * 
     * @xmlrpc.doc List all cobbler snippets for the logged in user
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *          #array()
     *            $SnippetSerializer
     *          #array_end()
     */
    public List<CobblerSnippet> listAll(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        verifyKSAdmin(loggedInUser);
        return CobblerSnippetLister.getInstance().list(loggedInUser);
    }
    
    /**
     * list custom cobbler snippets for a user.  
     * @param sessionKey The sessionKey containing the logged in user
     * @return List of cobbler snippet objects
     * 
     * @xmlrpc.doc List only custom snippets for the logged in user.
     *    These snipppets are editable.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *          #array()
     *            $SnippetSerializer
     *          #array_end()
     */
    public List<CobblerSnippet> listCustom(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        verifyKSAdmin(loggedInUser);
        return CobblerSnippetLister.getInstance().listCustom(loggedInUser);
    }

    /**
     * list all pre-made default cobbler snippets for a user. 
     * @param sessionKey The sessionKey containing the logged in user
     * @return List of cobbler snippet objects
     * 
     * @xmlrpc.doc List only pre-made default snippets for the logged in user.
     *    These snipppets are not editable.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *          #array()
     *            $SnippetSerializer
     *          #array_end()
     */
    public List<CobblerSnippet> listDefault(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        verifyKSAdmin(loggedInUser);
        return CobblerSnippetLister.getInstance().listDefault(loggedInUser);
    }
 
}
