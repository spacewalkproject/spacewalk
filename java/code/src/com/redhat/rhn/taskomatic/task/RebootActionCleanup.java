/**
 * Copyright (c) 2014 Novell, Inc
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
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
 * ChangeLogCleanUp
 * @version $Rev$
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
            List<Long> f_aids = invalidateActionRecursive(sid, aid);
            for (Long f_aid : f_aids) {
                invalidateKickstartSession(sid, f_aid);
            }
        }
        if (failedRebootActions.size() > 0) {
            log.info("Set " + failedRebootActions.size() +
                    " reboot action(s) to failed. Running longer than 6 hours.");
        }
    }

    private void invalidateKickstartSession(Long server_id, Long action_id) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_LOOKUP_KICKSTART_SESSION_ID);
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("server_id", server_id);
        params.put("action_id", action_id);

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
        return (List<Map<String, Long>>)m.execute(params);
    }

    private List<Long> invalidateActionRecursive(Long server_id, Long action_id) {
        List<Long> child_ids = lookupChildAction(server_id, action_id);
        List<Long> a_ids = new ArrayList<Long>();
        for (Iterator<Long> itr = child_ids.iterator(); itr.hasNext();) {
            Long childAction = (Long) itr.next();
            List<Long> c_ids = invalidateActionRecursive(server_id, childAction);
            a_ids.addAll(c_ids);
        }
        Server s = ServerFactory.lookupById(server_id);
        Action a = ActionFactory.lookupById(action_id);
        ServerAction sa = ActionFactory.getServerActionForServerAndAction(s, a);
        if (sa.getStatus().getName() != "Failed") {
            sa.setResultCode(-100L);
            sa.setResultMsg("Prerequisite failed");
            sa.setStatus(ActionFactory.STATUS_FAILED);
        }

        return a_ids;
    }

    private List<Long> lookupChildAction(Long server_id, Long action_id) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_LOOKUP_CHILD_ACTION);
        DataResult<?> retval = null;
        List<Long> childActions = new ArrayList<Long>();

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("server_id", server_id);
        params.put("action_id", action_id);
        retval = m.execute(params);
        if( retval != null) {
            for (Iterator<?> itr = retval.iterator(); itr.hasNext();) {
                String val = (String)itr.next();
                childActions.add(new Long(val));
            }
        }
        return childActions;
    }
}
