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
package com.redhat.rhn.frontend.dto;

import java.util.ArrayList;
import java.util.List;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.frontend.filter.DepthAware;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * ChannelTreeNode
 * @version $Rev$
 */
public class ChannelTreeNode extends BaseDto implements BaseListDto,
                                                            DepthAware,
                                                            Comparable<ChannelTreeNode> {

    private Long id;
    private String name;
    private Long channelArchId;
    private Long packageCount;
    private Long systemCount;
    private Long errataCount;
    private String channelLabel;
    private Long channelFamilyId;
    private Long channelFamilySearchedFor;
    private boolean accessible = true;
    private Long parentId;
    private Long orgId;
    private String orgName;
    private String archName;


    /**
     * Handle the orphan'd child channels by adding a "fake" node
     *   This is done because a child can be viewable when the parent is not
     * @param result list of nodes to solve
     */
    public static void processList(DataResult<ChannelTreeNode> result) {
        DataResult<ChannelTreeNode> toReturn =
                new DataResult<ChannelTreeNode>(new ArrayList());
            toReturn.setFilter(true);
            toReturn.setFilterData(result.getFilterData());

            //We want the orphans to be at the end of the list, so lets add them here
            //   and then add them to the whole list later
            List<ChannelTreeNode> orphans = new ArrayList<ChannelTreeNode>();


            ChannelTreeNode lastParent = null;
            ChannelTreeNode lastOrphan = null;

            for (ChannelTreeNode node : result) {
                //if the node is a parent, mark it as last and move on
                if (node.isParent()) {
                    lastParent = node;
                    toReturn.add(node);
                } //if the node is a child of previous parent, move on
                else if (lastParent != null && node.getParentId().
                        equals(lastParent.getId())) {
                    toReturn.add(node);
                } //else we couldn't find the previous parent (so it's probably not here :{)
                else {
                    //If this is the first orphan or the parent of the last orphan doesn't
                    //  match this orphan's parent, then we need to add a node for the
                    //  restriciton
                       if (lastOrphan == null ||
                               !lastOrphan.getParentId().equals(node.getParentId())) {
                       orphans.add(newRestrictedParent(node));
                       orphans.add(node);
                   }
                   //this orphan has the same parent as the last, so no new dummy node
                   else {
                       orphans.add(node);
                   }
                   lastOrphan = node;
                }
            }
            toReturn.addAll(orphans);

            result.clear();
            result.addAll(toReturn);
            result.setTotalSize(toReturn.size());
    }

    private static ChannelTreeNode newRestrictedParent(ChannelTreeNode child) {
        ChannelTreeNode parent = new ChannelTreeNode();
        parent.setAccessible(false);
        parent.setName(LocalizationService.getInstance().getMessage("channel.unavailable"));
        parent.setId(child.getParentId());
        parent.setParentId(null);
        return parent;
    }

    /**
     * @return Returns the parentId.
     */
    public Long getParentId() {
        return parentId;
    }


    /**
     * @param parentIdIn The parentId to set.
     */
    public void setParentId(Long parentIdIn) {
        this.parentId = parentIdIn;
    }

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
     * retrieves the name of the channel
     * @return name
     */
    public String getUpperName() {
        return this.getName().toUpperCase();
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
     * @return Returns the depth.
     */
    public Long getDepth() {
        //if it's a parent, the depth is 1
        if (parentId == null) {
            return 1L;
        } //if it's a child the depth is 2
        return 2L;
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
       return !(this.getDepth() > 1);
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
        if (parentId != null) {
            return "c" + id;
        }
        return "p" + id;

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
        if (isParent()) {
            return id;
        }
        return parentId;
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
        return parentId == null;
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


    /**
     * Used mainly for sorting so it is in a nice order.
     *
     * {@inheritDoc}
     */
    public int compareTo(ChannelTreeNode arg0) {
        //if they are both parents, just sort by name
        if (this.isParent() && arg0.isParent()) {
            return this.getUpperName().compareTo(arg0.getUpperName());
        }

        //if none of them are parents
        if (!this.isParent() && !arg0.isParent()) {
            //if they have the same parent
            if (this.getParentOrSelfId().equals(arg0.getParentOrSelfId())) {
                return this.getUpperName().compareTo(arg0.getUpperName());
            }
            Channel one = ChannelFactory.lookupById(this.getParentOrSelfId());
            Channel two = ChannelFactory.lookupById(arg0.getParentOrSelfId());
            return one.getName().toUpperCase().compareTo(two.getName().toUpperCase());
        }
        //If the first one is a parent, but the 2nd one isn't
        if (this.isParent() && !arg0.isParent()) {
            //if a is a parent of b
            if (this.getId().equals(arg0.getParentOrSelfId())) {
                return -1;
            }
            Channel two = ChannelFactory.lookupById(arg0.getParentOrSelfId());
            return this.getUpperName().compareTo(two.getName().toUpperCase());
        }

        if (!this.isParent() && arg0.isParent()) {
            //is b a parent of a
            if (this.getParentOrSelfId().equals(arg0.getId())) {
                return 1;
            } //else if this is just some random child
            Channel two = ChannelFactory.lookupById(parentId);
            return two.getName().toUpperCase().compareTo(arg0.getUpperName());
        }
        return 0;
    }

    /**
     * Get the channel's org id.
     * @return The channel's org id.
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * Set the channel's org id.
     * @param orgid The channel's org id.
     */
    public void setOrgId(Long orgid) {
        orgId = orgid;
    }

    /**
     * Get the channel's org name.
     * @return The channel's org name.
     */
    public String getOrgName() {
        return orgName;
    }

    /**
     * Set the channel's org name.
     * @param orgname An channel's org name.
     */
    public void setOrgName(String orgname) {
        orgName = orgname;
    }

    /**
     * @return Returns the archName.
     */
    public String getArchName() {
        return archName;
    }

    /**
     * @param archNameIn The archName to set.
     */
    public void setArchName(String archNameIn) {
        this.archName = archNameIn;
    }

    /**
     * @return errata count for channel
     */
    public Long getErrataCount() {
        return errataCount;
    }

    /**
     * @param errataCountIn errata count to set
     */
    public void setErrataCount(Long errataCountIn) {
        this.errataCount = errataCountIn;
    }

}
