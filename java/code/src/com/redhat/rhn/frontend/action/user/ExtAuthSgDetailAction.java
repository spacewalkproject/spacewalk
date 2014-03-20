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

import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.usergroup.OrgUserExtGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ExtAuthSgDetailAction
 * @version $Rev$
 */
public class ExtAuthSgDetailAction extends RhnAction {

    private static final String VALIDATION_XSD =
            "/com/redhat/rhn/frontend/action/user/validation/extGroupForm.xsd";

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext ctx = new RequestContext(request);
        DynaActionForm form = (DynaActionForm)formIn;

        User user = ctx.getCurrentUser();
        Org org = user.getOrg();

        Long gid = ctx.getParamAsLong("gid");
        OrgUserExtGroup extGroup = null;
        if (gid != null) {
            ctx.copyParamToAttributes("gid");
            extGroup = UserGroupFactory.lookupOrgExtGroupByIdAndOrg(gid, org);
            request.setAttribute("group", extGroup);
        }

        if (ctx.isSubmitted()) {
            ValidatorResult result = RhnValidationHelper.validate(this.getClass(),
                    makeValidationMap(form), null,
                    VALIDATION_XSD);
            if (!result.isEmpty()) {
                getStrutsDelegate().saveMessages(request, result);
                setupSystemGroups(request, user, extGroup, form);
                return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
            }

            String label = (String) form.get("extGroupLabel");
            String[] selectedSgs = form.getStrings("selected_sgs");

            Set <ServerGroup>sgs = new HashSet<ServerGroup>();
            for (String sg : selectedSgs) {
                sgs.add(ServerGroupFactory.lookupByNameAndOrg(sg, org));
            }

            if (extGroup == null) {
                extGroup = new OrgUserExtGroup(org);
            }

            if (!label.equals(extGroup.getLabel())) {
                if (UserGroupFactory.lookupOrgExtGroupByLabelAndOrg(label, org) != null) {
                    createErrorMessage(request, "extgrouplabel.already.exists", label);
                    setupSystemGroups(request, user, extGroup, form);
                    return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
                }
                extGroup.setLabel(label);
            }
            extGroup.setServerGroups(sgs);
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
        setupSystemGroups(request, user, extGroup, form);
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private Map makeValidationMap(DynaActionForm form) {
        Map<String, String> map = new HashMap<String, String>();
        map.put("label", (String) form.get("extGroupLabel"));
        return map;
    }

    /**
     * setup external system groups
     * @param request request
     * @param user logged in user
     * @param extGroupIn external group
     * @param form dyna form
     */
    public void setupSystemGroups(HttpServletRequest request, User user,
            OrgUserExtGroup extGroupIn, DynaActionForm form) {

        List<LabelValueBean> systemGroupList =
                new ArrayList<LabelValueBean>();
        for (ManagedServerGroup group : ServerGroupFactory.listManagedGroups(
                user.getOrg())) {
             systemGroupList.add(new LabelValueBean(group.getName(),
                     group.getName()));
        }

        Set<String> selectedSgs = new HashSet<String>();
        if (extGroupIn != null) {
            for (ServerGroup group : extGroupIn.getServerGroups()) {
                selectedSgs.add(group.getName());
            }
        }

        form.set("sgs", systemGroupList.toArray(new LabelValueBean[0]));
        form.set("selected_sgs", selectedSgs.toArray(new String[0]));
    }
}
