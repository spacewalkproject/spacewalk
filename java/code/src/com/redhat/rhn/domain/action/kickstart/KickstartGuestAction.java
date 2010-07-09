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
package com.redhat.rhn.domain.action.kickstart;

import com.redhat.rhn.domain.action.Action;


/**
 * KickstartGuestAction
 * @version $Rev$
 */
public class KickstartGuestAction extends Action {


    private KickstartGuestActionDetails kickstartGuestActionDetails;

    /**
     * Get the detail record associated with this KickstartGuestAction
     *
     * @return Returns the kickstartGuestActionDetails.
     */
    public KickstartGuestActionDetails getKickstartGuestActionDetails() {
        return kickstartGuestActionDetails;
    }

    /**
     * Set the detail record associated with this KickstartGuestAction
     * @param kickstartGuestActionDetailsIn The kickstartGuestActionDetails to set.
     */
    public void setKickstartGuestActionDetails(
            KickstartGuestActionDetails kickstartGuestActionDetailsIn) {
        this.kickstartGuestActionDetails = kickstartGuestActionDetailsIn;
    }
}
