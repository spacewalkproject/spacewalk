/**
 * Copyright (c) 2011 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.tasko;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.taskomatic.TaskomaticApi;
import com.redhat.rhn.taskomatic.TaskomaticApiException;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * DeleteScheduleAction
 * @version $Rev$
 */
public class DeleteScheduleAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        User loggedInUser = ctx.getLoggedInUser();

        if (ctx.hasParam("schid")) {
            Long scheduleId = ctx.getParamAsLong(("schid"));
            TaskomaticApi tapi = new TaskomaticApi();
            Map schedule = new HashMap();
            try {
                schedule = tapi.lookupScheduleById(loggedInUser, scheduleId);
            }
            catch (TaskomaticApiException e) {
                createErrorMessage(request,
                        "repos.jsp.message.taskomaticdown", null);
            }
            String scheduleName = (String) schedule.get("job_label");
            if (scheduleName != null) {
                String bunchName = (String) schedule.get("bunch");
                request.setAttribute("schedulename", scheduleName);
                request.setAttribute("bunch", bunchName);
                request.setAttribute("cronexpr", schedule.get("cron_expr"));
                request.setAttribute("activetill", schedule.get("active_till"));
                if (isActive(schedule)) {
                    if (ctx.isSubmitted()) {
                        try {
                            tapi.unscheduleSatTask(scheduleName, loggedInUser);
                            // there's not a good way to check
                            // whether the bunch was unscheduled
                            schedule = tapi.lookupScheduleByBunchAndLabel(loggedInUser,
                                    bunchName, scheduleName);
                            if (schedule == null) {
                                createSuccessMessage(request, "message.scheduledeleted",
                                        scheduleName);
                            }
                            return getStrutsDelegate().forwardParams(
                                    mapping.findForward("success"),
                                    new HashMap());
                        }
                        catch (TaskomaticApiException e) {
                            createErrorMessage(request,
                                    "repos.jsp.message.taskomaticdown", null);

                        }
                    }
                }
                else {
                    createErrorMessage(request, "message.schedulenotactive", scheduleName);
                }
            }
        }
        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                request.getParameterMap());
    }

    private Boolean isActive(Map schedule) {
        Date till = (Date) schedule.get("active_till");
        if (till == null) {
            return Boolean.TRUE;
        }
        Date now = new Date();
        return now.before(till);
    }
}
