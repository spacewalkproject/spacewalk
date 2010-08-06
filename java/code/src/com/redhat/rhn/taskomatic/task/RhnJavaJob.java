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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.manager.satellite.SystemCommandExecutor;
import com.redhat.rhn.taskomatic.TaskoRun;

import org.apache.log4j.FileAppender;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.IOException;


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
            FileAppender outLogAppender = new FileAppender(pattern, run.buildStdOutputLogPath());
            outLogAppender.setThreshold(Level.INFO);
            getLogger().addAppender(outLogAppender);
            FileAppender errLogAppender = new FileAppender(pattern, run.buildStdErrorLogPath());
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
        log.error(e.getMessage());
        log.error(e.getCause());
    }

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context, TaskoRun run)
        throws JobExecutionException {
        enableLogging(run);
        run.start();
        HibernateFactory.commitTransaction();
        try {
            execute(context);
            run.saveStatus(TaskoRun.STATUS_FINISHED);
        }
        catch (Exception e) {
            if (HibernateFactory.getSession().getTransaction().isActive()) {
                HibernateFactory.rollbackTransaction();
            }
            appendExceptionToLogError(e);
            run.saveStatus(TaskoRun.STATUS_FAILED);
        }
        run.finished();
        HibernateFactory.commitTransaction();
    }

    protected void executeExtCmd(String[] args) {
        SystemCommandExecutor ce = new SystemCommandExecutor();
        ce.execute(args);

        log.info(ce.getLastCommandOutput());
        log.error(ce.getLastCommandErrorMessage());
    }
}
