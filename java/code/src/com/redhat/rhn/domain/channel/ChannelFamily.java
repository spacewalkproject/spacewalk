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

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.common.VirtSubscriptionLevel;
import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.HashSet;
import java.util.Set;

/**
 * ChannelFamily
 * @version $Rev$
 */
public class ChannelFamily extends BaseDomainHelper {
    private Long id;
    private String name;
    private String label;
    private Org org;
    private String productUrl;
    private Set<Channel> channels = new HashSet<Channel>();
    private Set virtSubscriptionLevels = new HashSet();
    
    private Set<PrivateChannelFamily> channelFamilyOrgAllocations =
                                    new HashSet<PrivateChannelFamily>();

    /**
     * @return Returns the channels.
     */
    public Set<Channel> getChannels() {
        return this.channels;
    }
    
    /**
     * @param channelsIn The channels to set.
     */
    public void setChannels(Set<Channel> channelsIn) {
        this.channels = channelsIn;
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
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
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
        this.label = labelIn;
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
        this.id = idIn;
    }

    /**
     * @return Returns the productUrl.
     */
    public String getProductUrl() {
        return productUrl;
    }
    /**
     * @param productUrlIn The productUrl to set.
     */
    public void setProductUrl(String productUrlIn) {
        this.productUrl = productUrlIn;
    }

    /**
     * Returns the channel family allocations for a given org
     * @param orgIn org for which we need the allocation information
     * @return the allocation object
     */
    public PrivateChannelFamily getChannelFamilyAllocationFor(Org orgIn) {
        if (this.getChannelFamilyOrgAllocations() != null) {
            for (PrivateChannelFamily pcf : getChannelFamilyOrgAllocations()) {
                if (pcf.getOrg().getId().equals(orgIn.getId())) {
                    return pcf;
                }                
            }
        }
        return null;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ChannelFamily)) {
            return false;
        }
        ChannelFamily castOther = (ChannelFamily) other;
         
        return new EqualsBuilder().append(getLabel(), castOther.getLabel())
                                  .append(getName(), castOther.getName())
                                  .append(getOrg(), castOther.getOrg())
                                  .append(getProductUrl(), castOther.getProductUrl())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getId())
                                    .append(getLabel())
                                    .append(getName())
                                    .append(getOrg())
                                    .append(getProductUrl())
                                    .toHashCode();
    }
    
    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).append("name", name)
            .append("label", label).toString();
    }

    
    /**
     * @return Returns the virtSubscriptionLevels.
     */
    public Set getVirtSubscriptionLevels() {
        return virtSubscriptionLevels;
    }

    
    /**
     * @param virtSubscriptionLevelsIn The virtSubscriptionLevels to set.
     */
    public void setVirtSubscriptionLevels(Set virtSubscriptionLevelsIn) {
        this.virtSubscriptionLevels = virtSubscriptionLevelsIn;
    }

    /**
     * Add a virt subscription level to this ChannelFamily.
     * @param virtSubIn to add
     */
    public void addVirtSubscriptionLevel(VirtSubscriptionLevel virtSubIn) {
        if (this.virtSubscriptionLevels == null) {
            this.virtSubscriptionLevels = new HashSet();
        }
        this.virtSubscriptionLevels.add(virtSubIn);
    }

    /**
     * Get max members of this channel family.  NULL means unlimited
     * @param orgIn org to lookup the max members for
     * @return maxmembers of this channelfamily.  NULL == unlimited
     */
    public Long getMaxMembers(Org orgIn) {
        PrivateChannelFamily pcf = getChannelFamilyAllocationFor(orgIn);
        if (pcf == null) {
            return 0L;
        }
        return pcf.getMaxMembers();
    }
    
    /**
     * Get current members of this channel family. 
     * @param orgIn org to lookup the current members for
     * @return currentMembers of this channelfamily.
     */
    public Long getCurrentMembers(Org orgIn) {
        PrivateChannelFamily pcf = getChannelFamilyAllocationFor(orgIn);
        if (pcf == null) {
            return 0L;
        }
        return pcf.getCurrentMembers(); 
    }
    /**
     * Update the channelfamily current member counts in a given org   
     * @param orgIn the org to be updated
     * @param currentMembersIn the current members
     */
    public void setCurrentMembers(Org orgIn, Long currentMembersIn) {
        getChannelFamilyAllocationFor(orgIn).setCurrentMembers(currentMembersIn);
    }
    
    /**
     * Returns true if there are ant available subscriptions
     * @param orgIn the org which needs to be checked
     * @return true if there are ant available subscriptions
     */
    public boolean hasAvailableSlots(Org orgIn) {
        Long max = getMaxMembers(orgIn);
        //max = null means infinite slots
        if (max == null) {
            return true;
        }
        return max - getCurrentMembers(orgIn) > 0;
    }
    
    /**
     * @return Returns the privateChannelFamilies.
     */
    public Set<PrivateChannelFamily> getChannelFamilyOrgAllocations() {
        return channelFamilyOrgAllocations;
    }

    
    /**
     * @param privateChannelFamiliesIn The privateChannelFamilies to set.
     */
    protected void setChannelFamilyOrgAllocations(
            Set<PrivateChannelFamily> privateChannelFamiliesIn) {
        this.channelFamilyOrgAllocations = privateChannelFamiliesIn;
    }
    
    /**
     * Setter
     * @param pcfIn to set
     */
    public void addPrivateChannelFamily(PrivateChannelFamily pcfIn) {
        if (this.channelFamilyOrgAllocations == null) {
            this.channelFamilyOrgAllocations = new HashSet<PrivateChannelFamily>();
        }
        this.channelFamilyOrgAllocations.add(pcfIn);
    }
    
}

