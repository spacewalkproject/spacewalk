/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.taskomatic.task.TaskConstants;
import com.redhat.rhn.taskomatic.task.threaded.QueueWorker;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueue;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 
 * @version $Rev $
 * 
 */
public class ChannelRepodataWorker implements QueueWorker {

    private RepositoryWriter repoWriter;
    private TaskQueue parentQueue;
    private Logger logger;
    private String channelLabelToProcess;

    private List queueEntries;

    /**
     * 
     * @param workItem work item map
     * @param parentLogger repomd logger
     */
    public ChannelRepodataWorker(Map workItem, Logger parentLogger) {
        logger = parentLogger;
        String prefixPath = Config.get().getString(ConfigDefaults.REPOMD_PATH_PREFIX,
                "rhn/repodata");
        String mountPoint = 
            Config.get().getString(ConfigDefaults.REPOMD_CACHE_MOUNT_POINT, "/pub");
        channelLabelToProcess = (String) workItem.get("channel_label");
        repoWriter = new RepositoryWriter(prefixPath, mountPoint);
        logger.info("Creating ChannelRepodataWorker with prefixPath(" + prefixPath +
                "), mountPoint(" + mountPoint + ")" + "for channel_label (" +
                channelLabelToProcess + ")");
    }

    /**
     * Sets the parent queue
     * @param queue task queue
     */
    public void setParentQueue(TaskQueue queue) {
        parentQueue = queue;
    }

    /**
     * runner method to process the parentQueue
     */
    public void run() {
        try {
            parentQueue.workerStarting();
            if (!isChannelLabelAlreadyInProcess()) {
                markInProgress();
                populateQueueEntryDetails();
                Channel channelToProcess = ChannelFactory
                        .lookupByLabel(channelLabelToProcess);
                // if the channelExists in the db still
                if (channelToProcess != null) {
                    // see if the channel is stale, or one of the entries has
                    // force='Y'
                    if (queueContainsBypass("force") ||
                            repoWriter.isChannelRepodataStale(channelToProcess)) {
                        if (queueContainsBypass("bypass_filters") ||
                                channelToProcess.isChannelRepodataRequired()) {
                            repoWriter.writeRepomdFiles(channelToProcess);
                        }
                    }
                    else {
                        logger.debug("Not processing channel(" + channelLabelToProcess +
                        ") because the request isn't forced AND the channel repodata " +
                        "isn't stale");
                    }
                }
                else {
                    repoWriter.deleteRepomdFiles(channelLabelToProcess);
                }

                dequeueChannel();
                HibernateFactory.commitTransaction();
            }
            else {
                HibernateFactory.commitTransaction();
                logger.debug("NOT processing channel(" + channelLabelToProcess +
                        ") because another thread is already working on run");
            }
        }
        catch (Exception e) {
            logger.error(e);
            HibernateFactory.rollbackTransaction();
        }
        finally {
            parentQueue.workerDone();
        }
    }

    /**
     * populates the queue details for repomd event
     */
    private void populateQueueEntryDetails() {
        SelectMode selector = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_REPOMD_DETAILS_QUERY);
        Map<Object, Object> params = new HashMap<Object, Object>();
        params.put("channel_label", channelLabelToProcess);
        queueEntries = selector.execute(params);
    }

    /**
     * 
     * @return Returns the progress status of the channel
     */
    private boolean isChannelLabelAlreadyInProcess() {
        SelectMode selector = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_REPOMD_DETAILS_QUERY);
        Map<Object, Object> params = new HashMap<Object, Object>();
        params.put("channel_label", channelLabelToProcess);
        return (selector.execute(params).size() > 0);
    }

    /**
     * 
     * @param entryToCheck
     * @return Returns a boolean to force or not
     */
    private boolean queueContainsBypass(String entryToCheck) {
        boolean shouldForce = false;

        for (Object currentEntry : queueEntries) {
            String forceFlag = (String) ((Map) currentEntry).get(entryToCheck);
            if ("Y".equalsIgnoreCase(forceFlag)) {
                shouldForce = true;
            }
        }
        return shouldForce;
    }

    /**
     * marks the channel as in progress to avoid conflicts
     */
    private void markInProgress() throws Exception {
        WriteMode inProgressChannel = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_REPOMD_MARK_IN_PROGRESS);
        Map<String, String> dqeParams = new HashMap<String, String>();
        dqeParams.put("channel_label", channelLabelToProcess);
        try {
            int channelLabels = inProgressChannel.executeUpdate(dqeParams);
            if (logger.isDebugEnabled()) {
                logger.debug("Marked " + channelLabels + " rows from the " +
                        "rhnRepoRegenQueue table in progress by " +
                        "setting next_action to null");
            }
            HibernateFactory.commitTransaction();
        }
        catch (Exception e) {
            logger.error(
                    "Error marking in use for channel_label: " + channelLabelToProcess, e);
            HibernateFactory.rollbackTransaction();
            throw e;
        }
        finally {
            HibernateFactory.closeSession();
        }
    }

    /**
     * dequeue the queued channel for repomd generation
     */
    private void dequeueChannel() throws Exception {
        WriteMode deqChannel = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_REPOMD_DEQUEUE);
        Map<String, String> dqeParams = new HashMap<String, String>();
        dqeParams.put("channel_label", channelLabelToProcess);
        try {
            int eqDeleted = deqChannel.executeUpdate(dqeParams);
            if (logger.isDebugEnabled()) {
                logger.debug("deleted " + eqDeleted +
                        " rows from the rhnRepoRegenQueue table");
            }
            HibernateFactory.commitTransaction();
        }
        catch (Exception e) {
            logger.error("Error removing Channel from queue for Channel: " +
                    channelLabelToProcess, e);
            HibernateFactory.rollbackTransaction();
            return;
        }
        finally {
            HibernateFactory.closeSession();
        }
    }

}
