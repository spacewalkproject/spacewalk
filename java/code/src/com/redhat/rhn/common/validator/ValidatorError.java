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
package com.redhat.rhn.common.validator;



/**
 * <p>
 *  The <code>ValidatorError</code> class represents an error while
 *  validating an object.
 * </p>
 * @version $Rev: 1710 $
 */
public class ValidatorError extends ValidationMessage {
    
    /**
    * Construct a ValidatorError with the proper
    * key and values 
    * @param keyIn the key to use to lookup the localized string
    * @param valuesIn the values to substitute in the message
    */
    public ValidatorError(String keyIn, Object... valuesIn) {
        super(keyIn, valuesIn);
    }


    /**
     * Construct a new ValidatorError with the specified
     * l10n key
     * @param keyIn the key to use to lookup the localized string
     */
    public ValidatorError(String keyIn) {
        super(keyIn);
    }
    
    /** {@inheritDoc} */
    public String toString() {
        return "ValidatorError [Key: " + getKey() + "]";
    }
}
