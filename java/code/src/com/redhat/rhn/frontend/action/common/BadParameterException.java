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

/*
 * AUTOMATICALLY GENERATED FILE, DO NOT EDIT.
 */
package com.redhat.rhn.frontend.action.common;

/**
 * A required parameter from the request was either missing or invalid
 * <p>

 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class BadParameterException extends IllegalArgumentException  {

    protected String msg;
    protected Throwable rootCause;

    /////////////////////////
    // Constructors
    /////////////////////////
        /**
     * Constructor
     * @param message exception message
     */
    public BadParameterException(String message) {
            // begin member variable initialization
        this.msg =  message;
    }

        /**
     * Constructor
     * @param message exception message
     * @param cause the cause (which is saved for later retrieval
     * by the Throwable.getCause() method). (A null value is
     * permitted, and indicates that the cause is nonexistent or
     * unknown.)
     */
    public BadParameterException(String message ,   Throwable cause) {
            // begin member variable initialization
        this.msg =  message;
        this.rootCause = cause;
    }

    /////////////////////////
    // Getters/Setters
    /////////////////////////
    /**
     * Returns the value of message
     * @return String message
     */
    public String getMessage() {
        return msg;
    }

    /**
     * Sets the message to the given value.
     * @param message exception message
     */
    public void setMessage(String message) {
        this.msg = message;
    }

}
