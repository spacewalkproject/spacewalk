/**
 * Copyright (c) 2013 SUSE LLC
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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerHistoryEvent;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.SystemRecord;
import org.cobbler.XmlRpcException;

import java.util.Date;

/**
 * Powers on a system.
 */
public class CobblerPowerCommand extends CobblerCommand {

    /** The log. */
    private static Logger log = Logger.getLogger(CobblerPowerCommand.class);

    /** The server to power on or off. */
    private Server server;

    /** Power management operation kind. */
    private Operation operation;

    /**
     * Possible power management operations.
     */
    public enum Operation {
        /** Turn on. */
        PowerOn,
        /** Turn off. */
        PowerOff,
        /** Reboot. */
        Reboot
    };

    /**
     * Instantiates a new Cobbler power management command.
     * @param userIn the user running this command
     * @param serverIn the server to power on or off
     * @param operationIn the operation to run
     */
    public CobblerPowerCommand(User userIn, Server serverIn, Operation operationIn) {
        super(userIn);
        server = serverIn;
        operation = operationIn;
    }

    /**
     * Attempts to power on, off or reboot the server.
     * @return any errors
     */
    @Override
    public ValidatorError store() {
        CobblerConnection connection = getCobblerConnection();

        if (server != null) {
            String cobblerId = server.getCobblerId();
            if (!StringUtils.isEmpty(cobblerId)) {
                SystemRecord systemRecord = SystemRecord.lookupById(connection, cobblerId);
                if (systemRecord != null && systemRecord.getPowerType() != null) {
                    boolean success = false;
                    try {
                        switch (operation) {
                        case PowerOn:
                            success = systemRecord.powerOn();
                            break;
                        case PowerOff:
                            success = systemRecord.powerOff();
                            break;
                        default:
                            success = systemRecord.reboot();
                            break;
                        }
                    }
                    catch (XmlRpcException e) {
                        log.error(org.apache.velocity.util.StringUtils.stackTrace(e));
                        log.error(org.apache.velocity.util.StringUtils.stackTrace(e
                            .getCause()));
                    }
                    if (success) {
                        log.debug("Power management operation " + operation.toString() +
                            " on " + server.getId() + " succeded");
                        LocalizationService localizationService = LocalizationService
                            .getInstance();
                        ServerHistoryEvent event = new ServerHistoryEvent();
                        event.setCreated(new Date());
                        event.setServer(server);
                        event.setSummary(localizationService
                            .getPlainText("cobbler.powermanagement." +
                                operation.toString().toLowerCase()));
                        String details = "System has been powered on via " +
                            localizationService.getPlainText("cobbler.powermanagement." +
                                systemRecord.getPowerType());
                        event.setDetails(details);
                        server.getHistory().add(event);

                        return null;
                    }
                    log.error(operation.toString() + " on " + server.getId() +
                            " failed");
                    return new ValidatorError("cobbler.powermanagement.command_failed");
                }
            }
        }
        return new ValidatorError("cobbler.powermanagement.not_configured");
    }
}
