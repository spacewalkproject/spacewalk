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

import org.quartz.JobExecutionContext;
import org.quartz.Trigger;
import org.quartz.TriggerListener;

/**
 * Taskomatic's Quartz scheduled job listener
 * This listener counts down from a maximum number
 * of jobs scheduled and then shuts down the SchedulerKernel.
 * @version $Rev$
 */
public class SingleShotListener implements TriggerListener {

    private SchedulerKernel owner;
    private int jobCount;
    private boolean shutdownStarted = false;

    /**
     * @param count Maximum job count
     * @param myOwner Owning SchedulerKernel instance
     */
    public SingleShotListener(int count, SchedulerKernel myOwner) {
        this.jobCount = count;
        this.owner = myOwner;
    }

   /**
    * {@inheritDoc}
    */
    public String getName() {
        return "SingleShotListener";
    }

    /**
     * {@inheritDoc}
     */
    public void triggerFired(Trigger trigger, JobExecutionContext ctx) {
        synchronized (this) {
            if (this.jobCount > 0) {
                this.jobCount--;
                if (this.jobCount < 0) {
                    this.jobCount = 0;
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public boolean vetoJobExecution(Trigger trigger, JobExecutionContext ctx) {
        synchronized (this) {
            if (this.jobCount == 0 && !this.shutdownStarted) {
                this.shutdownStarted = true;
                this.owner.startShutdown();
            }
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public void triggerMisfired(Trigger trigger) {
        // TODO Auto-generated method stub

    }

    /**
     * {@inheritDoc}
     */
    public void triggerComplete(Trigger trigger, JobExecutionContext ctx, int duration) {
        synchronized (this) {
            if (this.jobCount == 0 && !this.shutdownStarted) {
                this.shutdownStarted = true;
                this.owner.startShutdown();
            }
        }
    }
}
