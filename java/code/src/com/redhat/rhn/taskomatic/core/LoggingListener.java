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

import EDU.oswego.cs.dl.util.concurrent.Channel;
import EDU.oswego.cs.dl.util.concurrent.LinkedQueue;

import org.apache.log4j.Logger;
import org.apache.log4j.Priority;
import org.quartz.JobExecutionContext;
import org.quartz.Trigger;
import org.quartz.TriggerListener;

import java.lang.reflect.Field;

/**
 * Quartz TriggerListener implementation which logs lifecycle events
 * for each executing Taskomatic task
 *
 * @version $Rev $
 */

public class LoggingListener implements TriggerListener {

    private static final String NAME = "LoggingListener";

    private static Logger logger = Logger.getLogger(SchedulerKernel.class);

    private Channel msgs = new LinkedQueue();

    private DaemonStateWriter stateWriter = null;

    /**
     * Default constructor
     *
     */
    public LoggingListener() {
        stateWriter = new DaemonStateWriter(msgs);
        Thread t = new Thread(stateWriter, "Daemon State Writer");
        t.setDaemon(true);
        t.start();
    }
    /**
     * {@inheritDoc}
     */
    public String getName() {
        return NAME;
    }

    /**
     * {@inheritDoc}
     */
    public void triggerFired(Trigger trigger, JobExecutionContext ctx) {
        updateDB(ctx.getJobDetail().getJobClass());
        if (logger.isInfoEnabled()) {
            StringBuffer msg = new StringBuffer();
            msg.append(trigger.getJobGroup()).append(":");
            msg.append(trigger.getJobName());
            msg.append(" started");
            logger.info(msg.toString());
        }
    }

    /**
     * {@inheritDoc}
     */
    public boolean vetoJobExecution(Trigger arg0, JobExecutionContext arg1) {
        // TODO Auto-generated method stub
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public void triggerMisfired(Trigger trigger) {
        if (logger.isEnabledFor(Priority.ERROR)) {
            StringBuffer msg = new StringBuffer();
            msg.append(trigger.getJobGroup()).append(":");
            msg.append(trigger.getJobName());
            msg.append(" trigger misfired");
            logger.error(msg.toString());
        }
    }

    /**
     * {@inheritDoc}
     */
    public void triggerComplete(Trigger trigger, JobExecutionContext ctx, int code) {
        updateDB(ctx.getJobDetail().getJobClass());
        if (logger.isInfoEnabled()) {
            StringBuffer msg = new StringBuffer();
            msg.append(trigger.getJobGroup()).append(":");
            msg.append(trigger.getJobName());
            msg.append(" completed");
            logger.info(msg.toString());
        }

    }

    private void updateDB(Class jobClass) {
        Field displayNameField = null;
        try {
            displayNameField = jobClass.getDeclaredField(
                    TaskomaticConstants.DISPLAY_NAME_CONST);
        }
        catch (NoSuchFieldException e) {
            logger.warn("Missing display name for " + jobClass.getName());
            return;
        }

        if (displayNameField != null) {
            try {
                String displayName = (String) displayNameField.get(null);
                this.msgs.put(displayName);
            }
            catch (Throwable t) {
                if (t instanceof InterruptedException) {
                    return;
                }
                logger.error(t.getMessage(), t);
            }

        }
        else {
            logger.warn("Missing display name for " + jobClass.getName());
        }
    }
}
