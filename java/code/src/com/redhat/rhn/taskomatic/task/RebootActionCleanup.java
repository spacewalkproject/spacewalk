/**
 * Copyright (c) 2014 Novell, Inc.
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

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.Server;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;


/**
 * Cleans up stale reboot action data if it is older than 6 hours. It is assumed
 * that after this time, the reboot action has failed for some reason.
 */
public class RebootActionCleanup extends RhnJavaJob {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext arg0In)
        throws JobExecutionException {
        List<Map<String, Long>> failedRebootActions = lookupRebootActionCleanup();
        for (Map<String, Long> fa : failedRebootActions) {
            Long sid = fa.get("server_id");
            Long aid = fa.get("action_id");
            List<Long> fAids = invalidateActionRecursive(sid, aid);
            for (Long fAid : fAids) {
                invalidateKickstartSession(sid, fAid);
            }
        }
        if (failedRebootActions.size() > 0) {
            log.info("Set " + failedRebootActions.size() +
                    " reboot action(s) to failed. Running longer than 6 hours.");
        }
    }

    private void invalidateKickstartSession(Long serverId, Long actionId) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_LOOKUP_KICKSTART_SESSION_ID);
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("server_id", serverId);
        params.put("action_id", actionId);

        List<Map<String, Object>> ksids = m.execute(params);
        if (ksids == null || ksids.get(0) == null || ksids.get(0).get("id") == null) {
            return;
        }
        Long ksid = (Long) ksids.get(0).get("id");
        KickstartSession ks = KickstartFactory.lookupKickstartSessionById(ksid);
        ks.setState(KickstartFactory.SESSION_STATE_FAILED);
        ks.setAction(null);
    }

    private List<Map<String, Long>> lookupRebootActionCleanup() {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_LOOKUP_REBOOT_ACTION_CLEANUP);

        Map<String, Integer> params = new HashMap<String, Integer>();
        // 6 hours
        params.put("threshold", new Integer(6));
        return m.execute(params);
    }

    private List<Long> invalidateActionRecursive(Long serverId, Long actionId) {
        List<Long> childIds = lookupChildAction(serverId, actionId);
        List<Long> aIds = new ArrayList<Long>();
        for (Iterator<Long> itr = childIds.iterator(); itr.hasNext();) {
            Long childAction = itr.next();
            List<Long> cIds = invalidateActionRecursive(serverId, childAction);
            aIds.addAll(cIds);
        }
        Server s = ServerFactory.lookupById(serverId);
        Action a = ActionFactory.lookupById(actionId);
        ServerAction sa = ActionFactory.getServerActionForServerAndAction(s, a);
        if (sa.getStatus().getName() != "Failed") {
            sa.setResultCode(-100L);
            sa.setResultMsg("Prerequisite failed");
            sa.setStatus(ActionFactory.STATUS_FAILED);
        }

        return aIds;
    }

    private List<Long> lookupChildAction(Long serverId, Long actionId) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_LOOKUP_CHILD_ACTION);
        DataResult<?> retval = null;
        List<Long> childActions = new ArrayList<Long>();

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("server_id", serverId);
        params.put("action_id", actionId);
        retval = m.execute(params);
        if (retval != null) {
            for (Iterator<?> itr = retval.iterator(); itr.hasNext();) {
                String val = (String)itr.next();
                childActions.add(new Long(val));
            }
        }
        return childActions;
    }
}
