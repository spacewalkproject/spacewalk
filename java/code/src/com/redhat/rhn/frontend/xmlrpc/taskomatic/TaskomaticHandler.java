/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.taskomatic;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;

import org.apache.log4j.Logger;

import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.List;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;


/**
 * TaskoHandler - translates all the taskomatic API calls to the internal
 * taskomatic xmlrpc handler
 * @version $Rev$
 */
public class TaskomaticHandler extends BaseHandler {

    private String TASKOMATIC_NAMESPACE = "tasko";
    private XmlRpcClient client;
    private static Logger log = Logger.getLogger(TaskomaticHandler.class);

    /**
     * default constructor
     */
    public TaskomaticHandler() {
        try {
            client = new XmlRpcClient(ConfigDefaults.get().getTaskoServerUrl(), false);
        }
        catch (MalformedURLException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * translates any taskomatic API call to the internal taskomatic xmlrpc hanlder
     * @param methodCalled method to be forwarded
     * @param arguments list of argumets to be translated
     * @return forwarded result of the internal xmlrpc API
     * @throws XmlRpcFault in case of any exception
     */
    public Object invoke(String methodCalled, List arguments) throws XmlRpcFault {
        List params = new ArrayList(arguments);
        String sessionKey = (String) params.remove(0);
        User loggedInUser =  getLoggedInUser(sessionKey);
        checkUserRole(loggedInUser);

        addParameters(loggedInUser, params);

        log.info("Translating " + methodCalled);

        try {
            Object obj = client.invoke(TASKOMATIC_NAMESPACE + "." + methodCalled, params);
            return obj;
        }
        catch (XmlRpcException e) {
            throw new XmlRpcFault(1, e.getMessage());
        }
    }

    protected void checkUserRole(User user) {
        ensureUserRole(user, RoleFactory.SAT_ADMIN);
    }

    protected void addParameters(User user, List params) {
        // empty
    }
}
