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
package com.redhat.rhn.common.validator;

import com.redhat.rhn.common.RhnRuntimeException;

/**
 * A RuntimeException indicating a fatal failure trying to use the ValidatorService
 * <p>

 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class ValidatorException extends RhnRuntimeException  {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 5157860212794007766L;
    private ValidatorResult result;
    /////////////////////////
    // Constructors
    /////////////////////////
        /**
     * Constructor
     * @param message exception message
     */
    public ValidatorException(String message) {
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
    public ValidatorException(String message ,   Throwable cause) {
        super(message, cause);
        // begin member variable initialization
    }

    /**
     *
     * @param valResult attach a validator result to the exception.
     */
    public ValidatorException(ValidatorResult valResult) {
        super();
        result = valResult;
    }

    /**
     * Helper method to raise a ValidatorException given a single error msg
     * @param key the msg key
     * @param args the args that go with the key.
     */
    public static void raiseException(String key, Object... args) {
        ValidatorResult valResult = new ValidatorResult();
        valResult.addError(key, args);
        throw new ValidatorException(valResult);
    }
    /**
     *
     * {@inheritDoc}
     */
    @Override
    public String getMessage() {
        if (result == null) {
            return super.getMessage();
        }
        else {
            return result.getMessage();
        }
    }

    /**
     *
     * @return a validator list associated to this exception
     *          or null if that doesnot exist.
     */
    public ValidatorResult getResult() {
        return result;
    }
    /////////////////////////
    // Getters/Setters
    /////////////////////////


}
