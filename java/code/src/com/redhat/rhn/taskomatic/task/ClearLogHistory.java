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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.taskomatic.TaskoFactory;
import com.redhat.rhn.taskomatic.TaskoRun;
import com.redhat.rhn.taskomatic.TaskoSchedule;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Calendar;
import java.util.Date;
import java.util.List;


/**
 * ClearRunHistory
 * @version $Rev$
 */
public class ClearLogHistory extends RhnJavaJob {

    private static final Integer DEFAULT_DAYS_VALUE = 7;
    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
        throws JobExecutionException {
        Integer days = null;
        try {
            days = (Integer) context.getJobDetail().getJobDataMap().get("days");
        }
        catch (java.lang.ClassCastException cce) {
            String passedDays = (String) context.getJobDetail().getJobDataMap().get("days");
            if (passedDays != null) {
                try {
                    days = Integer.parseInt(passedDays);
                }
                catch (NumberFormatException nfe) {
                    throw new JobExecutionException("Invalid argument: days");
                }
            }
        }

        // if no value given, use default
        if (days == null) {
            days = DEFAULT_DAYS_VALUE;
        }
        Calendar now = Calendar.getInstance();
        now.add(Calendar.DATE, -days);
        now.set(Calendar.HOUR_OF_DAY, 0);
        now.set(Calendar.MINUTE, 0);
        now.set(Calendar.SECOND, 0);
        now.set(Calendar.MILLISECOND, 0);
        Date limitTime = now.getTime();

        log.info("Clearing log history older than: " +
                LocalizationService.getInstance().formatCustomDate(limitTime));
        HibernateFactory.getSession();
        // loop accross all the orgs
        List<TaskoRun> runList = TaskoFactory.listRunsOlderThan(limitTime);
        for (TaskoRun run : runList) {
            // delete history of runs
            TaskoFactory.deleteRun(run);
        }

        // delete outdated schedules
        List<TaskoSchedule> scheduleList = TaskoFactory.listSchedulesOlderThan(limitTime);
        for (TaskoSchedule schedule : scheduleList) {
            if (TaskoFactory.listRunsBySchedule(schedule.getId()).isEmpty()) {
                TaskoFactory.delete(schedule);
            }
        }
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }
}
