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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.kickstart.BaseKickstartCommand;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartDetailsEdit extends RhnAction
 * @version $Rev: 1 $
 */
public abstract class BaseKickstartEditAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        if (!AclManager.hasAcl("user_role(org_admin) or user_role(config_admin)",
            request, null)) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException(
                    "Only Org Admins or Configuration Admins can modify kickstarts");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.summary.acl.header"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.acl.reason5"));
            throw pex;
        }
        String forwardname = "default";
        DynaActionForm form = (DynaActionForm) formIn;
        Map params = makeParamMap(request);
        RequestContext requestContext = new RequestContext(request);
        BaseKickstartCommand cmd = getCommand(requestContext);

        User user = requestContext.getLoggedInUser();
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        //Display message if this kickstart profile's channel is inadequate.
        KickstartHelper helper = new KickstartHelper(request);
        if (!helper.verifyKickstartChannel(cmd.getKickstartData(), user)) {
            strutsDelegate.saveMessages(request,
                   helper.createInvalidChannelMsg(cmd.getKickstartData()));
        }

        request.setAttribute(RequestContext.KICKSTART, cmd.getKickstartData());

        if (isSubmitted(form)) {
            ValidatorError ve = processFormValues(request, form, cmd);
            if (ve != null) {
                ValidatorError[] verr = {ve};
                strutsDelegate.saveMessages(request,
                        RhnValidationHelper.validatorErrorToActionErrors(verr));
            }
            else {
                cmd.store();
                createSuccessMessage(request, getSuccessKey(), null);
                forwardname = getSuccessForward();
            }
        }

        // Whether we processed the form submission or not, we need to
        // set up the form again for display.
        setupFormValues(requestContext, form, cmd);
        return strutsDelegate.forwardParams(mapping.findForward(forwardname), params);
    }

    protected abstract BaseKickstartCommand getCommand(RequestContext ctx);

    /**
     * 'Overrideable' method for baseclasses that require a
     * different action forward.  This currently returns "default".
     * @return String "default" that can be overridden
     */
    protected String getSuccessForward() {
        return "default";
    }

    /**
     * Process the values from the form. This is called when the form is
     * submitted.  This is the 'submit' side of the action.
     * @param form to process
     * @param cmd to execute
     * @return ValidatorError if something failed.
     */
    protected abstract ValidatorError processFormValues(HttpServletRequest request,
            DynaActionForm form,
            BaseKickstartCommand cmd);

    protected abstract String getSuccessKey();

    /**
     * Setup the form values and other attributes necessary for the
     * action to render.  This is where you pre-populate the form values
     * on the 'setup' side of the action.
     * @param ctx
     * @param form
     * @param cmd
     */
    protected abstract void setupFormValues(RequestContext ctx, DynaActionForm form,
            BaseKickstartCommand cmd);

}
