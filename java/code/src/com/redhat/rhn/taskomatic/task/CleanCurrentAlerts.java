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

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.HashMap;

/**
 * CleanCurrentAlerts
 * Cleans the RHN_CURRENT_ALERTS table
 * @version $Rev$
 */
public class CleanCurrentAlerts extends RhnJavaJob {

    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "clean_current_alerts";

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext contextIn)
        throws JobExecutionException {

        if (log.isDebugEnabled()) {
            log.debug("Starting clean_current_alerts run ...");
        }

        /*
         * First, set DATE_COMPLETED on any alerts that may be left hanging
         * around (e.g. from a server crash)
         */
        if (log.isDebugEnabled()) {
            log.debug("Updating DATE_COMPLETED");
        }

        int rowsUpdated = updateDateCompleted();

        if (log.isDebugEnabled()) {
            log.debug(rowsUpdated + " rows updated.");
        }

        /*
         * Next, delete old CURRENT_ALERTS records.
         */
        if  (log.isDebugEnabled()) {
            log.debug("Deleting old CURRENT_ALERTS records");
        }

        int rowsDeleted = deleteOldAlerts();

        if (log.isDebugEnabled()) {
            log.debug(rowsDeleted + " rows deleted");
        }

        if (log.isDebugEnabled()) {
            log.debug("Finished clean_current_alerts run.");
        }
    }

    /**
     * Updated the date_completed and in_progress columns of rhn_current_alerts.
     * @return Returns the number of rows affected.
     */
    private int updateDateCompleted() {
        WriteMode m = ModeFactory.getWriteMode("General_queries",
                                               "update_current_alerts_date_completed");
        return m.executeUpdate(new HashMap());
    }

    /**
     * Deletes old entries in the rhn_current_alerts table.
     * @return Returns the number of rows affected.
     */
    private int deleteOldAlerts() {
        WriteMode m = ModeFactory.getWriteMode("General_queries",
                                               "delete_old_current_alerts");
        return m.executeUpdate(new HashMap());
    }
}
