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
package com.redhat.rhn.frontend.dto;

import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * ChannelOverview
 * @version $Rev$
 */
public class ChannelOverview extends BaseDto implements Comparable {
    private Long id;
    private Long orgId;
    private String name;
    private String label;
    private Long currentMembers;
    private Long maxMembers;
    private Long currentFlex;
    private Long maxFlex;
    private Long subscribeCount;


    /**
     * @return Returns the subscribeCount.
     */
    public Long getSubscribeCount() {
        return subscribeCount;
    }




    /**
     * @param subscribeCountIn The subscribeCountIn to set.
     */
    public void setSubscribeCount(Long subscribeCountIn) {
        this.subscribeCount = subscribeCountIn;
    }



    /**
     * @return Returns the currentFlex.
     */
    public Long getCurrentFlex() {
        return currentFlex;
    }



    /**
     * @param currentFlexIn The currentFlex to set.
     */
    public void setCurrentFlex(Long currentFlexIn) {
        this.currentFlex = currentFlexIn;
    }



    /**
     * @return Returns the maxFlex.
     */
    public Long getMaxFlex() {
        return maxFlex;
    }



    /**
     * @param maxFlexIn The maxFlex to set.
     */
    public void setMaxFlex(Long maxFlexIn) {
        this.maxFlex = maxFlexIn;
    }



    private Long hasSubscription;
    private String url;
    private Long relevantPackages;
    private Long originalId;
    private List<PackageDto> packages = new ArrayList<PackageDto>();

    
    /**
     * @return Returns the originalId.
     */
    public Long getOriginalId() {
        return originalId;
    }

    
    /**
     * @param originalIdIn The originalId to set.
     */
    public void setOriginalId(Long originalIdIn) {
        this.originalId = originalIdIn;
    }

    /** Default no-arg constructor
     */
    public ChannelOverview() {
    }
    
    /**
     * Constructor with name and id
     * @param nameIn to set
     * @param idIn to set
     */
    public ChannelOverview(String nameIn, Long idIn) {
        this.name = nameIn;
        this.id = idIn;
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
     * @return Returns the free members.
     */
    public Long getFreeMembers() {
        // Looks like the schema sadly allows this to be null:
        Long max = maxMembers;
        if (max == null) {
            max = new Long(0);
        }
        return max - currentMembers;
    }
    
    /**
     * @return Returns the hasSubscription.
     */
    public Long isHasSubscription() {
        return hasSubscription;
    }
    /**
     * @param hasSubscriptionIn The hasSubscription to set.
     */
    public void setHasSubscription(Long hasSubscriptionIn) {
        this.hasSubscription = hasSubscriptionIn;
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
     * Returns the org ID for this channel overview. Note this is only used for some
     * queries and may be returned as null.
     * @return Returns the orgId.
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdIn The org id to set.
     */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
    }

    /**
     * @return Returns the maxMembers.
     */
    public Long getMaxMembers() {
        return maxMembers;
    }

    /**
     * @param maxMembersIn The maxMembers to set.
     */
    public void setMaxMembers(Long maxMembersIn) {
        this.maxMembers = maxMembersIn;
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
     * @return Returns the channel family label.
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
     * @return Returns the url.
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param urlIn The url to set.
     */
    public void setUrl(String urlIn) {
        this.url = urlIn;
    }

    /**
     * @return Returns the relevantPackages.
     */
    public Long getRelevantPackages() {
        return relevantPackages;
    }
    
    /**
     * @param r The relevantPackages to set.
     */
    public void setRelevantPackages(Long r) {
        this.relevantPackages = r;
    }
    
    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", id).append("name", name)
                .toString();
    }

    /**
     * 
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
           return getName().compareTo(((ChannelOverview) o).getName());
    }

    
    /**
     * @return Returns the hasSubscription.
     */
    public Long getHasSubscription() {
        return hasSubscription;
    }



    /**
     * @return Returns the packages.
     */
    public List<PackageDto> getPackages() {
        return packages;
    }



    /**
     * @param packagesIn The packages to set.
     */
    public void setPackages(List<PackageDto> packagesIn) {
        this.packages = packagesIn;
    }



}
