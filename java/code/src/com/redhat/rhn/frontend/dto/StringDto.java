/**
 * Copyright (c) 2015 Red Hat, Inc.
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

package com.redhat.rhn.frontend.dto;

/**
 * StringDto
 */
public class StringDto {

    private String value;

    /**
     * Constructor
     */
    public StringDto() {
        value = null;
    }

    /**
     * Constructor
     * @param valueIn value
     */
    public StringDto(String valueIn) {
        value = valueIn;
    }

    /**
     * @return Returns the value.
     */
    public String getValue() {
        return value;
    }

    /**
     * @param valueIn The value to set.
     */
    public void setValue(String valueIn) {
        this.value = valueIn;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return value;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        return (value == null) ? 0 : value.hashCode();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }

        if (obj instanceof StringDto) {
            if (value == null) {
                return ((StringDto) obj).getValue() == null;
            }
            else {
                return value.equals(((StringDto) obj).getValue());
            }
        }

        return false;
    }

}
