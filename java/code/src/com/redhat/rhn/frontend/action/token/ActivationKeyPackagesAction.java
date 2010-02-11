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
package com.redhat.rhn.frontend.action.token;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.token.ActivationKeyPackagesCommand;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ActivationKeyPackagesAction
 * @version $Rev: 1 $
 */
public class ActivationKeyPackagesAction extends RhnAction {
    public static final String PACKAGES = "packages";
    public static final String DESCRIPTION = "description";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        ActionErrors errors = new ActionErrors();
        DynaActionForm form = (DynaActionForm)formIn;
        Map params = makeParamMap(request);
        RequestContext ctx = new RequestContext(request);

        // keep the token id
        if (ctx.getParam(RequestContext.TOKEN_ID, true) != null) {
            params.put(RequestContext.TOKEN_ID, ctx.getParam(
                    RequestContext.TOKEN_ID, true));
        }

        ActivationKey key = ctx.lookupAndBindActivationKey();
        ActivationKeyPackagesCommand cmd = new ActivationKeyPackagesCommand(key);

        request.setAttribute(DESCRIPTION, key.getNote());

        if (!isSubmitted(form)) {
            // setup form
            setupForm(form, cmd);
            return getStrutsDelegate().forwardParams(
                    mapping.findForward("default"),
                    request.getParameterMap());
        }


        ValidatorError ve = edit(form, cmd);
        if (ve != null) {
            ValidatorError[] verr = {ve};
            getStrutsDelegate().saveMessages(request,
                    RhnValidationHelper.validatorErrorToActionErrors(verr));
        }
        else {
            cmd.store();

            ActionMessages messages = new ActionMessages();
            ActionMessage message =  new ActionMessage("activation-key.java.modified",
                    key.getNote());
            messages.add(ActionMessages.GLOBAL_MESSAGE, message);
            getStrutsDelegate().saveMessages(ctx.getRequest(), messages);
        }

        return getStrutsDelegate().forwardParams(mapping.findForward("success"), params);
    }

    /**
     * {@inheritDoc}
     */
    protected void setupForm(DynaActionForm form, ActivationKeyPackagesCommand cmd) {
        form.set(PACKAGES, cmd.populatePackages());
    }

    /**
     * {@inheritDoc}
     */
    protected ValidatorError edit(DynaActionForm form,
            ActivationKeyPackagesCommand cmd) {
        return cmd.parseAndUpdatePackages(form.getString(PACKAGES));
    }
}
