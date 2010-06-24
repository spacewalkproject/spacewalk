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


import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Date;
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

    public static TaskoBunch lookupOrgBunchByName(String bunchName) {
        Map params = new HashMap();
        params.put("name", bunchName);
        return (TaskoBunch) singleton.lookupObjectByNamedQuery(
                                       "TaskoBunch.lookupOrgBunchByName", params);
    }

    public static TaskoTemplate lookupTemplateByBunchAndOrder(Long bunchId, Long order) {
        Map params = new HashMap();
        params.put("bunch_id", bunchId);
        params.put("order", order);
        return (TaskoTemplate) singleton.lookupObjectByNamedQuery(
                                       "TaskoTemplate.lookupByBunchAndOrder", params);
    }

    public static List<TaskoBunch> listOrgBunches() {
        return (List) singleton.listObjectsByNamedQuery(
                                       "TaskoBunch.listOrgBunches", null);
    }

    public static List<TaskoBunch> listSatBunches() {
        return (List) singleton.listObjectsByNamedQuery(
                                       "TaskoBunch.listSatBunches", null);
    }

    public static void save(TaskoRun taskoRun) {
        singleton.saveObject(taskoRun);
    }

    public static void delete(TaskoRun taskoRun) {
        singleton.removeObject(taskoRun);
    }

    private static void delete(TaskoSchedule taskoSchedule) {
        singleton.removeObject(taskoSchedule);
    }

    public static void save(TaskoTemplate taskoTemplate) {
        singleton.saveObject(taskoTemplate);
    }

    public static void save(TaskoSchedule taskoSchedule) {
        singleton.saveObject(taskoSchedule);
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

    public static List<TaskoRun> listRunsOlderThan(Integer orgId, Date limitTime) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("limit_time", limitTime);
        return (List<TaskoRun>) singleton.listObjectsByNamedQuery(
                "TaskoRun.listOlderThan", params);
    }

    public static void clearOrgRunHistory(Integer orgId, Date limitTime)
        throws InvalidParamException {
        if (limitTime == null) {
            throw new InvalidParamException("Invalid limit date");
        }
        List<TaskoRun> runList = listRunsOlderThan(orgId, limitTime);
        for (TaskoRun run : runList) {
            // delete history of runs
            TaskoFactory.deleteLogFiles(run);
            TaskoFactory.delete(run);
        }

        // delete outdated schedules
        List<TaskoSchedule> scheduleList = listSchedulesByOrg(orgId);
        for (TaskoSchedule schedule : scheduleList) {
            Date endTime = schedule.getActiveTill();
            if ((endTime != null) && (endTime.before(limitTime)) &&
                    TaskoFactory.listRunsBySchedule(schedule.getId()).isEmpty()) {
                TaskoFactory.delete(schedule);
            }
        }
    }

    public static void deleteLogFiles(TaskoRun run) {
        String out = run.getStdOutputPath();
        if ((out != null) && (!out.isEmpty())) {
            deleteFile(out);
            run.setStdOutputPath(null);
        }
        String err = run.getStdErrorPath();
        if ((err != null) && (!err.isEmpty())) {
            deleteFile(err);
            run.setStdErrorPath(null);
        }
    }

    private static boolean deleteFile(String fileName) {
        File file = new File(fileName);
        if (file.exists()) {
            return file.delete();
        }
        return false;
    }

    public static List<TaskoSchedule> listActiveSchedulesByOrg(Integer orgId) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("timestamp", new Date());    // use server time, not DB time
        return (List<TaskoSchedule>) singleton.listObjectsByNamedQuery(
                   "TaskoSchedule.listActiveByOrg", params);
    }

    public static List<TaskoSchedule> listActiveSchedulesByOrgAndLabel(Integer orgId,
            String jobLabel) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("job_label", jobLabel);
        params.put("timestamp", new Date());    // use server time, not DB time
        return (List<TaskoSchedule>) singleton.listObjectsByNamedQuery(
                   "TaskoSchedule.listActiveByOrgAndLabel", params);
    }

    public static TaskoSchedule lookupScheduleById(Long scheduleId) {
        Map params = new HashMap();
        params.put("schedule_id", scheduleId);
        return (TaskoSchedule) singleton.lookupObjectByNamedQuery(
                                       "TaskoSchedule.lookupById", params);
    }

    public static List<TaskoSchedule> listSchedulesByOrg(Integer orgId) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listByOrg", params);
    }

    public static List<TaskoRun> listRunsBySchedule(Long scheduleId) {
        Map params = new HashMap();
        params.put("schedule_id", scheduleId);
        return singleton.listObjectsByNamedQuery(
                                       "TaskoRun.listBySchedule", params);
    }

    public static List<TaskoSchedule> listSchedulesByOrgAndBunch(Integer orgId,
            TaskoBunch bunch) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("bunch_id", bunch.getId());
        return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listByOrgAndBunch", params);
    }

    public static List<TaskoSchedule> listSchedulesByOrgAndLabel(Integer orgId,
            String jobLabel) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("job_label", jobLabel);
        return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listByOrgAndLabel", params);
    }

    public static TaskoRun lookupRunById(Long runId) {
        Map params = new HashMap();
        params.put("run_id", runId);
        return (TaskoRun) singleton.lookupObjectByNamedQuery(
                                       "TaskoRun.lookupById", params);
    }

    public static Boolean isTaskParalelizable(TaskoTask task) {
        Class taskClass;
        try {
            taskClass = Class.forName(task.getTaskClass());
            Method isParallelizableMethod = taskClass.getMethod("isParallelizable",
                    (Class[]) null);
            return (Boolean) isParallelizableMethod.invoke(null, (Object[]) null);
        }
        catch (ClassNotFoundException e) {
            return false;
        }
        catch (SecurityException e) {
            return false;
        }
        catch (NoSuchMethodException e) {
            return false;
        }
        catch (IllegalArgumentException e) {
            return false;
        }
        catch (IllegalAccessException e) {
            return false;
        }
        catch (InvocationTargetException e) {
            return false;
        }
    }

    public static TaskoRun getRunByOrgAndId(Integer orgId, Long runId)
        throws InvalidParamException {
        TaskoRun run = lookupRunById(runId);
        if ((run == null) || (!run.getOrgId().equals(orgId))) {
            throw new InvalidParamException("No such run id");
        }
        return run;
    }

    public static TaskoSchedule getScheduleByOrgAndId(Integer orgId,
            Long scheduleId) throws InvalidParamException {
        TaskoSchedule schedule = lookupScheduleById(scheduleId);
        if ((schedule == null) || (!schedule.getOrgId().equals(orgId))) {
            throw new InvalidParamException("No such schedule id");
        }
        return schedule;
    }

    public static List<TaskoRun> getRunsByOrgAndSchedule(Integer orgId,
            Integer scheduleId) {
        List<TaskoRun> runs = listRunsBySchedule(scheduleId.longValue());
        // verify it belongs to the right org
        for (Iterator<TaskoRun> iter = runs.iterator(); iter.hasNext();) {
            if (!iter.next().getOrgId().equals(orgId)) {
                iter.remove();
            }
        }
        return runs;
    }
}
