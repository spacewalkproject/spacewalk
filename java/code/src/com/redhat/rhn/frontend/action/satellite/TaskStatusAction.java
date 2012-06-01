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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.task.TaskManager;
import com.redhat.rhn.taskomatic.TaskomaticApi;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Date;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Task Status Action
 *
 * @version $Rev: 1 $
 */
public class TaskStatusAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        DataResult taskInfo = TaskManager.getTaskStatusInfo();
        // make some corrections
        for (Iterator iter = taskInfo.iterator(); iter.hasNext();) {
            Map info = (Map) iter.next();
            String name = "task.status." + info.get("name");
            info.put("name", name);
            Date startTime = (Date) info.get("start_time");
            info.put("start_time",
                    LocalizationService.getInstance().formatCustomDate(startTime));
        }

        TaskomaticApi taskomatic = new TaskomaticApi();
        String state = "ON";
        if (!taskomatic.isRunning()) {
            state = "OFF";
        }
        request.setAttribute("taskomatic_on", state);
        request.setAttribute("list", taskInfo);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
