/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessages;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * LoginSetupAction
 */
public class LoginSetupAction extends RhnAction {

    private static Logger log = Logger.getLogger(LoginSetupAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
        ActionForm form, HttpServletRequest request,
        HttpServletResponse response) {

        request.setAttribute("schemaUpgradeRequired",
                LoginHelper.isSchemaUpgradeRequired().toString());

        if (!UserManager.satelliteHasUsers()) {
            return mapping.findForward("needuser");
        }

        if (AclManager.hasAcl("user_authenticated()", request, null)) {
            return mapping.findForward("loggedin");
        }

        ActionErrors errors = new ActionErrors();
        ActionMessages messages = new ActionMessages();
        User remoteUser =
                LoginHelper.checkExternalAuthentication(request, messages, errors);
        // save stores msgs into the session (works for redirect)
        saveMessages(request, messages);
        addErrors(request, errors);
        if (errors.isEmpty() && remoteUser != null) {
            if (LoginHelper.successfulLogin(request, response, remoteUser)) {
                return null;
            }
            return mapping.findForward("loggedin");
        }

        // store url_bounce set by pxt pages
        RequestContext ctx = new RequestContext(request);
        ctx.copyParamToAttributes("url_bounce");
        ctx.copyParamToAttributes("request_method");

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
