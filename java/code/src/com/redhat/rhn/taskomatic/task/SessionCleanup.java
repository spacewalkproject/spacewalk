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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;

import org.apache.log4j.Logger;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.sql.Types;
import java.util.HashMap;
import java.util.Map;

/**
 * SessionCleanup
 * Deletes expired rows from the PXTSessions table to keep it from
 * growing too large.
 * @version $Rev$
 */
public class SessionCleanup extends SingleThreadedTask {
    
    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */    
    public static final String DISPLAY_NAME = "session_cleanup";
    
    private static Logger log = Logger.getLogger(SessionCleanup.class);
    
    /**
     * {@inheritDoc}
     */
    protected void run(JobExecutionContext context)
            throws JobExecutionException {
        Config c = Config.get();
        Map inParams = new HashMap();
        Map outParams = new HashMap();
        
        //retrieves info from user preferences
        long window = c.getInt("web.session_database_lifetime");
        int batchSize = c.getInt("web.session_delete_batch_size");
        int commitInterval = c.getInt("web.session_delete_commit_interval");
        
        // 100000 is an arbitrary value
        if (batchSize > 100000 || batchSize <= 0) {
            batchSize = 50000;
            log.warn("session_delete_batch_size out of range, using default of 50000");
        }
        
        //1000 is yet another arbitrary value
        if (commitInterval > 1000 || commitInterval <= 0) {
            commitInterval = 100;
            log.warn("session_delete_commit interval out of range, using default of 100");
        }
        
        long bound = (System.currentTimeMillis() / 1000) - (2 * window);

        log.info("session_cleanup: starting delete of stale sessions");
        if (log.isDebugEnabled()) {
            log.debug("Batch size is " + String.valueOf(batchSize));
            log.debug("Commit interval is " + String.valueOf(commitInterval));
            log.debug("Session expiry threshold is " + String.valueOf(bound));
        }

        //input parameters of the proc
        inParams.put("bound", new Long(bound));
        inParams.put("commit_interval", new Integer(commitInterval));
        inParams.put("batch_size", new Integer(batchSize));
        
        //output parameter of the proc
        outParams.put("sessions_deleted", new Integer(Types.NUMERIC));

        CallableMode m = ModeFactory.getCallableMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_SESSION_CLEANUP);
        if (log.isDebugEnabled()) {
            log.debug("Calling CallableMode " + TaskConstants.MODE_NAME + "::" + 
                    TaskConstants.TASK_QUERY_SESSION_CLEANUP);
        }
        Map row = m.execute(inParams, outParams);
        if (log.isDebugEnabled()) {
            log.debug("CallableMode " + TaskConstants.MODE_NAME + "::" + 
                    TaskConstants.TASK_QUERY_SESSION_CLEANUP + " returned");
        }            
        //retrieves and logs number of sessions deleted
        log.debug("session: cleanup " + row.get("sessions_deleted") + 
                 " stale sessions deleted\n");            
    }

}
