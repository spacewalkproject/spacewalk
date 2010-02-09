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

import java.util.regex.Pattern;

/**
 * <p>
 *  The <code>Constraint</code> class represents a single data constraint, 
 *    including the data type, allowed values, and required ranges.
 * </p>
 * @version $Rev$
 */
public class RequiredConstraint implements Constraint {
        
    /** The identifier for this constraint */
    private String identifier;

    /** The Java data type for this constraint */
    private String dataType;

    /** flag for ASCII property */
    private boolean ascii;

    /** flag for username property */
    private boolean username;

    /** flag for posix property */
    private boolean posix;
    
    /**
     * <p>
     *  This will create a new <code></code> with the specified
     *    identifier as the "name".
     * </p>
     * 
     * @param identifierIn <code>String</code> identifier for <code>Constraint</code>.
     */
    public RequiredConstraint(String identifierIn) {
        this.identifier = identifierIn;
    }

    /** {@inheritDoc} */
    public ValidatorError checkConstraint(Object value) {
        
        if (value != null) { 

            if (this.ascii && !this.isASCII((String)value)) {
                return new ValidatorError("errors.ascii",
                 LocalizationService.getInstance().getMessage(identifier));
            }

            if (this.username && !this.isValidUserName((String)value)) {
                return new ValidatorError("errors.username",
                 LocalizationService.getInstance().getMessage(identifier));
            }

            if (this.posix && !this.isPosix((String)value)) {
                return new ValidatorError("errors.posix",
                 LocalizationService.getInstance().getMessage(identifier));
            }

            return null;
        }
               
        return new ValidatorError("errors.required", 
            LocalizationService.getInstance().getMessage(identifier));
    }

    /**
     * <p>
     *  This will return the identifier for this <code>Constraint</code>.
     * </p>
     *
     * @return <code>String</code> - identifier for this constraint.
     */
    public String getIdentifier() {
        return identifier;
    }

    /**
     * <p>
     *  This will allow the data type for the constraint to be set. The type is specified
     *    as a Java <code>String</code>.
     * </p>
     *
     * @param dataTypeIn <code>String</code> that is the Java data type for this constraint.
     */
    public void setDataType(String dataTypeIn) {
        this.dataType = dataTypeIn;
    }

    /** {@inheritDoc} */
    public String getDataType() {
        return dataType;
    }


    /** 
     * {@inheritDoc}
     */
    public String toString() {
        return this.getClass().getName() + " : " + identifier + " dataType: " +
            dataType;
    }
    
    /**
     * set the ascii property check
     * @param flg boolean for on/off ascii check
     */
    public void setASCII(boolean flg) {
        ascii = flg;
    }

    /**
     * determines whether the ascii property has been set
     * @return boolean
     */
    public boolean getASCII() {
        return ascii;
    }
 
    /**
     * utility to check whether a string is strictly ascii.
     * @param s string to check for ascii chars
     * @return true if string is all ascii
     */
    private boolean isASCII(final String s) {
        return s.matches("^\\p{ASCII}+$");
    }

    /**
     * determines whether the username property has been set
     * @return boolean
     */
    public boolean getUserName() {
        return username;
    }

    /**
     * set the username property check
     * @param flg boolean for on/off username check
     */
    public void setUserName(boolean flg) {
        username = flg;
    }

    /**
     * small utility to check whether a string is a valid username.
     * @param s string to check for valid username 
     * @return true if string valid
     */
    public boolean isValidUserName(final String s) {
        // username contains ascii chars minus
        // whitespace, &, +, %, ', `, ", =, #
        return s.matches("^\\p{ASCII}+$") &&
            !Pattern.compile("[\\s&+%'`\"=#]").matcher(s).find();
    }

    /**
     * Checks whether a string is a POSIX-compliant username - see
     * http://www.opengroup.org/onlinepubs/009695399/basedefs/xbd_chap03.html#tag_03_276
     * for the definition
     * @param s string to be checked
     * @return true IFF all chars are a-zA-Z0-9._-, not beginning with -
     */
    public boolean isPosix(final String s) {
        return !s.startsWith("-") && s.matches("^[a-zA-Z0-9\\-_.]+$");
    }

    /**
     * Set the posix property check
     * @param flag true IFF we should do POSIX validation
     */
    public void setPosix(boolean flag) {
        posix = flag;
    }
    
    /**
     * Determines whether POSIX flag set
     * @return true IFF we want POSIX validation
     */
    public boolean getPosix() {
        return posix;
    }

}
