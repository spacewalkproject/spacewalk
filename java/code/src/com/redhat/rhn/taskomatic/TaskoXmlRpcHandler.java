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


/**
 *
 * TaskoXmlRpcHandler
 * @version $Rev$
 */
public class TaskoXmlRpcHandler {

    /**
     * dummy call
     * @param orgId organization id
     * @return 1
     */
    public int one(Integer orgId) {
        return 1;
    }

    /**
     * lists all available organizational bunches
     * @param orgId organization id
     * @return list of bunches
     */
    public List<TaskoBunch> listBunches(Integer orgId) {
        return TaskoFactory.listOrgBunches();
    }

    /**
     * lists all available satellite bunches
     * @return list of bunches
     */
    public List<TaskoBunch> listSatBunches() {
        return TaskoFactory.listSatBunches();
    }

    /**
     * start scheduling a organizational bunch
     * @param orgId organization id
     * @param bunchName bunch name
     * @param jobLabel job name
     * @param startTime schedule from
     * @param endTime schedule till
     * @param cronExpression cron expression
     * @param params job parameters
     * @return date of the first schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException thrown if job name already in use,
     * invalid cron expression, ...
     */
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

    /**
     * start scheduling a satellite bunch
     * @param bunchName bunch name
     * @param jobLabel job name
     * @param startTime schedule from
     * @param endTime scchedule till
     * @param cronExpression crom expression
     * @param params job parameters
     * @return date of the first schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException thrown if job name already in use,
     * invalid cron expression, ...
     */
    public Date scheduleSatBunch(String bunchName, String jobLabel,
            Date startTime, Date endTime, String cronExpression, Map params)
    throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleBunch(null, bunchName, jobLabel, startTime, endTime,
                cronExpression, params);
    }

    /**
     * start scheduling a organizational bunch
     * @param orgId organization id
     * @param bunchName bunch name
     * @param jobLabel job name
     * @param cronExpression crom expression
     * @param params job parameters
     * @return date of the first schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException thrown if job name already in use,
     * invalid cron expression, ...
     */
    public Date scheduleBunch(Integer orgId, String bunchName, String jobLabel,
            String cronExpression, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleBunch(orgId, bunchName, jobLabel, new Date(), null,
                cronExpression, params);
    }

    /**
     * start scheduling a satellite bunch
     * @param bunchName bunch name
     * @param jobLabel job name
     * @param cronExpression crom expression
     * @param params job paramters
     * @return date of the first schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException thrown if job name already in use,
     * invalid cron expression, ...
     */
    public Date scheduleSatBunch(String bunchName, String jobLabel,
            String cronExpression, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleBunch(null, bunchName, jobLabel,
                cronExpression, params);
    }

    private TaskoBunch doBasicCheck(Integer orgId, String bunchName,
            String jobLabel)
        throws NoSuchBunchTaskException, InvalidParamException, SchedulerException {
        TaskoBunch bunch = checkBunchName(orgId, bunchName);
        if (!TaskoFactory.listActiveSchedulesByOrgAndLabel(orgId, jobLabel).isEmpty() ||
                (SchedulerKernel.getScheduler().getTrigger(jobLabel, getGroupName(orgId)) !=
                null)) {
            String[] triggerNames =
                SchedulerKernel.getScheduler().getTriggerNames(getGroupName(orgId));
            throw new InvalidParamException("jobLabel already in use");
        }
        return bunch;
    }

    /**
     * stop scheduling an organizational bunch
     * @param orgId organization id
     * @param jobLabel job name
     * @return 1 if successful
     * @throws InvalidParamException thrown if job name not known
     */
    public Integer unscheduleBunch(Integer orgId, String jobLabel)
        throws InvalidParamException {
        List<TaskoSchedule> scheduleList =
            TaskoFactory.listActiveSchedulesByOrgAndLabel(orgId, jobLabel);
        Trigger trigger;
        try {
            trigger = SchedulerKernel.getScheduler().getTrigger(jobLabel,
                    getGroupName(orgId));
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

    /**
     * stop scheduling a satellite bunch
     * @param jobLabel job name
     * @return 1 if successful
     * @throws InvalidParamException thrown if jobLabel not known
     */
    public Integer unscheduleSatBunch(String jobLabel) throws InvalidParamException {
        return unscheduleBunch(null, jobLabel);
    }

    /**
     * schedule a one time organizational bunch
     * @param orgId organization id
     * @param bunchName bunch name
     * @param params job parameters
     * @param start schedule time
     * @return date of the schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException shall not be thrown
     */
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

    /**
     * schedule a one time satellite bunch
     * @param bunchName bunch name
     * @param params job parameters
     * @param start schedule time
     * @return date of the schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException shall not be thrown
     */
    public Date scheduleSingleSatBunchRun(String bunchName, Map params, Date start)
        throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleSingleBunchRun(null, bunchName, params, start);
    }

    /**
     * schedule a one time organizational bunch asap
     * @param orgId organization id
     * @param bunchName bunch name
     * @param params job parameters
     * @return date of the schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException shall not be thrown
     */
    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, Map params)
            throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleSingleBunchRun(orgId, bunchName, params, new Date());
    }

    /**
     * schedule a one time satellite bunch asap
     * @param bunchName bunch name
     * @param params job parameters
     * @return date of the schedule
     * @throws NoSuchBunchTaskException thrown if bunch name not known
     * @throws InvalidParamException shall not be thrown
     */
    public Date scheduleSingleSatBunchRun(String bunchName, Map params)
        throws NoSuchBunchTaskException, InvalidParamException {
        return scheduleSingleBunchRun(null, bunchName, params, new Date());
    }

    private String getUniqueSingleJobLabel(Integer orgId, String bunchName)
        throws SchedulerException {
        String jobLabel = "single-" + bunchName + "-";
        Integer count = 0;
        while (!TaskoFactory.listSchedulesByOrgAndLabel(orgId,
                jobLabel + count.toString()).isEmpty() ||
                (SchedulerKernel.getScheduler().getTrigger(jobLabel + count.toString(),
                        getGroupName(orgId)) != null)) {
            count++;
        }
        return jobLabel + count.toString();
    }

    private Date createJob(TaskoSchedule schedule) throws InvalidParamException {
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
                        getGroupName(schedule.getOrgId()), schedule.getCronExpr());
                trigger.setStartTime(schedule.getActiveFrom());
                trigger.setEndTime(schedule.getActiveTill());
            }
            catch (ParseException e) {
                throw new InvalidParamException("Invalid cron expression");
            }

        }
        // create job
        JobDetail jobDetail = new JobDetail(schedule.getJobLabel(),
                getGroupName(schedule.getOrgId()), TaskoJob.class);
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
            SchedulerKernel.getScheduler().unscheduleJob(jobLabel, getGroupName(orgId));
            return 1;
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    private TaskoBunch checkBunchName(Integer orgId, String bunchName)
        throws NoSuchBunchTaskException {
        TaskoBunch bunch = null;
        if (orgId == null) {
            bunch = TaskoFactory.lookupSatBunchByName(bunchName);
        }
        else {
            bunch = TaskoFactory.lookupOrgBunchByName(bunchName);
        }
        if (bunch == null) {
            throw new NoSuchBunchTaskException(bunchName);
        }
        return bunch;
    }

    /**
     * lists all organizational schedules
     * @param orgId organization id
     * @return list of schedules
     */
    public List<TaskoSchedule> listAllSchedules(Integer orgId) {
        return TaskoFactory.listSchedulesByOrg(orgId);
    }

    /**
     * lists all satellite schedules
     * @return list of schedules
     */
    public List<TaskoSchedule> listAllSatSchedules() {
        return listAllSchedules(null);
    }

    /**
     * lists all active organizational schedules
     * @param orgId organizational id
     * @return list of schedules
     */
    public List<TaskoSchedule> listActiveSchedules(Integer orgId) {
        return TaskoFactory.listActiveSchedulesByOrg(orgId);
    }

    /**
     * lists all active satellite schedules
     * @return list of schedules
     */
    public List<TaskoSchedule> listActiveSatSchedules() {
        return listActiveSchedules(null);
    }

    /**
     * lists all organizational runs of a give schedule
     * @param orgId organizational id
     * @param scheduleId schedule id
     * @return list of runs
     */
    public List<TaskoRun> listScheduleRuns(Integer orgId, Integer scheduleId) {
        return TaskoFactory.listRunsByOrgAndSchedule(orgId, scheduleId);
    }

    /**
     * lists all satellite runs of a give schedule
     * @param scheduleId schedule id
     * @return list of runs
     */
    public List<TaskoRun> listScheduleSatRuns(Integer scheduleId) {
        return listScheduleRuns(null, scheduleId);
    }

    /**
     * get last specified number of bytes of the organizational run std output log
     * whole log is returned if nBytes is negative
     * @param orgId organization id
     * @param runId run id
     * @param nBytes number of bytes
     * @return last n bytes of a run log
     * @throws InvalidParamException thrown if run id not known
     */
    public String getRunStdOutputLog(Integer orgId, Integer runId, Integer nBytes)
        throws InvalidParamException {
        TaskoRun run = TaskoFactory.lookupRunByOrgAndId(orgId, runId);
        return run.getTailOfStdOutput(nBytes);
    }

    /**
     * get last specified number of bytes of the satellite run std output log
     * whole log is returned if nBytes is negative
     * @param runId run id
     * @param nBytes number of bytes
     * @return last n bytes of a run log
     * @throws InvalidParamException thrown if run id not known
     */
    public String getSatRunStdOutputLog(Integer runId, Integer nBytes)
    throws InvalidParamException {
        return getRunStdOutputLog(null, runId, nBytes);
    }

    /**
     * get last specified number of bytes of the organizational run std error log
     * whole log is returned if nBytes is negative
     * @param orgId organization id
     * @param runId run id
     * @param nBytes number of bytes
     * @return last n bytes of a run log
     * @throws InvalidParamException thrown if run id not known
     */
    public String getRunStdErrorLog(Integer orgId, Integer runId, Integer nBytes)
        throws InvalidParamException {
        TaskoRun run = TaskoFactory.lookupRunByOrgAndId(orgId, runId);
        return run.getTailOfStdError(nBytes);
    }

    /**
     * get last specified number of bytes of the satellite run std error log
     * whole log is returned if nBytes is negative
     * @param runId run id
     * @param nBytes number of bytes
     * @return last n bytes of a run log
     * @throws InvalidParamException thrown if run id not known
     */
    public String getSatRunStdErrorLog(Integer runId, Integer nBytes)
    throws InvalidParamException {
        return getRunStdErrorLog(null, runId, nBytes);
    }

    private String getGroupName(Integer orgId) {
        if (orgId == null) {
            return null;
        }
        return orgId.toString();
    }
}
