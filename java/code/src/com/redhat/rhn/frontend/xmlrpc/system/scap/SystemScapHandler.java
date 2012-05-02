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

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

import com.redhat.rhn.domain.action.scap.ScapAction;
import com.redhat.rhn.domain.audit.ScapFactory;
import com.redhat.rhn.domain.audit.XccdfTestResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.XccdfRuleResultDto;
import com.redhat.rhn.frontend.dto.XccdfTestResultDto;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.MissingCapabilityException;
import com.redhat.rhn.manager.MissingEntitlementException;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.audit.ScapManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemScapHandler
 * @version $Rev$
 * @xmlrpc.namespace system.scap
 * @xmlrpc.doc Provides methods to schedule SCAP scans and access the results.
 */
public class SystemScapHandler extends BaseHandler {

    /**
     * List OpenSCAP XCCDF scans for a given system.
     * @param sessionKey The session key.
     * @param serverId The server ID.
     * @return a list of dto holding this info.
     *
     * @xmlrpc.doc Return a list of finished OpenSCAP scans for a given system.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     * #array()
     *   $XccdfTestResultDtoSerializer
     * #array_end()
     */
    public List<XccdfTestResultDto> listXccdfScans(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);

        /* Make sure the system is available to user and throw a nice exception.
         * If it was not done, an empty list would be returned. */
        SystemManager.ensureAvailableToUser(loggedInUser, new Long(serverId));
        return ScapManager.latestTestResultByServerId(loggedInUser, new Long(serverId));
    }

    /**
     * Get Details of given OpenSCAP XCCDF scan.
     * @param sessionKey The session key.
     * @param xid The id of XCCDF scan.
     * @return a details of OpenSCAP XCCDF scan.
     *
     * @xmlrpc.doc Get details of given OpenSCAP XCCDF scan.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "Id of XCCDF scan (xid).")
     * @xmlrpc.returntype $XccdfTestResultSerializer
     */
    public XccdfTestResult getXccdfScanDetails(String sessionKey, Integer xid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ScapManager.ensureAvailableToUser(loggedInUser, new Long(xid));
        return ScapFactory.lookupTestResultById(new Long(xid));
    }

    /**
     * List RuleResults for given XCCDF Scan.
     * @param sessionKey The session key.
     * @param xid The id of XCCDF scan.
     * @return a list of RuleResults for given scan.
     *
     * @xmlrpc.doc Return a full list of RuleResults for given OpenSCAP XCCDF scan.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "Id of XCCDF scan (xid).")
     * @xmlrpc.returntype
     * #array()
     *   $XccdfRuleResultDtoSerializer
     * #array_end()
     */
    public List<XccdfRuleResultDto> getXccdfScanRuleResults(String sessionKey,
            Integer xid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ScapManager.ensureAvailableToUser(loggedInUser, new Long(xid));
        return (List<XccdfRuleResultDto>) ScapManager.ruleResultsPerScan(new Long(xid));
    }

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

        try {
            ScapAction action = ActionManager.scheduleXccdfEval(loggedInUser,
                    longServerIds, xccdfPath, oscapParams, date);
            return action.getId().intValue();
        }
        catch (MissingEntitlementException e) {
           throw new com.redhat.rhn.frontend.xmlrpc.MissingEntitlementException(
                   e.getMessage());
        }
        catch (MissingCapabilityException e) {
           throw new com.redhat.rhn.frontend.xmlrpc.MissingCapabilityException(
                   e.getCapability(), e.getServer());
        }
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
    public int scheduleXccdfScan(String sessionKey, Integer sid,
            String xccdfPath, String oscapParams, Date date) {
        List serverIds = new ArrayList();
        serverIds.add(sid);
        return scheduleXccdfScan(sessionKey, serverIds, xccdfPath, oscapParams, date);
    }
}
