/**
 * Copyright (c) 2017 SUSE LLC
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

/**
 *  The <code>LongConstraint</code> class represents a constraint of type Long,
 *    including the required ranges.
 */
public class LongConstraint extends RequiredIfConstraint {

    /** Logger instance */
    private static Logger log = Logger.getLogger(LongConstraint.class);

    /** Minimum inclusive value allowed */
    private Long minInclusive;

    /** Maximum inclusive value allowed */
    private Long maxInclusive;

    /**
     *  This will create a new <code>Constraints</code> with the specified
     *    identifier as the "name".
     *
     * @param identifierIn <code>String</code> identifier for <code>Constraint</code>.
     */
    public LongConstraint(String identifierIn) {
        super(identifierIn);
        this.minInclusive = Long.MIN_VALUE;
        this.maxInclusive = Long.MAX_VALUE;
    }

    /** {@inheritDoc} */
    public ValidatorError checkConstraint(Object value) {

        ValidatorError requiredCheck = super.checkConstraint(value);
        if (requiredCheck != null) {
            return requiredCheck;
        }

        String localizedIdentifier =
            LocalizationService.getInstance().getMessage(getIdentifier());

        // Validate against range specifications
        try {
            long longValue = new Long(value.toString()).longValue();
            // Now we know its a valid number
            if (longValue < getMinInclusive().longValue()) {
                log.debug("Number too small ...");
                Object[] args = new Object[2];
                args[0] = localizedIdentifier;
                args[1] = getMinInclusive();
                return new ValidatorError("errors.minsize", args);
            }
            if (longValue > getMaxInclusive().longValue()) {
                log.debug("Number too big ...");
                Object[] args = new Object[2];
                args[0] = localizedIdentifier;
                args[1] = getMaxInclusive();
                return new ValidatorError("errors.maxsize", args);
            }
        }
        catch (NumberFormatException e) {
            log.debug("NumberFormatException .. ");
            Object[] args = new Object[1];
            args[0] = localizedIdentifier;
            return new ValidatorError("errors.notanumber", args);
        }

        return null;
    }

    /**
     *  This will set the minimum allowed value for this data type (inclusive).
     *
     * @param minInclusiveIn minimum allowed value (inclusive)
     */
    public void setMinInclusive(Long minInclusiveIn) {
        this.minInclusive = minInclusiveIn;
    }

    /**
     *  This will return the minimum allowed value for this data type (inclusive).
     *
     * @return <code>Double</code> - minimum value allowed (inclusive)
     */
    public Long getMinInclusive() {
        return minInclusive;
    }

    /**
     *  This will set the maximum allowed value for this data type (inclusive).
     *
     * @param maxInclusiveIn maximum allowed value (inclusive)
     */
    public void setMaxInclusive(Long maxInclusiveIn) {
        this.maxInclusive = maxInclusiveIn;
    }

    /**
     *  This will return the maximum allowed value for this data type (inclusive).
     *
     * @return <code>Double</code> - maximum value allowed (inclusive)
     */
    public Long getMaxInclusive() {
        return maxInclusive;
    }
}
