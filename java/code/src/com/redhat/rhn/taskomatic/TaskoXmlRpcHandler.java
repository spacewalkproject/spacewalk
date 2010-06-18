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
import java.util.List;
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
            throws NoSuchBunchTaskException, InvalidParamException {
        try {
            TaskoBunch bunch = doBasicCheck(orgId, bunchName, jobLabel);
            // create schedule
            TaskoSchedule schedule = null;
            try {
                schedule = new TaskoSchedule(orgId, bunch, jobLabel, params,
                        startTime, endTime, cronExpression);
                TaskoFactory.save(schedule);
                TaskoFactory.commitTransaction();
            }
            catch (HibernateException he) {
                TaskoFactory.rollbackTransaction();
                return null;
            }
            // create job
            return createJob(schedule);
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public Date scheduleBunch(Integer orgId, String bunchName, String jobLabel,
            String cronExpression, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleBunch(orgId, bunchName, jobLabel, new Date(), null,
                cronExpression, params);
    }

    private TaskoBunch doBasicCheck(Integer orgId, String bunchName,
            String jobLabel)
        throws NoSuchBunchTaskException, SchedulerException,
        InvalidParamException {
        TaskoBunch bunch = checkBunchName(bunchName);
        if (!checkUniqueName(jobLabel, orgId.toString())) {
            throw new InvalidParamException("jobLabel already in use");
        }
        return bunch;
    }

    public Integer unscheduleBunch(Integer orgId, String jobLabel) throws InvalidParamException {
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
        Trigger trigger;
        try {
            trigger = SchedulerKernel.getScheduler().getTrigger(jobLabel, orgId.toString());
        }
        catch (SchedulerException e) {
            trigger = null;
        }
        // check for inconsistencies
        // quartz unschedules job after trigger end time
        // so better handle quartz and schedules separately
        if ((schedule == null) && (trigger == null)) {
            throw new InvalidParamException("No such jobLabel");
        }
        if (schedule != null) {
            Transaction trns = TaskoFactory.getSession().beginTransaction();
            schedule.unschedule();
            TaskoFactory.save(schedule);
            trns.commit();
        }
        if (trigger != null) {
            return destroyJob(orgId, jobLabel);
        }
        return 1;
    }

    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, String jobLabel,
            Map params, Date start)
            throws NoSuchBunchTaskException,
                   InvalidParamException {
        try {
            TaskoBunch bunch = doBasicCheck(orgId, bunchName, jobLabel);
            // create schedule
            TaskoSchedule schedule = null;
            try {
                schedule = new TaskoSchedule(orgId, bunch, jobLabel, params,
                        start, null, "");
                TaskoFactory.save(schedule);
                TaskoFactory.commitTransaction();
            }
            catch (HibernateException he) {
                TaskoFactory.rollbackTransaction();
                return null;
            }
            // create job
            return createJob(schedule);
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, String jobLabel,
            Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleSingleBunchRun(orgId, bunchName, jobLabel, params, new Date());
    }

    private Date createJob(TaskoSchedule schedule) throws InvalidParamException {
        // create trigger
        Trigger trigger = null;
        if (schedule.getCronExpr().isEmpty()) {
            trigger = new SimpleTrigger(schedule.getJobLabel(),
                    schedule.getOrgId().toString(), 1, 1);
            trigger.setEndTime(new Date());
        }
        else {
            try {
                trigger = new CronTrigger(schedule.getJobLabel(),
                        schedule.getOrgId().toString(), schedule.getCronExpr());
                trigger.setStartTime(schedule.getActiveFrom());
                trigger.setEndTime(schedule.getActiveTill());
            }
            catch (ParseException e) {
                throw new InvalidParamException("Invalid cron expression");
            }

        }
        // create job
        JobDetail jobDetail = new JobDetail(schedule.getJobLabel(),
                schedule.getOrgId().toString(), TaskoSchedule.class);
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

    private Integer destroyJob(Integer orgId, String jobLabel) {
        try {
            SchedulerKernel.getScheduler().unscheduleJob(jobLabel, orgId.toString());
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

    public int clearRunHistory(Integer orgId, Date limitTime) throws InvalidParamException {
        TaskoFactory.clearRunHistory(orgId, limitTime);
        return 1;
    }

    public List<TaskoSchedule> listSchedules(Integer orgId) {
        return TaskoFactory.listSchedulesByOrg(orgId);
    }

    public List<TaskoRun> listScheduleRuns(Integer orgId, Long scheduleId) throws InvalidParamException {
        TaskoSchedule schedule = TaskoFactory.getScheduleByOrgAndId(orgId, scheduleId);
        return schedule.getRuns();
    }

    public String getRunStdOutputLog(Integer orgId, Long runId, Long nBytes)
        throws InvalidParamException {
        TaskoRun run = TaskoFactory.getRunByOrgAndId(orgId, runId);
        return run.getTailOfStdOutput(nBytes);
    }

    public String getRunStdErrorLog(Integer orgId, Long runId, Long nBytes)
        throws InvalidParamException {
        TaskoRun run = TaskoFactory.getRunByOrgAndId(orgId, runId);
        return run.getTailOfStdError(nBytes);
    }
}
