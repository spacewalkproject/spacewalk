/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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
import com.redhat.satellite.search.index.IndexingException;
import com.redhat.satellite.search.index.Result;
import com.redhat.satellite.search.index.QueryParseException;
import com.redhat.satellite.search.scheduler.ScheduleManager;

import org.apache.log4j.Logger;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import redstone.xmlrpc.XmlRpcFault;

/**
 * XML-RPC handler which handles calls for indexing
 * 
 * @version $Rev$
 */
public class IndexHandler {

    private static Logger log = Logger.getLogger(IndexHandler.class);
    private IndexManager indexManager;
    private DatabaseManager databaseManager;
    public static final int QUERY_ERROR = 100;
    public static final int INDEX_ERROR = 200;
    public static final int DB_ERROR = 300;
    public static final String DEFAULT_LANG = new Locale("EN", "US").toString();
    
    /**
     * Constructor
     * 
     * @param idxManager
     *            Search engine interface
     */
    public IndexHandler(IndexManager idxManager, DatabaseManager dbMgr,
            ScheduleManager schedMgr) {
        indexManager = idxManager;
        databaseManager = dbMgr;
    }

    /**
     * Search index -
     * assumes English language as default language
     * 
     * @param sessionId
     *            user's application session id
     * @param indexName
     *            index to use
     * @param query
     *            search query
     * @return list of document ids as results
     * @throws XmlRpcFault something bad happened 
     */
    public List<Result> search(long sessionId, String indexName, String query)
            throws XmlRpcFault {
        return search(sessionId, indexName, query, DEFAULT_LANG);
    }

    /**
     * Search index -
     * assumes English language as default language
     *
     * @param sessionId
     *            user's application session id
     * @param indexName
     *            index to use
     * @param query
     *            search query
     *  @param isFineGrained
     *            if set will restrict matches to be stricter and less forgiving
     * @return list of document ids as results
     * @throws XmlRpcFault something bad happened
     */
    public List<Result> search(long sessionId, String indexName, String query,
            boolean isFineGrained)
            throws XmlRpcFault {
        return search(sessionId, indexName, query, DEFAULT_LANG, isFineGrained);
    }

    /**
     * Search index
     *
     * @param sessionId
     *            user's application session id
     * @param indexName
     *            index to use
     * @param query
     *            search query
     *  @param lang
     *            language
     * @return list of document ids as results
     * @throws XmlRpcFault something bad happened
     */
    public List<Result> search(long sessionId, String indexName, String query,
            String lang)  throws XmlRpcFault {
        return search(sessionId, indexName, query, lang, false);
    }

    /**
     * Search index
     *
     * @param sessionId
     *            user's application session id
     * @param indexName
     *            index to use
     * @param query
     *            search query
     *  @param lang
     *            language
     *  @param isFineGrained
     *            if set will restrict matches to be stricter and less forgiving
     * @return list of document ids as results
     * @throws XmlRpcFault something bad happened
     */
    public List<Result> search(long sessionId, String indexName, String query,
            String lang, boolean isFineGrained)
            throws XmlRpcFault {
        if (log.isDebugEnabled()) {
            log.debug("IndexHandler:: searching for: " + query + ", indexName = " +
                    indexName + ", lang = " + lang);
        }
        try {
            List<Result> hits = indexManager.search(indexName, query, lang,
                    isFineGrained);
            if (indexName.compareTo("package") == 0) {
                return screenHits(sessionId, indexName, hits);
            }
            return hits;
        }
        catch (IndexingException e) {
            log.error("Caught exception: ", e);
            throw new XmlRpcFault(INDEX_ERROR, e.getMessage());
        }
        catch (QueryParseException e) {
            log.error("Caught exception: ", e);
            throw new XmlRpcFault(QUERY_ERROR, e.getMessage());
        }
        catch (SQLException e) {
            log.error("Caught exception: ", e);
            throw new XmlRpcFault(DB_ERROR, e.getMessage());
        }
    }
    
    private List<Result> screenHits(long sessionId, String indexName,
            List<Result> hits) throws SQLException {

        if (hits == null || hits.size() == 0) {
            if (log.isDebugEnabled()) {
                log.debug("NO HITS FOUND");
            }
            return Collections.EMPTY_LIST;
        }
        List<String> ids = new ArrayList<String>();
        for (Result pr : hits) {
            ids.add(pr.getId());
        }
        
        Query<String> query = null;
        if ("package".equals(indexName)) {
            query = databaseManager.getQuery("verifyPackageVisibility");
        }
        else if ("errata".equals(indexName)) {
            query = databaseManager.getQuery("verifyErrataVisibility");
        }
        else {
            if (log.isDebugEnabled()) {
                log.debug("screenHits(" + indexName +
                        ") no 'screening of results' performed");
                log.debug("results: " + hits);
            }
            return hits;
        }

        Map params = new HashMap();
        params.put("session_id", sessionId);
        params.put("id_list", ids);

        try {
           List<String> visible = query.loadList(params);
           if (log.isDebugEnabled()) {
               log.debug("results: " + visible);    
           }
           
           // add the PackageResults that match the visible list
           List<Result> realResults = new ArrayList<Result>();
           for (Result pr : hits) {
               if (visible.contains(pr.getId())) {
                   realResults.add(pr);
               }
           }
           return realResults;
        }
        finally {
            query.close();
        }
    }
}
