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
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class TaskoXmlRpcHandler {

    private Scheduler scheduler;

    public TaskoXmlRpcHandler() {
        scheduler = SchedulerKernel.getScheduler();
    }

    /*
    private String getUniqueName(String name, String group) throws SchedulerException {
        Integer count = 0;
        while ((SchedulerKernel.getScheduler().getTrigger(
                        name + "-" + count, group) != null)
              && (SchedulerKernel.getScheduler().getJobDetail(
                        name + "-" + count, group) != null)) {
            count ++;
        }
        return name + "-" + count;
    }
    */

    private Boolean checkUserName(String name, String group) throws SchedulerException {
        return ((SchedulerKernel.getScheduler().getTrigger(name, group) == null)
        && (SchedulerKernel.getScheduler().getJobDetail(name, group) == null));
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
            throws ParseException, NoSuchTaskException, InvalidJobLabelException {
        try {
            if (!checkUserName(jobLabel, orgId.toString())) {
                throw new InvalidJobLabelException();
            }
            // create job
            JobDetail jobDetail = new JobDetail(jobLabel, orgId.toString(),
                    TaskoBunch.class);
            // set job params
            jobDetail.getJobDataMap().putAll(params);
            jobDetail.getJobDataMap().put("org_id", orgId);
            jobDetail.getJobDataMap().put("bunch_name", bunchName);
            jobDetail.getJobDataMap().put("job_label", jobLabel);
            // create trigger
            CronTrigger ct = new CronTrigger(jobLabel, orgId.toString(),
                    cronExpression);
            if (startTime != null) {
                ct.setStartTime(startTime);
            }
            if (endTime != null) {
                ct.setEndTime(endTime);
            }
            // schedule job
            return SchedulerKernel.getScheduler().scheduleJob(jobDetail, ct);
        }
        catch (SchedulerException e) {
            return null;
        }
    }

    public Date scheduleBunch(Integer orgId, String bunchName, String jobLabel,
            String cronExpression, Map params)
            throws ParseException, NoSuchTaskException, InvalidJobLabelException {
        return scheduleBunch(orgId, bunchName, jobLabel, null, null, cronExpression, params);
    }

    public int unscheduleBunch(Integer orgId, String triggerName) throws NoSuchTaskoTriggerException {
        try {
            return SchedulerKernel.getScheduler().unscheduleJob(triggerName, orgId.toString())?1:0;
        }
        catch (SchedulerException e) {
            throw new NoSuchTaskoTriggerException();
        }
    }

    public int listBunchRuns(Integer orgId, String triggerName) throws NoSuchTaskoTriggerException {
        try {
            return SchedulerKernel.getScheduler().unscheduleJob(triggerName, orgId.toString())?1:0;
        }
        catch (SchedulerException e) {
            throw new NoSuchTaskoTriggerException();
        }
    }
}
