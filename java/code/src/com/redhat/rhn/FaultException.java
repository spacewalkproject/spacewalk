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

package com.redhat.rhn;

import com.redhat.rhn.common.localization.LocalizationService;

/**
 * Generic XML RPC fault
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class FaultException extends RuntimeException  {

    protected int errorCode;
    protected String label;

    /**
     * Constructor
     * @param error error code
     * @param lbl error label
     * @param message the message
     */
    public FaultException(int error, String lbl, String message) {
        super(message);
        this.errorCode =  error;
        this.label =  lbl;
    }

    /**
     * Constructor
     * @param error error code
     * @param lbl error label
     * @param messageId the string resource message ID
     * @param args arguments to be passed to the localization service
     */
    public FaultException(int error, String lbl, String messageId, Object [] args) {
        super(LocalizationService.getInstance().getMessage(messageId, args));
        this.errorCode =  error;
        this.label =  lbl;
    }

    /**
     * Constructor
     * @param error error code
     * @param lbl error label
     * @param message the message
     * @param cause the cause (which is saved for later retrieval
     * by the Throwable.getCause() method). (A null value is
     * permitted, and indicates that the cause is nonexistent or
     * unknown.)
     */
    public FaultException(int error, String lbl, String message, Throwable cause) {
        super(message, cause);
        // begin member variable initialization
        this.errorCode =  error;
        this.label =  lbl;
    }

    /**
     * Returns the value of errorCode
     * @return int errorCode
     */
    public int getErrorCode() {
        return errorCode;
    }

    /**
     * Sets the errorCode to the given value.
     * @param error error code
     */
    public void setErrorCode(int error) {
        this.errorCode = error;
    }

    /**
     * Returns the value of label
     * @return String label
     */
    public String getLabel() {
        return label;
    }

    /**
     * Sets the label to the given value.
     * @param lbl error label
     */
    public void setLabel(String lbl) {
        this.label = lbl;
    }

}
