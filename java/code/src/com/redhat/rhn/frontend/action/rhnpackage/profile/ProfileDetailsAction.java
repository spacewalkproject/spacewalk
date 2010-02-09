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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.profile.ProfileFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * ProfileDetailsAction
 * @version $Rev: 1 $
 */
public class ProfileDetailsAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        DynaActionForm form = (DynaActionForm)formIn;
        Map params = makeParamMap(request);
        RequestContext context = new RequestContext(request);

        Long prid = context.getRequiredParam(RequestContext.PRID);
        params.put(RequestContext.PRID, prid);

        Profile profile = null;
        if (prid != null) {
            profile = ProfileManager.lookupByIdAndOrg(prid,
                    context.getLoggedInUser().getOrg());

            request.setAttribute("profile", profile);
        }

        if (!isSubmitted(form)) {
            setupForm(form, profile);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    request.getParameterMap());
        }

        edit(form, profile);
        return getStrutsDelegate().forwardParams(mapping.findForward("success"), params);
    }

    private void setupForm(DynaActionForm form, Profile profile) {
        if (profile != null) {
            form.set("name", profile.getName());
            form.set("description", profile.getDescription());
        }
    }

    private void edit(DynaActionForm form, Profile profile) {
        if (profile != null) {
            profile.setName((String)form.get("name"));
            profile.setDescription((String)form.get("description"));
            ProfileFactory.save(profile);
        }
    }

    /** {@inheritDoc} */
    public String getParentUrl(RequestContext context) {
        return context.getRequest().getRequestURI() +
            "?prid=" + context.getParamAsLong(RequestContext.PRID);
    }
}
