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

/**
 * Format - Class representation of the table rhn_notification_formats.
 * @version $Rev: 1 $
 */
public class Format {

    private Long id;
    private Long customerId;
    private String description;
    private String subjectFormat;
    private String bodyFormat;
    private Long maxSubjectLength;
    private Long maxBodyLength;
    private String replyFormat;
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
     * Getter for description 
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /** 
     * Setter for description 
     * @param descriptionIn to set
    */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /** 
     * Getter for subjectFormat 
     * @return String to get
    */
    public String getSubjectFormat() {
        return this.subjectFormat;
    }

    /** 
     * Setter for subjectFormat 
     * @param subjectFormatIn to set
    */
    public void setSubjectFormat(String subjectFormatIn) {
        this.subjectFormat = subjectFormatIn;
    }

    /** 
     * Getter for bodyFormat 
     * @return String to get
    */
    public String getBodyFormat() {
        return this.bodyFormat;
    }

    /** 
     * Setter for bodyFormat 
     * @param bodyFormatIn to set
    */
    public void setBodyFormat(String bodyFormatIn) {
        this.bodyFormat = bodyFormatIn;
    }

    /** 
     * Getter for maxSubjectLength 
     * @return Long to get
    */
    public Long getMaxSubjectLength() {
        return this.maxSubjectLength;
    }

    /** 
     * Setter for maxSubjectLength 
     * @param maxSubjectLengthIn to set
    */
    public void setMaxSubjectLength(Long maxSubjectLengthIn) {
        this.maxSubjectLength = maxSubjectLengthIn;
    }

    /** 
     * Getter for maxBodyLength 
     * @return Long to get
    */
    public Long getMaxBodyLength() {
        return this.maxBodyLength;
    }

    /** 
     * Setter for maxBodyLength 
     * @param maxBodyLengthIn to set
    */
    public void setMaxBodyLength(Long maxBodyLengthIn) {
        this.maxBodyLength = maxBodyLengthIn;
    }

    /** 
     * Getter for replyFormat 
     * @return String to get
    */
    public String getReplyFormat() {
        return this.replyFormat;
    }

    /** 
     * Setter for replyFormat 
     * @param replyFormatIn to set
    */
    public void setReplyFormat(String replyFormatIn) {
        this.replyFormat = replyFormatIn;
    }

}
