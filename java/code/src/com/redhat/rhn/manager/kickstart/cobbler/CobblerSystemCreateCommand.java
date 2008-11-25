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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 * Login to Cobbler's XMLRPC API and get a token
 * @version $Rev$
 */
public class CobblerSystemCreateCommand extends CobblerCommand {

    private static Logger log = Logger.getLogger(CobblerSystemCreateCommand.class);
    
    private Server server;
    
    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to create in cobbler
     */
    public CobblerSystemCreateCommand(User userIn, Server serverIn) {
        super(userIn);
        server = serverIn;
    }

    /**
     * Store the System to cobbler
     * @return ValidatorError if the store failed.
     */
    public ValidatorError store() {
        String handle = (String) invokeXMLRPC("new_system", xmlRpcToken);
        log.debug("handle: " + handle);
        invokeXMLRPC("modify_system", handle, "name", server.getName(),
                                 xmlRpcToken);
        Map inet = new HashMap();
        inet.put("macaddress-eth0", "AA:BB:CC:EE:EE:EE");
        Object[] args = new Object[]{handle, "modify-interface", 
                inet, xmlRpcToken};
        invokeXMLRPC("modify_system", Arrays.asList(args));

        args = new String[]{handle, "profile", 
                "f9-x86_64", xmlRpcToken};
        invokeXMLRPC("modify_system", Arrays.asList(args));
        invokeXMLRPC("save_system", handle, xmlRpcToken);
        return null;
    }

    /**
     * @return the system
     */
    public Server getServer() {
        return server;
    }

    public Map getSystemMap() {
        List < String > args = new ArrayList();
        args.add(this.server.getName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_system", args);
        return retval;
    }
}
