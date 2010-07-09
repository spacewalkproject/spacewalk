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
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.SELinuxMode;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.SystemDetailsCommand;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Handles display and update of Kickstart -> System Details
 *
 * @version $Rev $
 */
public class SystemDetailsEditAction extends RhnAction {

    public static final String SE_LINUX_PARAM = "selinuxMode";
    public static final String REGISTRATION_TYPE_PARAM = "registrationType";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
        throws Exception {
           RequestContext context = new RequestContext(request);
           User user = context.getLoggedInUser();

        if (!user.hasRole(RoleFactory.ORG_ADMIN) &&
                    !user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            // Throw an exception with a nice error message so the user
            // knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(
                    "Only Org Admins or Configuration Admins can modify kickstarts");
            pex.setLocalizedTitle(ls
                    .getMessage("permission.jsp.summary.acl.header"));
            pex.setLocalizedSummary(ls
                    .getMessage("permission.jsp.summary.acl.reason5"));
            throw pex;
        }

        DynaActionForm dynaForm = (DynaActionForm) form;
        if (isSubmitted(dynaForm)) {
            return updateSystemDetails(mapping, dynaForm, request, response);
        }
        else {
            return viewSystemDetails(mapping, dynaForm, request, response);
        }
    }

    /**
     * Sets up the form bean for viewing
     * @param mapping Struts action mapping
     * @param dynaForm related form instance
     * @param request related request
     * @param response related response
     * @return jsp to render
     * @throws Exception when error occurs - this should be handled by the app
     * framework
     */
    public ActionForward viewSystemDetails(ActionMapping mapping,
            DynaActionForm dynaForm, HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        RequestContext ctx = new RequestContext(request);
        KickstartData ksdata = lookupKickstart(ctx, dynaForm);
        prepareForm(dynaForm, ksdata, ctx);
        request.setAttribute(RequestContext.KICKSTART, ksdata);
        return mapping.findForward("display");
    }

    /**
     * Processes form submission and displays updated data
     * @param mapping Struts action mapping
     * @param dynaForm related form instance
     * @param request related request
     * @param response related response
     * @return jsp to render
     * @throws Exception when error occurs - this should be handled by the app
     * framework
     */
    public ActionForward updateSystemDetails(ActionMapping mapping,
            DynaActionForm dynaForm, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        RequestContext ctx = new RequestContext(request);
        KickstartData ksdata = lookupKickstart(ctx, dynaForm);
        request.setAttribute("ksdata", ksdata);

        try {
            transferEdits(dynaForm, ksdata, ctx);
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "kickstart.systemdetails.update.confirm"));
            getStrutsDelegate().saveMessages(request, msg);
            Map params = new HashMap();
            params.put("ksid", ctx
                    .getRequiredParam(RequestContext.KICKSTART_ID));
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("display"), params);
        }
        catch (ValidatorException ve) {
            RhnValidationHelper.setFailedValidation(request);
            getStrutsDelegate().saveMessages(request, ve.getResult());
            request.setAttribute(RequestContext.KICKSTART, ksdata);
            return mapping.findForward("display");
        }

    }

    protected KickstartData lookupKickstart(RequestContext ctx,
            DynaActionForm form) {
        KickstartEditCommand cmd = new KickstartEditCommand(ctx
                .getRequiredParam(RequestContext.KICKSTART_ID), ctx
                .getCurrentUser());
        return cmd.getKickstartData();
    }

    private void transferEdits(DynaActionForm form, KickstartData ksdata,
            RequestContext ctx) {
        SystemDetailsCommand command = new SystemDetailsCommand(ksdata, ctx
                .getLoggedInUser());

        transferRootPasswordEdits(form, command);
        if (!ksdata.isLegacyKickstart()) {
            command.setMode(SELinuxMode.lookup(form.getString(SE_LINUX_PARAM)));
        }
        command.setRegistrationType(form.getString(REGISTRATION_TYPE_PARAM));
        transferFlagEdits(form, command);
        command.store();
    }

    private void prepareForm(DynaActionForm dynaForm, KickstartData ksdata,
            RequestContext ctx) {
        prepareSELinuxConfig(dynaForm, ksdata);
        prepareRegistrationTypeConfig(dynaForm, ksdata, ctx.getLoggedInUser());
        prepareFlags(dynaForm, ksdata);
        dynaForm.set("submitted", Boolean.TRUE);
    }

    private void prepareSELinuxConfig(DynaActionForm dynaForm,
            KickstartData ksdata) {
        dynaForm.set(SE_LINUX_PARAM, ksdata.getSELinuxMode().getValue());
    }
    private void prepareRegistrationTypeConfig(DynaActionForm dynaForm,
            KickstartData ksdata, User user) {
        dynaForm.set(REGISTRATION_TYPE_PARAM,
                ksdata.getRegistrationType(user).getType());
    }


    private void prepareFlags(DynaActionForm dynaForm, KickstartData ksdata) {
        if (ksdata.isConfigManageable()) {
            dynaForm.set("configManagement", "on");
        }
        else {
            dynaForm.set("configManagement", null);
        }
        if (ksdata.isRemoteCommandable()) {
            dynaForm.set("remoteCommands", "on");
        }
        else {
            dynaForm.set("remoteCommands", null);
        }
    }

    private void transferRootPasswordEdits(DynaActionForm form,
            SystemDetailsCommand command) {
        String rootPw = form.getString("rootPassword");
        String rootPwConfirm = form.getString("rootPasswordConfirm");
        if (!StringUtils.isBlank(rootPw) || !StringUtils.isBlank(rootPwConfirm)) {
            command.updateRootPassword(rootPw, rootPwConfirm);
        }
    }

    private void transferFlagEdits(DynaActionForm form,
            SystemDetailsCommand command) {
        command.enableConfigManagement(BooleanUtils.toBoolean(form
                .getString("configManagement")));
        command.enableRemoteCommands(BooleanUtils.toBoolean(form
                .getString("remoteCommands")));

    }
}
