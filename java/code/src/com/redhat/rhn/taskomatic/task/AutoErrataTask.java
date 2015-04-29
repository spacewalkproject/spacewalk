/**
 * Copyright (c) 2015 Red Hat, Inc.
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
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.action.errata.ErrataAction;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.errata.ErrataManager;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.List;
import java.util.Map;

/**
 * This is what automatically schedules automatic errata update actions.
 * This used to be part of what the Errata Queue job did, but that didn't work well.
 * Errata Queue is a run-once job that happens when you need to send notification
 * emails about new errata. But adding new errata is not the only time you might need
 * to schedule auto errata updates, instead you also need to do it if your server is
 * changing channel subscriptions or has installed on older version of a package. So
 * It made the most sense to separate things out into two separate jobs. This also
 * ensures that we don't miss auto errata update actions if the errata cache is not
 * ready or something, as now they'll just be scheduled the next time this job runs
 * after the errata cache is done.
 *
 * @version $Rev.$
 */

public class AutoErrataTask extends RhnJavaJob {

    /**
     * {@inheritDoc}
     */
    public void execute(JobExecutionContext context)
        throws JobExecutionException {

        List<Map<String, Long>> results = getErrataToProcess();
        if (results == null || results.size() == 0) {
            if (log.isDebugEnabled()) {
                log.debug("No unapplied auto errata found... exiting");
            }
            return;
        }

        if (log.isDebugEnabled()) {
            log.debug("=== Scheduling " + results.size() + " auto errata updates");
        }

        for (Map<String, Long> result : results) {
            Long errataId = result.get("errata_id");
            Long serverId = result.get("server_id");
            Long orgId = result.get("org_id");
            try {
                Errata errata = ErrataManager.lookupPublishedErrata(errataId);
                Org org = OrgFactory.lookupById(orgId);
                ErrataAction errataAction = ActionManager.
                        createErrataAction(org, errata);
                ActionManager.addServerToAction(serverId, errataAction);
                ActionManager.storeAction(errataAction);
            }
            catch (Exception e) {
                log.error("Errata: " + errataId + ", Org Id: " + orgId + ", Server: " +
                        serverId, e);
                throw new JobExecutionException(e);
            }
            if (log.isDebugEnabled()) {
                log.debug("Scheduling auto update actions for server " + serverId +
                        " and erratum " + errataId);
            }
        }
    }

    /**
     * The brains of the operation resides in this query. The query logic is:
     * Find all errata-server combinations where:
     * - server is auto-update capable (has feature)
     * - server has enabled auto-updates
     * - the errata cache (rhnServerNeededCache) says that the erratum is an upgrade
     *     for this server
     * - the channel that the erratum in is not currently regenerating yum metadata
     * - we have not already scheduled an action for this errata-server combination
     *   - If we have ever scheduled an action before then it'll never get rescheduled.
     *     So if the action failed or something the user will need to fix whatever was
     *     wrong and manually re-schedule.
     *
     * @return maps of errata_id, server_id, and org_id that need actions
     */
    protected List<Map<String, Long>> getErrataToProcess() {
        SelectMode select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_AUTO_ERRATA_CANDIDATES);
        @SuppressWarnings("unchecked")
        List<Map<String, Long>> results = select.execute();
        return results;
    }
}
