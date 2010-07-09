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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.taskomatic.core.SchedulerKernel;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * Custom Quartz Job implementation which only allows one thread to
 * run at a time. All other threads return without performing any work.
 * This policy was chosen instead of blocking so as to reduce threading
 * problems inside Quartz itself.
 *
 * @version $Rev $
 *
 */
public abstract class SingleThreadedTestableTask implements TestableTask {

    private boolean isExecuting = false;

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
            throws JobExecutionException {
        synchronized (this) {
            if (this.isExecuting) {
                Logger logger = Logger.getLogger(SchedulerKernel.class);
                logger.info("Instance of " + getClass().getName() + " already running..." +
                        "Exiting");
                return;
            }
            else {
                this.isExecuting =  true;
            }
        }
        try {
            execute(context, false);
            HibernateFactory.commitTransaction();
        }
        catch (Throwable t) {
            HibernateFactory.rollbackTransaction();
            Logger logger = Logger.getLogger(SchedulerKernel.class);
            logger.error(t);
            TaskHelper.sendErrorMail(logger, t);
            throw new JobExecutionException(t.getMessage());
        }
        finally {
            synchronized (this) {
                this.isExecuting = false;
            }
            HibernateFactory.closeSession();
        }
    }
}
