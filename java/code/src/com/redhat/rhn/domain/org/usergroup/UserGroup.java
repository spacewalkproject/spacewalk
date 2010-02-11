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

import com.redhat.rhn.domain.role.Role;

import java.util.Date;

/**
 * Class UserGroup that reflects the DB representation of RHNUSERGROUP
 * This class and package are only intended to be used internally by the 
 * parent of this package, com.redhat.rhn.domain.org
 *
 * DB table: RHNUSERGROUP
 * @version $Rev: 714 $
 */
public interface UserGroup {

    /** 
     * Getter for id 
     * @return id
     */
    Long getId();

    /** 
     * Setter for id 
     * @param idIn New value for id
     */
    void setId(Long idIn);

    /** 
     * Getter for name 
     * @return name
     */
    String getName();

    /** 
     * Setter for name 
     * @param nameIn New value for name
     */
    void setName(String nameIn);

    /** 
     * Getter for description 
     * @return description
     */
    String getDescription();

    /** 
     * Setter for description 
     * @param descriptionIn New value for description
     */
    void setDescription(String descriptionIn);

    /** 
     * Getter for currentMembers 
     * @return currentMembers
     */
    Long getCurrentMembers();

    /** 
     * Setter for currentMembers 
     * @param currentMembersIn New value for currentMembers
     */
    void setCurrentMembers(Long currentMembersIn);

    /** 
     * Getter for role 
     * @return role
     */
    Role getRole();

    /** 
     * Setter for role 
     * @param roleIn New value for role
     */
    void setRole(Role roleIn);

    /** 
     * Getter for orgId 
     * @return orgId
     */
    Long getOrgId();

    /** 
     * Setter for orgId 
     * @param orgIdIn New value for orgId
     */
    void setOrgId(Long orgIdIn);

    /** 
     * Getter for created 
     * @return created
     */
    Date getCreated();

    /** 
     * Setter for created 
     * @param createdIn New value for created
     */
    void setCreated(Date createdIn);

    /** 
     * Getter for modified
     * @return modified
     */
    Date getModified();

    /** 
     * Setter for modified 
     * @param modifiedIn New value for modified
     */
    void setModified(Date modifiedIn);
    
    /** 
     * Determine if the given Role is associated with this UserGroup
     * @param rin Role to test
     * @return true if rin is an associated role
     */
    boolean isAssociatedRole(Role rin);
    
   
}
