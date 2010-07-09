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
package com.redhat.rhn.taskomatic.task.entitlement;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.taskomatic.task.threaded.QueueWorker;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueue;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Map;

/**
 * Performs an entitlement recalc for a single org
 *
 * @version $Rev$
 */
class EntitlementWorker implements QueueWorker {

    private Long orgId;
    private Logger logger;
    private TaskQueue parentQueue;

    /**
     * Constructor
     * @param org org id to recalc entitlements on
     */
    public EntitlementWorker(Long org, Logger parentLogger) {
        orgId = org;
        logger = parentLogger;
    }

    /**
     * {@inheritDoc}
     */
    public void run() {
        // Get pause between iterations value from configs
        // Defaults to zero if none available
        try {
            parentQueue.workerStarting();
            long waitMillis = Long.parseLong(
                Config.get().getString("taskomatic.rapid_repoll_wait_millis",
                    "0"));
            // Pause if one is configured
            if (waitMillis > 0) {
                try {
                    Thread.sleep(waitMillis);
                }
                catch (InterruptedException e) {
                    return;
                }
            }

            // Recalc org entitlements via the
            Map params = new HashMap();
            params.put("org_id", orgId);
            try {
                CallableMode cm =
                    ModeFactory.getCallableMode("Task_queries", "entitle_org_direct");
                cm.execute(params, new HashMap());
                WriteMode wm = ModeFactory.getWriteMode("Task_queries",
                    "dequeue_entitlement_org");
                wm.executeUpdate(params);
                HibernateFactory.commitTransaction();
            }
            catch (Throwable t) {
                logger.error(t);
                HibernateFactory.rollbackTransaction();
            }
            finally {
                HibernateFactory.closeSession();
            }
        }
        finally {
            parentQueue.workerDone();
        }
    }

    public void setParentQueue(TaskQueue queue) {
        parentQueue = queue;
    }

}
