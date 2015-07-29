/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task.errata;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.taskomatic.task.TaskConstants;
import com.redhat.rhn.taskomatic.task.threaded.QueueWorker;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueue;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

/**
 * This task used to both schedule auto errata updates and schedule errata
 * notifications for the Errata Mailer task to pick up. Now auto errata updates
 * have been moved out to the AutoErrataTask, so it just is basically a gatekeeper
 * that ensures that the yum metadata has been regenerated and that the errata cache
 * has already been updated before scheduling the errata notifications.
 * TODO: consolidate this job with Errata Mailer.
 * ErrataQueueWorker
 * @version $Rev$
 */
class ErrataQueueWorker implements QueueWorker {

    private Logger logger;
    private Long errataId;
    private Long channelId;
    private Long orgId;
    private TaskQueue parentQueue;

    ErrataQueueWorker(Map<String, Long> row, Logger parentLogger) {
        channelId = row.get("channel_id");
        errataId = row.get("errata_id");
        orgId = row.get("org_id");
        logger = parentLogger;
    }

    public void run() {
        try {
            parentQueue.workerStarting();
            markInProgress();
            if (logger.isDebugEnabled()) {
                logger.debug("Processing errata queue for " +
                        errataId.longValue());
            }

            WriteMode marker = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATA_QUEUE_ENQUEUE_SAT_ERRATA);
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("errata_id", errataId);
            params.put("minutes", new Long(0));
            params.put("channel_id", channelId);
            int rowsUpdated = marker.executeUpdate(params);
            if (logger.isDebugEnabled()) {
                logger.debug("inserted " + rowsUpdated +
                    " rows into the rhnErrataNotificationQueue table");
            }
            dequeueErrata();
            HibernateFactory.commitTransaction();
        }
        catch (Exception e) {
            logger.error(e);
            HibernateFactory.rollbackTransaction();
        }
        finally {
            parentQueue.workerDone();
            HibernateFactory.closeSession();
        }
    }

    private void markInProgress() {
        WriteMode m = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATA_IN_PROGRESS);
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("errata_id", errataId);
        params.put("channel_id", channelId);
        int numRows = m.executeUpdate(params);
        if (logger.isDebugEnabled()) {
            logger.debug("marked " + numRows +
                    " rows as in progress in rhnErrataQueue table");
        }
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }

    private void dequeueErrata() {
        WriteMode deqErrata = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_ERRATA_QUEUE_DEQUEUE_ERRATA);
        Map<String, Long> dqeParams = new HashMap<String, Long>();
        dqeParams.put("errata_id", errataId);
        dqeParams.put("channel_id", channelId);
        int eqDeleted = deqErrata.executeUpdate(dqeParams);
        if (logger.isDebugEnabled()) {
            logger.debug("deleted " + eqDeleted +
                    " rows from the rhnErrataQueue table");
        }
    }

    public void setParentQueue(TaskQueue queue) {
        parentQueue = queue;
    }
}
