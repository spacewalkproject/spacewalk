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

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * Cleans up stale Kickstarts
 *
 * @version $Rev $
 */

public class KickstartCleanup extends RhnJavaJob {

    /**
     * Used to log stats in the RHNDAEMONSTATE table
     */
    public static final String DISPLAY_NAME = "kickstart_session_check";

    /**
     * Primarily a convenience method to make testing easier
     * @param ctx Quartz job runtime environment
     * @param testMode Enables task results validation
     *
     * @throws JobExecutionException Indicates somes sort of fatal error
     */
    public void execute(JobExecutionContext ctx) throws JobExecutionException {
        try {
            SelectMode select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                    TaskConstants.TASK_QUERY_KSCLEANUP_FIND_CANDIDATES);
            DataResult dr = select.execute(Collections.EMPTY_MAP);
            if (log.isDebugEnabled()) {
                log.debug("Found " + dr.size() + " entries to process");
            }
            // Bail early if no candidates
            if (dr.size() == 0) {
                return;
            }

            Long failedStateId = findFailedStateId();
            if (failedStateId == null) {
                log.warn("Failed kickstart state id not found");
                return;
            }
            for (Iterator iter = dr.iterator(); iter.hasNext();) {
                Map row = (Map) iter.next();
                processRow(failedStateId, row);
            }
        }
        catch (Exception e) {
            log.error(e.getMessage(), e);
            throw new JobExecutionException(e);
        }
    }

    private Long findFailedStateId() {
        Long retval = null;
        SelectMode select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_KSCLEANUP_FIND_FAILED_STATE_ID);
        DataResult dr = select.execute(Collections.EMPTY_MAP);
        if (dr.size() > 0) {
            retval = (Long) ((Map) dr.get(0)).get("id");
        }
        return retval;
    }

    private void processRow(Long failedStateId, Map row) {
        Long sessionId = (Long) row.get("id");
        if (log.isInfoEnabled()) {
            log.info("Processing stalled kickstart session " + sessionId.longValue());
        }
        Long actionId = (Long) row.get("action_id");
        Long oldServerId = (Long) row.get("old_server_id");
        Long newServerId = (Long) row.get("new_server_id");
        if (actionId != null) {
            actionId = findTopmostParentAction(actionId);
            if (oldServerId != null) {
                unlinkAction(actionId, oldServerId);
            }
            if (newServerId != null) {
                unlinkAction(actionId, newServerId);
            }
        }
        markFailed(sessionId, failedStateId);
    }

    private void markFailed(Long sessionId, Long failedStateId) {
        WriteMode update = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_KSCLEANUP_MARK_SESSION_FAILED);
        Map params = new HashMap();
        params.put("session_id", sessionId);
        params.put("failed_state_id", failedStateId);
        update.executeUpdate(params);
    }

    private void unlinkAction(Long actionId, Long serverId) {
        CallableMode proc = ModeFactory.getCallableMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_KSCLEANUP_REMOVE_ACTION);
        Map params = new HashMap();
        params.put("server_id", serverId);
        params.put("action_id", actionId);
        proc.execute(params, new HashMap());
    }

    private Long findTopmostParentAction(Long startingAction) {
        SelectMode select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_KSCLEANUP_FIND_PREREQ_ACTION);
        Map params = new HashMap();
        params.put("action_id", startingAction);
        if (log.isDebugEnabled()) {
            log.debug("StartingAction: " + startingAction);
        }

        Long retval = startingAction;
        Long preqid = startingAction;
        DataResult dr = select.execute(params);
        if (log.isDebugEnabled()) {
            log.debug("dr: " + dr);
        }

        while (dr.size() > 0 && preqid != null) {
            preqid = (Long)
                ((Map) dr.get(0)).get("prerequisite");
            if (preqid != null) {
                retval = preqid;
                params.put("action_id", retval);
                dr = select.execute(params);
            }
        }
        if (log.isDebugEnabled()) {
            log.debug("preqid: " + preqid);
            log.debug("Returning: " + retval);
        }

        return retval;
    }
}
