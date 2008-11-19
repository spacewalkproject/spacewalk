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

package com.redhat.rhn.frontend.xmlrpc.cobbler;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.RhnXmlRpcServer;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroSyncCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileSyncCommand;



/**
 * @author paji
 * CobblerHandler
 * @version $Rev$
 * @xmlrpc.namespace cobbler
 * @xmlrpc.doc Provides methods to sync cobbler
 *  profiles  and distros
 */
public class CobblerHandler extends BaseHandler {
    /**
     * This method basically synchronizes 
     * all the unsynced Kickstart Trees in the spacewalk 
     * database to cobbler. Basically useful
     * during the upgrade process
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @return Returns 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Synchronizes all the unsynced Kickstart Distrbution Trees
     *  in satellite to cobbler. Basically useful
     * during the upgrade process.
     * 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype #return_int_success()
     */
    public int syncDistributions(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        ensureSatAdmin(user);
        for (Org org : OrgFactory.lookupAllOrgs()) {
            User orgAdmin = UserFactory.findRandomOrgAdmin(org);
            syncDistroForOrg(orgAdmin);
        }
        return 1;
    }
    
    private void syncDistroForOrg(User orgAdmin) {
        ensureOrgAdmin(orgAdmin);
        CobblerDistroSyncCommand command = new 
                            CobblerDistroSyncCommand(orgAdmin);
        command.store();
    }

    
    /**
     * This method basically synchronizes 
     * all the unsynced Kickstart Trees in the spacewalk 
     * database to cobbler for a org. Basically useful
     * during the upgrade process
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @return Returns 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Synchronizes all the unsynced Kickstart Distrbution Trees
     *  in satellite to cobbler  for a org.. Basically useful
     * during the upgrade process.
     * 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype #return_int_success()
     */
    public int syncDistributionsForOrg(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        syncDistroForOrg(user);
        return 1;
    }
    
    
    /**
     * This method basically synchronizes 
     * all the unsynced Kickstart profiles in the spacewalk 
     * database to cobbler. Basically useful
     * during the upgrade process
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @return Returns 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Synchronizes all the unsynced Kickstart Profiles
     *  in satellite to cobbler. Basically useful
     * during the upgrade process.
     * 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "host",
     * "kickstart host (from cobbler settings file")
     * @xmlrpc.returntype #return_int_success()
     */
    public int syncProfiles(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        ensureSatAdmin(user);
        for (Org org : OrgFactory.lookupAllOrgs()) {
            User orgAdmin = UserFactory.findRandomOrgAdmin(org);
            syncProfilesForOrg(orgAdmin);
        }
        return 1;
    }
    
    private void syncProfilesForOrg(User user) {
        ensureOrgAdmin(user);
        CobblerProfileSyncCommand command =
                        new CobblerProfileSyncCommand(
                                RhnXmlRpcServer.getServerName(), user);
        command.store();        
    }
    
    /**
     * This method basically synchronizes 
     * all the unsynced Kickstart profiles in the spacewalk 
     * database to cobbler. Basically useful
     * during the upgrade process
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @return Returns 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Synchronizes all the unsynced Kickstart Profiles
     *  in satellite to cobbler for a org.. Basically useful
     * during the upgrade process.
     * 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "host",
     * "kickstart host (from cobbler settings file")
     * @xmlrpc.returntype #return_int_success()
     */
    public int syncProfilesForOrg(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        syncProfilesForOrg(user);
        return 1;
    }
    
}
