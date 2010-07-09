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
package com.redhat.rhn.frontend.xmlrpc.system;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.NoSuchSystemException;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * XmlRpcSystemHelper
 * Helper methods specific to the xml-rpc stack. This class should not be used outside of
 * the xml-rpc domain as it throws Xml-Rpc specific FaultExceptions.
 * @version $Rev$
 */
public class XmlRpcSystemHelper {

    // private instance
    private static XmlRpcSystemHelper helper = new XmlRpcSystemHelper();

    // private constructor
    private XmlRpcSystemHelper() {
    }

    /**
     * @return Returns the running instance of this helper class
     */
    public static XmlRpcSystemHelper getInstance() {
        return helper;
    }

    /**
     * Helper method to lookup a server from an sid, and throws a FaultException
     * if the server cannot be found.
     * @param user The user looking up the server
     * @param sid The id of the server we're looking for
     * @return Returns the server corresponding to sid
     * @throws NoSuchSystemException A NoSuchSystemException is thrown if the server
     * corresponding to sid cannot be found.
     */
    public Server lookupServer(User user, Number sid) throws NoSuchSystemException {
        Long serverId = new Long(sid.longValue());

        try {
            Server server = SystemManager.lookupByIdAndUser(serverId, user);

            // throw a no_such_system exception if the server was not found.
            if (server == null) {
                throw new NoSuchSystemException("No such system - sid = " + sid);
            }

            return server;
        }
        catch (LookupException e) {
            throw new NoSuchSystemException("No such system - sid = " + sid);
        }
    }

    /**
     * Helper method to lookup a bunch of servers from a list of  server ids,
     * and throws a FaultException
     * if the server cannot be found.
     * @param user The user looking up the server
     * @param serverIds The ids of the servers we're looking for
     * @return Returns a list of server corresponding to provided server id
     * @throws NoSuchSystemException A NoSuchSystemException is thrown if the server
     * corresponding to sid cannot be found.
     */
    public List<Server> lookupServers(User user,
                List< ? extends Number> serverIds)  throws NoSuchSystemException {
        List<Server> servers = new LinkedList<Server>();
        for (Number sid : serverIds) {
            servers.add(lookupServer(user, sid));
        }
        return servers;
    }


    /**
     * Basically creates a Minimalist representation of a
     * server object.. This is what will be retuned
     * in most cases when some one requests a server..
     * @param server server to format
     * @return a Map with just enough info to get details on a server
     */
    public Map format(Server server) {
        Map serverMap = new HashMap();
        serverMap.put("id", server.getId());
        serverMap.put("name", server.getName());
        serverMap.put("last_checkin", server.getLastCheckin());
        return serverMap;
    }

}
