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

import org.apache.log4j.Logger;

import java.util.Arrays;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerProfileCreateCommand extends CobblerProfileCommand {

    private static Logger log = Logger.getLogger(CobblerProfileCreateCommand.class);
    
    
    /**
     * Constructor
     * @param ksDataIn to sync
     * @param cobblerTokenIn to auth
     * @param kickstartUrlIn URL of the kickstart file we are creating.
     */
    public CobblerProfileCreateCommand(KickstartData ksDataIn,
            String cobblerTokenIn, String kickstartUrlIn) {
        super(ksDataIn, cobblerTokenIn);
        this.kickstartUrl = kickstartUrlIn;
    }


     /**
     * Save the Cobbler profile to cobbler.
     * @return ValidatorError if there was a problem
     */
    public ValidatorError store() {
        String[] args = {xmlRpcToken};
        String id = (String) invokeXMLRPC("new_profile", Arrays.asList(args));
        log.debug("id: " + id);
        args = new String[]{id, "name", this.ksData.getLabel(), xmlRpcToken};
        invokeXMLRPC("modify_profile", Arrays.asList(args));
        
        updateCobblerFields(id);
        
        args = new String[]{id, xmlRpcToken};
        invokeXMLRPC("save_profile", Arrays.asList(args));
        this.ksData.setCobblerName(this.ksData.getLabel());
        return null;
    }

}
