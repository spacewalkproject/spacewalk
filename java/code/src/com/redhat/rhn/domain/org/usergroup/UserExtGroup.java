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

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.role.Role;

import java.util.HashSet;
import java.util.Set;


/**
 * UserExtGroup
 * @version $Rev$
 */
public class UserExtGroup extends BaseDomainHelper implements Comparable {

    private Long id;
    private String label;

    private Set<Role> roles;

    /**
     *
     */
    public UserExtGroup() {
        // TODO Auto-generated constructor stub
    }

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

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
        String roleNames = null;
        for (Role role : roles) {
            roleNames = (roleNames == null) ? role.getName() :
                roleNames + ", " + role.getName();
        }
        if (roleNames == null) {
            return "(normal user)";
        }
        return roleNames;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(Object objectIn) {
        if (objectIn == null || objectIn instanceof UserExtGroup) {
            return 0;
        }
        return id.compareTo(((UserExtGroup) objectIn).getId());
    }
}
