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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.satellite.CobblerSyncCommand;

import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.Distro;
import org.cobbler.Profile;
import org.cobbler.SystemRecord;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Configures a Cobbler system, profile and distro to serve a default PXE image
 * for automatic bare-metal server registration.
 *
 * @version $Rev$
 */
public class CobblerEnableBootstrapCommand extends CobblerCommand {

    /** The log. */
    private static Logger log = Logger.getLogger(CobblerEnableBootstrapCommand.class);

    /** If true, skip checking the existence of kernel and initrd files. */
    private boolean skipFileCheck = false;

    /**
     * Standard constructor.
     *
     * @param userIn the user running this command
     */
    public CobblerEnableBootstrapCommand(User userIn) {
        super(userIn);
    }

    /**
     * File-check skipping constructor.
     *
     * @param userIn the user running this command
     * @param skipFileCheckIn if true, skip file checks
     */
    public CobblerEnableBootstrapCommand(User userIn, boolean skipFileCheckIn) {
        super(userIn);
        skipFileCheck = skipFileCheckIn;
    }

    /**
     * Stores a Cobbler system, profile and distro for bare-metal
     * server registration.
     *
     * Replaces existing entries, if any.
     *
     * @return any errors
     */
    @Override
    public ValidatorError store() {
        // remove any existing record
        ValidatorError result = new CobblerDisableBootstrapCommand(user).store();
        if (result != null) {
            return result;
        }

        ConfigDefaults config = ConfigDefaults.get();
        String kernelPath = config.getCobblerBootstrapKernel();
        String initrdPath = config.getCobblerBootstrapInitrd();

        if (!skipFileCheck) {
            if (kernelPath == null || !new File(kernelPath).exists()) {
                log.error("Kernel file not found: " + kernelPath);
                return new ValidatorError("bootstrapsystems.kernel_not_found", kernelPath);
            }
            if (initrdPath == null || !new File(initrdPath).exists()) {
                log.error("Initrd file not found: " + kernelPath);
                return new ValidatorError("bootstrapsystems.initrd_not_found", initrdPath);
            }
        }

        // add new records
        CobblerConnection connection = getCobblerConnection();

        Distro distro = Distro.create(connection, Distro.BOOTSTRAP_NAME, kernelPath,
            initrdPath, new HashMap<Object, Object>());
        distro.setBreed(config.getCobblerBootstrapBreed());
        distro.setArch(config.getCobblerBootstrapArch());
        distro.save();
        log.debug("Distro added");

        Profile profile = Profile.create(connection, Profile.BOOTSTRAP_NAME, distro);
        Map<String, Object> kernelOptions = new HashMap<String, Object>();
        kernelOptions.put("spacewalk_hostname", config.getHostname());
        Long orgId = user.getOrg().getId();
        kernelOptions.put("spacewalk_activationkey", orgId +
            "-spacewalk-bootstrap-activation-key");

        String[] splits = config.getCobblerBootstrapExtraKernelOptions().split("[= ]");
        for (int i = 0; i < splits.length / 2; i++) {
            kernelOptions.put(splits[i * 2], splits[i * 2 + 1]);
        }

        profile.setKernelOptions(kernelOptions);
        profile.save();
        log.debug("Profile added");

        SystemRecord system = SystemRecord
            .create(connection, SystemRecord.BOOTSTRAP_NAME, profile);
        system.save();
        log.debug("System record added");

        ActivationKey activationKey = ActivationKeyFactory.createNewKey(user, null,
            ActivationKey.BOOTSTRAP_TOKEN, "For bootstrap use", null, null, false);
        activationKey.setBootstrap("Y");
        log.debug("Activation key added");

        Set<ServerGroupType> entitlements = activationKey.getEntitlements();
        for (ServerGroupType entitlement : entitlements) {
            activationKey.removeEntitlement(entitlement);
        }
        activationKey.addEntitlement(ServerConstants.getServerGroupTypeBootstrapEntitled());
        log.debug("Entitlement added");

        return new CobblerSyncCommand(user).store();
    }
}
