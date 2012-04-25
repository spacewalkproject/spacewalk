/**
 * Copyright (c) 2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.system.scap;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

import com.redhat.rhn.domain.action.scap.ScapAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemScapHandler
 * @version $Rev$
 * @xmlrpc.namespace system.scap
 * @xmlrpc.doc Provides methods to schedule SCAP scans and access the results.
 */
public class SystemScapHandler extends BaseHandler {

    /**
     * Run OpenSCAP XCCDF Evaluation on a given list of servers
     * @param sessionKey The session key.
     * @param serverIds The list of server ids,
     * @param xccdfPath The path to xccdf document.
     * @param oscapParams The additional params for oscap tool.
     * @return ID of new SCAP action.
     *
     * @xmlrpc.doc Schedule OpenSCAP scan.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #array_single("int", "serverId")
     * @xmlrpc.param #param("string", "Path to xccdf content on targeted systems.")
     * @xmlrpc.param #param("string", "Additional parameters for oscap tool.")
     * @xmlrpc.returntype int - ID if SCAP action created.
     */
    public int scheduleXccdfScan(String sessionKey, List serverIds,
            String xccdfPath, String oscapParams) {
        return scheduleXccdfScan(sessionKey, serverIds, xccdfPath,
                oscapParams, new Date());
    }

    /**
     * Run OpenSCAP XCCDF Evaluation on a given list of servers
     * @param sessionKey The session key.
     * @param serverIds The list of server ids,
     * @param xccdfPath The path to xccdf document.
     * @param oscapParams The additional params for oscap tool.
     * @param date The date of earliest occurence.
     * @return ID of new SCAP action.
     *
     * @xmlrpc.doc Schedule OpenSCAP scan.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #array_single("int", "serverId")
     * @xmlrpc.param #param("string", "Path to xccdf content on targeted systems.")
     * @xmlrpc.param #param("string", "Additional parameters for oscap tool.")
     * @xmlrpc.param #param_desc("dateTime.iso8601","date",
     *                       "The date to schedule the action")
     * @xmlrpc.returntype int - ID if SCAP action created.
     */
    public int scheduleXccdfScan(String sessionKey, List serverIds,
             String xccdfPath, String oscapParams, Date date) {
        User loggedInUser = getLoggedInUser(sessionKey);

        HashSet<Long> longServerIds = new HashSet<Long>();
        for (Iterator it = serverIds.iterator(); it.hasNext();) {
            longServerIds.add(new Long((Integer) it.next()));
        }

        ScapAction action = ActionManager.scheduleXccdfEval(loggedInUser,
                longServerIds, xccdfPath, oscapParams, date);
        return action.getId().intValue();
    }

    /**
     * Run Open Scap XCCDF Evaluation on a given server
     * @param sessionKey The session key.
     * @param sid The server id.
     * @param xccdfPath The path to xccdf path.
     * @param oscapParams The additional params for oscap tool.
     * @return ID of the new scap action.
     *
     * @xmlrpc.doc Schedule Scap XCCDF scan.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "Path to xccdf content on targeted system.")
     * @xmlrpc.param #param("string", "Additional parameters for oscap tool.")
     * @xmlrpc.returntype int - ID of the scap action created.
     */
    public int scheduleXccdfScan(String sessionKey, Integer sid,
        String xccdfPath, String oscapParams) {
        return scheduleXccdfScan(sessionKey, sid, xccdfPath, oscapParams, new Date());
    }

    /**
     * Run Open Scap XCCDF Evaluation on a given server at a given time.
     * @param sessionKey The session key.
     * @param sid The server id.
     * @param xccdfPath The path to xccdf path.
     * @param oscapParams The additional params for oscap tool.
     * @param date The date of earliest occurence
     * @return ID of the new scap action.
     *
     * @xmlrpc.doc Schedule Scap XCCDF scan.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "Path to xccdf content on targeted system.")
     * @xmlrpc.param #param("string", "Additional parameters for oscap tool.")
     * @xmlrpc.param #param_desc("dateTime.iso8601","date",
     *                       "The date to schedule the action")
     * @xmlrpc.returntype int - ID of the scap action created.
     */
    // TODO: install all the needed stuff
    public int scheduleXccdfScan(String sessionKey, Integer sid,
            String xccdfPath, String oscapParams, Date date) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()),
                loggedInUser);
        ScapAction action = ActionManager.scheduleXccdfEval(loggedInUser, server,
            xccdfPath, oscapParams, date);
        return action.getId().intValue();
    }
}
