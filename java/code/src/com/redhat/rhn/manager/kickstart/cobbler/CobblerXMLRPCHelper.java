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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.integration.IntegrationService;
import com.redhat.rhn.frontend.xmlrpc.util.XMLRPCInvoker;

import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;

import java.net.MalformedURLException;
import java.util.List;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

/**
 *
 * XMLRPCHelper - class that contains wraps calls to Redstone's XMLRPC client.
 * Intentionally implements the XMLRPCInvoker interface so we can also provide
 * a mock implementation to our unit tests so they don't require an actual cobbler
 * server.
 *
 * @version $Rev$
 */
public class CobblerXMLRPCHelper implements XMLRPCInvoker {

    private XmlRpcClient client;
    private static Logger log = Logger.getLogger(CobblerXMLRPCHelper.class);
    /**
     * Constructor
     */
    public CobblerXMLRPCHelper() {
        try {
            client = new XmlRpcClient(getCobblerUrl(), false);
        }
        catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * Invoke an XMLRPC method.
     * @param procedureName to invoke
     * @param args to pass to method
     * @return Object returned.
     * @throws XmlRpcFault if expected error occurs
     */
    public Object invokeMethod(String procedureName, List args) throws XmlRpcFault {
        log.debug("procedure: " + procedureName + " Orig args: " + args);
        Object retval;
        try {
            retval = client.invoke(procedureName, args);
        }
        catch (XmlRpcException e) {
            throw new RuntimeException("XmlRpcException calling cobbler.", e);
        }
        return retval;
    }

    /**
     * Returns the a new cobbler connection object
     * @param user the logged in user to ge the auth token
     * @return the authenticated cobbler connection.
     */
    public static CobblerConnection getConnection(User user) {
        return getConnection(user.getLogin());
    }

    /**
     * Returns the new cobbler object, if you can't specify a user
     * @param userName the username
     * @return the autehnticated cobbler connection
     */
    public static CobblerConnection getConnection(String userName) {
        String token =
            IntegrationService.get().getAuthToken(userName);
        return (CobblerConnection)MethodUtil.getClassFromConfig(
                                CobblerConnection.class.getName(),
                                ConfigDefaults.get().getCobblerServerUrl(), token);
    }

    private static String getCobblerUrl() {
        CobblerConnection conn = (CobblerConnection)MethodUtil.getClassFromConfig(
                CobblerConnection.class.getName(),
                ConfigDefaults.get().getCobblerServerUrl());
        return conn.getUrl();
    }

    /**
     * Returns the cobbler anonymous/automated using the connection
     * cobbler automated user config entry..
     * @return the cobbler connection..
     */
    public static CobblerConnection getAutomatedConnection() {
        return getConnection(ConfigDefaults.get().getCobblerAutomatedUser());
    }
}
