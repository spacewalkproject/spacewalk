/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.taskomatic.TaskoRun;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueue;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueueFactory;

import org.apache.log4j.FileAppender;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.IOException;

/**
 * Custom Quartz Job implementation which only allows one thread to
 * run at a time. All other threads return without performing any work.
 * This policy was chosen instead of blocking so as to reduce threading
 * problems inside Quartz itself.
 *
 * @version $Rev $
 *
 */
public abstract class RhnQueueJob implements RhnJob {

    private TaskoRun jobRun = null;
    private boolean queueEmpty = true;

    protected abstract Logger getLogger();

    /**
     * {@inheritDoc}
     */
    public void appendExceptionToLogError(Exception e) {
        getLogger().error(e.getMessage());
        getLogger().error(e.getCause());
    }

    private void logToNewFile() {
        PatternLayout pattern =
            new PatternLayout(DEFAULT_LOGGING_LAYOUT);
        try {
            getLogger().removeAllAppenders();
            FileAppender appender = new FileAppender(pattern,
                    jobRun.buildStdOutputLogPath());
            getLogger().addAppender(appender);
        }
        catch (IOException e) {
            getLogger().warn("Logging to file disabled");
            e.printStackTrace();
        }
    }

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx, TaskoRun runIn)
            throws JobExecutionException {
        setJobRun(runIn);
        try {
            execute(ctx);
        }
        catch (Exception e) {
            if (HibernateFactory.getSession().getTransaction().isActive()) {
                HibernateFactory.rollbackTransaction();
                HibernateFactory.closeSession();
            }
            appendExceptionToLogError(e);
            jobRun.saveStatus(TaskoRun.STATUS_FAILED);
        }
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx)
            throws JobExecutionException {
        TaskQueueFactory factory = TaskQueueFactory.get();
        String queueName = getQueueName();
        TaskQueue queue = factory.getQueue(queueName);
        if (queue == null) {
            try {
                queue = factory.createQueue(queueName, getDriverClass(), getLogger());
            }
            catch (Exception e) {
                getLogger().error(e);
                return;
            }
        }
        if (queue.changeRun(jobRun)) {
            jobRun.start();
            HibernateFactory.commitTransaction();
            HibernateFactory.closeSession();
            logToNewFile();
            getLogger().debug("Starting run " + jobRun.getId());
        }
        int maxWorkItems = Config.get().getInt("taskomatic." + queueName +
                "_max_work_items", 3);
        if (queue.getQueueSize() < maxWorkItems) {
            queue.run(this);
        }
        else {
            getLogger().debug("Maximum number of workers already put ... skipping.");
        }
    }

    /**
     * @return Returns the run.
     */
    public TaskoRun getRun() {
        return jobRun;
    }

    /**
     * @param runIn The run to set.
     */
    public void setJobRun(TaskoRun runIn) {
        jobRun = runIn;
    }

    protected abstract Class getDriverClass();

    protected abstract String getQueueName();
}
