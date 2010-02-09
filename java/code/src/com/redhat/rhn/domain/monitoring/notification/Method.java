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

import com.redhat.rhn.domain.user.User;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 * Method - Class representation of the table rhn_contact_methods.
 * @version $Rev: 1 $
 */
public class Method {

    private Long id;
    private String methodName;
    private Long scheduleId;
    private Long methodTypeId;
    private Long pagerTypeId;
    private String pagerPin;
    private String pagerEmail;
    private Long pagerMaxMessageLength;
    private String pagerSplitLongMessages;
    private String emailAddress;
    private String emailReplyTo;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private String snmpHost;
    private Long snmpPort;
    private Long notificationFormatId;
    private Long senderSatClusterId;
    
    private User user;
    private MethodType type;
    private Format format;
    
    private Set contactGroupMembers;
    
    
    /**
     * Default constructor to setup default values.
     */
    public Method() {
        this.scheduleId = new Long(1);
    }
    
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
     * Getter for methodName 
     * @return String to get
    */
    public String getMethodName() {
        return this.methodName;
    }

    /** 
     * Setter for methodName 
     * @param methodNameIn to set
    */
    public void setMethodName(String methodNameIn) {
        this.methodName = methodNameIn;
    }

    /** 
     * Getter for scheduleId 
     * @return Long to get
    */
    public Long getScheduleId() {
        return this.scheduleId;
    }

    /** 
     * Setter for scheduleId 
     * @param scheduleIdIn to set
    */
    public void setScheduleId(Long scheduleIdIn) {
        this.scheduleId = scheduleIdIn;
    }

    /** 
     * Getter for methodTypeId 
     * @return Long to get
    */
    public Long getMethodTypeId() {
        return this.methodTypeId;
    }

    /** 
     * Setter for methodTypeId 
     * @param methodTypeIdIn to set
    */
    public void setMethodTypeId(Long methodTypeIdIn) {
        this.methodTypeId = methodTypeIdIn;
    }

    /** 
     * Getter for pagerTypeId 
     * @return Long to get
    */
    public Long getPagerTypeId() {
        return this.pagerTypeId;
    }

    /** 
     * Setter for pagerTypeId 
     * @param pagerTypeIdIn to set
    */
    public void setPagerTypeId(Long pagerTypeIdIn) {
        this.pagerTypeId = pagerTypeIdIn;
    }

    /** 
     * Getter for pagerPin 
     * @return String to get
    */
    public String getPagerPin() {
        return this.pagerPin;
    }

    /** 
     * Setter for pagerPin 
     * @param pagerPinIn to set
    */
    public void setPagerPin(String pagerPinIn) {
        this.pagerPin = pagerPinIn;
    }

    /** 
     * Getter for pagerEmail 
     * @return String to get
    */
    public String getPagerEmail() {
        return this.pagerEmail;
    }

    /** 
     * Setter for pagerEmail 
     * @param pagerEmailIn to set
    */
    public void setPagerEmail(String pagerEmailIn) {
        this.pagerEmail = pagerEmailIn;
    }

    /** 
     * Getter for pagerMaxMessageLength 
     * @return Long to get
    */
    public Long getPagerMaxMessageLength() {
        return this.pagerMaxMessageLength;
    }

    /** 
     * Setter for pagerMaxMessageLength 
     * @param pagerMaxMessageLengthIn to set
    */
    public void setPagerMaxMessageLength(Long pagerMaxMessageLengthIn) {
        this.pagerMaxMessageLength = pagerMaxMessageLengthIn;
    }

    /** 
     * Getter for pagerSplitLongMessages 
     * @return String to get
    */
    public String getPagerSplitLongMessages() {
        return this.pagerSplitLongMessages;
    }

    /** 
     * Setter for pagerSplitLongMessages 
     * @param pagerSplitLongMessagesIn to set
    */
    public void setPagerSplitLongMessages(String pagerSplitLongMessagesIn) {
        this.pagerSplitLongMessages = pagerSplitLongMessagesIn;
    }

    /** 
     * Getter for emailAddress 
     * @return String to get
    */
    public String getEmailAddress() {
        return this.emailAddress;
    }

    /** 
     * Setter for emailAddress 
     * @param emailAddressIn to set
    */
    public void setEmailAddress(String emailAddressIn) {
        this.emailAddress = emailAddressIn;
    }

    /** 
     * Getter for emailReplyTo 
     * @return String to get
    */
    public String getEmailReplyTo() {
        return this.emailReplyTo;
    }

    /** 
     * Setter for emailReplyTo 
     * @param emailReplyToIn to set
    */
    public void setEmailReplyTo(String emailReplyToIn) {
        this.emailReplyTo = emailReplyToIn;
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
     * Getter for snmpHost 
     * @return String to get
    */
    public String getSnmpHost() {
        return this.snmpHost;
    }

    /** 
     * Setter for snmpHost 
     * @param snmpHostIn to set
    */
    public void setSnmpHost(String snmpHostIn) {
        this.snmpHost = snmpHostIn;
    }

    /** 
     * Getter for snmpPort 
     * @return Long to get
    */
    public Long getSnmpPort() {
        return this.snmpPort;
    }

    /** 
     * Setter for snmpPort 
     * @param snmpPortIn to set
    */
    public void setSnmpPort(Long snmpPortIn) {
        this.snmpPort = snmpPortIn;
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

    /** 
     * Getter for senderSatClusterId 
     * @return Long to get
    */
    public Long getSenderSatClusterId() {
        return this.senderSatClusterId;
    }

    /** 
     * Setter for senderSatClusterId 
     * @param senderSatClusterIdIn to set
    */
    public void setSenderSatClusterId(Long senderSatClusterIdIn) {
        this.senderSatClusterId = senderSatClusterIdIn;
    }
    
    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }
    
    /**
     * @param userIn The user to set.
     */
    public void setUser(User userIn) {
        this.user = userIn;
    }

    /**
     * @return Returns the type.
     */
    public MethodType getType() {
        return type;
    }
    
    /**
     * @param typeIn The type to set.
     */
    public void setType(MethodType typeIn) {
        this.type = typeIn;
    }

    /**
     * @return Returns the format.
     */
    public Format getFormat() {
        return format;
    }

    /**
     * @param formatIn The format to set.
     */
    public void setFormat(Format formatIn) {
        this.format = formatIn;
    }
    /**
     * @return Returns the contactGroupMembers.
     */
    public Set getContactGroupMembers() {
        return contactGroupMembers;
    }

    /**
     * @param contactGroupMembersIn The contactGroupMembers to set.
     */
    public void setContactGroupMembers(Set contactGroupMembersIn) {
        this.contactGroupMembers = contactGroupMembersIn;
    }

    /**
     * Get the ContactGroup associated with this Member.
     * @return ContactGroup - there should be always one.
     */
    public ContactGroup getContactGroup() {
        ContactGroupMember cgm = (ContactGroupMember) 
            this.getContactGroupMembers().iterator().next();
        return cgm.getContactGroup();
    }

    /**
     * Set the ContactGroup associated with this Method
     * @param group to set.
     */
    public void setContactGroup(ContactGroup group) {
        if (this.contactGroupMembers == null) {
            this.contactGroupMembers = new HashSet();
        }
        ContactGroupMember cgm = new ContactGroupMember();
        cgm.setContactGroup(group);
        cgm.setLastUpdateDate(new Date());
        cgm.setLastUpdateUser("unknown");
        cgm.setOrderNumber(new Long(0));
        cgm.setContactMethod(this);
        this.contactGroupMembers.add(cgm);
    }
}
