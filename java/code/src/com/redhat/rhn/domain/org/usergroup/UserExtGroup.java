/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.domain.org.usergroup;

import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.manager.user.UserManager;

import java.util.HashSet;
import java.util.Set;


/**
 * UserExtGroup
 * @version $Rev$
 */
public class UserExtGroup extends ExtGroup {

    private Set<Role> roles;

    /**
     * @return Returns the roles.
     */
    public Set<Role> getRoles() {
        if (roles == null) {
            return new HashSet<Role>();
        }
        return roles;
    }

    /**
     * @param rolesIn The roles to set.
     */
    public void setRoles(Set<Role> rolesIn) {
        roles = rolesIn;
    }

    /**
     * Return roleName string
     * similar to coalesce(rhn_user.role_names(u.id), '(normal user)') as role_names
     * @return roleNames string
     */
    public String getRoleNames() {
        return UserManager.roleNames(roles);
    }
}
