/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.frontend.filter.DepthAware;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * ChannelTreeNode
 * @version $Rev$
 */
public class ChannelTreeNode extends BaseDto implements BaseListDto, 
                                                            DepthAware {
    
    private Long id;
    private String name;
    private Long depth;
    private Long channelArchId;
    private Long currentMembers;
    private Long availableMembers; 
    private Long packageCount;
    private Long systemCount;
    private String parentOrSelfLabel;
    private String channelLabel;
    private Long parentOrSelfId;
    private Long channelFamilyId;
    private Long channelFamilySearchedFor;
    private boolean accessible = true;
    
    /**
     * @return Returns the channelFamilySearchedFor.
     */
    public Long getChannelFamilySearchedFor() {
        return channelFamilySearchedFor;
    }

    /**
     * @param channelFamilySearchedForIn The channelFamilySearchedFor to set.
     */
    public void setChannelFamilySearchedFor(Long channelFamilySearchedForIn) {
        this.channelFamilySearchedFor = channelFamilySearchedForIn;
    }

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param idIn channel id
     */
    public void setId(Long idIn) {
        id = idIn;
    }
    
    /**
     * retrieves the name of the channel
     * @return name
     */
    public String getName() {
        return name;
    }

    /**
     * @return Returns the availableMembers.
     */
    public Long getAvailableMembers() {
        return availableMembers;
    }

    /**
     * @param availableMembersIn The availableMembers to set.
     */
    public void setAvailableMembers(Long availableMembersIn) {
        this.availableMembers = availableMembersIn;
    }

    /**
     * @return Returns the channelArchId.
     */
    public Long getChannelArchId() {
        return channelArchId;
    }

    /**
     * @param channelArchIdIn The channelArchId to set.
     */
    public void setChannelArchId(Long channelArchIdIn) {
        this.channelArchId = channelArchIdIn;
    }

    /**
     * @return Returns the channelLabel.
     */
    public String getChannelLabel() {
        return channelLabel;
    }

    /**
     * @param channelLabelIn The channelLabel to set.
     */
    public void setChannelLabel(String channelLabelIn) {
        this.channelLabel = channelLabelIn;
    }

    /**
     * @return Returns the currentMembers.
     */
    public Long getCurrentMembers() {
        return currentMembers;
    }

    /**
     * @param currentMembersIn The currentMembers to set.
     */
    public void setCurrentMembers(Long currentMembersIn) {
        this.currentMembers = currentMembersIn;
    }

    /**
     * @return Returns the depth.
     */
    public Long getDepth() {
        return depth;
    }

    /**
     * @param depthIn The depth to set.
     */
    public void setDepth(Long depthIn) {
        this.depth = depthIn;
    }

    /**
     * @return Returns the packageCount.
     */
    public Long getPackageCount() {
        return packageCount;
    }

    /**
     * @param packageCountIn The packageCount to set.
     */
    public void setPackageCount(Long packageCountIn) {
        this.packageCount = packageCountIn;
    }

    /**
     * @return Returns the parentOrSelfLabel.
     */
    public String getParentOrSelfLabel() {
        return parentOrSelfLabel;
    }

    /**
     * @param parentOrSelfLabelIn The parentOrSelfLabel to set.
     */
    public void setParentOrSelfLabel(String parentOrSelfLabelIn) {
        this.parentOrSelfLabel = parentOrSelfLabelIn;
    }

    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @return Returns the systemCount.
     */
    public Long getSystemCount() {
        return systemCount;
    }

    /**
     * @param systemCountIn The systemCount to set.
     */
    public void setSystemCount(Long systemCountIn) {
        this.systemCount = systemCountIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean changeRowColor() {
       return !(depth.longValue() > 1);
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean greyOutRow() {
        if (channelFamilyId == null || channelFamilySearchedFor == null) {
            return false;
        }
        
        return !channelFamilyId.equals(channelFamilySearchedFor);
        
    }
    
    /**
     * {@inheritDoc}
     */
    public String getNodeIdString() {
        if (id.equals(parentOrSelfId)) {
            return "p" + parentOrSelfId;
        }
        else {
            return "c" + parentOrSelfId;
        }
            
    }
    /**
     * @return Returns the channelFamilyId.
     */
    public Long getChannelFamilyId() {
        return channelFamilyId;
    }

    /**
     * @param channelFamilyIdIn The channelFamilyId to set.
     */
    public void setChannelFamilyId(Long channelFamilyIdIn) {
        this.channelFamilyId = channelFamilyIdIn;
    }

    /**
     * @return Returns the parentOrSelfId.
     */
    public Long getParentOrSelfId() {
        return parentOrSelfId;
    }

    /**
     * @param parentOrSelfIdIn The parentOrSelfId to set.
     */
    public void setParentOrSelfId(Long parentOrSelfIdIn) {
        this.parentOrSelfId = parentOrSelfIdIn;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).
            append("id", id).append("name", name).toString();
    }

    /**
     * If we want to allow users to view this channel or not.
     * @param accessibleIn or not.
     */
    public void setAccessible(boolean accessibleIn) {
        this.accessible = accessibleIn;
        
    }
    
    /**
     * Get if we should let the user see this channel or not. Defaults
     * to true.
     * @return if accessible
     */
    public boolean getAccessible() {
        return this.accessible;
    }

    /**
     * Returns <code>true</code> if this node is a parent channel node, <code>false</code>
     * otherwise. A node is considered a parent if its <code>depth</code> is 1 and its
     * <code>id</code> and <code>parentOrSelfId</code> properties have the same value.
     * 
     * @return <code>true</code> if this node is a parent node, <code>false</code> 
     * otherwise.
     */
    public boolean isParent() {
        return new Long(1).equals(depth);
    }
    
    /**
     * Returns <code>true</code> if this node is a child node of the specified <code>parent
     * </code>.
     * 
     * @param parent The parent to compare against
     * 
     * @return <code>true</code> if this node is a child of <code>parent</code>, or return
     * <code>false</code> if <code>parent</code> is not a parent node or not the parent of
     * this node.
     */
    public boolean isChildOf(ChannelTreeNode parent) {
        return parent != null && parent.isParent() && parentOrSelfId.equals(parent.id);
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object object) {
        if (object == null || !getClass().equals(object.getClass())) {
            return false;
        }
        
        ChannelTreeNode that = (ChannelTreeNode)object;
        
        return new EqualsBuilder().append(this.id, that.id).isEquals();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.id).toHashCode();
    }

    /**
     * 
     * {@inheritDoc}
     */
    public long depth() {
        return getDepth().longValue();
    }
    
}
