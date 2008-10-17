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

import com.redhat.rhn.domain.kickstart.KickstartData;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * CobblerProfileComand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public abstract class CobblerProfileCommand extends CobblerCommand {

    protected KickstartData ksData;

    /**
     * @param cobblerTokenIn - xmlrpc token for cobbler 
     */
    public CobblerProfileCommand(String cobblerTokenIn) {
        super(cobblerTokenIn);
    }
    
    /**
     * @param ksDataIn - KickstartData to sync
     * @param cobblerTokenIn - xmlrpc token for cobbler 
     */
    public CobblerProfileCommand(KickstartData ksDataIn, String cobblerTokenIn) {
        super(cobblerTokenIn);
        this.ksData = ksDataIn;
    }

    /**
     * Get the Cobbler profile associated with this KickstartData
     * @return Map of Cobbler profile fields.
     */
    public Map getProfile() {
        List < String > args = new ArrayList();
        args.add(this.ksData.getCobblerName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_profile", args);
        return retval;
    }

}
