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

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * ContactGroupMember - Class representation of the table rhn_contact_group_members.
 * @version $Rev: 1 $
 */
public class ContactGroupMember implements Serializable {

    private ContactGroup contactGroup;
    private Long orderNumber;
    private Method contactMethod;
    private String lastUpdateUser;
    private Date lastUpdateDate;

    // NOT USED
    private Long memberContactGroupId;

    /**
     * Getter for contactGroup
     * @return ContactGroup to get
    */
    public ContactGroup getContactGroup() {
        return this.contactGroup;
    }

    /**
     * Setter for contactGroupId
     * @param contactGroupIn to set
    */
    public void setContactGroup(ContactGroup contactGroupIn) {
        this.contactGroup = contactGroupIn;
    }


    /**
     * @return Returns the contactMethod.
     */
    public Method getContactMethod() {
        return this.contactMethod;
    }


    /**
     * @param contactMethodIn The contactMethod to set.
     */
    public void setContactMethod(Method contactMethodIn) {
        this.contactMethod = contactMethodIn;
    }

    /**
     * Getter for orderNumber
     * @return Long to get
    */
    public Long getOrderNumber() {
        return this.orderNumber;
    }

    /**
     * Setter for orderNumber
     * @param orderNumberIn to set
    */
    public void setOrderNumber(Long orderNumberIn) {
        this.orderNumber = orderNumberIn;
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
     * Getter for memberContactGroupId
     * @return Long to get
    */
    private Long getMemberContactGroupId() {
        return this.memberContactGroupId;
    }

    /**
     * Setter for memberContactGroupId
     * @param memberContactGroupIdIn to set
    */
    private void setMemberContactGroupId(Long memberContactGroupIdIn) {
        this.memberContactGroupId = memberContactGroupIdIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ContactGroupMember)) {
            return false;
        }
        ContactGroupMember castOther = (ContactGroupMember) other;
        return new EqualsBuilder().append(this.getContactGroup(),
                castOther.getContactGroup()).append(this.getOrderNumber(),
                castOther.getOrderNumber()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getContactGroup()).append(
                this.getOrderNumber()).toHashCode();
    }

}
