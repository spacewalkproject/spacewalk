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
package com.redhat.rhn.frontend.action.satellite;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.task.TaskManager;
import com.redhat.rhn.taskomatic.task.CleanCurrentAlerts;
import com.redhat.rhn.taskomatic.task.DailySummary;
import com.redhat.rhn.taskomatic.task.ErrataQueue;
import com.redhat.rhn.taskomatic.task.SessionCleanup;
import com.redhat.rhn.taskomatic.task.SummaryPopulation;
import com.redhat.rhn.taskomatic.task.SynchProbeState;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Task Status Action
 *
 * @version $Rev: 1 $
 */
public class TaskStatusAction extends RhnAction {

    private static final String KEY = "key";
    private static final String DATE = "date";
    private static final String LABEL = "label";

    private static final String CURRENT_DB_TIME = "current_db";

    private static final String LAST_COMPLETED = "last_task_completed";


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {


        List<Map> toDisplay = getDisplayList();


        for (Map map : toDisplay) {
            Date date = TaskManager.getTaskExecutionTime((String) map.get(LABEL));
            if (date != null) {
                map.put(DATE, LocalizationService.getInstance().formatDate(date));
            }
        }

        
        request.setAttribute(CURRENT_DB_TIME, LocalizationService.getInstance().formatDate(
                                        TaskManager.getCurrentDBTime()));
        request.setAttribute("list", toDisplay);
        return mapping.findForward("default");
    }


    private List<Map> getDisplayList() {
        List<Map> list = new ArrayList<Map>();


        list.add(new HashMap() {
            {
                put(KEY, "task.status.last.completed");
                put(LABEL, LAST_COMPLETED);
            }
        });

        list.add(new HashMap() {
            {
                put(KEY, "task.status.session.cleanup");
                put(LABEL, SessionCleanup.DISPLAY_NAME);
            }
        });

        list.add(new HashMap() {
            {
                put(KEY, "task.status.errata.queue.notif");
                put(LABEL, ErrataQueue.DISPLAY_NAME);
            }
        });

        list.add(new HashMap() {
            {
                put(KEY, "task.status.errata.mail");
                put(LABEL, "errata_engine");
            }
        });

        list.add(new HashMap() {
            {
                put(KEY, "task.status.daily.summary");
                put(LABEL, SummaryPopulation.DISPLAY_NAME);
            }
        });

        list.add(new HashMap() {
            {
                put(KEY, "task.status.daily.summary.mail");
                put(LABEL, DailySummary.DISPLAY_NAME);
            }
        });

        list.add(new HashMap() {
            {
                put(KEY, "task.status.clean.alerts");
                put(LABEL, CleanCurrentAlerts.DISPLAY_NAME);
            }
        });

        list.add(new HashMap() {
            {
                put(KEY, "task.status.sync.probe");
                put(LABEL, SynchProbeState.DISPLAY_NAME);
            }
        });

        return list;
    }

}

