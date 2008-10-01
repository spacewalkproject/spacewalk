/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import java.util.Arrays;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$ 
 */
public class CobblerDistroDeleteCommand extends CobblerCommand {


    /**
     * Constructor
     * @param ksDataIn to sync
     * @param cobblerTokenIn to auth with
     */
    public CobblerDistroDeleteCommand(KickstartData ksDataIn,
            String cobblerTokenIn) {
        super(ksDataIn, cobblerTokenIn);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        String[] args = { 
                this.ksData.getKsdefault().getKstree().getLabel(), xmlRpcToken};
        Boolean rc = (Boolean) invokeXMLRPC("remove_distro", Arrays.asList(args));
        if (rc == null || !rc.booleanValue()) {
            return new ValidatorError("cobbler.profile.remove_failed");
        }
        else {
            return null;
        }
    }


}
