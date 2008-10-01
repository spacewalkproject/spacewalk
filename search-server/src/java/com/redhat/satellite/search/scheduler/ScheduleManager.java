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
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.scheduler.tasks.IndexErrataTask;
import com.redhat.satellite.search.scheduler.tasks.IndexPackagesTask;
import com.redhat.satellite.search.scheduler.tasks.IndexSnapshotTagsTask;
import com.redhat.satellite.search.scheduler.tasks.IndexSystemsTask;
import com.redhat.satellite.search.scheduler.tasks.IndexHardwareDevicesTask;
//import com.redhat.satellite.search.scheduler.tasks.IndexDocumentsTask;

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
    
    private Scheduler scheduler;
    private DatabaseManager databaseManager;
    private IndexManager indexManager;
    
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
            scheduler = StdSchedulerFactory.getDefaultScheduler();
            long interval = 300000;
            int mode = SimpleTrigger.REPEAT_INDEFINITELY;
            if (System.getProperties().get("isTesting") != null) {
                interval = 100;
                mode = 0;
            }
            Trigger pkgTrigger = createTrigger("packages", "index", mode,
                    interval);
            Trigger errataTrigger = createTrigger("errata", "index", mode,
                    interval);
            Trigger systemTrigger = createTrigger("systems", "index", mode,
                    interval);
            Trigger hwDeviceTrigger = createTrigger("hwdevice", "index", mode,
                    interval);
            Trigger snapshotTagTrigger = createTrigger("snapshotTag", "index",
                    mode, interval);
//            Trigger docsTrigger = createTrigger("docs", "index", mode,
//                    interval);
            
            JobDetail pkgDetail = new JobDetail("packages", "index",
                    IndexPackagesTask.class);
            JobDetail errataDetail = new JobDetail("errata", "index",
                    IndexErrataTask.class);
            JobDetail systemDetail = new JobDetail("systems", "index",
                    IndexSystemsTask.class);
            JobDetail hwDeviceDetail = new JobDetail("hwdevice", "index",
                    IndexHardwareDevicesTask.class);
            JobDetail snapshotTagDetail = new JobDetail("snapshotTag", "index",
                    IndexSnapshotTagsTask.class);
//            JobDetail docsDetail = new JobDetail("docs", "index", 
//                    IndexDocumentsTask.class);
            JobDataMap jobData = new JobDataMap();
            jobData.put("indexManager", indexManager);
            jobData.put("databaseManager", databaseManager);
            jobData.put("configuration", new Configuration());
            
            pkgDetail.setJobDataMap(jobData);
            errataDetail.setJobDataMap(jobData);
            systemDetail.setJobDataMap(jobData);
            hwDeviceDetail.setJobDataMap(jobData);
            snapshotTagDetail.setJobDataMap(jobData);
//            docsDetail.setJobDataMap(jobData);
            scheduler.scheduleJob(pkgDetail, pkgTrigger);
            scheduler.scheduleJob(errataDetail, errataTrigger);
            scheduler.scheduleJob(systemDetail, systemTrigger);
            scheduler.scheduleJob(hwDeviceDetail, hwDeviceTrigger);
            scheduler.scheduleJob(snapshotTagDetail, snapshotTagTrigger);
            // the doc task is incomplete, so we don't want it scheduled to run
            //scheduler.scheduleJob(docsDetail, docsTrigger);
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
}
