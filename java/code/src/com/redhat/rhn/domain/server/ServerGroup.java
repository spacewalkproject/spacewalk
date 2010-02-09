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

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.manager.system.ServerGroupManager;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.List;

/**
 * Server - Class representation of the table rhnServer.
 * 
 * @version $Rev: 2143 $
 */
public class ServerGroup extends BaseDomainHelper
                                implements Identifiable {
    
    public static final long UNLIMITED = Long.MAX_VALUE;

    private Long id;
    private String name;
    private String description;
    private ServerGroupType groupType;
    private Org org;
    /** 
     * Getter for id 
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /** 
     * Getter for name 
     * @return String to get
    */
    public String getName() {
        return this.name;
    }

    /** 
     * Setter for name 
     * @param nameIn to set
    */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /** 
     * Getter for description 
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /** 
     * Setter for description 
     * @param descriptionIn to set
    */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }


    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }
    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }
  
    /**
     * @return Returns the groupType.
     */
    public ServerGroupType getGroupType() {
        return groupType;
    }
    
    /**
     * Note this is to be set by hibernate only
     * @param groupTypeIn The groupType to set.
     */
    protected void setGroupType(ServerGroupType groupTypeIn) {
        this.groupType = groupTypeIn;
    }

    /**
     * Returns the set of servers associated to the group
     * Note this is readonly set because we DONOT
     * want you to modify this set. 
     * @return a list of Servers which are members of the group.
     */    
    public List getServers() {
        return ServerGroupManager.getInstance().
                                listServers(this);
    }

    
    /**
     * Returns true if this server group is a User Managed
     * false if its Entitlement Managed.
     * @return true if its managed
     */
    public boolean isManaged() {
        return getGroupType() == null;
    }    


    /** 
     * the number of current servers
     * @return Long number for current servers
    */
    public Long getCurrentMembers() {
        return ServerGroupFactory.getCurrentMembers(this);
    }    
    
    /** 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getId())
                                    .append(getName())
                                    .append(getDescription())
                                    .append(getOrg())
                                    .append(getGroupType())
                                    .toHashCode();
    }

    /** 
     * {@inheritDoc}
     */
    public boolean equals(Object other) {
        if (!(other instanceof ServerGroup)) {
            return false;
        }
        ServerGroup castOther = (ServerGroup) other;
        return new EqualsBuilder().append(getId(), castOther.getId())
                                  .append(getName(), castOther.getName())
                                  .append(getDescription(), castOther.getDescription())
                                  .append(getOrg(), castOther.getOrg())
                                  .append(getGroupType(), castOther.getGroupType())
                                  .isEquals();
                                  
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", getId()).
                                          append("name", getName()).
                                          append("groupType", getGroupType()).
                                          toString();
    }


}
