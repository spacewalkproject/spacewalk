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
package com.redhat.rhn.domain.kickstart;

import java.util.Comparator;

/**
 * KickstartCommandComparator this compares custom kickstart commands.
 * It works essentially as this.  We prefer an id, so we compare ids if we can.
 * If we can't then the one with an id is first, if neither objects have an id, we compare
 * customPositions
 * @version $Rev$
 */
public class KickstartCommandComparator implements Comparator {

    /**
     *
     * {@inheritDoc}
     */
    public int compare(Object o1, Object o2) {
        KickstartCommand kc1 = (KickstartCommand) o1;
        KickstartCommand kc2 = (KickstartCommand) o2;

        if (kc1.getId() != null && kc2.getId() != null) {
            return kc1.getId().compareTo(kc2.getId());
        }
        else if (kc1.getId() == null && kc2.getId() == null) {
            return kc1.getCustomPosition().compareTo(kc2.getCustomPosition());
        }
        else if (kc1.getId() != null && kc2.getId() == null) {
           return -1;
        }
        else if (kc1.getId() == null && kc2.getId() != null) {
           return 1;
        }
        return 0;
    }

}
