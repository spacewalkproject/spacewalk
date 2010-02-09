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

import com.redhat.rhn.domain.monitoring.MonitoringConstants;

/**
 * Validator for probe states
 * @version $Rev$
 */
class ProbeStateValidator extends ParameterValidator {

    ProbeStateValidator(CommandParameter cp) {
        super(cp);
    }

    /**
     * {@inheritDoc}
     */
    public boolean isConvertible(String value) {
        if (value == null) {
            return true;
        }
        String[] s = MonitoringConstants.PROBE_STATES;
        for (int i = 0; i < s.length; i++) {
            if (s[i].equals(value)) {
                return true;
            }
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public String normalize(String value) {
        if (value != null) {
            value = value.toUpperCase();
        }
        return value;
    }

}
