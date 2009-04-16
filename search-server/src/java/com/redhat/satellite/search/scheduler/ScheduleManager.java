/**
 * Copyright (c) 2008 Red Hat, Inc.
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

package com.redhat.satellite.search.scheduler;

import com.redhat.satellite.search.config.Configuration;
import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.index.builder.BuilderFactory;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.scheduler.tasks.IndexErrataTask;
import com.redhat.satellite.search.scheduler.tasks.IndexPackagesTask;
import com.redhat.satellite.search.scheduler.tasks.IndexSnapshotTagsTask;
import com.redhat.satellite.search.scheduler.tasks.IndexServerCustomInfoTask;
import com.redhat.satellite.search.scheduler.tasks.IndexSystemsTask;
import com.redhat.satellite.search.scheduler.tasks.IndexHardwareDevicesTask;

import org.apache.log4j.Logger;

import org.picocontainer.Startable;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.SimpleTrigger;
import org.quartz.Trigger;
import org.quartz.impl.StdSchedulerFactory;

import java.util.Date;

/**
 * Manages all scheduled tasks for the search server
 * Right now all tasks are hardcoded -- this should be
 * changed to be more config file driven
 * 
 * @version $Rev $
 */
public class ScheduleManager implements Startable {
    private static Logger log = Logger.getLogger(ScheduleManager.class);
    private Scheduler scheduler;
    private DatabaseManager databaseManager;
    private IndexManager indexManager;
    
    private JobDetail pkgDetail;
    private JobDetail errataDetail;
    private JobDetail systemDetail;
    private JobDetail hwDeviceDetail;
    private JobDetail snapshotTagDetail;
    private JobDetail serverCustomInfoDetail;

    private Trigger pkgTrigger;
    private Trigger errataTrigger;
    private Trigger systemTrigger;
    private Trigger hwDeviceTrigger;
    private Trigger snapshotTagTrigger;
    private Trigger serverCustomInfoTrigger;
    private final String updateIndexGroupName = "updateIndex";
    /**
     * Constructor
     * @param dbmgr allows ScheduleManager to access the database.
     * @param idxmgr allows the ScheduleManager to access the indexer.
     */
    public ScheduleManager(DatabaseManager dbmgr, IndexManager idxmgr) {
        databaseManager = dbmgr;
        indexManager = idxmgr;
    }
    
    private Trigger createTrigger(String name, String group, int mode,
            long interval) {
        Trigger trigger = new SimpleTrigger(name, "default", name, group,
                new Date(), null, mode, interval);
        trigger.setMisfireInstruction(
                SimpleTrigger.MISFIRE_INSTRUCTION_RESCHEDULE_NEXT_WITH_EXISTING_COUNT);
        return trigger;
    }
    
    /**
     * {@inheritDoc}
     */
    public void start() {
        try {
            Configuration config = new Configuration();
            scheduler = StdSchedulerFactory.getDefaultScheduler();
            long interval = config.getInt("search.schedule.interval", 300000);
            log.info("ScheduleManager task interval is set to " + interval);
            int mode = SimpleTrigger.REPEAT_INDEFINITELY;
            if (System.getProperties().get("isTesting") != null) {
                interval = 100;
                mode = 0;
            }
            pkgTrigger = createTrigger(BuilderFactory.PACKAGES_TYPE,
                    updateIndexGroupName, mode, interval);
            errataTrigger = createTrigger(BuilderFactory.ERRATA_TYPE,
                    updateIndexGroupName, mode, interval);
            systemTrigger = createTrigger(BuilderFactory.SERVER_TYPE,
                    updateIndexGroupName, mode, interval);
            hwDeviceTrigger = createTrigger(BuilderFactory.HARDWARE_DEVICE_TYPE,
                    updateIndexGroupName, mode, interval);
            snapshotTagTrigger = createTrigger(BuilderFactory.SNAPSHOT_TAG_TYPE,
                    updateIndexGroupName, mode, interval);
            serverCustomInfoTrigger = createTrigger(BuilderFactory.SERVER_CUSTOM_INFO_TYPE,
                    updateIndexGroupName, mode, interval);

            pkgDetail = new JobDetail(BuilderFactory.PACKAGES_TYPE,
                    updateIndexGroupName, IndexPackagesTask.class);
            errataDetail = new JobDetail(BuilderFactory.ERRATA_TYPE,
                    updateIndexGroupName, IndexErrataTask.class);
            systemDetail = new JobDetail(BuilderFactory.SERVER_TYPE,
                    updateIndexGroupName, IndexSystemsTask.class);
            hwDeviceDetail = new JobDetail(BuilderFactory.HARDWARE_DEVICE_TYPE,
                    updateIndexGroupName, IndexHardwareDevicesTask.class);
            snapshotTagDetail = new JobDetail(BuilderFactory.SNAPSHOT_TAG_TYPE,
                    updateIndexGroupName, IndexSnapshotTagsTask.class);
            serverCustomInfoDetail = new JobDetail(BuilderFactory.SERVER_CUSTOM_INFO_TYPE,
                    updateIndexGroupName, IndexServerCustomInfoTask.class);

            JobDataMap jobData = new JobDataMap();
            jobData.put("indexManager", indexManager);
            jobData.put("databaseManager", databaseManager);
            jobData.put("configuration", new Configuration());
            
            pkgDetail.setJobDataMap(jobData);
            errataDetail.setJobDataMap(jobData);
            systemDetail.setJobDataMap(jobData);
            hwDeviceDetail.setJobDataMap(jobData);
            snapshotTagDetail.setJobDataMap(jobData);
            serverCustomInfoDetail.setJobDataMap(jobData);

            scheduler.scheduleJob(pkgDetail, pkgTrigger);
            scheduler.scheduleJob(errataDetail, errataTrigger);
            scheduler.scheduleJob(systemDetail, systemTrigger);
            scheduler.scheduleJob(hwDeviceDetail, hwDeviceTrigger);
            scheduler.scheduleJob(snapshotTagDetail, snapshotTagTrigger);
            scheduler.scheduleJob(serverCustomInfoDetail, serverCustomInfoTrigger);

            scheduler.start();
        }
        catch (SchedulerException e) {
            throw new RuntimeException(e);
        }
    }
    
    /**
     * {@inheritDoc}
     */
    public void stop() {
        try {
            scheduler.shutdown();
        }
        catch (SchedulerException e) {
            throw new RuntimeException(e);
        }
    }

    private boolean isSupported(String indexName) {
        if (BuilderFactory.ERRATA_TYPE.compareTo(indexName) == 0) {
            return true;
        }
        else if (BuilderFactory.PACKAGES_TYPE.compareTo(indexName) == 0) {
            return true;
        }
        else if (BuilderFactory.SERVER_TYPE.compareTo(indexName) == 0) {
            return true;
        }
        else if (BuilderFactory.HARDWARE_DEVICE_TYPE.compareTo(indexName) == 0) {
            return true;
        }
        else if (BuilderFactory.SNAPSHOT_TAG_TYPE.compareTo(indexName) == 0) {
            return true;
        }
        else if (BuilderFactory.SERVER_CUSTOM_INFO_TYPE.compareTo(indexName) == 0) {
            return true;
        }
        else if (BuilderFactory.DOCS_TYPE.compareTo(indexName) == 0) {
            log.info("Index updates for " + BuilderFactory.DOCS_TYPE +
                    " are not supported.");
            return false;
        }
        log.info("Unknown index: " + indexName);
        return false;
    }


    /**
     * Will create/schedule a trigger for the passed in indexName.
     * Note: Only one trigger per indexName is allowed, if subsequent calls
     * are made before the current trigger finishes completion, this request
     * will be dropped.
     * @param indexName
     * @return
     */
    public boolean triggerIndexTask(String indexName) {
        if (!isSupported(indexName)) {
            log.info(indexName + " is not a supported for scheduler modifications.");
            return false;
        }
        // Define a Trigger that will fire "now" and associate it with the existing job
        Trigger trigger = new SimpleTrigger("immediateTrigger-" + indexName,
                "group1", new Date());
        trigger.setJobName(indexName);
        trigger.setJobGroup(updateIndexGroupName);
        try {
            // Schedule the trigger
            log.info("Scheduling trigger: " + trigger);
            scheduler.scheduleJob(trigger);
        }
        catch (SchedulerException e) {
            log.warn("Scheduling trigger: " + trigger + " failed.");
            log.warn("Exception was caught: ",  e);
            return false;
        }
        return true;
    }
}
