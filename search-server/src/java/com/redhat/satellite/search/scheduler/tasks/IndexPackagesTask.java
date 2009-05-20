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
import com.redhat.satellite.search.db.models.RhnPackage;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.index.IndexingException;
import com.redhat.satellite.search.index.builder.BuilderFactory;
import com.redhat.satellite.search.index.builder.DocumentBuilder;

import org.apache.log4j.Logger;
import org.apache.lucene.document.Document;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.sql.SQLException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Task to index package information
 * 
 * @version $Rev$
 */
public class IndexPackagesTask implements Job {

    private static Logger log = Logger.getLogger(IndexPackagesTask.class);
    private String lang = "en";
    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx) throws JobExecutionException {
        JobDataMap jobData = ctx.getJobDetail().getJobDataMap();
        DatabaseManager databaseManager =
            (DatabaseManager)jobData.get("databaseManager");
        IndexManager indexManager =
            (IndexManager)jobData.get("indexManager");

        try {
            if (System.getProperties().get("isTesting") != null) {
                cleanLastPackage(databaseManager);
            }                    
            List<RhnPackage> packages = getPackages(databaseManager);
            int count = 0;
            log.info("found [" + packages.size() + "] packages to index");
            for (Iterator<RhnPackage> iter = packages.iterator(); iter.hasNext();) {
                RhnPackage current = iter.next();
                indexPackage(indexManager, current);
                count++;
                if (count == 10 || !iter.hasNext()) {
                    if (System.getProperties().get("isTesting") == null) {
                        updateLastPackageId(databaseManager, current.getId());
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
    
    private void cleanLastPackage(DatabaseManager databaseManager) throws SQLException {
        WriteQuery query = null;
        try {
            query = databaseManager.getWriterQuery("deleteLastPackage");
            query.delete(null);
        }
        finally {
            query.close();
        }
    }
    
    private void indexPackage(IndexManager indexManager, RhnPackage pkg) 
            throws IndexingException {
        Map<String, String> attrs = new HashMap<String, String>();
        attrs.put("name", pkg.getName());
        attrs.put("version", pkg.getVersion());
        attrs.put("release", pkg.getRelease());
        attrs.put("filename", pkg.getFileName());
        attrs.put("description", pkg.getDescription());
        attrs.put("summary", pkg.getSummary());
        attrs.put("arch", pkg.getArch());
        log.info("Indexing package: " + pkg.getId() + ": " + attrs.toString());
        DocumentBuilder pdb = BuilderFactory.getBuilder(BuilderFactory.PACKAGES_TYPE);
        Document doc = pdb.buildDocument(new Long(pkg.getId()), attrs);
        indexManager.addToIndex("package", doc, lang);
    }
    
    private void updateLastPackageId(DatabaseManager databaseManager, 
            Long packageId) throws SQLException {
        WriteQuery updateQuery = databaseManager.getWriterQuery("updateLastPackage");
        WriteQuery insertQuery = databaseManager.getWriterQuery("createLastPackage");
        try {
            Map params = new HashMap();
            params.put("id", packageId);
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
    
    private List<RhnPackage> getPackages(DatabaseManager databaseManager) 
            throws SQLException {
        List<RhnPackage> retval = null;
        Query<Long> query = databaseManager.getQuery("getLastPackageId");
        Long packageId = null;
        try {
            packageId = query.load();
        }
        finally {
            query.close();
        }
        if (packageId == null) {
            packageId = new Long(0);
        }
        Query<RhnPackage> pkgQuery = databaseManager.getQuery("listPackagesFromId");
        try {
            retval = pkgQuery.loadList(packageId);
        }
        finally {
            pkgQuery.close();
        }
        return retval;
    }
}
