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
 * Validator for integer parameters
 * @version $Rev$
 */
class IntegerValidator extends ParameterValidator {

    public IntegerValidator(CommandParameter cp) {
        super(cp);
    }

    /**
     * {@inheritDoc}
     */
    public boolean inRange(String value) {
        if (value == null) {
            return true;
        }
        int i = Integer.parseInt(value);
        Integer min = getParam().getMinValue();
        Integer max = getParam().getMaxValue();
        return ((min == null || min.intValue() <= i) &&
                (max == null || i <= max.intValue()));
    }

    /**
     * {@inheritDoc}
     */
    public String normalize(String value) {
        return StringUtils.stripToNull(value);
    }

    /**
     * {@inheritDoc}
     */
    public boolean isConvertible(String value) {
        if (value == null) {
            return true;
        }
        try {
            Integer.parseInt(value);
            return true;
        } 
        catch (NumberFormatException e) {
            return false;
        }
    }

}
