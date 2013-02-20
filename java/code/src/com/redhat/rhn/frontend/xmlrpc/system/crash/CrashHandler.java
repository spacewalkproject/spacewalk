/**
 * Copyright (c) 2013 Red Hat, Inc.
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

package com.redhat.rhn.frontend.xmlrpc.system.crash;

import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.NoCrashesFoundException;
import com.redhat.rhn.frontend.xmlrpc.system.XmlRpcSystemHelper;
import com.redhat.rhn.domain.server.CrashCount;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

import java.util.Date;

/**
 * CrashHandler
 * @version $Rev$
 * @xmlrpc.namespace system.crash
 * @xmlrpc.doc Provides methods to access and modify software crash information.
 */
public class CrashHandler extends BaseHandler {

    private static Logger log = Logger.getLogger(SystemCrashHandler.class);

    private CrashCount getCrashCount(Server serverIn) {
        CrashCount crashCount = serverIn.getCrashCount();
        if (crashCount == null) {
            throw new NoCrashesFoundException();
        }
        return crashCount;
    }

    /**
     * Return date of last software crashes report for given system.
     * @param sessionKey Session key
     * @param serverId Server ID
     * @return Date of the last software crash report.
     *
     * @xmlrpc.doc Return date of last software crashes report for given system
     * @xmlrpc.param @param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype dateTime.iso8601 - Date of the last software crash report.
     */
    public Date getLastReportDate(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        Server server = sysHelper.lookupServer(loggedInUser, serverId);

        CrashCount crashCount = getCrashCount(server);
        return crashCount.getLastReport();
    }


    /**
     * Return number of unique software crashes for given system.
     * @param sessionKey Session key
     * @param serverId Server ID
     * @return Number of unique software crashes.
     *
     * @xmlrpc.doc Return number of unique software recorded crashes for given system
     * @xmlrpc.param @param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype int - Number of unique software crashes
     */
    public long getUniqueCrashCount(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        Server server = sysHelper.lookupServer(loggedInUser, serverId);

        CrashCount crashCount = getCrashCount(server);
        return crashCount.getUniqueCrashCount();
    }

    /**
     * Return total number of software recorded crashes for given system.
     * @param sessionKey Session key
     * @param serverId Server ID
     * @return Total number of recorded software crashes.
     *
     * @xmlrpc.doc Return total number of software recorded crashes for given system
     * @xmlrpc.param @param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype int - Total number of recorded software crashes
     */
    public long getTotalCrashCount(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        Server server = sysHelper.lookupServer(loggedInUser, serverId);

        CrashCount crashCount = getCrashCount(server);
        return crashCount.getTotalCrashCount();
    }
}
