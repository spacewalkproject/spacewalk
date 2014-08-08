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
package com.redhat.rhn.frontend.action.token;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.token.ActivationKeyCloneCommand;
import com.redhat.rhn.domain.token.ActivationKey;
import org.apache.commons.lang.StringUtils;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

//import java.util.HashMap;
//import java.util.Map;


/**
 * KickstartCloneAction - action for cloning a KS. Can't use BaseKickstartEdit
 * action because we have to forward to a different Kickstart vs the one we
 * started with.
 * @version $Rev: 1 $
 */
public class ActivationKeyCloneAction extends RhnAction {

    /** {@inheritDoc} */
    @Override
    public final ActionForward execute(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {

        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        if (isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, form);
            if (!errors.isEmpty()) {
                strutsDelegate.saveMessages(request, errors);
            }
            else {
                String cloneDescription = form.getString("label");
                String sdesc = (String) request.getSession().getAttribute(
                        "sdesc");
                if (StringUtils.isBlank(cloneDescription)) {
                    cloneDescription = "clone-" + sdesc;
                }
                String sak = (String) request.getSession().getAttribute("sak");
                ActivationKeyCloneCommand cak = new ActivationKeyCloneCommand(
                        ctx.getCurrentUser(), sak, cloneDescription);

                createSuccessMessage(request, "activation-key.java.cloned",
                        sdesc);
                return mapping.findForward("success");
            }
        }

        ActivationKey key = ctx.lookupAndBindActivationKey();
        request.setAttribute("stoken", key.getToken());
        request.getSession().setAttribute("sak", key.getKey());
        request.getSession().setAttribute("sdesc", key.getNote());
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
