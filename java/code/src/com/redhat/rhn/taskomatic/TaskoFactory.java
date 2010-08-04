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

    /**
     * default constructor
     */
    TaskoFactory() {
        super();
    }

    protected Logger getLogger() {
        return log;
    }

    /**
     * lookup a organization bunch by name
     * @param bunchName bunch name
     * @return bunch
     */
    public static TaskoBunch lookupOrgBunchByName(String bunchName) {
        Map params = new HashMap();
        params.put("name", bunchName);
        return (TaskoBunch) singleton.lookupObjectByNamedQuery(
                                       "TaskoBunch.lookupOrgBunchByName", params);
    }

    /**
     * lookup a satellite bunch by name
     * @param bunchName bunch name
     * @return bunch
     */
    public static TaskoBunch lookupSatBunchByName(String bunchName) {
        Map params = new HashMap();
        params.put("name", bunchName);
        return (TaskoBunch) singleton.lookupObjectByNamedQuery(
                                       "TaskoBunch.lookupSatBunchByName", params);
    }

    /**
     * lookup template by bunch id and position
     * @param bunchId id of the bunch
     * @param order position
     * @return template
     */
    public static TaskoTemplate lookupTemplateByBunchAndOrder(Long bunchId, Long order) {
        Map params = new HashMap();
        params.put("bunch_id", bunchId);
        params.put("order", order);
        return (TaskoTemplate) singleton.lookupObjectByNamedQuery(
                                       "TaskoTemplate.lookupByBunchAndOrder", params);
    }

    /**
     * list all available organizational bunches
     * @return list of bunches
     */
    public static List<TaskoBunch> listOrgBunches() {
        return (List) singleton.listObjectsByNamedQuery(
                                       "TaskoBunch.listOrgBunches", null);
    }

    /**
     * list all available satellite bunches
     * @return list of bunches
     */
    public static List<TaskoBunch> listSatBunches() {
        return (List) singleton.listObjectsByNamedQuery(
                                       "TaskoBunch.listSatBunches", null);
    }

    /**
     * hibernate save run
     * @param taskoRun run to save
     */
    public static void save(TaskoRun taskoRun) {
        singleton.saveObject(taskoRun);
    }

    /**
     * hibernate delete run
     * @param taskoRun run to delete
     */
    public static void delete(TaskoRun taskoRun) {
        singleton.removeObject(taskoRun);
    }

    /**
     * hibernate delete schedule
     * @param taskoSchedule schadule to delete
     */
    public static void delete(TaskoSchedule taskoSchedule) {
        singleton.removeObject(taskoSchedule);
    }

    /**
     * hibernate save schedule
     * @param taskoSchedule schedule to save
     */
    public static void save(TaskoSchedule taskoSchedule) {
        singleton.saveObject(taskoSchedule);
    }

    /**
     * lists all available tasks
     * @return list of tasks
     */
    public static List<TaskoTask> listTasks() {
        return (List<TaskoTask>) singleton.listObjectsByNamedQuery(
                                       "TaskoTask.listTasks", new HashMap());
    }

    /**
     * lists runs older than given date
     * @param limitTime date of interest
     * @return list of runs
     */
    public static List<TaskoRun> listRunsOlderThan(Date limitTime) {
        Map params = new HashMap();
        params.put("limit_time", limitTime);
        return (List<TaskoRun>) singleton.listObjectsByNamedQuery(
                "TaskoRun.listOlderThan", params);
    }

    /**
     * delete log files associated with given run
     * @param run run to delete logs
     */
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

    /**
     * lists active schedules for a given org
     * @param orgId organization id
     * @return list of active schedules
     */
    public static List<TaskoSchedule> listActiveSchedulesByOrg(Integer orgId) {
        Map params = new HashMap();
        params.put("timestamp", new Date());    // use server time, not DB time
        if (orgId == null) {
            return (List<TaskoSchedule>) singleton.listObjectsByNamedQuery(
                    "TaskoSchedule.listActiveInSat", params);
        }
        else {
            params.put("org_id", orgId);
            return (List<TaskoSchedule>) singleton.listObjectsByNamedQuery(
                   "TaskoSchedule.listActiveByOrg", params);
        }
    }

    /**
     * lists active schedules of given name for a given org
     * @param orgId organization id
     * @param jobLabel unique job name
     * @return list of active schedules
     */
    public static List<TaskoSchedule> listActiveSchedulesByOrgAndLabel(Integer orgId,
            String jobLabel) {
        Map params = new HashMap();
        params.put("job_label", jobLabel);
        params.put("timestamp", new Date());    // use server time, not DB time
        if (orgId == null) {
            return (List<TaskoSchedule>) singleton.listObjectsByNamedQuery(
                    "TaskoSchedule.listActiveInSatByLabel", params);
        }
        else {
            params.put("org_id", orgId);
            return (List<TaskoSchedule>) singleton.listObjectsByNamedQuery(
                       "TaskoSchedule.listActiveByOrgAndLabel", params);
        }
    }

    /**
     * lookup schedule by id
     * @param scheduleId schedule id
     * @return schedule
     */
    public static TaskoSchedule lookupScheduleById(Long scheduleId) {
        Map params = new HashMap();
        params.put("schedule_id", scheduleId);
        return (TaskoSchedule) singleton.lookupObjectByNamedQuery(
                                       "TaskoSchedule.lookupById", params);
    }

    /**
     * lists all schedules for an org
     * @param orgId organizational id
     * @return list of all schedules
     */
    public static List<TaskoSchedule> listSchedulesByOrg(Integer orgId) {
        Map params = new HashMap();
        if (orgId == null) {
            return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listInSat", params);
        }
        else {
            params.put("org_id", orgId);
            return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listByOrg", params);
        }
    }

    /**
     * list all runs associated with a schedule
     * @param scheduleId schedule id
     * @return list of runs
     */
    public static List<TaskoRun> listRunsBySchedule(Long scheduleId) {
        Map params = new HashMap();
        params.put("schedule_id", scheduleId);
        return singleton.listObjectsByNamedQuery(
                                       "TaskoRun.listBySchedule", params);
    }

    /**
     * list schedules older than given date
     * @param limitTime time of interest
     * @return list of schedules
     */
    public static List<TaskoSchedule> listSchedulesOlderThan(Date limitTime) {
        Map params = new HashMap();
        params.put("limit_time", limitTime);
        return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listOlderThan", params);
    }

    /**
     * lists organizational schedules by bunch
     * @param orgId organization id
     * @param bunch type of schedules
     * @return list of schedules
     */
    public static List<TaskoSchedule> listSchedulesByOrgAndBunch(Integer orgId,
            TaskoBunch bunch) {
        Map params = new HashMap();
        params.put("bunch_id", bunch.getId());
        if (orgId == null) {
            return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listInSatByBunch", params);
        }
        else {
            params.put("org_id", orgId);
            return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listByOrgAndBunch", params);
        }
    }

    /**
     * lists organizational schedules by name
     * @param orgId organization id
     * @param jobLabel unique job name
     * @return list of schedules
     */
    public static List<TaskoSchedule> listSchedulesByOrgAndLabel(Integer orgId,
            String jobLabel) {
        Map params = new HashMap();
        params.put("job_label", jobLabel);
        if (orgId == null) {
            return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listInSatByLabel", params);
        }
        else {
            params.put("org_id", orgId);
            return singleton.listObjectsByNamedQuery(
                                       "TaskoSchedule.listByOrgAndLabel", params);
        }
    }

    /**
     * lookup run by id
     * @param runId run id
     * @return run
     */
    public static TaskoRun lookupRunById(Long runId) {
        Map params = new HashMap();
        params.put("run_id", runId);
        return (TaskoRun) singleton.lookupObjectByNamedQuery(
                                       "TaskoRun.lookupById", params);
    }

    /**
     * lookup organizational run by id
     * @param orgId organizational id
     * @param runId run id
     * @return run
     * @throws InvalidParamException thrown in case of wrong runId
     */
    public static TaskoRun lookupRunByOrgAndId(Integer orgId, Integer runId)
        throws InvalidParamException {
        TaskoRun run = lookupRunById(runId.longValue());
        if ((run == null) || (run.getOrgId() != orgId)) {
            throw new InvalidParamException("No such run id");
        }
        return run;
    }

    /**
     * lists organizational runs by schedule
     * @param orgId organization id
     * @param scheduleId schedule id
     * @return list of runs
     */
    public static List<TaskoRun> listRunsByOrgAndSchedule(Integer orgId,
            Integer scheduleId) {
        List<TaskoRun> runs = listRunsBySchedule(scheduleId.longValue());
        // verify it belongs to the right org
        for (Iterator<TaskoRun> iter = runs.iterator(); iter.hasNext();) {
            if (iter.next().getOrgId() != orgId) {
                iter.remove();
            }
        }
        return runs;
    }
}
