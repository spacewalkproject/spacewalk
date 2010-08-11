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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.kickstart.KickstartCloneCommand;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartCloneAction - action for cloning a KS.  Can't use BaseKickstartEdit action
 * because we have to forward to a different Kickstart vs the one we started with.
 * @version $Rev: 1 $
 */
public class KickstartCloneAction extends RhnAction {

    /** {@inheritDoc} */
    @Override
    public final ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);

        StrutsDelegate strutsDelegate = getStrutsDelegate();

        KickstartCloneCommand cmd =
            new KickstartCloneCommand(ctx.getRequiredParam(RequestContext.KICKSTART_ID),
                ctx.getCurrentUser(), form.getString(RequestContext.LABEL));

        request.setAttribute(RequestContext.KICKSTART, cmd.getKickstartData());

        if (isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, form);

            if (!errors.isEmpty()) {
                strutsDelegate.saveMessages(request, errors);
            }
            else {
                String label = form.getString("label");
                KickstartBuilder builder = new KickstartBuilder(ctx.getLoggedInUser());
                // Validate the label
                try {
                    builder.validateNewLabel(label);
                    ValidatorError ve = cmd.store();

                    if (ve != null) {
                        ValidatorError[] verr = {ve};
                        strutsDelegate.saveMessages(request,
                                RhnValidationHelper.validatorErrorToActionErrors(verr));
                    }
                    else {
                        createSuccessMessage(request, "kickstart.clone.success", null);
                        request.setAttribute(RequestContext.KICKSTART,
                                cmd.getClonedKickstart());
                        Map params = new HashMap();
                        params.put(RequestContext.KICKSTART_ID,
                                cmd.getClonedKickstart().getId());
                        return strutsDelegate.forwardParams(mapping.findForward("success"),
                                params);
                    }
                }
                catch (ValidatorException ve) {
                    getStrutsDelegate().saveMessages(request, ve.getResult());
                    return mapping.findForward("default");
                }
            }
        }

        form.set(RequestContext.LABEL, cmd.getNewLabel());
        return mapping.findForward("default");
    }

    private boolean alreadyExists(String label, User user) {
        long oid = user.getOrg().getId();
        KickstartData d =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(label, oid);
        return (d != null);
    }
}
