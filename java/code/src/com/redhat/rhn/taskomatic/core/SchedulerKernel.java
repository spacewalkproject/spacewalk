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
import com.redhat.rhn.taskomatic.TaskoRun;
import com.redhat.rhn.taskomatic.TaskoSchedule;
import com.redhat.rhn.taskomatic.TaskoXmlRpcServer;

import org.apache.log4j.Logger;
import org.hibernate.Transaction;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SchedulerFactory;
import org.quartz.impl.StdSchedulerFactory;

import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Properties;

/**
 * Taskomatic Kernel.
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
        String dbName = Config.get().getString(ConfigDefaults.DB_NAME);
        String dbUser = Config.get().getString(ConfigDefaults.DB_USER);
        String dbPass = Config.get().getString(ConfigDefaults.DB_PASSWORD);
        String dbProto = Config.get().getString(ConfigDefaults.DB_PROTO);
        props.setProperty(dataSourceConfigPath, defaultDataSource);
        String ds = dataSourcePrefix + "." + defaultDataSource;
        props.setProperty(ds + ".user", dbUser);
        props.setProperty(ds + ".password", dbPass);
        // props.setProperty(ds + ".maxConnections", 30);

        if (ConfigDefaults.get().isOracle()) {
            props.setProperty("org.quartz.jobStore.driverDelegateClass",
                    "org.quartz.impl.jdbcjobstore.oracle.OracleDelegate");

            String driver = Config.get().getString(ConfigDefaults.DB_CLASS,
                    "oracle.jdbc.driver.OracleDriver");
            props.setProperty(ds + ".driver", driver);

            String dbUrl = dbProto + ":@";
            if (dbProto.contains("thin")) {
                String dbHost = Config.get().getString(ConfigDefaults.DB_HOST);
                String dbPort = Config.get().getString(ConfigDefaults.DB_PORT);
                dbUrl += dbHost + ":" + dbPort + ":";
            }
            dbUrl += dbName;
            props.setProperty(ds + ".URL", dbUrl);
        }
        else if (ConfigDefaults.get().isPostgresql()) {
            props.setProperty("org.quartz.jobStore.driverDelegateClass",
                    "org.quartz.impl.jdbcjobstore.PostgreSQLDelegate");

            String driver = Config.get().getString(ConfigDefaults.DB_CLASS,
                    "org.postgresql.Driver");
            props.setProperty(ds + ".driver", driver);

            String connectionUrl = Config.get().getString(
                    ConfigDefaults.DB_PROTO) +
                    ":";
            String dbHost = Config.get().getString(ConfigDefaults.DB_HOST);
            String dbPort = Config.get().getString(ConfigDefaults.DB_PORT);
            if (dbHost != null && dbHost.length() > 0) {
                connectionUrl += "//" + dbHost;
                if (dbPort != null && dbPort.length() > 0) {
                    connectionUrl += ":" + dbPort;
                }
                connectionUrl += "/";
            }
            connectionUrl += dbName;
            props.setProperty(ds + ".URL", connectionUrl);
        }
        else {
            throw new InstantiationException(
                    "Unknown db backend set, expecting oracle or postgresql");
        }

        try {
            SchedulerKernel.factory = new StdSchedulerFactory(props);
            SchedulerKernel.scheduler = SchedulerKernel.factory.getScheduler();
            SchedulerKernel.scheduler.setJobFactory(new RhnJobFactory());

            // Setup TriggerListener chain
            this.chainedTriggerListener = new ChainedListener();
            this.chainedTriggerListener.addListener(new TaskEnvironmentListener());

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
            SchedulerKernel.scheduler.start();
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
            SchedulerKernel.scheduler.standby();
            SchedulerKernel.scheduler.shutdown();
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
        Date now = new Date();
        try {
            jobNames = Arrays.asList(
                    SchedulerKernel.scheduler.getJobNames(
                        TaskoQuartzHelper.getGroupName(null)));
            for (TaskoSchedule schedule : TaskoFactory.listActiveSchedulesByOrg(null)) {
                if (!jobNames.contains(schedule.getJobLabel())) {
                    schedule.sanityCheckForPredefinedSchedules();
                    log.info("Initializing " + schedule.getJobLabel());
                    TaskoQuartzHelper.createJob(schedule);
                }
                else {
                    List<TaskoRun> runList =
                            TaskoFactory.listNewerRunsBySchedule(schedule.getId(), now);
                    if (!runList.isEmpty()) {
                        // there're runs in the future
                        // reinit the schedule
                        Transaction tx = TaskoFactory.getSession().beginTransaction();
                        log.warn("Reinitializing " + schedule.getJobLabel() + ", found " +
                        runList.size() + " runs in the future.");
                        TaskoFactory.reinitializeScheduleFromNow(schedule, now);
                        for (TaskoRun run : runList) {
                            TaskoFactory.deleteRun(run);
                        }
                        tx.commit();
                    }
                }
            }
            TaskoFactory.closeSession();
        }
        catch (Exception e) {
            e.printStackTrace();
            return;
        }
    }
}
