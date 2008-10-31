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

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.List;

import redstone.xmlrpc.XmlRpcFault;


/**
 * 
 * Login to Cobbler's XMLRPC API and get a token
 * @version $Rev$
 */
public class CobblerLoginCommand {

    private static Logger log = Logger.getLogger(CobblerLoginCommand.class);
    
    private String username;
    private String password;
    
    /**
     * Constructor
     * @param usernameIn who is logging in
     * @param passwordIn of user
     */
    public CobblerLoginCommand(String usernameIn, String passwordIn) {
        username = usernameIn;
        password = passwordIn;
    }

    /**
     * Call the login method and return the token if valid
     * @return String token
     */
    public String login() {
        XMLRPCHelper helper = new XMLRPCHelper();
        List args = new ArrayList();
        args.add(username);
        args.add(password);
        String retval = null;
        try {
            retval = (String) helper.invokeXMLRPC("login", args);
        }
        catch (XmlRpcFault e) {
            log.error("XmlRpcFault while logging in.  " +
                    "most likely user doesn't have permissions. ", e);
        }
        log.debug("token received from cobbler: " + retval);
        return retval;
    }

}
