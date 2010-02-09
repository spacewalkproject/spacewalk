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
package com.redhat.rhn.domain.monitoring.command;

import org.apache.commons.lang.StringUtils;

/**
 * A class to help with validating values for command
 * parameters
 * @version $Rev$
 */
public abstract class ParameterValidator {

    private CommandParameter param;

    /**
     * Create a new validator backed by <code>cp</code>
     * @param cp the command parameter against which to validate
     */
    protected ParameterValidator(CommandParameter cp) {
        param = cp;
    }

    /**
     * Return the translation key for the data type
     * of the parameter
     * @return the translation key for the data type
     * of the parameter
     */
    public String getTypeKey() {
        return param.getDataTypeName();
    }

    /**
     * Return <code>true</code> if this parameter must always 
     * have a value
     * @return <code>true</code> if this parameter must always 
     * have a value
     */
    public boolean isMandatory() {
        return param.isMandatory();
    }

    /**
     * Return <code>true</code> if <code>value</code> can be 
     * converted to the data type for the parameter
     * @param value the value to check
     * @return <code>true</code> if <code>value</code> can be 
     * converted to the data type for the parameter
     */
    public abstract boolean isConvertible(String value);

    /**
     * Return <code>true</code> if <code>value</code> is in the
     * permissible range for this parameter
     * @param value the value to check
     * @return <code>true</code> if <code>value</code> is in the
     * permissible range for this parameter
     */
    public boolean inRange(String value) {
        return true;
    }

    /**
     * Normalize <code>value</code>. Returns <code>null</code> if the
     * value is considered empty or not present.
     * @param value the value to normalized
     * @return the normalized value
     */
    public String normalize(String value) {
        return StringUtils.isBlank(value) ? null : value;
    }

    /**
     * @return Returns the underlying command parameter.
     */
    protected CommandParameter getParam() {
        return param;
    }

    /**
     * Return <code>true</code> if <code>value</code> is a valid value for
     * this parameter. For more fine-grained checking, use {@link #isMandatory},
     * {@link #isConvertible}, and {@link #inRange}
     * @param value the value to check
     * @return <code>true</code> if <code>value</code> is a valid value for
     * this parameter
     */
    public boolean isValid(String value) {
        return (value != null || 
                !isMandatory()) && isConvertible(value) && inRange(value);
    }
}
