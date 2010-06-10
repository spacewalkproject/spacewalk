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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.taskomatic.TaskoBunch;
import com.redhat.rhn.taskomatic.core.SchedulerKernel;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.SchedulerException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


/**
 * TaskoFactory
 * @version $Rev$
 */
public class TaskoFactory extends HibernateFactory {
    private static TaskoFactory singleton = new TaskoFactory();
    private static Logger log = Logger.getLogger(TaskoFactory.class);

    TaskoFactory() {
        super();
    }

    protected Logger getLogger() {
        return log;
    }

    public static TaskoBunch lookupByName(String bunchName) {
        Map params = new HashMap();
        params.put("name", bunchName);
        return (TaskoBunch) singleton.lookupObjectByNamedQuery(
                                       "TaskoBunch.findByName", params);
    }

    public static List<TaskoBunch> listBunches() {
        return (List) singleton.listObjectsByNamedQuery(
                                       "TaskoBunch.listBunches", null);
    }

    public static void save(TaskoRun taskoRun) {
        singleton.saveObject(taskoRun);
    }

    public static boolean isBunchTypeCurrentlyExecuting(TaskoBunch bunch) throws SchedulerException {
        List<JobExecutionContext> contexts = SchedulerKernel.getScheduler().getCurrentlyExecutingJobs();
        int count = 0;
        for (JobExecutionContext context : contexts) {
            String runningBunchName = context.getJobDetail().getJobDataMap().getString("bunch_name");
            if (runningBunchName.equals(bunch.getName())) {
                count ++;
            }
        }
        return count > 1;
    }

    public static boolean isTaskTypeCurrentlyExecuting(TaskoTask task) {
        Map params = new HashMap();
        params.put("task_id", task.getId());
        params.put("status1", TaskoRun.STATUS_READY_TO_RUN);
        params.put("status2", TaskoRun.STATUS_RUNNING);
        List<TaskoRun> runs = (List<TaskoRun>) singleton.listObjectsByNamedQuery(
                                       "TaskoRun.listRunsWithStatus", params);
        return runs.size() != 0;
    }

    public static void sleep(long millis) {
        try {
            Thread.sleep(millis);
        }
        catch (InterruptedException e) {
            log.warn("InterruptedException");
        }
    }

    public static List<TaskoTask> listTasks() {
        return (List<TaskoTask>) singleton.listObjectsByNamedQuery(
                                       "TaskoTask.listTasks", new HashMap());
    }
}
