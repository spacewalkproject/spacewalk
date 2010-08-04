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
import com.redhat.rhn.taskomatic.TaskoFactory;
import com.redhat.rhn.taskomatic.TaskoQuartzHelper;
import com.redhat.rhn.taskomatic.TaskoSchedule;
import com.redhat.rhn.taskomatic.TaskoXmlRpcServer;

import org.apache.log4j.Logger;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SchedulerFactory;
import org.quartz.impl.StdSchedulerFactory;

import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

/**
 * Taskomatic Kernel.
 * @version $Rev$
 */
public class SchedulerKernel {

    private static final String[] TASKOMATIC_PACKAGE_NAMES = {"com.redhat.rhn.taskomatic"};
    private static Logger log = Logger.getLogger(SchedulerKernel.class);
    private byte[] shutdownLock = new byte[0];
    private static SchedulerFactory factory = null;
    private static Scheduler scheduler = null;
    private static TaskoXmlRpcServer xmlrpcServer = null;
    private ChainedListener chainedTriggerListener = null;
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
            this.chainedTriggerListener = new ChainedListener();
            this.chainedTriggerListener.addListener(new TaskEnvironmentListener());
            this.chainedTriggerListener.addListener(new LoggingListener());

            try {
                SchedulerKernel.scheduler.addTriggerListener(this.chainedTriggerListener);
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

    /**
     * returns scheduler
     * @return scheduler
     */
    public static Scheduler getScheduler() {
        return SchedulerKernel.scheduler;
    }

    /**
     * Starts Taskomatic
     * This method does not return until the this.scheduler is shutdown
     * @throws TaskomaticException error occurred during Quartz or Hibernate startup
     */
    public void startup() throws TaskomaticException {
        HibernateFactory.createSessionFactory(TASKOMATIC_PACKAGE_NAMES);
        if (!HibernateFactory.isInitialized()) {
            throw new TaskomaticException("HibernateFactory failed to initialize");
        }
        MessageQueue.startMessaging();
        MessageQueue.configureDefaultActions();
        try {
            this.scheduler.start();
            initializeAllSatSchedules();
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


    /**
     * load DB schedule configuration
     */
    public void initializeAllSatSchedules() {
        List jobNames;
        try {
            jobNames = Arrays.asList(
                    this.scheduler.getJobNames(TaskoQuartzHelper.getGroupName(null)));
            for (TaskoSchedule schedule : TaskoFactory.listSchedulesByOrg(null)) {
                if (!jobNames.contains(schedule.getJobLabel())) {
                    TaskoQuartzHelper.createJob(schedule);
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }
}
