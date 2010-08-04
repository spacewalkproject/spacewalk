/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic;

import com.redhat.rhn.taskomatic.core.SchedulerKernel;

import org.apache.log4j.Logger;
import org.quartz.CronTrigger;
import org.quartz.JobDetail;
import org.quartz.SchedulerException;
import org.quartz.SimpleTrigger;
import org.quartz.Trigger;

import java.text.ParseException;
import java.util.Date;


/**
 * TaskoQuartzHelper
 * @version $Rev$
 */
public class TaskoQuartzHelper {

    private static Logger log = Logger.getLogger(TaskoQuartzHelper.class);

    /**
     * cann't construct
     */
    private TaskoQuartzHelper() {
    }
    /**
     * unschedule quartz trigger
     * just for sanity purposes
     * @param trigger trigger to unschedule
     */
    public static void unscheduleTrigger(Trigger trigger) {
        try {
            log.warn("Removing trigger " + trigger.getGroup() + "." + trigger.getName());
            SchedulerKernel.getScheduler().unscheduleJob(trigger.getName(),
                    trigger.getGroup());
        }
        catch (SchedulerException e) {
            // be silent
        }
    }

    /**
     * creates a quartz job according to the schedule
     * @param schedule schedule as a job template
     * @return date of first schedule
     * @throws InvalidParamException thrown in case of invalid cron expression
     */
    public static Date createJob(TaskoSchedule schedule) throws InvalidParamException {
        // create trigger
        Trigger trigger = null;
        if (schedule.getCronExpr().isEmpty()) {
            trigger = new SimpleTrigger(schedule.getJobLabel(),
                    getGroupName(schedule.getOrgId()), 1, 1);
            trigger.setEndTime(new Date());
        }
        else {
            try {
                trigger = new CronTrigger(schedule.getJobLabel(),
                        getGroupName(schedule.getOrgId()),
                            schedule.getCronExpr());
                trigger.setStartTime(schedule.getActiveFrom());
                trigger.setEndTime(schedule.getActiveTill());
            }
            catch (ParseException e) {
                throw new InvalidParamException("Invalid cron expression " +
                        schedule.getCronExpr());
            }

        }
        // create job
        JobDetail jobDetail = new JobDetail(schedule.getJobLabel(),
                getGroupName(schedule.getOrgId()), TaskoJob.class);
        // set job params
        if (schedule.getDataMap() != null) {
            jobDetail.getJobDataMap().putAll(schedule.getDataMap());
        }
        jobDetail.getJobDataMap().put("schedule_id", schedule.getId());

        // schedule job
        try {
            Date date = SchedulerKernel.getScheduler().scheduleJob(jobDetail, trigger);
            log.info("Job " + schedule.getJobLabel() + " scheduled succesfully.");
            return date;
        }
        catch (SchedulerException e) {
            log.warn("Job " + schedule.getJobLabel() + " failed to schedule.");
            return null;
        }
    }

    /**
     * unschedules job
     * @param orgId organization id
     * @param jobLabel job name
     * @return 1 if successful
     */
    public static Integer destroyJob(Integer orgId, String jobLabel) {
        try {
            SchedulerKernel.getScheduler().unscheduleJob(jobLabel,
                    getGroupName(orgId));
            log.info("Job " + jobLabel + " unscheduled succesfully.");
            return 1;
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    /**
     * return quartz group name
     * @param orgId organizational id
     * @return group name
     */
    public static String getGroupName(Integer orgId) {
        if (orgId == null) {
            return null;
        }
        return orgId.toString();
    }
}
