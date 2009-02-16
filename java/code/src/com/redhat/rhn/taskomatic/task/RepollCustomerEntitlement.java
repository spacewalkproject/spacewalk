/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.taskomatic.task.entitlement.EntitlementQueueDriver;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueue;
import com.redhat.rhn.taskomatic.task.threaded.TaskQueueFactory;

/**
 * RepollCustomerEntitlement
 * @version $Rev$
 */
public class RepollCustomerEntitlement extends SingleThreadedTask {
        
    /**
     * Used to LOG stats in the RHNDAEMONSTATE table
     */    
    public static final String DISPLAY_NAME = "repoll_customer_entitlement";

    private static Logger log = Logger.getLogger(RepollCustomerEntitlement.class);
    
    /**
     * {@inheritDoc}
     */
    protected void run(JobExecutionContext arg0In)
        throws JobExecutionException {
        if (log.isDebugEnabled()) {
            log.debug("starting customer entitlement repoll run...");
        }
        try {
            if (needsRepoll()) {
                if (needsRapidRepoll()) {
                    if (log.isDebugEnabled()) {
                        log.debug("Doing rapid repoll");
                    }
                    doRapidRepoll();
                    if (log.isDebugEnabled()) {
                        log.debug("All orgs have been scheduled for repoll");
                    }
                }
                else {
                    if (log.isDebugEnabled()) {
                        log.debug("Doing standard repoll");
                    }
                    doStandardRepoll();
                }
            }
        }
        finally {
            if (log.isDebugEnabled()) {
                log.debug("customer entitlement repoll run complete");
            }
        }
    }
    
    private void doRapidRepoll() {
        System.out.println("Doing rapid repoll");
        TaskQueue queue = TaskQueueFactory.get().getQueue("entitlement_repoll");
        if (queue == null) {
            try {
                queue = TaskQueueFactory.get().createQueue("entitlement_repoll", 
                        EntitlementQueueDriver.class);
            }
            catch (Exception e) {
                log.error(e);
                return;
            }            
        }
        if (queue.getQueueSize() == 0) {
            queue.run();
        }
    }
    
    private void doStandardRepoll() {
        try {
            /*
             * Run the rhn_ep.process_queue_batch stored proc with the 
             * duration and batch sizes retrieved from rhn_web.conf
             */
    
            int duration = Config.get().getInt("ep_poll_duration");
            int batch = Config.get().getInt("ep_commit_interval");
            
            //reset the in/outparams maps for the new proc
            Map inparams = new HashMap();
            inparams.put("duration", new Integer(duration));
            inparams.put("batch", new Integer(batch));
            
            Map outparams = new HashMap();
            outparams.put("done", new Integer(Types.NUMERIC));
            
            CallableMode processMode = ModeFactory.getCallableMode("Task_queries", 
                                                   "process_queue_batch");
            
            processMode.execute(inparams, outparams);
                    
        }
        catch (Throwable t) {
            log.error(t.getMessage(), t);
        }        
    }
    
    private boolean needsRepoll() {
        TaskQueue queue = TaskQueueFactory.get().getQueue("entitlement_repoll");
        return ((queue == null || queue.getQueueSize() == 0) && 
                getPendingQueueSize() > 0);        
    }
    
    private boolean needsRapidRepoll() {
        int threshold = Config.get().getInt("taskomatic.rapid_repoll_threshold");
        boolean exceedsThreshold = getPendingQueueSize() >= threshold;
        TaskQueue queue = TaskQueueFactory.get().getQueue("entitlement_repoll");        
        if (exceedsThreshold && (queue == null || queue.getQueueSize() == 0)) {
            log.warn("Entitlement queue exceeds threshold size of " + threshold + 
                    ": Starting rapid repoll");
            return true;
        }
        return false;
    }
    
    private long getPendingQueueSize() {
        CallableMode pendingMode = ModeFactory.getCallableMode("Task_queries", 
            "entitlement_queue_pending");
        Map inparams = new HashMap(); //arguments to the stored proc

        Map outparams = new HashMap(); //results out of the stored proc
        outparams.put("total", new Integer(Types.NUMERIC));
        
        Map result = pendingMode.execute(inparams, outparams);
        Long total = new Long(result.get("total").toString());
        return total.longValue();
        
    }

}
