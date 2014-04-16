/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * SystemGroupConfigAction
 * @version $Rev$
 */
public class SystemGroupConfigAction extends RhnAction {

    private final String CREATE_DEFAULT_SG = "create_default";

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        DynaActionForm daForm = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getCurrentUser();
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            throw new PermissionException(RoleFactory.ORG_ADMIN);
        }

        Org org = user.getOrg();

        if (ctx.isSubmitted()) {
            Boolean createDefaultSG = (Boolean) daForm.get(CREATE_DEFAULT_SG);
            // store the value
            org.getOrgConfig().setCreateDefaultSg(createDefaultSG);

            createSuccessMessage(request, "message.sg.configupdated", null);
            return mapping.findForward("success");
        }

        // not submitted
        setupForm(request, daForm, org);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private void setupForm(HttpServletRequest request, DynaActionForm form, Org orgIn) {
        form.set(CREATE_DEFAULT_SG, orgIn.getOrgConfig().isCreateDefaultSg());
    }
}
