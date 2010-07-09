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
package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.common.messaging.MessageAction;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.satellite.RestartCommand;

import org.apache.log4j.Logger;

/**
 * UpdateErrataCacheAction
 * @version $Rev: 74533 $
 */
public class RestartSatelliteAction implements MessageAction {

    private static Logger log = Logger.getLogger(RestartSatelliteAction.class);

    /**
     * {@inheritDoc}
     */
    public void execute(EventMessage msgIn) {

        RestartSatelliteEvent evt = (RestartSatelliteEvent) msgIn;
        User user = evt.getUser();
        RestartCommand rc = getCommand(user);
        // This is a pretty intrusive action so we want to log it.
        log.warn("Restarting satellite.");
        ValidatorError[] errors = rc.storeConfiguration();
        if (errors != null) {
            for (int i = 0; i < errors.length; i++) {
                ValidatorError error = errors[i];
                log.error("Error trying to restart the satellite: " +
                        LocalizationService.getInstance()
                        .getMessage(error.getKey(), evt.getUserLocale()));
            }
        }

    }

    protected RestartCommand getCommand(User currentUser) {
        RestartCommand rc = new RestartCommand(currentUser);
        return rc;
    }

}
