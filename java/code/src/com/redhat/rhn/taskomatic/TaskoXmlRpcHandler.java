/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.taskomatic.core.SchedulerKernel;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.quartz.CronTrigger;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerUtils;

import java.text.ParseException;
import java.util.Date;
import java.util.List;

public class TaskoXmlRpcHandler {

    public static String RHN_BUNCH = "RHN_BUNCH";
    public static String RHN_TASK = "RHN_TASK";
    private Scheduler scheduler;

    public TaskoXmlRpcHandler() {
        scheduler = SchedulerKernel.getScheduler();
    }

    private String getUniqueTriggerName(String name, String group) throws SchedulerException {
        String triggerName = name;
        Integer count = 0;
        while (SchedulerKernel.getScheduler().getTrigger(
                triggerName + "-" + count, group) != null) {
            count ++;
        }
        return triggerName + "-" + count;
    }

    private String getUniqueJobName(String name, String group) throws SchedulerException {
        String jobName = name;
        Integer count = 0;
        while (SchedulerKernel.getScheduler().getJobDetail(
                jobName + "-" + count, group) != null) {
            count ++;
        }
        return jobName + "-" + count;
    }

    public int one(Integer orgId) {
        return 1;
    }

    public String[] listBunches(Integer orgId) {
        try {
            String[] triggerNames = SchedulerKernel.getScheduler().getTriggerNames(RHN_BUNCH);

            for (String triggerName : triggerNames) {
                Trigger trigger = SchedulerKernel.getScheduler().getTrigger(triggerName, RHN_BUNCH);
                // JobDetail jd = SchedulerKernel.getScheduler().getJobDetail(trigger.getJobName(), RHN_BUNCH);
            }

            return triggerNames;
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public Date scheduleBunch(Integer orgId, String bunchName, String cronExpression) throws ParseException, NoSuchTaskException {
        try {
            JobDetail jobDetail = SchedulerKernel.getScheduler().getJobDetail(bunchName, RHN_BUNCH);
            if (jobDetail == null) {
                jobDetail = new JobDetail(bunchName, RHN_BUNCH, TaskoBunch.class);
                jobDetail.getJobDataMap().put("org_id", orgId);
                jobDetail.getJobDataMap().put("name", bunchName);
                CronTrigger ct = new CronTrigger(getUniqueTriggerName(bunchName + "Trigger" + orgId, RHN_BUNCH), RHN_BUNCH,
                        cronExpression);
                return SchedulerKernel.getScheduler().scheduleJob(jobDetail, ct);
            }
            else {
                CronTrigger ct = new CronTrigger(getUniqueTriggerName(bunchName + "Trigger" + orgId, RHN_BUNCH), RHN_BUNCH,
                        bunchName, RHN_BUNCH, cronExpression);
                return SchedulerKernel.getScheduler().scheduleJob(ct);
            }
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public int unscheduleBunch(Integer orgId, String triggerName) throws NoSuchTaskoTriggerException {
        try {
            return SchedulerKernel.getScheduler().unscheduleJob(triggerName, RHN_BUNCH)?1:0;
        }
        catch (SchedulerException e) {
            throw new NoSuchTaskoTriggerException();
        }
    }
/*
    public Date scheduleTask(Integer orgId, String taskName, String cronExpression) throws ParseException, NoSuchTaskException {
        try {
            JobDetail jobDetail = SchedulerKernel.getScheduler().getJobDetail(taskName, RHN_TASK);
            if (jobDetail == null) {
                Class taskClass = TaskoFactory.traslateTaskNameToClass(taskName);
                if (taskClass == null) {
                    throw new NoSuchTaskException();
                }
                jobDetail = new JobDetail(taskName, RHN_TASK, taskClass);
                jobDetail.getJobDataMap().put("org_id", orgId);
                CronTrigger ct = new CronTrigger(getUniqueTriggerName(taskName + "Trigger" + orgId, RHN_TASK), RHN_TASK,
                        cronExpression);
                return SchedulerKernel.getScheduler().scheduleJob(jobDetail, ct);
            }
            else {
                CronTrigger ct = new CronTrigger(getUniqueTriggerName(taskName + "Trigger" + orgId, RHN_TASK), RHN_TASK,
                        taskName, RHN_TASK, cronExpression);
                return SchedulerKernel.getScheduler().scheduleJob(ct);
            }
        }
        catch (SchedulerException e) {
            return null;
        }
    }
*/
}
