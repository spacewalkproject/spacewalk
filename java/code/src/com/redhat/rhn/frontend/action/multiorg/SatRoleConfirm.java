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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.SatManager;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * OrgDetailsAction extends RhnAction - Class representation of the table web_customer
 * @version $Rev: 1 $
 */
public class SatRoleConfirm extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
              new PermissionException("Only satellite admin's can assign Sat Admin roles");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orgdetail"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        RequestContext requestContext = new RequestContext(request);
        Long uid = requestContext.getParamAsLong(RequestContext.USER_ID);
        // protect against cached/manual urls
        if (uid == null) {
            return mapping.findForward("cancel");
        }

        User u = UserManager.lookupUser(requestContext.getLoggedInUser(), uid);

        // just in case user bypasses user page using bookmarks
        if (SatManager.getActiveSatAdmins().size() == 1) {
            createErrorMessage(request, "satadmin.jsp.error.lastsatadmin",
                               u.getLogin());
            return mapping.findForward("cancel");
        }

        ActionForward retval = mapping.findForward("default");

        DynaActionForm dynaForm = (DynaActionForm) formIn;
        if (isSubmitted(dynaForm)) {
          u.removeRole(RoleFactory.SAT_ADMIN);
          retval = mapping.findForward("logout");
        }
        else {
          request.setAttribute("username", u.getLogin());
        }

        return retval;
    }

}
