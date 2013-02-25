/**
 * Copyright (c) 2013 Red Hat, Inc.
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

package com.redhat.rhn.frontend.action.kickstart;

/**
 * types of kickstart tree update strategies
 * @author sherr
 */
public enum KickstartTreeUpdateType {
    ALL("all"), RED_HAT("red_hat"), NONE("none");
    private String type;

    /**
     * Create a new KickstartTreeUpdateType
     * @param updateType
     */
    KickstartTreeUpdateType(String updateType) {
        type = updateType;
    }

    /**
     * get the type
     * @return the registration type
     */
    public String getType() {
        return type;
    }

    /**
     * Set the type
     * @param updateType the update type to set
     */
    public void setType(String updateType) {
        type = updateType;
    }

    /**
     * Find the appropriate KTUT for a given string
     * @param typeIn the string to search for
     * @return the KTUT
     */
    public static KickstartTreeUpdateType find(String typeIn) {
        if (typeIn.equals(ALL.type)) {
            return ALL;
        }
        else if (typeIn.equals(RED_HAT.type)) {
            return RED_HAT;
        }
        else {
            return NONE;
        }
    }

    /**
     * Standard toString function
     * @return the String to return
     */
    public String toString() {
        return getType();
    }

}
