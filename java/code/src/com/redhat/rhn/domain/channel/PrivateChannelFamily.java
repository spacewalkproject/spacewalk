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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * PrivateChannelFamily - Class representation of the table rhnPrivateChannelFamily.
 * @version $Rev: 1 $
 */
public class PrivateChannelFamily implements Serializable {

    private ChannelFamily channelFamily;
    private Org org;
    private Long maxMembers;
    private Long currentMembers;
    private Date created;
    private Date modified;

    /**
     * @return Returns the channelFamily.
     */
    public ChannelFamily getChannelFamily() {
        return channelFamily;
    }

    /**
     * @param channelFamilyIn The channelFamily to set.
     */
    public void setChannelFamily(ChannelFamily channelFamilyIn) {
        this.channelFamily = channelFamilyIn;
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
     * Getter for maxMembers 
     * @return Long to get
    */
    public Long getMaxMembers() {
        return this.maxMembers;
    }

    /** 
     * Setter for maxMembers 
     * @param maxMembersIn to set
    */
    public void setMaxMembers(Long maxMembersIn) {
        this.maxMembers = maxMembersIn;
    }

    /** 
     * Getter for currentMembers 
     * @return Long to get
    */
    public Long getCurrentMembers() {
        return this.currentMembers;
    }

    /** 
     * Setter for currentMembers 
     * @param currentMembersIn to set
    */
    public void setCurrentMembers(Long currentMembersIn) {
        this.currentMembers = currentMembersIn;
    }

    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /** 
     * Getter for modified 
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /** 
     * Setter for modified 
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }


    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof PrivateChannelFamily)) {
            return false;
        }
        PrivateChannelFamily castOther = (PrivateChannelFamily) other;
        return new EqualsBuilder().append(this.getChannelFamily(),
                castOther.getChannelFamily()).append(this.getOrg(), 
                        castOther.getOrg()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getChannelFamily()).append(this.getOrg())
                .toHashCode();
    }

}
