/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
import com.redhat.rhn.domain.org.Org;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.HashSet;
import java.util.Set;

/**
 * ChannelFamily
 */
public class ChannelFamily extends BaseDomainHelper {

    private Long id;
    private String name;
    private String label;
    private Org org;
    private String productUrl;
    private Set<Channel> channels = new HashSet<Channel>();

    private Set<PrivateChannelFamily> privateChannelFamilies =
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
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ChannelFamily)) {
            return false;
        }
        ChannelFamily castOther = (ChannelFamily) other;

        return new EqualsBuilder().append(id, castOther.id)
                                  .append(label, castOther.label)
                                  .append(name, castOther.name)
                                  .append(org, castOther.org)
                                  .append(productUrl, castOther.productUrl)
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id)
                                    .append(label)
                                    .append(name)
                                    .append(org)
                                    .append(productUrl)
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
     * returns the channel family allocation of this channel family
     * in  the given org
     * @param orgIn the org whose allocation is requested
     * @return the channel allocation
     */
    private PrivateChannelFamily getAllocation(Org orgIn) {
        for (PrivateChannelFamily alloc : getPrivateChannelFamilies()) {
            if (orgIn.getId().equals(alloc.getOrg().getId())) {
                return alloc;
            }
        }
        return null;
    }

    /**
     * @return Returns the privateChannelFamilies.
     */
    public Set<PrivateChannelFamily> getPrivateChannelFamilies() {
        return privateChannelFamilies;
    }


    /**
     * @param privateChannelFamiliesIn The privateChannelFamilies to set.
     */
    protected void setPrivateChannelFamilies(
            Set<PrivateChannelFamily> privateChannelFamiliesIn) {
        this.privateChannelFamilies = privateChannelFamiliesIn;
    }

    /**
     * Setter
     * @param pcfIn to set
     */
    public void addPrivateChannelFamily(PrivateChannelFamily pcfIn) {
        if (this.privateChannelFamilies == null) {
            this.privateChannelFamilies = new HashSet<PrivateChannelFamily>();
        }
        this.privateChannelFamilies.add(pcfIn);
    }


}

