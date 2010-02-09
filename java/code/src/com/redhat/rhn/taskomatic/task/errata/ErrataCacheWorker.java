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
package com.redhat.rhn.taskomatic.task.errata;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.manager.errata.cache.UpdateErrataCacheCommand;
import com.redhat.rhn.taskomatic.task.threaded.QueueWorker;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueue;

import org.apache.log4j.Logger;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Performs errata cache recalc for a given server or channel
 * @version $Rev $
 */
class ErrataCacheWorker implements QueueWorker {
    
    public static final String BY_CHANNEL = "update_errata_cache_by_channel";
    public static final String FOR_SERVER = "update_server_errata_cache";

    
    private Task task;
    private Long orgId;
    private Logger logger;
    private TaskQueue parentQueue;
    
    public ErrataCacheWorker(Map items, Logger parentLogger) {
        task = (Task) items.get("task");
        orgId = (Long) items.get("orgId");
        logger = parentLogger;
    }

    /**
     * 
     * {@inheritDoc}
     */
    public void run() {
        try {
            Date d = new Date(System.currentTimeMillis());
            Date d2 = new Date(System.currentTimeMillis() + System.currentTimeMillis());
            removeTask();
            HibernateFactory.commitTransaction();
            HibernateFactory.closeSession();
            parentQueue.workerStarting();
            UpdateErrataCacheCommand uecc = new UpdateErrataCacheCommand();        
            if (ErrataCacheWorker.FOR_SERVER.equals(task.getName())) {
                Long sid = task.getData();
                if (logger.isDebugEnabled()) {
                    logger.debug("Updating errata cache for sid [" + sid + "]");
                }
                uecc.updateErrataCacheForServer(sid, orgId, false);
            }
            else if (ErrataCacheWorker.BY_CHANNEL.equals(task.getName())) {
                Long cid = task.getData();
                if (logger.isDebugEnabled()) {
                    logger.debug("Updating errata cache for cid [" + cid + "]");
                }
                uecc.updateErrataCacheForChannel(cid);                
            }
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

    public void setParentQueue(TaskQueue queue) {
        parentQueue = queue;
    }
    
    private void removeTask() {
        WriteMode mode = ModeFactory.getWriteMode("Task_queries", "delete_task");
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("name", task.getName());
        params.put("task_data", task.getData());
        params.put("priority", new Integer(task.getPriority()));
        mode.executeUpdate(params);
    }

}
