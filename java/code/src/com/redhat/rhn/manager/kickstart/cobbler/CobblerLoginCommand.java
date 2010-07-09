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

import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.frontend.xmlrpc.util.XMLRPCInvoker;

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

    /**
     * Call the login method and return the token if valid
     * @param usernameIn of user wanting to login to cobbler
     * @param passwordIn of user wanting to login
     * @return String token
     */
    public String login(String usernameIn, String passwordIn) {
        XMLRPCInvoker helper =
            (XMLRPCInvoker) MethodUtil.getClassFromConfig(
                    CobblerXMLRPCHelper.class.getName());
        List args = new ArrayList();
        args.add(usernameIn);
        args.add(passwordIn);
        String retval = null;
        try {
            retval = (String) helper.invokeMethod("login", args);
        }
        catch (XmlRpcFault e) {
            log.error("XmlRpcFault while logging in.  " +
                    "most likely user doesn't have permissions. ", e);
            throw new NoCobblerTokenException(
                    "We had an error trying to login.", e);
        }
        log.debug("token received from cobbler: " + retval);
        return retval;
    }

    /**
     * Check to see if the passed in token is still valid from
     * cobbler's perspective.  If it is, return true, else return
     * false.
     *
     * @param token to check
     * @return boolean indicating validity
     */
    public boolean checkToken(String token) {
        XMLRPCInvoker helper =
            (XMLRPCInvoker) MethodUtil.getClassFromConfig(
                    CobblerXMLRPCHelper.class.getName());
        List args = new ArrayList();
        args.add(token);
        Boolean retval = null;
        try {
            retval = (Boolean) helper.invokeMethod("token_check", args);
            if (retval == null) {
                return false;
            }
        }
        catch (XmlRpcFault e) {
            if (e.getMessage().contains("invalid token")) {
                return false;
            }
            log.error("XmlRpcFault while logging in.  " +
                    "most likely user doesn't have permissions. ", e);
            throw new NoCobblerTokenException(
                    "We errored out trying to check the token.", e);
        }
        log.debug("token received from cobbler: " + retval);

        return retval.booleanValue();
    }

}
