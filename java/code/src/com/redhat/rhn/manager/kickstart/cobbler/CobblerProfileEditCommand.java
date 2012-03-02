/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.cobbler.Profile;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerProfileEditCommand extends CobblerProfileCommand {
    /**
     * Constructor
     * @param ksDataIn to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerProfileEditCommand(KickstartData ksDataIn,
            User userIn) {
        super(ksDataIn, userIn);
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        if (StringUtils.isBlank(ksData.getCobblerId())) {
            return new CobblerProfileCreateCommand(ksData, user).store();
        }

        Profile prof = Profile.lookupById(CobblerXMLRPCHelper.getConnection(user),
                ksData.getCobblerId());

        if (prof != null) {
            String cobName = makeCobblerName(ksData);
            if (!cobName.equals(prof.getName())) {
                // delete current cfg file
                KickstartFactory.removeKickstartTemplatePath(ksData);
                // create new cfg file
                KickstartFactory.saveKickstartData(ksData);
                // change ks profile name
                prof.setName(cobName);
                // change ks profile cfg path
                prof.setKickstart(this.ksData.buildCobblerFileName());
            }
            updateCobblerFields(prof);
        }

        return null;
    }
}
