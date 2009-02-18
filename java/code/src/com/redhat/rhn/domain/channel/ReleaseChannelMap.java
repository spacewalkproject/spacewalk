/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;


/**
 * ReleaseChannelMap
 * @version $Rev$
 */
public class ReleaseChannelMap implements Serializable {

    private String product;
    private String version;
    private String release;
    private ChannelArch channelArch;
    private Channel channel;
    private char isDefault; // 'Y' or 'N'
    
    /**
     * @return Returns the product.
     */
    public String getProduct() {
        return product;
    }
    
    /**
     * @param productIn The product to set.
     */
    public void setProduct(String productIn) {
        this.product = productIn;
    }
    
    /**
     * @return Returns the version.
     */
    public String getVersion() {
        return version;
    }
    
    /**
     * @param versionIn The version to set.
     */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }
    
    /**
     * @return Returns the release.
     */
    public String getRelease() {
        return release;
    }
    
    /**
     * @param releaseIn The release to set.
     */
    public void setRelease(String releaseIn) {
        this.release = releaseIn;
    }
    
    /**
     * @return Returns the channelArch.
     */
    public ChannelArch getChannelArch() {
        return channelArch;
    }
    
    /**
     * @param channelArchIn The channelArch to set.
     */
    public void setChannelArch(ChannelArch channelArchIn) {
        this.channelArch = channelArchIn;
    }
    
    /**
     * @return Returns the channel.
     */
    public Channel getChannel() {
        return channel;
    }
    
    /**
     * @param channelIn The channel to set.
     */
    public void setChannel(Channel channelIn) {
        this.channel = channelIn;
    }
    
    /**
     * @return Returns the isDefault.
     */
    public char getIsDefault() {
        return isDefault;
    }
    
    /**
     * @param isDefaultIn The isDefault to set.
     */
    public void setIsDefault(char isDefaultIn) {
        this.isDefault = isDefaultIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ReleaseChannelMap)) {
            return false;
        }
        ReleaseChannelMap castOther = (ReleaseChannelMap) other;
        return new EqualsBuilder().append(getProduct(), castOther.getProduct()).
            append(getRelease(), castOther.getRelease()).
            append(getVersion(), castOther.getVersion()).
            append(getChannelArch(), castOther.getChannelArch()).
            append(getIsDefault(), castOther.getIsDefault()).
            append(getChannel(), castOther.getChannel()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getProduct()).append(getVersion()).append(
                getRelease()).append(getChannelArch()).append(getChannel()).toHashCode();
    }
    
}
