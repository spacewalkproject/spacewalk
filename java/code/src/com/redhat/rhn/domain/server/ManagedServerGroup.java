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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.system.ServerGroupManager;

import java.util.HashSet;
import java.util.Set;


/**
 * This class represents the User Managed Server Groups
 * i.e. the types 
 * @version $Rev$
 */
public class ManagedServerGroup extends ServerGroup {
    private Set associatedAdmins = new HashSet();
    /** 
     * returns the set of 'non-org-admin' users that have been 
     * subscribed to this ServerGroup 
     * Note: since ORG ADMINS are subscribed by default this 
     * list does not include that.
     * @return a set of users
     */
    protected Set getAssociatedAdmins() {
        return associatedAdmins;
    }
    
    /** 
     * returns the set of 'non-org-admin' users that are 
     * associated to this ServerGroup 
     * Note: since ORG ADMINS are subscribed by default this 
     * list does not include that.
     * @param user needed for authentication
     * @return a set of users
     */
    public Set getAssociatedAdminsFor(User user) {
        ServerGroupManager.getInstance().
                validateAdminCredentials(user);
        return getAssociatedAdmins();
    }
    
    /**
     * sets admins
     * @param newUsers the associated users of the group
     */
    protected void setAssociatedAdmins(Set newUsers) {        
        this.associatedAdmins = newUsers;
    }    
    
    /**
     * returns true if this is user managed, false otherwise.
     * @return true if this is user managed, false otherwise.
     */
    public boolean isUserManaged() {
        return true;
    }    
}
