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

    public int one(Integer orgId) {
        return 1;
    }

    public List<TaskoBunch> listBunches(Integer orgId) {
        return TaskoFactory.listOrgBunches();
    }

    public List<TaskoBunch> listSatBunches() {
        return TaskoFactory.listSatBunches();
    }

    public Date scheduleBunch(Integer orgId, String bunchName, String jobLabel,
            Date startTime, Date endTime, String cronExpression, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        TaskoBunch bunch = null;
        try {
            bunch = doBasicCheck(orgId, bunchName, jobLabel);
        }
        catch (SchedulerException se) {
            return null;
        }
        // create schedule
        TaskoSchedule schedule = null;
        schedule = new TaskoSchedule(orgId, bunch, jobLabel, params,
                startTime, endTime, cronExpression);
        TaskoFactory.save(schedule);
        // create job
        Date scheduleDate =  createJob(schedule);
        if (scheduleDate == null) {
            TaskoFactory.delete(schedule);
        }
        return scheduleDate;
    }

    public Date scheduleSatBunch(String bunchName, String jobLabel,
            Date startTime, Date endTime, String cronExpression, Map params)
    throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleBunch(null, bunchName, jobLabel, startTime, endTime,
                cronExpression, params);
    }

    public Date scheduleBunch(Integer orgId, String bunchName, String jobLabel,
            String cronExpression, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleBunch(orgId, bunchName, jobLabel, new Date(), null,
                cronExpression, params);
    }

    public Date scheduleSatBunch(String bunchName, String jobLabel,
            String cronExpression, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleBunch(null, bunchName, jobLabel,
                cronExpression, params);
    }

    private TaskoBunch doBasicCheck(Integer orgId, String bunchName,
            String jobLabel)
        throws NoSuchBunchTaskException, InvalidParamException, SchedulerException {
        TaskoBunch bunch = checkBunchName(bunchName);
        if (!TaskoFactory.listActiveSchedulesByOrgAndLabel(orgId, jobLabel).isEmpty() ||
                (SchedulerKernel.getScheduler().getTrigger(jobLabel, orgId.toString()) !=
                null)) {
            throw new InvalidParamException("jobLabel already in use");
        }
        return bunch;
    }

    public Integer unscheduleBunch(Integer orgId, String jobLabel)
        throws InvalidParamException {
        List<TaskoSchedule> scheduleList =
            TaskoFactory.listActiveSchedulesByOrgAndLabel(orgId, jobLabel);
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
        if ((scheduleList.isEmpty()) && (trigger == null)) {
            throw new InvalidParamException("No such jobLabel");
        }
        for (TaskoSchedule schedule : scheduleList) {
            schedule.unschedule();
        }
        if (trigger != null) {
            return destroyJob(orgId, jobLabel);
        }
        return 1;
    }

    public Integer unscheduleSatBunch(String jobLabel) throws InvalidParamException {
        return unscheduleBunch(null, jobLabel);
    }

    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, Map params,
            Date start)
            throws NoSuchBunchTaskException,
                   InvalidParamException {
        String jobLabel = null;
        TaskoBunch bunch = null;
        try {
            jobLabel = getUniqueSingleJobLabel(orgId, bunchName);
            bunch = doBasicCheck(orgId, bunchName, jobLabel);
        }
        catch (SchedulerException se) {
            return null;
        }
        // create schedule
        TaskoSchedule schedule = null;
        schedule = new TaskoSchedule(orgId, bunch, jobLabel, params,
                start, null, "");
        TaskoFactory.save(schedule);
        // create job
        Date scheduleDate = createJob(schedule);
        if (scheduleDate == null) {
            TaskoFactory.delete(schedule);
        }
        return scheduleDate;
    }

    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleSingleBunchRun(orgId, bunchName, params, new Date());
    }

    private String getUniqueSingleJobLabel(Integer orgId, String bunchName)
        throws SchedulerException {
        String jobLabel = "single-" + bunchName + "-";
        Integer count = 0;
        while (!TaskoFactory.listSchedulesByOrgAndLabel(orgId,
                jobLabel + count.toString()).isEmpty() ||
                (SchedulerKernel.getScheduler().getTrigger(jobLabel + count.toString(),
                        orgId.toString()) != null)) {
            count++;
        }
        return jobLabel + count.toString();
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

    public int clearRunHistory(Integer orgId, Date limitTime) throws InvalidParamException {
        TaskoFactory.clearOrgRunHistory(orgId, limitTime);
        return 1;
    }

    public int clearSatRunHistory(Date limitTime) throws InvalidParamException {
        TaskoFactory.clearOrgRunHistory(null, limitTime);
        return 1;
    }

    public List<TaskoSchedule> listAllSchedules(Integer orgId) {
        return TaskoFactory.listSchedulesByOrg(orgId);
    }

    public List<TaskoSchedule> listAllSatSchedules() {
        return listAllSchedules(null);
    }

    public List<TaskoSchedule> listActiveSchedules(Integer orgId) {
        return TaskoFactory.listActiveSchedulesByOrg(orgId);
    }

    public List<TaskoSchedule> listActiveSatSchedules() {
        return listActiveSchedules(null);
    }

    public List<TaskoRun> listScheduleRuns(Integer orgId, Integer scheduleId) {
        return TaskoFactory.getRunsByOrgAndSchedule(orgId, scheduleId);
    }

    public List<TaskoRun> listScheduleSatRuns(Integer scheduleId) {
        return listScheduleRuns(null, scheduleId);
    }

    public String getRunStdOutputLog(Integer orgId, Long runId, Long nBytes)
        throws InvalidParamException {
        TaskoRun run = TaskoFactory.getRunByOrgAndId(orgId, runId);
        return run.getTailOfStdOutput(nBytes);
    }

    public String getSatRunStdOutputLog(Long runId, Long nBytes)
    throws InvalidParamException {
        return getRunStdOutputLog(null, runId, nBytes);
    }

    public String getRunStdErrorLog(Integer orgId, Long runId, Long nBytes)
        throws InvalidParamException {
        TaskoRun run = TaskoFactory.getRunByOrgAndId(orgId, runId);
        return run.getTailOfStdError(nBytes);
    }

    public String getSatRunStdErrorLog(Long runId, Long nBytes)
    throws InvalidParamException {
        return getRunStdErrorLog(null, runId, nBytes);
    }
}
