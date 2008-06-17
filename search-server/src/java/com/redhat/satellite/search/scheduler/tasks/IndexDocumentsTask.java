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

import com.redhat.satellite.search.config.Configuration;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.scheduler.tasks.crawl.WebCrawl;

import org.apache.log4j.Logger;

import org.quartz.JobDataMap;
import org.quartz.StatefulJob;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.File;
import java.io.IOException;


/**
 * Task to index help documents
 * 
 * @version $Rev: $
 */
public class IndexDocumentsTask implements StatefulJob {
    // We do _not_ want this task to run concurrently with itself,
    // therefore using StatefulJob.
    private static Logger log = Logger.getLogger(IndexDocumentsTask.class);
    public static final String TASK_REINDEX = new String("TASK.RE-INDEX");
    public static final String TASK_COMPLETE = new String("TASK.COMPLETE");

    
    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx)
        throws JobExecutionException {
        JobDataMap jobData = ctx.getJobDetail().getJobDataMap();
        IndexManager indexManager = (IndexManager) jobData.get("indexManager");
        
        String indexWorkDir = indexManager.getIndexWorkDir();
        if ((indexWorkDir == null) || (indexWorkDir.compareTo("") == 0)) {
            throw new JobExecutionException("indexWorkDir invalid");
        }
        File docsIndexDir = new File(indexWorkDir + File.separator +
                IndexManager.DOCS_INDEX_NAME);
        File indexCheck = new File(docsIndexDir, TASK_REINDEX);
        File success = new File(docsIndexDir, TASK_COMPLETE);
        
        boolean reindex = false;
        
        log.info("task running");
        
        if (!docsIndexDir.exists()) {
            // first time running, the index needs to be created from scratch
            log.info("Creating directory: " + docsIndexDir.getPath());
            if (!docsIndexDir.mkdirs()) {
                throw new JobExecutionException("Unable to create dir: " + 
                        docsIndexDir.getPath());
            }
            reindex = true;
        }
        else {
            // Will reindex if a TASK.RE-INDEX is present or
            // we don't see TASK.COMPLETE
            log.info("docsIndexDir<" + docsIndexDir + "> exists");
            if (indexCheck.exists()) {
                log.info("Found (" + indexCheck.getPath() + 
                        "), Index needs to be updated.");
                reindex = true;
            } 
            else if (!success.exists()) {
                log.info("Index exists, but it appears to be incomplete, missing " + 
                        success.getPath());
                reindex = true;
            } 
        }
        
        if (reindex) {
            //We need to communicate index is incomplete by removing the success file
            
            if (success.exists()) {
                if (!success.delete()) {
                    throw new JobExecutionException("Unable to delete file: " + 
                            success.getPath());
                }
            }
            if ((indexCheck != null) && (indexCheck.exists())) {
                // cleanup the file which triggered the re-index
                if (!indexCheck.delete()) {
                    throw new JobExecutionException("Unable to delete file: " + 
                            indexCheck.getPath());
                }
            }
            try {
                Configuration config = (Configuration)jobData.get("configuration");
                if (!reIndexDocs(docsIndexDir.getPath(), config)) {
                    log.error("Failed reindexing documents to : ");
                    throw new JobExecutionException("Reindexing of Documents failed.");
                }
                //Mark that docs have been indexed and are ready to be used.
                success.createNewFile();
            }
            catch (IOException e) {
                throw new JobExecutionException(e);
            }
        }
    }
    
    protected boolean reIndexDocs(String docsIndexDir, Configuration config) 
        throws IOException {
        
        int threads = config.getInt("search.nutch.threads", 10);
        int depth = config.getInt("search.nutch.depth", 5);
        String inputUrlFile = config.getString("search.nutch.inputUrlFile", "nutch/urls");
        String tmpCrawlDir = config.getString("search.nutch.tmpDir", "/tmp/crawl_output");
        
        WebCrawl wCrawl = new WebCrawl();
        wCrawl.setDepth(depth);
        wCrawl.setInputUrlFile(inputUrlFile);
        wCrawl.setOutputIndexDir(docsIndexDir);
        wCrawl.setThreads(threads);
        wCrawl.setTmpCrawlDir(tmpCrawlDir);
        
        return wCrawl.crawl();
    }

}
