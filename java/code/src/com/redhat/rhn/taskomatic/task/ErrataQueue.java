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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.taskomatic.task.errata.ErrataQueueDriver;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueue;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueueFactory;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * Manages the pending errata queue
 *
 * @version $Rev $
 */
public class ErrataQueue extends SingleThreadedTestableTask {

    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "errata_queue";

    private static final Logger LOG = Logger.getLogger(ErrataQueue.class);

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx, boolean testContext)
            throws JobExecutionException {
        TaskQueueFactory factory = TaskQueueFactory.get();
        TaskQueue queue = factory.getQueue("errata_queue");
        if (queue == null) {
            try {
                queue = factory.createQueue("errata_queue", ErrataQueueDriver.class);
            }
            catch (Exception e) {
                LOG.error(e);
                return;
            }
        }
        int maxWorkItems = Config.get().getInt("taskomatic.errata_queue_max_work_items", 2);
        if (queue.getQueueSize() < maxWorkItems) {
            queue.run();
        }
    }

}
