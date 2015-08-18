/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.satellite;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.system.XmlRpcSystemHelper;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.List;

/**
 * SatelliteHandler
 *
 * @xmlrpc.namespace satellite
 * @xmlrpc.doc Provides methods to obtain details on the Satellite.
 */
public class SatelliteHandler extends BaseHandler {
    private static Logger log = Logger.getLogger(SatelliteHandler.class);

    /**
     * List all proxies on the Satellite for the current org
     * @param loggedInUser The current user
     * @return  list of Maps containing "id", "name", and "last_checkin"
     *
     * @xmlrpc.doc List the proxies within the user's organization.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     * #array()
     *   $SystemOverviewSerializer
     * #array_end()
     */
    public Object[] listProxies(User loggedInUser) {
        List <Server> proxies = ServerFactory.lookupProxiesByOrg(loggedInUser);
        List toReturn = new ArrayList();
        XmlRpcSystemHelper helper = XmlRpcSystemHelper.getInstance();
        for (Server server : proxies) {
            toReturn.add(helper.format(server));
        }
        return toReturn.toArray();
    }
}
