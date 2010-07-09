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
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Change e-mail
 * @version $Rev: 1244 $
 */
public class ChangeEmailSetupAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm)formIn;
        LocalizationService ls = LocalizationService.getInstance();

        RequestContext requestContext = new RequestContext(request);

        //set logged in user and target user
        User loggedInUser = requestContext.getLoggedInUser();
        User targetUser;
        Long uid = requestContext.getParamAsLong("uid");
        if (uid == null) {
            targetUser = loggedInUser; //We are editing ourself
        }
        else {
            targetUser = UserManager.lookupUser(loggedInUser, uid);
        }
        request.setAttribute(RhnHelper.TARGET_USER, targetUser);
        // If targetUser is null we must have gotten a bad uid
        if (targetUser == null) {
            throw new BadParameterException("Invalid uid, targetUser not found");
        }

        String email = targetUser.getEmail();

        String pageInstructions;
        String buttonLabel;
        /*
         * ** Logic from Sniglests/Users.pm - rhn_email_change_form **
         * If this is a satellite, we don't care about whether or not this addr is verified.
         */
        pageInstructions = ls.getMessage("yourchangeemail.instructions");
        buttonLabel = ls.getMessage("message.Update");

        //Set request and form vars for page
        request.setAttribute("pageinstructions", pageInstructions);
        request.setAttribute("button_label", buttonLabel);
        form.set("email", email);

        return getStrutsDelegate().forwardParam(mapping.findForward("default"), "uid",
                                      String.valueOf(targetUser.getId()));
    }

}
