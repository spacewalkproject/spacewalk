/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * This command finds profiles that have been changed on the cobbler server and syncs
 *  those changes to the satellite
 * @version $Rev$
 */
public class CobblerSystemSyncCommand extends CobblerCommand {

    private Logger log;

    /**
     * Command to sync unsynced Kickstart profiles to cobbler.
     */
    public CobblerSystemSyncCommand() {
        super();
        log = Logger.getLogger(this.getClass());
    }





    /**
     *  Get a map of CobblerID -> profileMap from cobbler
     * @return a list of cobbler profile names
     */
    private Map<String, Map> getModifiedSystemNames() {
        Map<String, Map> toReturn = new HashMap<String, Map>();
        List<Map> systems = (List<Map>)invokeXMLRPC("get_systems", xmlRpcToken);
        for (Map system : systems) {
                toReturn.put((String)system.get("uid"), system);
        }
        return toReturn;
    }


    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        Map<String, Map> systemNames = getModifiedSystemNames();
        log.debug("systemNames: " + systemNames);
        return null;
    }

}
