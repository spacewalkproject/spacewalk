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
import com.redhat.rhn.manager.kickstart.KickstartIpCommand;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartIpRangeAction extends RhnAction
 * @version $Rev: 1 $
 */
public class KickstartIpRangeAction extends RhnAction {

    public static final String RANGES = "ranges";

    public static final String OCTET1A = "octet1a";
    public static final String OCTET1B = "octet1b";
    public static final String OCTET1C = "octet1c";
    public static final String OCTET1D = "octet1d";
    public static final String OCTET2A = "octet2a";
    public static final String OCTET2B = "octet2b";
    public static final String OCTET2C = "octet2c";
    public static final String OCTET2D = "octet2d";

    public static final String URL = "url";
    public static final String URLRANGE = "urlRange";

    /**
     *
     * {@inheritDoc}
     */
    public final ActionForward execute(ActionMapping mapping,
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

        DynaActionForm form = (DynaActionForm) formIn;
        Map params = makeParamMap(request);
        RequestContext ctx = new RequestContext(request);

        StrutsDelegate strutsDelegate = getStrutsDelegate();

        KickstartIpCommand cmd =
            new KickstartIpCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                                   ctx.getCurrentUser());

        request.setAttribute(RequestContext.KICKSTART, cmd.getKickstartData());

        //Display message if this kickstart profile's channel is inadequate.
        KickstartHelper helper = new KickstartHelper(request);
        User user = new RequestContext(request).getLoggedInUser();
        if (!helper.verifyKickstartChannel(cmd.getKickstartData(), user)) {
            strutsDelegate.saveMessages(request,
                    helper.createInvalidChannelMsg(cmd.getKickstartData()));
        }

        // user submitted form to add ip range
        if (isSubmitted(form)) {

            // try to add the ip range
            ValidatorError ve = processFormValues(form, cmd);
            // error submitting range
            if (ve != null) {
                ValidatorError[] verr = {ve};
                strutsDelegate.saveMessages(request,
                        RhnValidationHelper.validatorErrorToActionErrors(verr));
            }
            // sunny day, range added, show user success msg
            else {
                cmd.store();
                createSuccessMessage(request, getSuccessKey(),
                        cmd.getKickstartData().getLabel());
                setupFormValues(form);
            }

        }
        // display the ranges (if any), and allow user to add ranges (dynaform)
        else {
            setupFormValues(form);
        }

        List displayList = new LinkedList();
        displayList = cmd.getDisplayRanges();

        //Create the kickstart urls to display

        String host = helper.getKickstartHost();
        KickstartUrlHelper urlHelper = new KickstartUrlHelper(cmd.getKickstartData(), host);

        request.setAttribute(URL, urlHelper.getKickstartFileUrl());
        request.setAttribute(URLRANGE, urlHelper.getKickstartFileUrlIpRange());

        request.setAttribute(RANGES, displayList);

        return strutsDelegate.forwardParams(mapping.findForward("default"),
                params);

    }

    /**
     *
     * @return i18n string for iprange success
     */
    private String getSuccessKey() {
        return "kickstart.iprange_add.success";
    }

    /**
     *
     * @param form DynaAction Form coming in
     * @param cmd Command for KS
     * @return Validation Error if occurs
     */
    private ValidatorError processFormValues(DynaActionForm form,
            KickstartIpCommand cmd) {

        ValidatorError retval = null;

        Long [] octet1 = { ((Long)form.get(OCTET1A)),
                           ((Long)form.get(OCTET1B)),
                           ((Long)form.get(OCTET1C)),
                           ((Long)form.get(OCTET1D)), };
        Long [] octet2 = { ((Long)form.get(OCTET2A)),
                           ((Long)form.get(OCTET2B)),
                           ((Long)form.get(OCTET2C)),
                           ((Long)form.get(OCTET2D)), };

        if (!cmd.validateIpRange(octet1, octet2)) {
            retval = new ValidatorError("kickstart.iprange_validate.failure");
        }
        else if (!cmd.addIpRange(octet1, octet2)) {

            retval = new ValidatorError("kickstart.iprange_conflict.failure",
                    cmd.getKickstartData().getLabel());
        }

        return retval;
    }

    /**
     * @param form DynaActionForm
     */
    private void setupFormValues(DynaActionForm form) {
        form.set(OCTET1A, new Long(0));
        form.set(OCTET1B, new Long(0));
        form.set(OCTET1C, new Long(0));
        form.set(OCTET1D, new Long(0));
        form.set(OCTET2A, new Long(0));
        form.set(OCTET2B, new Long(0));
        form.set(OCTET2C, new Long(0));
        form.set(OCTET2D, new Long(0));
    }

}
