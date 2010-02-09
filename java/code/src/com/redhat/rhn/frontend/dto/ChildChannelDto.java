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

/**
 * ChildChannelDTO
 * @version $Rev$
 */
public class ChildChannelDto {

    private Long id;
    private Long parentId;
    private String name;
    private String label;
    private boolean subscribed;
    private boolean isFreeForGuests;
    private boolean isSubscribable;
    private Long availableSubscriptions;
    private Long systemCount;
    
    /**
     * Constructor
     */
    public ChildChannelDto() {
        super();
    }
    
    /**
     * Constructor
     * @param idIn id
     * @param nameIn name
     * @param subscribedIn sub
     * @param isFreeForGuestsIn is it free?
     * @param isSubscriableIn if subscriable or not
     */
    public ChildChannelDto(Long idIn, String nameIn, 
            boolean subscribedIn, boolean isFreeForGuestsIn, boolean isSubscriableIn) {
        this.id = idIn;
        this.name = nameIn;
        this.subscribed = subscribedIn;
        this.isFreeForGuests = isFreeForGuestsIn;
        this.isSubscribable = isSubscriableIn;
    }
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * Set the id.
     * @param idIn id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /**
     * 
     * @return parent ID.
     */
    public Long getParentId() {
        return parentId;
    }

    
    /**
     * Set the parentId.
     * @param inId to set.
     */
    public void setParentId(Long inId) {
        parentId = inId;
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
     * @return Returns the subscribed.
     */
    public boolean getSubscribed() {
        return subscribed;
    }

    
    /**
     * @param subscribedIn The subscribed to set.
     */
    public void setSubscribed(boolean subscribedIn) {
        this.subscribed = subscribedIn;
    }

    
    /**
     * @return Returns the isSubscribable.
     */
    public boolean getSubscribable() {
        return isSubscribable;
    }

    
    /**
     * @param isSubscribableIn The isSubscribable to set.
     */
    public void setSubscribable(Long isSubscribableIn) {
        this.isSubscribable = !new Long(0).equals(isSubscribableIn);
    }

    
    /**
     * @return Returns the availableSubscriptions.
     */
    public Long getAvailableSubscriptions() {
        return availableSubscriptions;
    }

    
    /**
     * @param availableSubscriptionsIn The availableSubscriptions to set.
     */
    public void setAvailableSubscriptions(Long availableSubscriptionsIn) {
        this.availableSubscriptions = availableSubscriptionsIn;
    }

    
    /**
     * @return Returns the isSubscribable.
     */
    public boolean isSubscribable() {
        return isSubscribable;
    }
    
    /**
     * @return the isFreeForGuests
     */
    public boolean getFreeForGuests() {
        return isFreeForGuests;
    }

    /**
     * @param isFreeForGuestsIn the isFreeForGuests to set
     */
    public void setFreeForGuests(boolean isFreeForGuestsIn) {
        this.isFreeForGuests = isFreeForGuestsIn;
    }
    
    /**
     * 
     * @return label
     */
    public String getLabel() {
        return label;
    }

    /**
     * Set the label
     * @param labelIn to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }
    
    /**
     * Get the system count.
     * @return system count.
     */
    public Long getSystemCount() {
        return systemCount;
    }

    
    /**
     * Set the system count.
     * @param systemCountIn to set.
     */
    public void setSystemCount(Long systemCountIn) {
        this.systemCount = systemCountIn;
    }
    
}
