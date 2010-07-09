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
package com.redhat.rhn.domain.monitoring.notification;

import java.util.Date;

/**
 * ContactGroup - Class representation of the table rhn_contact_groups.
 * @version $Rev: 1 $
 */
public class ContactGroup {

    private Long id;
    private String contactGroupName;
    private Long customerId;
    private Long strategyId;
    private Long ackWait;
    private String rotateFirst;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private Long notificationFormatId;

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
     * Getter for contactGroupName
     * @return String to get
    */
    public String getContactGroupName() {
        return this.contactGroupName;
    }

    /**
     * Setter for contactGroupName
     * @param contactGroupNameIn to set
    */
    public void setContactGroupName(String contactGroupNameIn) {
        this.contactGroupName = contactGroupNameIn;
    }

    /**
     * Getter for customerId
     * @return Long to get
    */
    public Long getCustomerId() {
        return this.customerId;
    }

    /**
     * Setter for customerId
     * @param customerIdIn to set
    */
    public void setCustomerId(Long customerIdIn) {
        this.customerId = customerIdIn;
    }

    /**
     * Getter for strategyId
     * @return Long to get
    */
    public Long getStrategyId() {
        return this.strategyId;
    }

    /**
     * Setter for strategyId
     * @param strategyIdIn to set
    */
    public void setStrategyId(Long strategyIdIn) {
        this.strategyId = strategyIdIn;
    }

    /**
     * Getter for ackWait
     * @return Long to get
    */
    public Long getAckWait() {
        return this.ackWait;
    }

    /**
     * Setter for ackWait
     * @param ackWaitIn to set
    */
    public void setAckWait(Long ackWaitIn) {
        this.ackWait = ackWaitIn;
    }

    /**
     * Getter for rotateFirst
     * @return String to get
    */
    public String getRotateFirst() {
        return this.rotateFirst;
    }

    /**
     * Setter for rotateFirst
     * @param rotateFirstIn to set
    */
    public void setRotateFirst(String rotateFirstIn) {
        this.rotateFirst = rotateFirstIn;
    }

    /**
     * Getter for lastUpdateUser
     * @return String to get
    */
    public String getLastUpdateUser() {
        return this.lastUpdateUser;
    }

    /**
     * Setter for lastUpdateUser
     * @param lastUpdateUserIn to set
    */
    public void setLastUpdateUser(String lastUpdateUserIn) {
        this.lastUpdateUser = lastUpdateUserIn;
    }

    /**
     * Getter for lastUpdateDate
     * @return Date to get
    */
    public Date getLastUpdateDate() {
        return this.lastUpdateDate;
    }

    /**
     * Setter for lastUpdateDate
     * @param lastUpdateDateIn to set
    */
    public void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * Getter for notificationFormatId
     * @return Long to get
    */
    public Long getNotificationFormatId() {
        return this.notificationFormatId;
    }

    /**
     * Setter for notificationFormatId
     * @param notificationFormatIdIn to set
    */
    public void setNotificationFormatId(Long notificationFormatIdIn) {
        this.notificationFormatId = notificationFormatIdIn;
    }

}
