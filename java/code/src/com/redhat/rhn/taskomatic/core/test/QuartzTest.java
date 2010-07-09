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
package com.redhat.rhn.taskomatic.core.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.quartz.CronTrigger;
import org.quartz.Job;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.Scheduler;
import org.quartz.SchedulerFactory;
import org.quartz.impl.StdSchedulerFactory;

import java.util.Properties;

public class QuartzTest extends RhnBaseTestCase {

    public void testA() throws Exception {
       Properties props = Config.get().getNamespaceProperties("org.quartz");

       assertNotNull(props);

       // create a SchedulerFactory
       SchedulerFactory fact = new StdSchedulerFactory(props);

       // Scheduler
       Scheduler sched = fact.getScheduler();

       // starts the scheduler, we can do this at the
       // beginning of the taskomatic
       sched.start();

       JobDetail detail = new JobDetail(
           "Income Report", "Report Generation", QuartzReport.class);
       detail.getJobDataMap().put("type", "Full");

       // We read in the configuration entry to get cron information
       CronTrigger trigger = new CronTrigger(
           "Income Report", "report generation");
       trigger.setCronExpression("10 * * * * ?");

       // Now schedule the job
       sched.scheduleJob(detail, trigger);

       // you can also schedule without a detail: sched.scheduleJob(trigger);
    }

    /**
     * To implement a task you simply implement the Job interface.
     */
    public static class QuartzReport implements Job {
        public void execute(JobExecutionContext ctx)
            throws JobExecutionException {

            System.out.println("Generating report" +
                 ctx.getJobDetail().getJobDataMap().get("type"));
        }
    }
}
