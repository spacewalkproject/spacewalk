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
            // create trigger
            CronTrigger ct = new CronTrigger(jobLabel, orgId.toString(),
                    cronExpression);
            if (startTime != null) {
                ct.setStartTime(startTime);
            }
            if (endTime != null) {
                ct.setEndTime(endTime);
            }
            // create job
            JobDetail jobDetail = createJob(bunchName, orgId, jobLabel, params,
                    startTime, endTime);
            // schedule job
            return SchedulerKernel.getScheduler().scheduleJob(jobDetail, ct);
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

    public int unscheduleBunch(Integer orgId, String jobLabel)
                                            throws NoSuchTaskoTriggerException {
        try {
            Trigger trigger = SchedulerKernel.getScheduler().getTrigger(
                    jobLabel, orgId.toString());
            if (false) {
                Trigger newTrigger = (Trigger) trigger.clone();
                newTrigger.setEndTime(new Date());
                SchedulerKernel.getScheduler().rescheduleJob(jobLabel, orgId.toString(),
                        newTrigger);
            }
            else {
                SchedulerKernel.getScheduler().unscheduleJob(jobLabel, orgId.toString());
                TaskoSchedule schedule =
                    TaskoFactory.lookupActiveScheduleByOrgAndLabel(orgId, jobLabel);
                Map map = schedule.getDataMap();
                schedule.unschedule();

                // TaskoFactory.save(schedule);
                TaskoFactory.commitTransaction();
            }
            return 1;
        }
        catch (SchedulerException e) {
            throw new NoSuchTaskoTriggerException();
        }
    }

    public Date scheduleSingleBunchRun(Integer orgId, String bunchName, String jobLabel,
            Map params, Date start)
            throws InvalidJobLabelException, NoSuchBunchTaskException {
        try {
            SimpleTrigger st = new SimpleTrigger(jobLabel, orgId.toString(), 1, 1);
            st.setEndTime(new Date());
            JobDetail jobDetail = createJob(bunchName, orgId, jobLabel, params,
                    start, st.getEndTime());

            // schedule job
            return SchedulerKernel.getScheduler().scheduleJob(jobDetail, st);
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

    private JobDetail createJob(String bunchName, Integer orgId,
            String jobLabel, Map params, Date start, Date end)
        throws SchedulerException, InvalidJobLabelException, NoSuchBunchTaskException {
        if (!checkUniqueName(jobLabel, orgId.toString())) {
            throw new InvalidJobLabelException("jobLabel already in use");
        }
        TaskoBunch bunch = TaskoFactory.lookupOrgBunchByName(bunchName);
        if (bunch == null) {
            throw new NoSuchBunchTaskException(bunchName);
        }
        // create job
        JobDetail jobDetail = new JobDetail(jobLabel, orgId.toString(),
                TaskoSchedule.class);
        TaskoSchedule schedule = new TaskoSchedule(orgId, bunch, jobLabel, params,
                start, end);
        TaskoFactory.save(schedule);
        TaskoFactory.commitTransaction();
        // set job params
        jobDetail.getJobDataMap().putAll(params);
        jobDetail.getJobDataMap().put("org_id", orgId);
        jobDetail.getJobDataMap().put("schedule_id", schedule.getId());

        return jobDetail;
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
