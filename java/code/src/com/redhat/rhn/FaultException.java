/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorWarning;

import java.util.Iterator;

/**
 * Generic XML RPC fault
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class FaultException extends RuntimeException  {

    private static final long serialVersionUID = -8293171315924454538L;
    protected int errorCode;
    protected String label;
    protected Object [] arguments;

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
        this.arguments = args;
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
     * create an exception from a ValidatorResult
     * @param errorIn error number
     * @param labelIn label
     * @param resultIn validator result
     * @return new FaultException
     */
    public static FaultException create(int errorIn, String labelIn,
            ValidatorResult resultIn) {
        for (Iterator <ValidatorError> iter = resultIn.getErrors().iterator();
                iter.hasNext();) {
            ValidatorError ve = iter.next();
            return new FaultException(errorIn, labelIn, ve.getKey(), ve.getValues());
        }
        for (Iterator <ValidatorWarning> iter = resultIn.getWarnings().iterator();
                iter.hasNext();) {
            ValidatorWarning vw = iter.next();
            return new FaultException(errorIn, labelIn, vw.getKey(), vw.getValues());
        }
        return new FaultException(errorIn, labelIn, "");
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

    /**
     * getter for exception arguments
     * @return arguments
     */
    public Object[] getArgs() {
        return arguments;
    }

    /**
     * setter for exception arguments
     * @param args arguments
     */
    public void setArgs(Object[] args) {
        this.arguments = args;
    }

}
