/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * User locale override stuff
 *
 * @version $Rev $
 */
public class UserLocalePrefAction extends BaseUserSetupAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        if (request.getRequestURL().toString().indexOf("/rhn/users/") != -1 &&
                request.getParameter("uid") == null) {
            throw new BadParameterException(
                    "Invalid [null] value for parameter uid");
        }
        DynaActionForm dynaForm = (DynaActionForm) form;
        RequestContext ctx = new RequestContext(request);
        User currentUser = lookupUser(ctx, dynaForm);
        ActionForward retval = null;
        if (isSubmitted(dynaForm)) {
            retval =  save(mapping, ctx, currentUser, dynaForm);
        }
        else {
            retval = display(mapping, ctx, currentUser, dynaForm);
        }
        return retval;
    }

    private ActionForward save(ActionMapping mapping, RequestContext ctx,
                User currentUser, DynaActionForm form) {
        String preferredLocale = form.getString("preferredLocale");
        if (preferredLocale != null && preferredLocale.equals("none")) {
            preferredLocale = null;
        }
        currentUser.setTimeZone(UserManager.getTimeZone(
                ((Integer) form.get("timezone")).intValue()));
        currentUser.setPreferredLocale(preferredLocale);
        UserManager.storeUser(currentUser);
        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("message.preferencesModified"));
        getStrutsDelegate().saveMessages(ctx.getRequest(), msgs);
        if (ctx.getRequest().getParameter("uid") != null) {
            ActionForward display = mapping.findForward("display");
            ActionForward fwd = new ActionForward();
            fwd.setPath(display.getPath() + "?uid=" + currentUser.getId());
            fwd.setRedirect(true);
            return fwd;
        }
        return mapping.findForward("display");
    }

    private ActionForward display(ActionMapping mapping, RequestContext ctx,
            User currentUser, DynaActionForm form) {
        ctx.getRequest().setAttribute("targetuser", currentUser);
        ctx.getRequest().setAttribute("supportedLocales", buildImageMap());
        ctx.getRequest().setAttribute("noLocale", buildNoneLocale());
        setCurrentLocale(ctx, currentUser);
        ctx.getRequest().setAttribute("timezones", getTimeZones());
        if (currentUser.getTimeZone() != null) {
            form.set("timezone",
                    new Integer(currentUser.getTimeZone().getTimeZoneId()));
        }
        else {
            form.set("timezone", new Integer(UserManager.getDefaultTimeZone()
                    .getTimeZoneId()));
        }
        form.set("uid", currentUser.getId());

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private User lookupUser(RequestContext ctx, DynaActionForm form) {
        User retval = null;
        if (form.get("uid") != null) {
            Long uid = (Long) form.get("uid");
            retval = UserManager.lookupUser(ctx.getCurrentUser(), uid);
        }
        else {
            retval = ctx.getCurrentUser();
        }
        return retval;
    }
}
