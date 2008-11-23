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
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

import java.util.Map;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$ 
 */
public class CobblerDistroDeleteCommand extends CobblerDistroCommand {

    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(CobblerDistroDeleteCommand.class);


    /**
     * Constructor
     * @param ksTreeIn to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerDistroDeleteCommand(KickstartableTree ksTreeIn,
            User userIn) {
        super(ksTreeIn, userIn);
    }


    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        
        Map distro = this.getDistroMap();
        if (distro == null || distro.isEmpty()) {
            log.warn("No cobbler distro associated with this Tree.");
            return null;
        }
        Boolean rc = (Boolean) invokeXMLRPC("remove_distro", 
                                    tree.getCobblerDistroName(), xmlRpcToken);
        if (rc == null || !rc.booleanValue()) {
            return new ValidatorError("cobbler.profile.remove_failed");
        }
        else {
            return null;
        }
    }


}
