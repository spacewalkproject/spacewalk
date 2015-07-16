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

package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.struts.RequestContext;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * OrgConfigSatAction
 */
public class OrgConfigSatAction extends OrgConfigAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response)
    throws Exception {
        RequestContext ctx = new RequestContext(request);
        Org org = ctx.lookupAndBindOrg();
        if (ctx.isSubmitted()) {
            if (!ctx.getCurrentUser().hasRole(RoleFactory.SAT_ADMIN)) {
                throw new PermissionException("Satellite Administrator role is required.");
            }
            org.getOrgAdminMgmt().setEnabled(request.
                    getParameter("org_admin_mgmt") != null);
        }
        else {
            request.setAttribute("org_admin_mgmt", org.getOrgAdminMgmt().isEnabled());
        }
        return process(mapping, request, ctx, org);
    }
}
