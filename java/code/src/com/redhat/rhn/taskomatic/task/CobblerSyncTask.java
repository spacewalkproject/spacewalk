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
package com.redhat.rhn.taskomatic.task;

import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.frontend.xmlrpc.util.XMLRPCInvoker;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroSyncCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileSyncCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSystemSyncCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.atomic.AtomicLong;

import redstone.xmlrpc.XmlRpcFault;

/**
 * DailySummary task.
 * sends daily report of stats. reaps org suggestions
 * from rhnDailySummaryQueue. Not very "daily" since it runs every
 * 30 seconds.  Need to look at RHN::DailySummaryEngine.  This task
 * queues org emails, mails queued emails, then dequeues the emails.
 * @version $Rev$
 */
public class CobblerSyncTask extends SingleThreadedTestableTask {
    
    private static final AtomicLong LAST_UPDATED = new AtomicLong();
    private long errorCount;
    private long distroWarnCount;
    
    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "sync_from_cobbler";

    private static Logger log = Logger.getLogger(CobblerSyncTask.class);
    
    /**
     * Default constructor
     */
    public CobblerSyncTask() {
        errorCount = 0;
        distroWarnCount = 0;
    }
 
    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctxIn, boolean testContextIn)
        throws JobExecutionException {
        
        try {
            XMLRPCInvoker invoker = (XMLRPCInvoker)  
            MethodUtil.getClassFromConfig(CobblerXMLRPCHelper.class.getName());
        
            Double mtime = null;
            try {
                mtime = (Double) invoker.invokeMethod("last_modified_time", 
                        new ArrayList());
            }
            catch (XmlRpcFault e) {
                log.error("Error calling cobbler.", e);
            }
            
            CobblerDistroSyncCommand distSync = new CobblerDistroSyncCommand();
            ValidatorError ve = distSync.syncNullDistros();
            if (ve != null && distroWarnCount < 1) {
                TaskHelper.sendErrorEmail(log, ve.getMessage());
                distroWarnCount++;
            }
            
            
            log.debug("mtime: " + mtime.longValue() + ", last modified: " + 
                LAST_UPDATED.get());
            //If we got an mtime from cobbler and that mtime is before our last update
            // Then don't update anything
            if (mtime != null && mtime.longValue() < CobblerSyncTask.LAST_UPDATED.get()) {
                log.debug("Cobbler mtime is less than last change, skipping");
                return;
            }
            else {
                log.debug("Syncing distros and profiles.");
                
                ve = distSync.store();
                if (ve != null) {
                    TaskHelper.sendErrorEmail(log, ve.getMessage());
                }
                
                CobblerProfileSyncCommand profSync = new CobblerProfileSyncCommand();
                profSync.store();
                
                CobblerSystemSyncCommand systemSync = new CobblerSystemSyncCommand();
                systemSync.store();
            }
            
            LAST_UPDATED.set((new Date()).getTime() / 1000 + 1);
        }
        catch (RuntimeException re) {
            log.error("RuntimeExceptioneError trying to sync to cobbler: " + 
                    re.getMessage(), re);
            // Only throw up one error.  Otherwise if say cobblerd is shutoff you can 
            // possibly generate 1 stacktrace email per minute which is quite spammy.
            if (errorCount < 1) {
                errorCount++;
                log.error("re-throwing exception since we havent yet.");
                throw re;
            }
            else {
                log.error("Not re-throwing any more errors.");
            }
        }
    }
    
    

}
