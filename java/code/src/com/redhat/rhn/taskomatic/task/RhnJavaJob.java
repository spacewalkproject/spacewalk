/**
 * Copyright (c) 2010--2013 Red Hat, Inc.
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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.manager.satellite.SystemCommandThreadedExecutor;
import com.redhat.rhn.taskomatic.TaskoRun;

import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Arrays;



/**
 * RhnJavaJob
 * @version $Rev$
 */
public abstract class RhnJavaJob implements RhnJob {

    protected Logger log = Logger.getLogger(getClass());

    protected Logger getLogger() {
        return log;
    }

    void enableLogging(TaskoRun run) {
        PatternLayout pattern = new PatternLayout(DEFAULT_LOGGING_LAYOUT);
        try {
            getLogger().removeAllAppenders();
            FileAppender outLogAppender = new FileAppender(pattern,
                    run.buildStdOutputLogPath());
            outLogAppender.setThreshold(Level.INFO);
            getLogger().addAppender(outLogAppender);
            FileAppender errLogAppender = new FileAppender(pattern,
                    run.buildStdErrorLogPath());
            errLogAppender.setThreshold(Level.ERROR);
            getLogger().addAppender(errLogAppender);
        }
        catch (IOException e) {
            getLogger().warn("Logging to file disabled");
            e.printStackTrace();
        }
    }

    /**
     * {@inheritDoc}
     */
    public void appendExceptionToLogError(Exception e) {
        log.error("Executing a task threw an exception: " + e.getClass().getName());
        log.error("Message: " + e.getMessage());
        log.error("Cause: " + e.getCause());

        StringWriter errors = new StringWriter();
        e.printStackTrace(new PrintWriter(errors));
        log.error("Stack trace:" + errors.toString());
    }

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context, TaskoRun run)
        throws JobExecutionException {
        run.start();
        enableLogging(run);
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
        execute(context);
        run.saveStatus(TaskoRun.STATUS_FINISHED);
        run.finished();
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
    }

    protected void executeExtCmd(String[] args)
        throws JobExecutionException {

        SystemCommandThreadedExecutor ce = new SystemCommandThreadedExecutor(getLogger());
        int exitCode = ce.execute(args);

        if (exitCode != 0) {
            throw new JobExecutionException(
                    "Command '" + Arrays.asList(args) +
                    "' exited with error code " + exitCode);
        }
    }
}
