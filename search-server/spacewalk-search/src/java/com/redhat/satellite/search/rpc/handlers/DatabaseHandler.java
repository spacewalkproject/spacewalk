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

package com.redhat.satellite.search.rpc.handlers;

import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.db.Query;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.index.Result;
import com.redhat.satellite.search.index.QueryParseException;
import com.redhat.satellite.search.scheduler.ScheduleManager;

import com.ibatis.sqlmap.client.SqlMapException;

import org.apache.log4j.Logger;

import redstone.xmlrpc.XmlRpcFault;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * XML-RPC handler which handles calls for database queries
 *
 * TODO:
 * 1) Restrict this class to only being able to call queries
 * defined in specified namespaces, for now that would be: "errataHandler",
 * errata_handler.xml.
 * 2) Screenhits returned, verify these objects are allowed to be seen by the logged in
 * user.
 *
 *
 * @version $Rev$
 */
public class DatabaseHandler {

    private static Logger log = Logger.getLogger(DatabaseHandler.class);
    private DatabaseManager databaseManager;
    /**
     * Constructor
     * @param idxManager IndexManager - unused param, needed for interface compatibility
     * with RpcServer constructing us.
     * @param dbMgr DatabaseManager
     * Will perform database queries
     * @param schedManager ScheduleManager unused param, needed for interface compatibility
     * with RpcServer constructing us.
     */
    public DatabaseHandler(IndexManager idxManager, DatabaseManager dbMgr,
            ScheduleManager schedManager) {
        databaseManager = dbMgr;
    }

    /**
     * Search database
     *
     * @param sessionId
     *            user's application session id
     * @param namespace
     *            namespace query is located in
     * @param query
     *            search query
     * @return list of document ids as results
     * @throws XmlRpcFault something bad happened
     */
    public List<Result> search(long sessionId, String namespace, String query)
            throws XmlRpcFault {
        if (log.isDebugEnabled()) {
            log.debug("DatabaseHandler:: searching for <" + namespace + ">: " + query);
        }
        try {
            String queryName = getQueryName(query);
            Map<String, String> params = getQueryParams(query);
            if (log.isDebugEnabled()) {
                log.debug("Calling runQuery(" + sessionId + ", " + namespace +
                        ", " + queryName + ", " + params + ")");
            }
            List<Result> hits = runQuery(sessionId, namespace, queryName,
                    params);
            log.info("Returned " + hits.size() + " records");
            return hits;
        }
        catch (SqlMapException e) {
            log.warn("Caught SqlMapException: " + e.getMessage());
            e.printStackTrace();
            throw new XmlRpcFault(IndexHandler.DB_ERROR, e.getMessage());
        }
        catch (SQLException e) {
            log.warn("Caught SQLException: " + e.getMessage());
            e.printStackTrace();
            throw new XmlRpcFault(IndexHandler.DB_ERROR, e.getMessage());
        }
        catch (QueryParseException e) {
            log.warn("Caught QueryParseException: " + e.getMessage());
            e.printStackTrace();
            throw new XmlRpcFault(IndexHandler.QUERY_ERROR, e.getMessage());
        }
    }

    /**
     *
     * @param queryIn format "name(param1, param2, ....)"
     * @return query name from query
     * @throws QueryParseException thrown when queryIn is malformed
     */
    private String getQueryName(String queryIn) throws QueryParseException {
        queryIn = queryIn.trim();
        int index = queryIn.indexOf(":(");
        if (index < 0) {
            throw new QueryParseException("Could not parse query: '" + queryIn + "'");
        }
        String queryName = queryIn.substring(0, index);
        return queryName;
    }
    /**
     *
     * @param queryIn String format of "name(param1, param2, ....)"
     * @return List of params from query
     * @throws QueryParseException thrown when queryIn is malformed
     */
    private Map<String, String> getQueryParams(String queryIn) throws QueryParseException {
        queryIn = queryIn.trim();
        String delim = ":(";
        int index = queryIn.indexOf(delim);
        if (index < 0) {
            throw new QueryParseException("Could not parse query: '" + queryIn + "'");
        }
        int indexB = queryIn.indexOf(")", index);
        if (indexB < 0) {
            throw new QueryParseException("Could not parse query: '" + queryIn + "'");
        }
        index = index + delim.length() - 1;  // We want to be pointed to end of location of
                                            // delim
        String[] temps = queryIn.substring(index + delim.length() - 1, indexB).split(",");
        Map params = new HashMap<String, String>();
        for (int i = 0; i < temps.length; i++) {
            params.put("param" + new Integer(i).toString(), temps[i].trim());
        }
        return params;
    }

    /**  Will need to generalize this... right now it's specific to Errata only
     *
     * @param namespace  namespace query lives in
     * @param queryName  query to run
     * @param args       parameters to the query
     * @return List of results
     */
    private List<Result> runQuery(Long sessionId, String namespace, String queryName,
            Map<String, String> args)
        throws SQLException, SqlMapException {
        // Look up Query in DB
        args.put("sessionId", sessionId.toString());
        Query query = databaseManager.getQuery(queryName);
        List<Result> retval;
        try {
            retval = query.loadList(args);
        }
        finally {
            query.close();
        }
        return retval;
    }
}
