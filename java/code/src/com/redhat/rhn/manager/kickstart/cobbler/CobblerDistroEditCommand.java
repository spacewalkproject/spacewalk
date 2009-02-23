/**
 * Copyright (c) 2009 Red Hat, Inc.
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
public class CobblerDistroEditCommand extends CobblerDistroCommand {

    
    /**
     * Constructor
     * @param ksTreeIn to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerDistroEditCommand(KickstartableTree ksTreeIn,
            User userIn) {
        super(ksTreeIn, userIn);
    }

    private static Logger log = Logger.getLogger(CobblerDistroEditCommand.class);
    
    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        
        Map cDistro = getDistroMap();
        // now that we have saved the distro to the filesystem
        // we need to reflect this in the actual Java object. 
        
        // Get a new handle because the old handled pointed to 
        // the old object and if we call save_distro below we will
        // get a new distro saved.
        
        String cDistroName = (String)cDistro.get("name");
        String handle = (String) invokeXMLRPC("get_distro_handle",
                                        cDistroName, xmlRpcToken);
        String spacewalkName = makeCobblerName(tree);
        if (!spacewalkName.equals(cDistroName)) {
            invokeXMLRPC("rename_distro", handle, spacewalkName, xmlRpcToken);
            handle = (String) invokeXMLRPC("get_distro_handle", 
                                            spacewalkName, xmlRpcToken);            
        }        
        updateCobblerFields(handle);
        invokeXMLRPC("save_distro", handle, xmlRpcToken);
        invokeCobblerUpdate();
        return null;
    }

}
