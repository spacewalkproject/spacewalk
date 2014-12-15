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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.Image;
import org.cobbler.SystemRecord;
import org.cobbler.XmlRpcException;

import java.io.IOException;

/**
 * Changes power management settings for a server.
 */
public class CobblerPowerSettingsUpdateCommand extends CobblerCommand {

    /**
     * Name of the dummy image that can be created to use power management on
     * systems that do not have an existing Cobbler profile.
     */
    public static final String POWER_MANAGEMENT_DUMMY_NAME = "dummy_for_power_management";

    /** The log. */
    private static Logger log = Logger.getLogger(CobblerPowerSettingsUpdateCommand.class);

    /** The server to update. */
    private Server server;

    /** The new power management scheme. */
    private String powerType;

    /** The new power management IP address or hostname. */
    private String powerAddress;

    /** The new power management username. */
    private String powerUsername;

    /** The new power management password. */
    private String powerPassword;

    /** The new power management id. */
    private String powerId;

    /**
     * Standard constructor. Empty parameters strings can be used to leave
     * existing values untouched.
     * @param userIn the user running this command
     * @param serverIn the server to update
     * @param powerTypeIn the new power management scheme
     * @param powerAddressIn the new power management IP address or hostname
     * @param powerUsernameIn the new power management username
     * @param powerPasswordIn the new power management password
     * @param powerIdIn the new power management id
     */
    public CobblerPowerSettingsUpdateCommand(User userIn, Server serverIn,
        String powerTypeIn, String powerAddressIn, String powerUsernameIn,
        String powerPasswordIn, String powerIdIn) {
        super(userIn);
        server = serverIn;
        powerType = powerTypeIn;
        powerAddress = powerAddressIn;
        powerUsername = powerUsernameIn;
        powerPassword = powerPasswordIn;
        powerId = powerIdIn;
    }

    /**
     * Clears server's power settings
     * @return any errors
     */
    public ValidatorError removeSystemProfile() {
        Long sid = server.getId();
        SystemRecord systemRecord = getSystemRecordForSystem();
        if (systemRecord != null) {
            systemRecord.remove();
            log.debug("Cobbler system profile removed for system " + sid);
        }

        return null;
    }

    private SystemRecord getSystemRecordForSystem() {
        CobblerConnection connection = getCobblerConnection();
        SystemRecord systemRecord = null;

        // is there an existing record? if so, use it
        String cobblerId = server.getCobblerId();
        if (!StringUtils.isEmpty(cobblerId)) {
            systemRecord = SystemRecord.lookupById(connection, cobblerId);
        }
        return systemRecord;
    }

    /**
     * Updates a server's power settings. Creates a Cobbler system profile if it
     * does not exist.
     * @return any errors
     */
    @Override
    public ValidatorError store() {
        Long sid = server.getId();
        SystemRecord systemRecord = getSystemRecordForSystem();

        if (systemRecord == null) {
            log.debug("No Cobbler system record found for system " + sid);
            try {
                CobblerConnection connection = getCobblerConnection();
                Image image = createDummyImage(connection);
                systemRecord = SystemRecord.create(connection,
                    CobblerSystemCreateCommand.getCobblerSystemRecordName(server), image);
                systemRecord.enableNetboot(false);
                server.setCobblerId(systemRecord.getId());
            }
            catch (IOException e) {
                log.error("Could not create temporary file for Cobbler image");
                return new ValidatorError("kickstart.powermanagement.cannot_create_file");
            }
        }

        try {
            log.debug("Setting Cobbler parameters for system " + sid);
            if (powerType != null && !powerType.equals("") &&
                    !powerType.equals(systemRecord.getPowerType())) {
                systemRecord.setPowerType(powerType);
            }
            if (powerAddress != null &&
                    !powerAddress.equals(systemRecord.getPowerAddress())) {
                systemRecord.setPowerAddress(powerAddress);
            }
            if (powerUsername != null &&
                    !powerUsername.equals(systemRecord.getPowerUsername())) {
                systemRecord.setPowerUsername(powerUsername);
            }
            if (powerPassword != null &&
                    !powerPassword.equals(systemRecord.getPowerPassword())) {
                systemRecord.setPowerPassword(powerPassword);
            }
            if (powerId != null && !powerId.equals(systemRecord.getPowerId())) {
                systemRecord.setPowerId(powerId);
            }
            systemRecord.save();
            log.debug("Settings saved for system " + sid);
        }
        catch (XmlRpcException e) {
            Throwable cause = e.getCause();
            if (cause != null) {
                String message = cause.getMessage();
                if (message != null && message.contains("power type must be one of")) {
                    log.error("Unsupported Cobbler power type " + powerType);
                    return new ValidatorError(
                        "kickstart.powermanagement.unsupported_power_type");
                }
                if (message != null && message.contains(
                        "Invalid characters found in input")) {
                    log.error(message);
                    return new ValidatorError("kickstart.powermanagement.invalid_chars");
                }
            }
            throw e;
        }

        return null;
    }

    /**
     * HACK: create a dummy image to be able to add non-netbooting system
     * profile to Cobbler in case one has not already been defined for
     * Kickstart. That is, support Cobbler power management features even with
     * systems that do not need PXE booting.
     * @param connection the connection
     * @return the image
     * @throws IOException Signals that an I/O exception has occurred.
     */
    private Image createDummyImage(CobblerConnection connection) throws IOException {
        Image image = Image.lookupByName(connection, POWER_MANAGEMENT_DUMMY_NAME);
        if (image == null) {
            log.debug("Creating Cobbler dummy image");
            // any existing readable filename is accepted by Cobbler
            String tempFile = "/dev/null";
            image = Image.create(connection, POWER_MANAGEMENT_DUMMY_NAME, Image.TYPE_ISO,
                tempFile);
            image.save();
            log.debug("Cobbler dummy image saved");
        }
        return image;
    }
}
