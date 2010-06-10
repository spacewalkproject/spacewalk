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
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.frontend.dto.OrgIdWrapper;

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * SummaryPopulation figures out what orgs might be candidates for sending
 * daily summary email
 * @version $Rev$
 */
public class SummaryPopulation implements Job {
    
    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */    
    public static final String DISPLAY_NAME = "summary_populator";
    
    private static Logger log = Logger.getLogger(SummaryPopulation.class);
    
    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext ctx) throws JobExecutionException {
        
        try {
            // don't want duplicates otherwise we risk violating the
            // RHN_DSQUEUE_OID_UQ unique constraint on org_id
            Set orgSet = new LinkedHashSet();
            
            log.debug("Finding orgs with awol servers");
            List orgs = awolServerOrgs();
            orgSet.addAll(orgs);
            if (log.isDebugEnabled()) {
                int orgCount = 0;
                if (orgs != null) {
                    orgCount = orgs.size();
                }
                else {
                    log.debug("awolServerOrgs() returned null");
                }
                log.debug("Found  " + orgCount + " awol servers");
            }
            
            log.debug("Finding orgs w/ recent action activity");
            orgSet.addAll(orgsWithRecentActions());
            log.debug("Done finding orgs w/ recent action activity");
            
            log.debug("Enqueing orgs");
            for (Iterator itr = orgSet.iterator(); itr.hasNext();) {
                OrgIdWrapper bdw = (OrgIdWrapper) itr.next();
                enqueueOrg(bdw.toLong());
            }
            log.debug("Finished enqueing orgs");
            log.debug("finished queueing orgs for daily summary emails");
        }
        catch (Exception e) {
            log.error(e.getMessage(), e);
            throw new JobExecutionException(e);
        }
    }
    
    private List awolServerOrgs() {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_SUMMARYPOP_AWOL_SERVER_IN_ORGS);
        
        Map params = new HashMap();
        int checkin = Config.get().getInt(ConfigDefaults.SYSTEM_CHECKIN_THRESHOLD);
        if (log.isDebugEnabled()) {
            log.debug("Server checkin threshold for AWOL servers: " + checkin);
        }
        params.put("checkin_threshold", new Integer(checkin));
        return m.execute(params);
    }
    
    private List orgsWithRecentActions() {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_SUMMARYPOP_ORGS_RECENT_ACTIONS);
        return m.execute();
    }
    
    private int enqueueOrg(Long orgId) {
        Map params = new HashMap();
        params.put("org_id", orgId);
        SelectMode select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_VERIFY_SUMMARY_QUEUE);
        WriteMode m = ModeFactory.getWriteMode(
                TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_INSERT_SUMMARY_QUEUE);
        
        try {
            DataResult result = select.execute(params);
            Map row = (Map) result.get(0);
            Long count = (Long) row.get("queued");
            if (count.intValue() == 0) {
                return m.executeUpdate(params);
            }
            else {
                log.warn("Skipping " + orgId + " because it's already queued");
                return 0;
            }
        }
        catch (RuntimeException e) {
            log.warn(e.getMessage(), e);
            return -1;
        }
    }

}
