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

import com.redhat.rhn.common.hibernate.HibernateRuntimeException;
import com.redhat.rhn.taskomatic.TaskoBunch;
import com.redhat.rhn.taskomatic.TaskoFactory;

import org.quartz.Job;
import org.quartz.SchedulerException;
import org.quartz.spi.JobFactory;
import org.quartz.spi.TriggerFiredBundle;


/**
 * A custom Quartz JobFactory implementation which insures that
 * only one instance of a job class is every instantiated.
 *
 * @version $Rev: 75283 $
 */
public class RhnJobFactory implements JobFactory {
    /**
     * {@inheritDoc}
     */
    public synchronized Job newJob(TriggerFiredBundle trigger) throws SchedulerException {
        TaskoBunch bunch = null;
        String bunchName = trigger.getJobDetail().getJobDataMap().getString("bunch_name");

        try {
            bunch = TaskoFactory.lookupByName(bunchName);
        }
        catch (HibernateRuntimeException re) {
                throw new SchedulerException("No such bunch task " + bunchName);
        }

        return bunch;
    }
}
