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
package com.redhat.rhn.frontend.action.user;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserPreferencesAction, edit action for user detail page
 * @version $Rev: 742 $
 */
public class EditAddressSetupAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        DynaActionForm form = (DynaActionForm)formIn;
        String type = request.getParameter("type");
        Long uid = requestContext.getRequiredParam("uid");
        if (type == null) {
            throw new BadParameterException(
                "Invalid type parameter with null value");
        }

        User user = UserManager.lookupUser(requestContext.getLoggedInUser(), uid);
        request.setAttribute(RhnHelper.TARGET_USER, user);
        form.set("uid", user.getId());
        if (!RhnValidationHelper.getFailedValidation(request) &&
                user != null) {
            form.set("address1", user.getAddress1());
            form.set("address2", user.getAddress2());
            form.set("phone", user.getPhone());
            form.set("fax", user.getFax());
            form.set("city", user.getCity());
            form.set("state", user.getState());
            form.set("country", user.getCountry());
            form.set("zip", user.getZip());
        }
        form.set("typedisplay",
            LocalizationService.getInstance().
                getMessage("address type " + type));
        form.set("type", type);
        // set the Country map
        request.setAttribute(
            "availableCountries", UserActionHelper.getCountries());

        ActionForward fwd = mapping.findForward("default");
        return fwd;
    }

}
