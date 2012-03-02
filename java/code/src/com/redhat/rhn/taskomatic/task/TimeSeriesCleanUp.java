/**
 * Copyright (c) 2010--2012 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.HashMap;


/**
 * TimeSeriesCleanUp
 * Cleans up orphaned monitoring data from the following tables:
 * time_series_data, state_change, rhn_probe_state
 * @version $Rev$
 */
public class TimeSeriesCleanUp extends RhnJavaJob {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext arg0In)
        throws JobExecutionException {
        // TODO Auto-generated method stub
        int rowsDeleted = deleteOrphanedTimeSeriesData();
        if (rowsDeleted > 0) {
            log.info("Deleted " + rowsDeleted +
                " row(s) of orphaned data in time_series_data.");
        }

        rowsDeleted = deleteOrphanedStateChange();
        if (rowsDeleted > 0) {
            log.info("Deleted " + rowsDeleted +
                " row(s) of orphaned data in state_change.");
        }

        rowsDeleted = deleteOrphanedProbeState();
        if (rowsDeleted > 0) {
            log.info("Deleted " + rowsDeleted +
                " row(s) of orphaned data in rhn_probe_state.");
        }
    }

    private int deleteOrphanedTimeSeriesData() {
        WriteMode m = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_TIME_SERIES_DATA_CLEANUP);
        return m.executeUpdate(new HashMap());
    }

    private int deleteOrphanedStateChange() {
        WriteMode m = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_STATE_CHANGE_CLEANUP);
        return m.executeUpdate(new HashMap());
    }

    private int deleteOrphanedProbeState() {
        WriteMode m = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_PROBE_STATE_CLEANUP);
        return m.executeUpdate(new HashMap());
    }
}
