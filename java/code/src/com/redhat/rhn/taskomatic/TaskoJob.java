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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.HashMap;
import java.util.Map;

public class TaskoJob implements Job {

    private static Logger log = Logger.getLogger(TaskoJob.class);
    private static Map<String, Integer> tasks = new HashMap<String, Integer>();
    private static Map<String, Object> locks = new HashMap<String, Object>();

    private Long scheduleId; 

    static {
        for (TaskoTask task : TaskoFactory.listTasks()) {
            tasks.put(task.getName(), 0);
            locks.put(task.getName(), new Object());
        }
    }

    public TaskoJob(Long scheduleIdIn) {
        setScheduleId(scheduleIdIn);
    }

    private boolean isTaskRunning(TaskoTask task) {
        return tasks.get(task.getName()) > 0;
    }

    private boolean isTaskThreadAvailable(TaskoTask task) {
        return tasks.get(task.getName()) < Config.get().getInt("taskomatic." +
                task.getTaskClass() + ".parallel_threads", 1);
    }

    private static synchronized void markTaskRunning(TaskoTask task) {
        int count = tasks.get(task.getName());
        count++;
        tasks.put(task.getName(), count);
    }

    private static synchronized void unmarkTaskRunning(TaskoTask task) {
        int count = tasks.get(task.getName());
        count--;
        tasks.put(task.getName(), count);
    }

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
        throws JobExecutionException {
        TaskoRun previousRun = null;

        TaskoSchedule schedule = TaskoFactory.lookupScheduleById(scheduleId);
        if (schedule == null) {
            // means, that schedule was deleted (in the DB), but quartz still schedules it
            log.error("No such schedule with id  " + scheduleId);
            TaskoFactory.unscheduleTrigger(context.getTrigger());
            return;
        }

        log.info(schedule.getJobLabel() + ":" + " bunch " + schedule.getBunch().getName() +
                " started");

        for (TaskoTemplate template : schedule.getBunch().getTemplates()) {
            if ((previousRun == null) ||
                    (previousRun.getStatus().equals(template.getStartIf()))) {
                TaskoTask task = template.getTask();

                Object lock = locks.get(task.getName());
                synchronized (lock) {
                    while (!isTaskThreadAvailable(task)) {
                        log.debug(schedule.getJobLabel() + ":" + " task " +
                                task.getName() +
                                " all allowed threads running ... WAITING");
                        try {
                            lock.wait();
                            log.debug(schedule.getJobLabel() + ":" + " task " +
                                    task.getName() + " ... AWAKE");
                        }
                        catch (InterruptedException e) {
                            // ok
                        }
                    }
                    markTaskRunning(task);
                }
                log.debug(schedule.getJobLabel() + ":" + " task " + task.getName() +
                        " STARTED");
                TaskoRun taskRun = new TaskoRun(schedule.getOrgId(), template, scheduleId);
                TaskoFactory.save(taskRun);
                taskRun.execute(context);
                TaskoFactory.commitTransaction();
                log.debug(task.getName() +
                        " (" + schedule.getJobLabel() + ") ... " + taskRun.getStatus());
                previousRun = taskRun;
                synchronized (lock) {
                    unmarkTaskRunning(task);
                    lock.notify();
                }
            }
            else {
                log.info("Interrupting " + schedule.getBunch().getName() +
                        " (" + schedule.getJobLabel() + ")");
                break;
            }
        }
        HibernateFactory.closeSession();
        log.info(schedule.getJobLabel() + ":" + " bunch " + schedule.getBunch().getName() +
                " finished");
    }

    /**
     * @param scheduleIdIn The scheduleId to set.
     */
    public void setScheduleId(Long scheduleIdIn) {
        this.scheduleId = scheduleIdIn;
    }

    /**
     * @return Returns the scheduleId.
     */
    public Long getScheduleId() {
        return scheduleId;
    }
}
