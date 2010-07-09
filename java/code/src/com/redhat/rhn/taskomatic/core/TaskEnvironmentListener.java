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
package com.redhat.rhn.taskomatic.core;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.Trigger;
import org.quartz.TriggerListener;

import java.util.HashMap;
import java.util.Map;

/**
 * Insures that the basic runtime environment is in a sane state
 * @version $Rev$
 */
public class TaskEnvironmentListener implements TriggerListener {

    public static final String LISTENER_NAME = "TaskEnvironmentListener";

    private static Logger logger = Logger.getLogger(SchedulerKernel.class);

    private Map vetoedJobs = new HashMap();
    /**
     * {@inheritDoc}
     */
    public String getName() {
        return TaskEnvironmentListener.LISTENER_NAME;
    }

    /**
     * {@inheritDoc}
     */
    public void triggerFired(Trigger trigger, JobExecutionContext ctx) {
        // Insure that Hibernate is in a valid state before executing the task
        // Need to synchronize this because the method get called by multiple
        // scheduler threads concurrently
        synchronized (this) {
            try {
                HibernateFactory.initialize();
                if (!HibernateFactory.isInitialized()) {
                    logger.error("HibernateFactory failed to initialize");
                    this.vetoedJobs.put(new Integer(ctx.hashCode()), Boolean.TRUE);
                }
            }
            catch (Throwable t) {
                logger.error(t.getLocalizedMessage(), t);
                this.vetoedJobs.put(new Integer(ctx.hashCode()), Boolean.TRUE);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public boolean vetoJobExecution(Trigger trigger, JobExecutionContext ctx) {
        // Closest we get to a unique id
        Integer contextHashCode = new Integer(ctx.hashCode());
        return this.vetoedJobs.remove(contextHashCode) != null;
    }

    /**
     * {@inheritDoc}
     */
    public void triggerMisfired(Trigger trigger) {
    }

    /**
     * {@inheritDoc}
     */
    public void triggerComplete(Trigger trigger, JobExecutionContext ctx, int reasonCode) {
    }

}
