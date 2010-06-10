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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.conf.ConfigException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.taskomatic.TaskoXmlRpcServer;

import org.apache.log4j.Logger;
import org.quartz.CronTrigger;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SchedulerFactory;
import org.quartz.Trigger;
import org.quartz.impl.StdSchedulerFactory;

import java.net.UnknownHostException;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;

/**
 * Taskomatic Kernel.
 * @version $Rev$
 */
public class SchedulerKernel {
    
    private static Logger log = Logger.getLogger(SchedulerKernel.class);
    private byte[] shutdownLock = new byte[0];
    private static SchedulerFactory factory = null;
    private static Scheduler scheduler = null;
    private static TaskoXmlRpcServer xmlrpcServer = null;
    private ChainedListener chainedJobListener = null;
    private String dataSourceConfigPath = "org.quartz.jobStore.dataSource";
    private String dataSourcePrefix = "org.quartz.dataSource";
    private String defaultDataSource = "rhnDs";

    
    /**
     * Kernel main driver behind Taskomatic
     * @throws InstantiationException thrown if this.scheduler can't be initialized.
     * @throws UnknownHostException thrown if xmlrcp host is unknown
     */
    public SchedulerKernel() throws InstantiationException, UnknownHostException {
        Properties props = Config.get().getNamespaceProperties("org.quartz");
        String dbHost = Config.get().getString(ConfigDefaults.DB_HOST);
        String dbPort = Config.get().getString(ConfigDefaults.DB_PORT);
        String dbName = Config.get().getString(ConfigDefaults.DB_NAME);
        String dbUser = Config.get().getString(ConfigDefaults.DB_USER);
        String dbPass = Config.get().getString(ConfigDefaults.DB_PASSWORD);
        props.setProperty(dataSourceConfigPath, defaultDataSource);
        String ds = dataSourcePrefix + "." + defaultDataSource;
        props.setProperty(ds + ".user", dbUser);
        props.setProperty(ds + ".password", dbPass);
        // props.setProperty(ds + ".maxConnections", 30);

        if (ConfigDefaults.get().isOracle()) {
            props.setProperty("org.quartz.jobStore.driverDelegateClass",
                    "org.quartz.impl.jdbcjobstore.oracle.OracleDelegate");
            props.setProperty(ds + ".driver", "oracle.jdbc.driver.OracleDriver");
            props.setProperty(ds + ".URL", "jdbc:oracle:thin:@" +
                    dbHost + ":" + dbPort + ":" + dbName);
        }

        try {
            SchedulerKernel.factory = new StdSchedulerFactory(props);
            SchedulerKernel.scheduler = SchedulerKernel.factory.getScheduler();
            SchedulerKernel.scheduler.setJobFactory(new RhnJobFactory());
            
            // Setup TriggerListener chain
            this.chainedJobListener = new ChainedListener();
            this.chainedJobListener.addListener(new TaskEnvironmentListener());
            this.chainedJobListener.addListener(new LoggingListener());

            try {
                SchedulerKernel.scheduler.addTriggerListener(this.chainedJobListener);
            }
            catch (SchedulerException e) {
                throw new ConfigException(e.getLocalizedMessage(), e);
            }
            xmlrpcServer = new TaskoXmlRpcServer(Config.get());
            xmlrpcServer.start();
        }
        catch (SchedulerException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            throw new InstantiationException("this.scheduler failed");
        }
    }

    public static Scheduler getScheduler() {
        return SchedulerKernel.scheduler;
    }
    
    /**
     * Starts Taskomatic
     * This method does not return until the this.scheduler is shutdown
     * @throws TaskomaticException error occurred during Quartz or Hibernate startup
     */
    public void startup() throws TaskomaticException {
        HibernateFactory.createSessionFactory();
        if (!HibernateFactory.isInitialized()) {
            throw new TaskomaticException("HibernateFactory failed to initialize");
        }
        MessageQueue.startMessaging();
        MessageQueue.configureDefaultActions();
        try {
            this.scheduler.start();
            synchronized (this.shutdownLock) {
                try {
                    this.shutdownLock.wait();
                }
                catch (InterruptedException ignored) {
                    return;
                }
            }
        }
        catch (SchedulerException e) {
            throw new TaskomaticException(e.getMessage(), e);
        }
    }
    
    /**
     * Initiates the shutdown process. Needs to happen in a
     * separate thread to prevent Quartz scheduler errors.
     */
    public void startShutdown() {
        Runnable shutdownTask = new Runnable() {
            public void run() {
                shutdown();
            }
        };
        Thread t = new Thread(shutdownTask);
        t.setDaemon(true);
        t.start();
    }

    /**
     * Shutsdown the application
     */
    protected void shutdown() {
        try {
            this.scheduler.standby();            
            deleteAllJobs();
            this.scheduler.shutdown();
        }
        catch (SchedulerException e) {
            // TODO Figure out what to do with this guy
            e.printStackTrace();
        }
        finally {
            MessageQueue.stopMessaging();            
            HibernateFactory.closeSessionFactory();            
            // Wake up thread waiting in startup() so it can exit
            synchronized (this.shutdownLock) {
                this.shutdownLock.notify();
            }
        }
    }
    
    
    private void scheduleJobs(Map pendingJobs) throws ConfigException {
       // No jobs to schedule
       // This would be quite odd, but it could happen
        if (pendingJobs == null || pendingJobs.size() == 0) {
            log.error("No tasks scheduled");
            throw new ConfigException("No tasks scheduled");
        }
        try {
            for (Iterator iter = pendingJobs.keySet().iterator(); iter.hasNext();) {
                String suffix = (String) iter.next();
                String[] data = (String[]) pendingJobs.get(suffix);
                String jobImpl = data[0];
                String crontab = data[1];
                String jobName = jobImpl + "-" + suffix;
                JobDetail detail = new JobDetail(jobName, 
                        TaskomaticConstants.TASK_GROUP, 
                        this.getClass().getClassLoader().loadClass(jobImpl));
                Trigger trigger = null;
                trigger = new CronTrigger(jobImpl, 
                        TaskomaticConstants.TASK_GROUP, crontab);
                trigger.setMisfireInstruction(CronTrigger.MISFIRE_INSTRUCTION_DO_NOTHING);
                trigger.addTriggerListener(this.chainedJobListener.getName());
                this.scheduler.scheduleJob(detail, trigger);
                if (log.isDebugEnabled()) {
                    log.debug("Scheduled " + detail.getFullName());
                }
            }
        }
        catch (Throwable t) {
            log.error(t.getMessage(), t);
            throw new ConfigException(t.getMessage(), t);
        }
    }
    
    private void deleteAllJobs() {
        boolean done = false;
        while (!done) {
            try {
                String[] groups = this.scheduler.getJobGroupNames();
                if (groups == null || groups.length == 0) {
                    done = true;
                }
                else {
                    String group = groups[0];
                    String[] jobs = this.scheduler.getJobNames(group);
                    for (int x = jobs.length - 1; x > -1; x--) {
                        this.scheduler.deleteJob(jobs[x], group);
                    }
                }
            }
            catch (SchedulerException e) {
                done = true;
            }
        }
    }
}
