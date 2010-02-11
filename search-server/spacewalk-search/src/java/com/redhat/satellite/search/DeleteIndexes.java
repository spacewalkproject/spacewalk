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

package com.redhat.satellite.search;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.db.WriteQuery;
import com.redhat.satellite.search.config.Configuration;


/**
 * Reindex - cleans up indexes on filesystem and database so reindexing will occur
 * @version $Rev: 1 $
 */
public class DeleteIndexes {
    private static Logger log = Logger.getLogger(DeleteIndexes.class);

    private DeleteIndexes() {
    }

    protected static boolean deleteDirectory(File dir) {
        File[] files = dir.listFiles();
        boolean warning = true;
        for (int i = 0; i < files.length; i++) {
            if (files[i].isDirectory()) {
                deleteDirectory(files[i]);
            }
            if (files[i].delete()) {
                log.debug("Deleted: " + files[i].getAbsolutePath());
            }
            else {
                log.warn("*ERROR* unable to delete: " + files[i].getAbsolutePath());
                warning = false;
            }
        }
        if (!dir.delete()) {
            log.warn("*ERROR* unable to delete: " + dir.getAbsolutePath());
            warning = false;
        }
        return warning;
    }

    protected static boolean deleteIndexPath(String path) {
        File dir = new File(path);
        if ("/".equals(dir.getAbsolutePath())) {
            log.warn("Error, passed in path is <" + path + "> this looks wrong");
            return false;
        }
        if (!dir.exists()) {
            log.debug("Path <" + dir.getAbsolutePath() + "> doesn't exist");
            return true;  // dir doesn't exist, so just as good as deleted
        }
        if (!dir.isDirectory()) {
            log.warn("Error, passed in path <" + path + "> is not a directory");
            return false;
        }
        log.info("Attempting to delete " + dir.getAbsolutePath());
        return deleteDirectory(dir);
    }

    protected static void deleteQuery(DatabaseManager databaseManager,
            String queryName) throws SQLException {
        WriteQuery query = null;
        log.info("Running query: " + queryName);
        query = databaseManager.getWriterQuery(queryName);
        query.delete(null);
        query.close();
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        try {
            Configuration config = new Configuration();
            DatabaseManager databaseManager = new DatabaseManager(config);
            String indexWorkDir = config.getString("search.index_work_dir", null);
            if (StringUtils.isBlank(indexWorkDir)) {
                log.warn("Couldn't find path for where index files are stored.");
                log.warn("Looked in config for property: search.index_work_dir");
                return;
            }
            List<IndexInfo> indexes = new ArrayList<IndexInfo>();
            indexes.add(new IndexInfo("deleteLastErrata",
                    indexWorkDir + File.separator + "errata"));
            indexes.add(new IndexInfo("deleteLastPackage",
                    indexWorkDir + File.separator + "package"));
            indexes.add(new IndexInfo("deleteLastServer",
                    indexWorkDir + File.separator + "server"));
            indexes.add(new IndexInfo("deleteLastHardwareDevice",
                    indexWorkDir + File.separator + "hwdevice"));
            indexes.add(new IndexInfo("deleteLastSnapshotTag",
                    indexWorkDir + File.separator + "snapshotTag"));
            indexes.add(new IndexInfo("deleteLastServerCustomInfo",
                    indexWorkDir + File.separator + "serverCustomInfo"));
            for (IndexInfo info : indexes) {
                deleteQuery(databaseManager, info.getQueryName());
                if (!deleteIndexPath(info.getDirPath())) {
                    log.warn("Failed to delete index for " + info.getDirPath());
                }
            }
        }
        catch (SQLException e) {
            log.error("Caught Exception: ", e);
            if (e.getErrorCode() == 17002) {
                log.error("Unable to establish database connection.");
                log.error("Ensure database is available and connection details are " +
                        "correct, then retry");
            }
            System.exit(1);
        }
        catch (IOException e) {
            log.error("Caught Exception: ", e);
            System.exit(1);
        }
        log.info("Index files have been deleted and database has been cleaned up, " +
            "ready to reindex");
    }

    /**
     * IndexInfo
     */
    protected static class IndexInfo {
        protected String queryName;
        protected String dirPath;

        /**
         *
         * @param query query name to delete all records
         * @param path string pointing to where index files reside
         */
        public IndexInfo(String query, String path) {
            queryName = query;
            dirPath = path;
        }

        /**
         * Set the query name to delete all records for this index
         * @param queryNameIn name of the query
         */
        public void setQueryName(String queryNameIn) {
            queryName = queryNameIn;
        }
        /**
         * Returns the query name
         * @return
         */
        public String getQueryName() {
            return queryName;
        }
        /**
         * Set the path where the index files exist
         * @param path String which points to index files
         */
        public void setDirPath(String path) {
            dirPath = path;
        }
        /**
         * Returns the path
         * @return a string which points to the index files
         */
        public String getDirPath() {
            return dirPath;
        }
    }
}
