/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
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
 * CreateUserSetupAction
 * @version $Rev: 1029 $
 */
public class CreateUserSetupAction extends BaseUserSetupAction {
    /** placeholder string, package protected; so we don't transmit
     * the actual pw but the form doesn't look empty */
    static final String PLACEHOLDER_PASSWORD = "******";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm)formIn;
        RequestContext ctx = new RequestContext(request);
        User currentUser = ctx.getCurrentUser();

        // We have to set these on the Session because struts throws them away
        // if we set them on the request itself and validation fails.
        request.setAttribute("availablePrefixes",
                                  UserActionHelper.getPrefixes());
        request.setAttribute("countries",
                                  UserActionHelper.getCountries());

        if (!RhnValidationHelper.getFailedValidation(request)) {
            form.set("country", "US");
            form.set("contact_email", Boolean.TRUE);
            form.set("contact_partner", Boolean.TRUE);
            form.set("prefix",
                LocalizationService.getInstance().getMessage("user prefix Mr."));
        }

        //make sure we don't put the user's password on the form in cleartext
        form.set("desiredpassword", "");
        form.set("desiredpasswordConfirm", "");

        /*
         * If we are a sat, then we for sure want to display the PAM section
         */
        request.setAttribute("displaypam", "true");
        /*
        * If we are a sat and we have setup pam authentication already, display the
        * checkbox and instructions
        */
        String pamAuthService = Config.get().getString(ConfigDefaults.WEB_PAM_AUTH_SERVICE);
        if (pamAuthService != null && pamAuthService.trim().length() > 0) {
            request.setAttribute("displaypamcheckbox", "true");
        }

        request.setAttribute("timezones", getTimeZones());

        // There's no currentUser when creating the very first user
        if (currentUser != null && currentUser.getTimeZone() != null) {
            request.setAttribute("default_tz", new Integer(currentUser.getTimeZone()
                .getTimeZoneId()));
        }
        else {
            request.setAttribute("default_tz", new Integer(UserManager
                .getDefaultTimeZone().getTimeZoneId()));
        }

        request.setAttribute("noLocale", buildNoneLocale());
        request.setAttribute("supportedLocales", buildImageMap());
        // There's no currentUser when creating the very first user
        if (currentUser != null) {
            setCurrentLocale(ctx, currentUser);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}

