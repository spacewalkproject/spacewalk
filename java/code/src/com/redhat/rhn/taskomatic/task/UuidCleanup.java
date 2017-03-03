/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.HashMap;

/**
 * SessionCleanup
 * Deletes orphan uuids from rhnVirtualInstance table
 * @version $Rev$
 */
public class UuidCleanup extends RhnJavaJob {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
            throws JobExecutionException {

        WriteMode m = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_UUID_CLEANUP);
        if (log.isDebugEnabled()) {
            log.debug("Calling WriteMode " + TaskConstants.MODE_NAME + "::" +
                    TaskConstants.TASK_QUERY_UUID_CLEANUP);
        }
        m.executeUpdate(new HashMap());
        if (log.isDebugEnabled()) {
            log.debug("WriteMode " + TaskConstants.MODE_NAME + "::" +
                    TaskConstants.TASK_QUERY_UUID_CLEANUP + " returned");
        }
    }

}
