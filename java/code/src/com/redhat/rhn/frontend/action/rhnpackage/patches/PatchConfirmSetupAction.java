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
package com.redhat.rhn.frontend.action.rhnpackage.patches;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.solarispackage.SolarisManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Date;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PatchConfirmSetupAction
 * @version $Rev: 53116 $
 */
public class PatchConfirmSetupAction extends RhnListAction {
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        PageControl pc = new PageControl();

        clampListBounds(pc, request, user);

        DataResult dr = SolarisManager.patchesInSet(user, pc, SetLabels.PATCH_REMOVE_SET);

        String msg = "";
        Object[] args = new Object[4];
        args[0] = server.getName();
        args[1] = server.getLastCheckin();
        args[2] = new Date(server.getLastCheckin().getTime() +
                            (1000 * 60 * 60 * 2));
        args[3] = sid.toString();

        if (dr.size() == 1) {
            msg = LocalizationService.getInstance()
            .getMessage("packagelist.confirmpatchsummary", args);
        }
        else {
            msg = LocalizationService.getInstance()
                    .getMessage("packagelist.confirmpatchsummary.plural", args);
        }

        request.setAttribute("lastcheckin", server.getLastCheckin());
        request.setAttribute("now", new Date());
        Date expectedCheckIn = new Date(server.getLastCheckin().getTime() +
                                        (1000 * 60 * 60 * 2));
        request.setAttribute("expectedcheckin", expectedCheckIn);
        request.setAttribute("pageList", dr);
        request.setAttribute("sid", sid);
        request.setAttribute("pageSummary", msg);
        request.setAttribute("system", server);

        return mapping.findForward("default");
    }
}
