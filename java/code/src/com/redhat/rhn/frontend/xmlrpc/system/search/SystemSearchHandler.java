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
package com.redhat.rhn.frontend.xmlrpc.system.search;

import java.net.MalformedURLException;
import java.util.Collections;

import org.apache.log4j.Logger;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcFault;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.FaultException;
import com.redhat.rhn.frontend.action.systems.SystemSearchHelper;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.CommunicationErrorSearchServer;
import com.redhat.rhn.frontend.xmlrpc.ErrorWithSearchQuery;

/**
 * SystemSearchHandler
 * Provides access to the internal XMLRPC search-server for system searches
 * @version $Rev: 1 $
 *
 */
public class SystemSearchHandler extends BaseHandler {
    private static Logger log = Logger.getLogger(SystemSearchHandler.class);

    private DataResult performSearch(String sessionKey, String searchString,
            String viewMode) throws FaultException {
        Boolean invertResults = false;
        String whereToSearch = ""; // if this is "system_list" it will search SSM only

        DataResult dr = null;
        try {
            dr = SystemSearchHelper.systemSearch(sessionKey,
                    searchString,
                    viewMode,
                    invertResults,
                    whereToSearch);
        }
        catch (MalformedURLException e) {
            log.info("Caught Exception :" + e);
            e.printStackTrace();
            throw new CommunicationErrorSearchServer();
            // Connection error to XMLRPC search server
        }
        catch (XmlRpcFault e) {
            log.info("Caught Exception :" + e);
            log.info("ErrorCode = " + e.getErrorCode());
            e.printStackTrace();
            if (e.getErrorCode() == 100) {
                log.error("Invalid search query", e);
            }
            throw new ErrorWithSearchQuery();
            // Could not parse query
        }
        catch (XmlRpcException e) {
            log.info("Caught Exception :" + e);
            e.printStackTrace();
            // Connection error
            throw new CommunicationErrorSearchServer();
        }
        if (dr != null) {
            dr.elaborate(Collections.EMPTY_MAP);
        }
        return dr;
    }

    /**
     * List the systems which match this ip.
     * @param sessionKey the session of the user
     * @param searchTerm the search term to match
     * @return list of systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the systems which match this ip.
     * @xmlrpc.param #param("string", "sessionKey", "searchTerm")
     * @xmlrpc.returntype array
     *              $SystemSearchResultSerializer
     */
    public Object[] ip(String sessionKey, String searchTerm)
        throws FaultException {
        DataResult result = performSearch(sessionKey, searchTerm, SystemSearchHelper.IP);
        return result.toArray();
    }

    /**
     * List the systems which match this hostname
     * @param sessionKey the session of the user
     * @param searchTerm the search term to match
     * @return list of systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the systems which match this hostname
     * @xmlrpc.param #param("string", "sessionKey", "searchTerm")
     * @xmlrpc.returntype array
     *              $SystemSearchResultSerializer
     */
    public Object[] hostname(String sessionKey, String searchTerm)
        throws FaultException {
        DataResult result = performSearch(sessionKey, searchTerm,
                SystemSearchHelper.HOSTNAME);
        return result.toArray();
    }

    /**
     * List the systems which match this device vendor id
     * @param sessionKey the session of the user
     * @param searchTerm the search term to match
     * @return list of systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the systems which match this device vendor_id
     * @xmlrpc.param #param("string", "sessionKey", "searchTerm")
     * @xmlrpc.returntype array
     *              $SystemSearchResultSerializer
     */
    public Object[] deviceVendorId(String sessionKey, String searchTerm)
        throws FaultException {
        DataResult result = performSearch(sessionKey, searchTerm,
                SystemSearchHelper.HW_VENDOR_ID);
        return result.toArray();
    }

    /**
     * List the systems which match this device id
     * @param sessionKey the session of the user
     * @param searchTerm the search term to match
     * @return list of systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the systems which match this device id
     * @xmlrpc.param #param("string", "sessionKey", "searchTerm")
     * @xmlrpc.returntype array
     *              $SystemSearchResultSerializer
     */
    public Object[] deviceId(String sessionKey, String searchTerm)
        throws FaultException {
        DataResult result =  performSearch(sessionKey, searchTerm,
                SystemSearchHelper.HW_DEVICE_ID);
        return result.toArray();
    }

    /**
     * List the systems which match this device driver
     * @param sessionKey the session of the user
     * @param searchTerm the search term to match
     * @return list of systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the systems which match this device driver.
     * @xmlrpc.param #param("string", "sessionKey", "searchTerm")
     * @xmlrpc.returntype array
     *              $SystemSearchResultSerializer
     */
    public Object[] deviceDriver(String sessionKey, String searchTerm)
        throws FaultException {
        DataResult result =  performSearch(sessionKey, searchTerm,
                SystemSearchHelper.HW_DRIVER);
        return result.toArray();
    }

    /**
     * List the systems which match this device description
     * @param sessionKey the session of the user
     * @param searchTerm the search term to match
     * @return list of systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the systems which match the device description.
     * @xmlrpc.param #param("string", "sessionKey", "searchTerm")
     * @xmlrpc.returntype array
     *              $SystemSearchResultSerializer
     */
    public Object[] deviceDescription(String sessionKey, String searchTerm)
        throws FaultException {
        DataResult result = performSearch(sessionKey, searchTerm,
                SystemSearchHelper.HW_DESCRIPTION);
        return result.toArray();
    }

    /**
     * List the systems which match this name or description
     * @param sessionKey the session of the user
     * @param searchTerm the search term to match
     * @return list of systems
     * @throws FaultException A FaultException is thrown on error.
     *
     * @xmlrpc.doc List the systems which match this name or description
     * @xmlrpc.param #param("string", "sessionKey", "searchTerm")
     * @xmlrpc.returntype array
     *              $SystemSearchResultSerializer
     */
    public Object[] nameAndDescription(String sessionKey, String searchTerm)
        throws FaultException {
        DataResult result = performSearch(sessionKey, searchTerm,
                SystemSearchHelper.NAME_AND_DESCRIPTION);
        return result.toArray();
    }

}
