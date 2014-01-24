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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.org.usergroup.UserExtGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SelectableLabelValueBean;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ExtGroupDetailAction
 * @version $Rev$
 */
public class ExtGroupDetailAction extends RhnAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getCurrentUser();

        Long gid = ctx.getParamAsLong("gid");
        UserExtGroup extGroup = null;
        if (gid != null) {
            ctx.copyParamToAttributes("gid");
            extGroup = UserGroupFactory.lookupExtGroupById(gid);
            request.setAttribute("group", extGroup);
        }

        if (ctx.isSubmitted()) {
            DynaActionForm form = (DynaActionForm)formIn;
            String label = (String) form.get("extGroupLabel");
            Boolean satAdm = (Boolean) form.get("role_satellite_admin");
            Boolean orgAdm = (Boolean) form.get("role_org_admin");
            String selectedRoles = (String) form.get("selected_regular_roles");

            Set<Role> roles = new HashSet<Role>();
            if (BooleanUtils.isTrue(satAdm)) {
                roles.add(RoleFactory.SAT_ADMIN);
            }
            if (BooleanUtils.isTrue(orgAdm)) {
                roles.add(RoleFactory.ORG_ADMIN);
            }
            else {
                for (String roleString : selectedRoles.split(" ")) {
                    if (!StringUtils.isEmpty(roleString)) {
                        roles.add(RoleFactory.lookupByLabel(roleString));
                    }
                }
            }

            if (extGroup == null) {
                extGroup = new UserExtGroup();
            }

            if (!label.equals(extGroup.getLabel())) {
                if (UserGroupFactory.lookupExtGroupByLabel(label) != null) {
                    createErrorMessage(request, "extgrouplabel.already.exists", label);
                    setupRoles(request, user, extGroup);
                    return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
                }
            }

            extGroup.setLabel(label);
            extGroup.setRoles(roles);
            UserGroupFactory.save(extGroup);


            if (gid == null) {
                createSuccessMessage(request, "message.extgroup.created", label);
            }
            else {
                createSuccessMessage(request, "message.extgroup.updated", label);
            }
            return mapping.findForward("success");
        }

        // not submitted
        setupRoles(request, user, extGroup);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * setup external group roles
     * @param request request
     * @param user logged in user
     * @param extGroup external group
     */
    public void setupRoles(HttpServletRequest request, User user,
            UserExtGroup extGroup) {
        List<SelectableLabelValueBean> adminRoles =
                new ArrayList<SelectableLabelValueBean>();
        List<SelectableLabelValueBean> regularRoles =
                new ArrayList<SelectableLabelValueBean>();

        for (Role role : user.getOrg().getRoles()) {
            String label = role.getLabel();
            if (UserFactory.IMPLIEDROLES.contains(role)) {
                // channel, config, system group, activation key, monitoring admin
                boolean hasOrgAdmin = extGroup == null ? false :
                    extGroup.getRoles().contains((RoleFactory.ORG_ADMIN));
                SelectableLabelValueBean bean = new SelectableLabelValueBean(
                        LocalizationService.getInstance().getMessage(label),
                        label,
                        hasOrgAdmin ||
                            (extGroup == null ? false : extGroup.getRoles().contains(role)),
                        hasOrgAdmin && UserFactory.IMPLIEDROLES.contains(role));
                regularRoles.add(bean);
            }
            else {
                // org and satellite admin
                boolean hasSatAdmin = extGroup == null ? false :
                    extGroup.getRoles().contains((RoleFactory.SAT_ADMIN));
                SelectableLabelValueBean bean = new SelectableLabelValueBean(
                        LocalizationService.getInstance().getMessage(label),
                        label,
                        extGroup == null ? false : extGroup.getRoles().contains(role),
                        false);
                adminRoles .add(bean);
            }
        }

        request.setAttribute("adminRoles", adminRoles);
        request.setAttribute("regularRoles", regularRoles);
        request.setAttribute("orgAdmin", extGroup == null ? false :
            extGroup.getRoles().contains(RoleFactory.ORG_ADMIN));
    }
}
