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

import org.hibernate.HibernateException;
import org.quartz.CronTrigger;
import org.quartz.JobDetail;
import org.quartz.SchedulerException;
import org.quartz.SimpleTrigger;
import org.quartz.Trigger;

import java.text.ParseException;
import java.util.Date;
import java.util.Map;

public class TaskoXmlRpcHandler {

    private Boolean checkUniqueName(String name, String group) throws SchedulerException {
        return ((SchedulerKernel.getScheduler().getTrigger(name, group) == null) &&
        (SchedulerKernel.getScheduler().getJobDetail(name, group) == null));
    }

    public int one(Integer orgId) {
        return 1;
    }

    public String[] listBunches(Integer orgId) {
        try {
            return SchedulerKernel.getScheduler().getTriggerNames(orgId.toString());
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public Date scheduleBunch(Integer orgId, String bunchName, String jobLabel,
            Date startTime, Date endTime, String cronExpression, Map params)
            throws InvalidJobLabelException, NoSuchBunchTaskException, ParseException {
        try {
            TaskoBunch bunch = doBasicCheck(orgId, bunchName, jobLabel);
            // create trigger
            CronTrigger ct = new CronTrigger(jobLabel, orgId.toString(),
                    cronExpression);
            if (startTime == null) {
                ct.setStartTime(startTime);
            }
            else {
                ct.setStartTime(new Date());
            }
            if (endTime != null) {
                ct.setEndTime(endTime);
            }
            // create schedule
            TaskoSchedule schedule = null;
            try {
                schedule = new TaskoSchedule(orgId, bunch, jobLabel, params, ct);
                TaskoFactory.save(schedule);
                TaskoFactory.commitTransaction();
            }
            catch (HibernateException he) {
                TaskoFactory.rollbackTransaction();
                return null;
            }
            // create job
            return createJob(schedule, ct);
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public Date scheduleBunch(Integer orgId, String bunchName, String jobLabel,
            String cronExpression, Map params)
            throws ParseException, InvalidJobLabelException, NoSuchBunchTaskException {
        return scheduleBunch(orgId, bunchName, jobLabel, new Date(), null, cronExpression,
                params);
    }

    private TaskoBunch doBasicCheck(Integer orgId, String bunchName,
            String jobLabel)
        throws NoSuchBunchTaskException, SchedulerException,
        InvalidJobLabelException {
        TaskoBunch bunch = checkBunchName(bunchName);
        if (!checkUniqueName(jobLabel, orgId.toString())) {
            throw new InvalidJobLabelException("jobLabel already in use");
        }
        return bunch;
    }

    public Integer unscheduleBunch(Integer orgId, String jobLabel) {
        /*
        try {
            Trigger trigger = SchedulerKernel.getScheduler().getTrigger(
                    jobLabel, orgId.toString());
            Trigger newTrigger = (Trigger) trigger.clone();
            newTrigger.setEndTime(new Date());
            SchedulerKernel.getScheduler().rescheduleJob(jobLabel, orgId.toString(),
                    newTrigger);
        }
        catch (SchedulerException e) {
                throw new NoSuchTaskoTriggerException();
        }
        */
        TaskoSchedule schedule =
            TaskoFactory.lookupActiveScheduleByOrgAndLabel(orgId, jobLabel);
        schedule.unschedule();
        TaskoFactory.commitTransaction();
        return destroyJob(schedule);
    }

    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, String jobLabel,
            Map params, Date start)
            throws InvalidJobLabelException, NoSuchBunchTaskException {
        try {
            TaskoBunch bunch = doBasicCheck(orgId, bunchName, jobLabel);
            SimpleTrigger st = new SimpleTrigger(jobLabel, orgId.toString(), 1, 1);
            st.setEndTime(new Date());
            // create schedule
            TaskoSchedule schedule = null;
            try {
                schedule = new TaskoSchedule(orgId, bunch, jobLabel, params, st);
                TaskoFactory.save(schedule);
                TaskoFactory.commitTransaction();
            }
            catch (HibernateException he) {
                TaskoFactory.rollbackTransaction();
                return null;
            }
            // create job
            return createJob(schedule, st);
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, String jobLabel,
            Map params)
            throws InvalidJobLabelException, NoSuchBunchTaskException {
        return scheduleSingleBunchRun(orgId, bunchName, jobLabel, params, new Date());
    }

    private Date createJob(TaskoSchedule schedule, Trigger trigger) {
        // create job
        JobDetail jobDetail = new JobDetail(schedule.getJobLabel(), schedule.getOrgId().toString(),
                TaskoSchedule.class);
        // set job params
        jobDetail.getJobDataMap().putAll(schedule.getDataMap());
        jobDetail.getJobDataMap().put("schedule_id", schedule.getId());

        // schedule job
        try {
            return SchedulerKernel.getScheduler().scheduleJob(jobDetail, trigger);
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    private Integer destroyJob(TaskoSchedule schedule) {
        try {
            SchedulerKernel.getScheduler().unscheduleJob(schedule.getJobLabel(),
                    schedule.getOrgId().toString());
            return 1;
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    private TaskoBunch checkBunchName(String bunchName)
        throws NoSuchBunchTaskException {
        TaskoBunch bunch = TaskoFactory.lookupOrgBunchByName(bunchName);
        if (bunch == null) {
            throw new NoSuchBunchTaskException(bunchName);
        }
        return bunch;
    }

    public int listBunchRuns(Integer orgId, String triggerName)
                                            throws SchedulerException {
        return SchedulerKernel.getScheduler().unscheduleJob(triggerName,
                orgId.toString()) ? 1 : 0;
    }

    public int clearRunHistory(Integer orgId, Date limitTime) {
        TaskoFactory.clearRunHistory(orgId, limitTime);
        return 1;
    }
}
