/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.ssm;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * IndexAction extends RhnAction
 * @version $Rev: 1 $
 */
public class ConfirmSystemPreferencesAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        DynaActionForm form = (DynaActionForm) formIn;
        User user = context.getCurrentUser();

        if (context.isSubmitted() && request.getAttribute("no_execute") == null) {
            String notify = form.getString("notify");
            String summary = form.getString("summary");
            String update = form.getString("update");
            if (notify.equals("yes") || notify.equals("no")) {
                SystemManager.setUserSystemPreferenceBulk(user, "receive_notifications",
                        notify.equals("yes"), true);
            }
            if (summary.equals("yes") || summary.equals("no")) {
                SystemManager.setUserSystemPreferenceBulk(user, "include_in_daily_summary",
                        summary.equals("yes"), true);
            }
            if (update.equals("yes") || update.equals("no")) {
                SystemManager.setAutoUpdateBulk(user, update.equals("yes"));
                if (update.equals("yes")) {
                    getStrutsDelegate().saveMessage(
                            "ssm.misc.changeprefs.updatesscheduled", context.getRequest());
                }
            }

            getStrutsDelegate().saveMessage("ssm.misc.changeprefs.changed",
                    context.getRequest());

            return mapping.findForward(RhnHelper.CONFIRM_FORWARD);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

}
