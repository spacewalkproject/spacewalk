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

import java.util.Comparator;

/**
 * Implements the java.util.Comparator class for sorting SystemOverview objects
 * 
 * @version $Rev$
 */
public class SystemOverviewComparator implements Comparator {

    /**
     * {@inheritDoc}
     */
    public int compare(Object firstObj, Object secondObj) {
        /*
         * Sorts in descending order:
         *   Security Errata Count
         *     Bug Errata Count
         *       Enhancement Errata Count
         *         Alphabetically by system name
         */
        SystemOverview first = (SystemOverview) firstObj;
        SystemOverview second = (SystemOverview) secondObj;
        int retval = compareLongs(first.getSecurityErrata(),
                second.getSecurityErrata());
        if (retval == 0) {
            retval = compareLongs(first.getBugErrata(), 
                    second.getBugErrata());
            if (retval == 0) {
                retval = compareLongs(first.getEnhancementErrata(),
                        second.getEnhancementErrata());
                if (retval == 0) {
                    if (first.getName() != null && second.getName() != null) {
                        retval = first.getName().compareTo(second.getName());
                    }
                }
            }
        }
        return retval;
    }
    
    private int compareLongs(Long first, Long second) {
        int retval = -2;
        if (first != null && second == null) {
            retval = 1;
        }
        else if (first == null && second != null) {
            retval = -1;
        }
        else if (first == null && second == null) {
            retval = 0;
        }
        if (retval == -2) {
            long diff = first.longValue() - second.longValue();
            if (diff < 0) {
                retval = -1;
            }
            else if (diff > 0) {
                retval = 1;
            }
            else {
                retval = 0;
            }
        }
        return retval * -1;
    }

}
