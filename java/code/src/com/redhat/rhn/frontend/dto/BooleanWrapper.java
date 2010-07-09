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
package com.redhat.rhn.frontend.dto;

import org.apache.commons.lang.BooleanUtils;

/**
 * BooleanWrapper
 * @version $Rev$
 */
public class BooleanWrapper {

    private Boolean bool;

    /**
     * Sets the boolean value to the given value.
     * @param aBool the value to be used
     */
    public void setBool(Boolean aBool) {
        bool = aBool;
    }

    /**
     * Sets the boolean value to true if the aBool is 1, false if aBool is 0.
     * @param aBool the value to be used
     */
    public void setBool(Integer aBool) {
        bool = BooleanUtils.toBooleanObject(aBool);
    }

    /**
     * Returns the Boolean value.
     * @return the Boolean value.
     */
    public Boolean getBool() {
        return bool;
    }

    /**
     * Returns the boolean value
     * @return the boolean value
     */
    public boolean booleanValue() {
        if (bool != null) {
            return bool.booleanValue();
        }

        return false;
    }
}
