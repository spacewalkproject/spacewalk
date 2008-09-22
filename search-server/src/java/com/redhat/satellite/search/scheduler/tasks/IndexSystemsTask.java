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
package com.redhat.satellite.search.scheduler.tasks;

import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.db.Query;
import com.redhat.satellite.search.db.WriteQuery;
import com.redhat.satellite.search.db.models.Server;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.index.IndexingException;
import com.redhat.satellite.search.index.builder.DocumentBuilder;
import com.redhat.satellite.search.index.builder.ServerDocumentBuilder;

import org.apache.log4j.Logger;
import org.apache.lucene.document.Document;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


// Main tasks:
// 1) Index new systems, i.e. system id is greater than last recorded system id indexed.
// 2) Update the existing index of systems which have been modified
// 3) Remove systems which have been deleted from the system.
// TODO:
//  **  Handle removal of systems


/**
 * IndexSystemsTask
 * @version $Rev$
 */
public class IndexSystemsTask implements Job {

    private static Logger log = Logger.getLogger(IndexSystemsTask.class);
    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx)
        throws JobExecutionException {
        JobDataMap jobData = ctx.getJobDetail().getJobDataMap();
        DatabaseManager databaseManager =
            (DatabaseManager)jobData.get("databaseManager");
        IndexManager indexManager =
            (IndexManager)jobData.get("indexManager");

        try {
              
            List<Server> servers = getServers(databaseManager);
            int count = 0;
            log.info("found [" + servers.size() + "] packages to index");
            for (Iterator<Server> iter = servers.iterator(); iter.hasNext();) {
                Server current = iter.next();
                indexServer(indexManager, current);
                count++;
                if (count == 10 || !iter.hasNext()) {
                    if (System.getProperties().get("isTesting") == null) {
                        updateLastServerId(databaseManager, current.getId());
                    }
                    count = 0;
                }
            }
        }
        catch (SQLException e) {
            throw new JobExecutionException(e);
        }
        catch (IndexingException e) {
            throw new JobExecutionException(e);
        }
    }
    /**
     * @param databaseManager
     * @param sid
     */
    private void updateLastServerId(DatabaseManager databaseManager, long sid)
        throws SQLException {

        WriteQuery updateQuery = databaseManager.getWriterQuery("updateLastServer");
        WriteQuery insertQuery = databaseManager.getWriterQuery("createLastServer");

        try {
            Map params = new HashMap();
            params.put("id", sid);
            params.put("last_modified", Calendar.getInstance().getTime());

            if (updateQuery.update(params) == 0) {
                insertQuery.insert(params);
            }
        }
        finally {
            try {
                if (updateQuery != null) {
                    updateQuery.close();
                }
            }
            finally {
                if (insertQuery != null) {
                    insertQuery.close();
                }
            }
        }
    }
    
    /**
     * @param indexManager
     * @param current
     */
    private void indexServer(IndexManager indexManager, Server srvr)
        throws IndexingException {

        Map<String, String> attrs = new HashMap<String, String>();
        /*
         * activity:
         * days since last check-in
         * days since first registered
         * details:
         * name/description
         * ID
         * custom info
         * snapshot tag
         * packages:
         * installed packages
         * needed packages
         * dmi info:
         * system
         * BIOS
         * asset tag
         * location:
         * address
         * building
         * room
         * rack
         * hardware devices:
         * description
         * driver
         * device id
         * vendor id
         * network info:
         * hostname
         * ip address
         * hardware:
         * cpu model
         * cpu mhz less than
         * cpu mhz greater than
         * ram less than
         * ram greater than
         */
        attrs.put("id", new Long(srvr.getId()).toString());
        attrs.put("name", srvr.getName());
        attrs.put("description", srvr.getDescription());
        attrs.put("info", srvr.getInfo());
        log.info("Indexing package: " + srvr.getId() + ": " + attrs.toString());
        DocumentBuilder pdb = new ServerDocumentBuilder();
        Document doc = pdb.buildDocument(new Long(srvr.getId()), attrs);
        indexManager.addToIndex("server", doc);
    }
    
    /**
     * @param databaseManager
     * @return
     */
    private List<Server> getServers(DatabaseManager databaseManager) 
        throws SQLException {
        // What was the last server id we indexed?
        List<Server> retval = null;
        Query<Long> query = databaseManager.getQuery("getLastServerId");
        Long sid = null;
        try {
            sid = query.load();
        }
        finally {
            query.close();
        }
        if (sid == null) {
            sid = new Long(0);
        }
        // When was the last time we ran the indexing of servers?
        Query<Date> queryLast = databaseManager.getQuery("getLastServerIndexRun");
        Date indexServerLastRun = null;
        try {
            indexServerLastRun = queryLast.load();
        }
        finally {
            queryLast.close();
        }
        if (indexServerLastRun == null) {
            indexServerLastRun = new Date(0);
        }
        // Lookup what servers have not been indexed, or need to be reindexed.
        Query<Server> srvrQuery = databaseManager.getQuery("getServersByModDateOrId");
        try {
            Map params = new HashMap();
            params.put("id", sid);
            params.put("modified_date", indexServerLastRun);
            retval = srvrQuery.loadList(params);
        }
        finally {
            srvrQuery.close();
        }
        return retval;
    }
}
