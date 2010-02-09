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
package com.redhat.rhn.domain.session;

import com.redhat.rhn.common.RhnRuntimeException;

/**
 * A RuntimeException indicating the WebSession has an invalid id
 * <p>

 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class InvalidSessionIdException extends RhnRuntimeException  {


    /////////////////////////
    // Constructors
    /////////////////////////
        /**
     * Constructor
     * @param message exception message
     */
    public InvalidSessionIdException(String message) {
        super(message);
        // begin member variable initialization
    }

        /**
     * Constructor
     * @param message exception message
     * @param cause the cause (which is saved for later retrieval
     * by the Throwable.getCause() method). (A null value is 
     * permitted, and indicates that the cause is nonexistent or 
     * unknown.)
     */
    public InvalidSessionIdException(String message ,   Throwable cause) {
        super(message, cause);
        // begin member variable initialization
    }

    /////////////////////////
    // Getters/Setters
    /////////////////////////
}
