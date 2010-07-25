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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.taskomatic.task.threaded.QueueDriver;
import com.redhat.rhn.taskomatic.task.threaded.QueueWorker;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Driver for the threaded errata cache update queue
 * @version $Rev$
 */
public class ErrataCacheDriver implements QueueDriver {

    private Logger logger = null;

    /**
     *
     * {@inheritDoc}
     */
    public boolean canContinue() {
        return true;
    }

    /**
     *
     * {@inheritDoc}
     */
    public List getCandidates() {
        List<Task> tasks = TaskFactory.getTaskListByNameLike(ErrataCacheWorker.BY_CHANNEL);
        tasks.addAll(TaskFactory.getTaskListByNameLike(ErrataCacheWorker.FOR_SERVER));
        List retval = new LinkedList();
        for (Task current : tasks) {
            Map item = new HashMap();
            item.put("task", current);
            item.put("orgId", current.getOrg().getId());
            retval.add(item);
        }
        return retval;
    }

    /**
     *
     * {@inheritDoc}
     */
    public Logger getLogger() {
        return logger;
    }

    /**
     * {@inheritDoc}
     */

    public void setLogger(Logger loggerIn) {
        logger = loggerIn;
    }

    /**
     *
     * {@inheritDoc}
     */
    public int getMaxWorkers() {
        return Config.get().getInt("taskomatic.errata_cache_workers", 2);
    }

    /**
     *
     * {@inheritDoc}
     */
    public QueueWorker makeWorker(Object workItem) {
        Map item = (Map) workItem;
        return new ErrataCacheWorker(item, logger);
    }
}
