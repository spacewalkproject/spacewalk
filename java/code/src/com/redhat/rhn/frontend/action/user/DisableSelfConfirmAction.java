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

import com.redhat.rhn.common.security.user.StateChangeException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DisableSelfConfirmAction
 * @version $Rev$
 */
public class DisableSelfConfirmAction extends RhnAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
        throws Exception {

        RequestContext requestContext = new RequestContext(request);

        ActionForward forward = null;
        DynaActionForm f = (DynaActionForm)form;
        User user = requestContext.getLoggedInUser();

        if (!isSubmitted(f)) {
            forward =  getStrutsDelegate().forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }
        else {
            try {
                UserManager.disableUser(user, user);
            }
            catch (StateChangeException e) {
                ActionErrors errors = new ActionErrors();
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage(e.getMessage()));
                addErrors(request, errors);
                return mapping.findForward("failure");
            }

            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("account.disabled"));
            getStrutsDelegate().saveMessages(request, msg);
            forward = mapping.findForward("logout");
        }

        return forward;
    }

}
