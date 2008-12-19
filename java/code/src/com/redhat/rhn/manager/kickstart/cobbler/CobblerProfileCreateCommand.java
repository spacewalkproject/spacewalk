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

import java.util.HashMap;
import java.util.Map;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerProfileCreateCommand extends CobblerProfileCommand {

    private static Logger log = Logger.getLogger(CobblerProfileCreateCommand.class);
    
    
    /**
     * Constructor
     * @param ksDataIn to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerProfileCreateCommand(KickstartData ksDataIn, User userIn) {
        super(ksDataIn, userIn);
    }

    /**
     * Call this if you want to use the taskomatic_user.
     * 
     * Useful for automated non-user initiated syncs
     * @param ksDataIn to sync
     */
    public CobblerProfileCreateCommand(KickstartData ksDataIn) {
        super(ksDataIn);
    }



     /**
     * Save the Cobbler profile to cobbler.
     * @return ValidatorError if there was a problem
     */
    public ValidatorError store() {
        String id = (String) invokeXMLRPC("new_profile", xmlRpcToken);
        log.debug("id: " + id);
        invokeXMLRPC("modify_profile", id, "name", 
                           CobblerCommand.makeCobblerName(this.ksData), xmlRpcToken);
        updateCobblerFields(id);
        Map<String, Object> meta = new HashMap<String, Object>();
        meta.put("org", ksData.getOrg().getId());
        invokeXMLRPC("modify_profile", id, "ksmeta", meta, xmlRpcToken);
        invokeXMLRPC("save_profile", id, xmlRpcToken);
        
        invokeCobblerUpdate();
        Map cProfile = getProfileMap();
        ksData.setCobblerId((String)cProfile.get("uid"));
        return null;
    }

}
