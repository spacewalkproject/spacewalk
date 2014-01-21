/**
 * Copyright (c) 2013 SUSE
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
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.satellite.CobblerSyncCommand;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.Distro;
import org.cobbler.Profile;
import org.cobbler.SystemRecord;

import java.util.List;

/**
 * Reverses CobblerEnableBootstrapCommand
 */
public class CobblerDisableBootstrapCommand extends CobblerCommand {

    /** The log. */
    private static Logger log = Logger.getLogger(CobblerDisableBootstrapCommand.class);

    /**
     * Standard constructor.
     *
     * @param userIn the user running this command
     */
    public CobblerDisableBootstrapCommand(User userIn) {
        super(userIn);
    }

    /**
     * Removes any existing Cobbler system, profile, distro for bare-metal
     * server registration.
     * @return any errors
     */
    @Override
    public ValidatorError store() {
        CobblerConnection connection = getCobblerConnection();

        // remove any pre-existing record
        SystemRecord previousSystem = SystemRecord.lookupByName(connection,
            SystemRecord.BOOTSTRAP_NAME);
        if (previousSystem != null) {
            if (!previousSystem.remove()) {
                log.error("Could not remove existing system record");
                return new ValidatorError("cobbler.system.remove_failed");
            }
            log.debug("Existing system record removed");
        }
        Profile previousProfile = Profile.lookupByName(connection, Profile.BOOTSTRAP_NAME);
        if (previousProfile != null) {
            if (!previousProfile.remove()) {
                log.error("Could not remove existing profile");
                return new ValidatorError("cobbler.profile.remove_failed");
            }
            log.debug("Existing profile removed");
        }
        Distro previousDistro = Distro.lookupByName(connection, Distro.BOOTSTRAP_NAME);
        if (previousDistro != null) {
            if (!previousDistro.remove()) {
                log.error("Could not remove existing distro");
                return new ValidatorError("cobbler.distro.remove_failed");
            }
            log.debug("Existing distro removed");
        }

        List<ActivationKey> previousActivationKeys = ActivationKeyManager.getInstance()
            .findBootstrap();
        for (ActivationKey key : previousActivationKeys) {
            ActivationKeyFactory.removeKey(key);
        }
        log.debug("Existing activation keys removed");

        return new CobblerSyncCommand(user).store();
    }
}
