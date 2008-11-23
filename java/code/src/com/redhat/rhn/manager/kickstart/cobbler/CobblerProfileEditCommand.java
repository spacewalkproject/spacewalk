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
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerProfileEditCommand extends CobblerProfileCommand {

    

    private static Logger log = Logger.getLogger(CobblerProfileEditCommand.class);
    
    /**
     * Constructor
     * @param ksDataIn to sync 
     * @param userIn - user wanting to sync with cobbler
     * @param kickstartUrlIn that the KickstartData can be accessed from.
     */
    public CobblerProfileEditCommand(KickstartData ksDataIn,
            User userIn, String kickstartUrlIn) {
        super(ksDataIn, userIn, kickstartUrlIn);
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        log.debug("ProfileMap: " + this.getProfileMap());
        
        if (!ksData.getCobblerName().equals(ksData.getOldCobblerName())) {
            String handle = (String) invokeXMLRPC("get_profile_handle",
                                        ksData.getOldCobblerName(), xmlRpcToken);
            invokeXMLRPC("rename_profile", handle, 
                        this.ksData.getCobblerName(), xmlRpcToken);
            
        }

        String handle = (String) invokeXMLRPC("get_profile_handle",
                ksData.getCobblerName(), xmlRpcToken);        
        
        updateCobblerFields(handle);
        
        invokeXMLRPC("save_profile", handle, xmlRpcToken);
        return null;

    }

}
