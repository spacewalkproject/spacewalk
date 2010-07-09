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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.cobbler.Profile;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerProfileDeleteCommand extends CobblerProfileCommand {


    private static Logger log = Logger.getLogger(CobblerProfileDeleteCommand.class);

    /**
     * Constructor
     * @param ksDataIn to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerProfileDeleteCommand(KickstartData ksDataIn,
            User userIn) {
        super(ksDataIn, userIn);
    }


    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        // No need to delete if it doesnt exist in cobbler
        Profile profile = ksData.getCobblerObject(user);
        if (profile == null) {
            log.warn("No cobbler profile associated with this Profile.");
            return null;
        }
        if (!profile.remove()) {
            return new ValidatorError("cobbler.profile.remove_failed");
        }
        invokeCobblerUpdate();
        return null;

    }

}
