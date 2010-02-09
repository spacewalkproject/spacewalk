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

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.log4j.Logger;

import java.io.UnsupportedEncodingException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * <p>
 *  The <code>Constraint</code> class represents a single data constraint, 
 *    including the data type, allowed values, and required ranges.
 * </p>
 * @version $Rev: 94458 $
 */
public class StringConstraint extends RequiredIfConstraint {

    protected static Logger log = Logger.getLogger(StringConstraint.class);
    
    /** Min length of the string */
    protected Double minLength;
    
    /** Max length of the String */
    protected Double maxLength;
    
    /** String must match this regular expression **/
    protected String regEx;
    
    /**
     * <p>
     *  This will create a new <code>Constraints</code> with the specified
     *    identifier as the "name".
     * </p>
     * 
     * @param identifierIn <code>String</code> identifier for <code>Constraint</code>.
     */
    public StringConstraint(String identifierIn) {
        super(identifierIn);
    }
    
    private boolean lengthLessThan(String str, Number length) {
        try {
            return str.getBytes("UTF8").length <= length.intValue();    
        }
        catch (UnsupportedEncodingException use) {
            log.warn("Couldn;t convert to UTF8-> [" + str + "]");
            return str.length() < length.intValue();    
        }
    }
    
    private boolean lengthGreaterThan(String str, Number length) {
        try {
            return str.getBytes("UTF8").length >= length.intValue();    
        }
        catch (UnsupportedEncodingException use) {
            log.warn("Couldn;t convert to UTF8-> [" + str + "]");
            return str.length() >= length.intValue();    
        }
    }    
    
    /** {@inheritDoc} */
    public ValidatorError checkConstraint(Object value) {

        ValidatorError requiredCheck = super.checkConstraint(value);
        if (requiredCheck != null) {
            return requiredCheck;
        }
        String strValue = (String) value;
        String localizedIdentifier = 
                LocalizationService.getInstance().getMessage(getIdentifier());

        // Validate String length
        if (hasMaxLength()) {
            log.debug("HasMaxlength ..");
            if (!(lengthLessThan(strValue, getMaxLength()))) {
                log.debug("Above max length: " + strValue.length() + " data: " + strValue + 
                        "max length: " + getMaxLength());
                Object[] args = new Object[2];
                args[0] = localizedIdentifier;                
                args[1] = getMaxLength();
                return new ValidatorError("errors.maxlength", args);
            }
        }
        if (hasMinLength()) {
            // If its zero length just warn that the field is required
            // NOTE: We trim the string here.
            if (strValue.trim().length() == 0) {
                Object[] args = new Object[1];
                args[0] = localizedIdentifier;
                return new ValidatorError("errors.required", args);
            }
            if (!(lengthGreaterThan(strValue, getMinLength()))) {
                log.debug("Below min length: " + strValue.length() + " data: " + strValue);
                Object[] args = new Object[2];
                args[0] = localizedIdentifier;
                args[1] = getMinLength();
                return new ValidatorError("errors.minlength", args);
            }
        }
        
        if (hasRegEx()) {
            Pattern pattern = Pattern.compile(regEx);
            Matcher matcher = pattern.matcher(strValue);
            
            if (!matcher.matches()) {
                log.debug("Does not match pattern " + regEx + " data: " + strValue);
                
                return new ValidatorError("errors.invalid", localizedIdentifier);
            }
        }
        
        return null;
    }


    /**
     * Set the max length of the Constraint
     * 
     * @param maxLengthIn The maxLength to set.
     */
    public void setMaxLength(Double maxLengthIn) {
        this.maxLength = maxLengthIn;
    }

    /**
     * @return Returns the maxLength.
     */
    public Double getMaxLength() {
        return maxLength;
    }

    /**
     * <p>
     *  This will return <code>true</code> if a maximum length constraint
     *    exists.
     * </p>
     *
     * @return <code>boolean</code> - whether there is a constraint for the
     *         maximum legnth (inclusive)
     */
    public boolean hasMaxLength() {
        return maxLength != null;
    }


    /**
     * Set the minimum length of the Constraint
     * 
     * @param minLengthIn The minLength to set.
     */
    public void setMinLength(Double minLengthIn) {
        this.minLength = minLengthIn;
    }

    /**
     * @return Returns the minLength.
     */
    public Double getMinLength() {
        return minLength;
    }

    /**
     * <p>
     *  This will return <code>true</code> if a minimum length constraint
     *    exists.
     * </p>
     *
     * @return <code>boolean</code> - whether there is a constraint for the
     *         minimum legnth (inclusive)
     */
    public boolean hasMinLength() {
        return minLength != null;
    }
    
    /** 
     * Sets the regular expression for the Constraint. Must be a String 
     * containing a valid Java  egular expression pattern
     * @param regExIn Java Reg Ex to validate the field against
     */
    public void setRegEx(String regExIn) {
        regEx = regExIn;
    }
    
    /**
     * Returns the regular expression
     * @return regular expression to validate against
     */
    public String getRegEx() {
        return regEx;
    }
    
    /**
     * @return True if a reg ex has been set, false otherwise
     */
    public boolean hasRegEx() {
        return regEx != null;
    }

}
