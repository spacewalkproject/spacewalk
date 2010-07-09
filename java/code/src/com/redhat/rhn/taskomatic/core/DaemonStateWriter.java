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
package com.redhat.rhn.taskomatic.core;

import EDU.oswego.cs.dl.util.concurrent.Channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;
import org.hibernate.Transaction;

import java.util.HashMap;
import java.util.Map;

/**
 * Single-threads all writes to the RHNDAEMONSTATE table
 * to prevent locking due to table contention
 *
 * @version $Rev $
 */
class DaemonStateWriter implements Runnable {

    private static final String LAST_TASK = "last_task_completed";

    private static Logger logger = Logger.getLogger(SchedulerKernel.class);

    private boolean stopped = false;

    private Channel stateQueue;

    public DaemonStateWriter(Channel queue) {
        this.stateQueue = queue;
    }

    /**
     * Sets the stopped flag
     * @param flag true to stop
     */
    public synchronized void isStopped(boolean flag) {
        this.stopped = flag;
    }

    /**
     * Returns current stop state
     * @return true if stopped, false if not
     */
    public synchronized boolean isStopped() {
        return this.stopped;
    }

    /**
     * {@inheritDoc}
     */
    public void run() {
        try {
            while (!isStopped()) {
                String name = (String) this.stateQueue.poll(500);
                if (name != null) {
                    writeUpdate(name);
                    writeUpdate(LAST_TASK);
                }
            }
        }
        catch (InterruptedException e) {
            logger.error(e.getMessage(), e);
            return;
        }

    }

    private void writeUpdate(String displayName) {
        Transaction txn = null;
        try {
            txn = HibernateFactory.getSession().beginTransaction();
            SelectMode mode = ModeFactory.getMode(TaskomaticConstants.MODE_NAME,
                    TaskomaticConstants.DAEMON_QUERY_FIND_STATS);
            Map params = new HashMap();
            params.put("display_name", displayName);
            DataResult dr = mode.execute(params);
            Map row = (Map) dr.get(0);
            Long count = (Long) row.get("stat_exists");
            WriteMode statsQuery = null;
            if (count.intValue() < 1) {
                statsQuery = ModeFactory.getWriteMode(TaskomaticConstants.MODE_NAME,
                        TaskomaticConstants.DAEMON_QUERY_CREATE_STATS);
            }
            else {
                statsQuery = ModeFactory.getWriteMode(TaskomaticConstants.MODE_NAME,
                        TaskomaticConstants.DAEMON_QUERY_UPDATE_STATS);
            }
            statsQuery.executeUpdate(params);
            txn.commit();
        }
        catch (Throwable t) {
            txn.rollback();
            logger.error(t.getMessage(), t);
        }
    }

}
