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

package com.redhat.rhn.common.messaging.test;

import com.redhat.rhn.common.messaging.Mail;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

import junit.framework.AssertionFailedError;

/**
 * A Mock implementation of our Mail interface.
 *
 * @version $Rev$
 */
public class MockMail implements Mail {

    private int sendCount = 0;
    private int expectedSendCount = 0;
    private String body;
    private String subject;

    /**
     * Create a mail message
     */
    public MockMail() {
    }

    /**
    * Send the actual message
    */
    public void send() {
        sendCount++;
    }

    /** Set the recipient of the email message.
     *  This can be a comma or space separated list of recipients
    */
    public void setRecipient(String recipIn) {
        verifyAddress(recipIn);
    }

    /** Set the recipient of the email message.
     *  This can be a comma or space separated list of recipients
    */
    public void setRecipients(String[] recipIn) {
        if (recipIn != null) {
            for (int i = 0; i < recipIn.length; i++) {
                verifyAddress(recipIn[i]);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void setCCRecipients(String[] emailAddrs) {
        if (emailAddrs != null) {
            for (int i = 0; i < emailAddrs.length; i++) {
                verifyAddress(emailAddrs[i]);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void setBCCRecipients(String[] emailAddrs) {
        if (emailAddrs != null) {
            for (int i = 0; i < emailAddrs.length; i++) {
                verifyAddress(emailAddrs[i]);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void setFrom(String from) {
        verifyAddress(from);
    }

    private void verifyAddress(String addr) {
        try {
            InternetAddress.parse(addr);
        }
        catch (AddressException e) {
            throw new RuntimeException("Bad address [" + addr + "]", e);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void setHeader(String name, String value) {
    }

    /** Set the subject of the email message
    */
    public void setSubject(String subIn) {
        subject = subIn;
    }

    /** Set the text of the email message
    */
    public void setBody(String bodyIn) {
        body = bodyIn;
    }

    /**
    * Set the expected number of times send() will be called
    */
    public void setExpectedSendCount(int count) {
        expectedSendCount = count;
    }

    /**
    * Get the subject so we can verify against it
    */
    public String getSubject() {
        return subject;
    }

    /**
    * Get the body so we can verify against it
    */
    public String getBody() {
        return body;
    }

    /**
     * Verify that the mailer sent enough email.
     */
    public void verify() {
        if (expectedSendCount > sendCount) {
            throw new AssertionFailedError("expectedSendCount: " +
                    expectedSendCount + " actual count: " + sendCount);
        }
    }

}


