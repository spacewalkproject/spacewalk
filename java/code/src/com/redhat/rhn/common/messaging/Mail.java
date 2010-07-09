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

package com.redhat.rhn.common.messaging;

/**
 * A interface to implemenent sending mail messages
 *
 * @version $Rev$
 */
public interface Mail {

    /**
    * Send the actual message
    */
    void send();

    /**
     * Set the from field of the email message
     * @param from Email address this message is from.
     */
    void setFrom(String from);

    /**
     * Set a header value for the message
     * @param name The header name to set
     * @param value The header value to set
     */
    void setHeader(String name, String value);

    /**
     * Set the recipients of the email message.
     * @param recipIn Array of Recipients to whom to send.
     */
    void setRecipients(String[] recipIn);

    /**
     * Sets the CC recipients of the email message
     * @param emailAddrs Array of email addrs to whom to send.
     */
    void setCCRecipients(String[] emailAddrs);

    /**
     * Sets the BCC recipients of the email message
     * @param emailAddrs Array of email addrs to whom to send.
     */
    void setBCCRecipients(String[] emailAddrs);

    /** Set a single recipient of the email message.
     * @param recipIn The intended recipient.
     */
    void setRecipient(String recipIn);

    /** Set the subject of the email message
     * @param subIn Subject of email message.
     */
    void setSubject(String subIn);

    /** Set the text of the email message
     * @param textIn Text of email.
    */
    void setBody(String textIn);
}


