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


/**
 * Validator for checkbox parameters
 * @version $Rev$
 */
class CheckboxValidator extends ParameterValidator {

    private static final String TRUE = "1";
    private static final String FALSE = "0";

    CheckboxValidator(CommandParameter cp) {
        super(cp);
    }

    /**
     * {@inheritDoc}
     */
    public boolean inRange(String value) {
        return FALSE.equals(value) || TRUE.equals(value);
    }

    /**
     * {@inheritDoc}
     */
    public String normalize(String value) {
        return TRUE.equals(value) ? TRUE : FALSE;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isConvertible(String value) {
        return inRange(value);
    }

}
