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

package com.redhat.rhn.domain.org.usergroup;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.role.Role;

/**
 * Class UserGroup that reflects the DB representation of RHNUSERGROUP
 * DB table: RHNUSERGROUP
 * @version $Rev: 789 $
 */
public class UserGroupImpl extends BaseDomainHelper implements UserGroup {
    
    private Long id;
    private String name;
    private String description;
    private Long currentMembers;
    private Long orgId;
    private Role role;

    /** 
     * Getter for id 
     * {@inheritDoc}
     */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * {@inheritDoc}
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /** 
     * Getter for name 
     * {@inheritDoc}
     */
    public String getName() {
        return this.name;
    }

    /** 
     * Setter for name
     * {@inheritDoc} 
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /** 
     * Getter for description 
     * {@inheritDoc}
     */
    public String getDescription() {
        return this.description;
    }

    /** 
     * Setter for description 
     * {@inheritDoc}
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /** 
     * Getter for currentMembers 
     * {@inheritDoc}
     */
    public Long getCurrentMembers() {
        return this.currentMembers;
    }

    /** 
     * Setter for currentMembers 
     * {@inheritDoc}
     */
    public void setCurrentMembers(Long currentMembersIn) {
        this.currentMembers = currentMembersIn;
    }

    /** 
     * Getter for groupType 
     * {@inheritDoc}
     */
    public Role getRole() {
        return role;
    }

    /** 
     * Setter for groupType 
     * {@inheritDoc}
     */
    public void setRole(Role roleIn) {
        role = roleIn;
    }

    /** 
     * Getter for orgId 
     * {@inheritDoc}
     */
    public Long getOrgId() {
        return this.orgId;
    }

    /** 
     * Setter for orgId 
     * {@inheritDoc}
     */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
    }
    
    /** 
     * {@inheritDoc} 
     */
    public boolean isAssociatedRole(Role rin) {
        return (rin.equals(role));
    }
    
    /** 
     * {@inheritDoc} 
     */
    public String toString() { 
        return "ID: " + id + " name: " + name +
                  " desc: " + description + " orgid: " + orgId;
    }
}
