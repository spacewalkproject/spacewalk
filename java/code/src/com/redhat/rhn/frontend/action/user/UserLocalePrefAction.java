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
import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * User locale override stuff
 *
 * @version $Rev $
 */
public class UserLocalePrefAction extends RhnAction {

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
        else {
            return mapping.findForward("display");
        }
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

        return mapping.findForward("default");
    }

    private LangDisplayBean buildNoneLocale() {
        LocalizationService ls =
            LocalizationService.getInstance();
        LangDisplayBean ldb = new LangDisplayBean();
        ldb.setImageUri("");
        ldb.setLanguageCode("none");
        ldb.setLocalizedName(ls.getMessage("preferences.jsp.lang.none"));
        return ldb;
    }

    private void setCurrentLocale(RequestContext ctx, User user) {
        String userLocale = user.getPreferredLocale();

        // If user has locale set, then just use that
        if (userLocale != null) {
            ctx.getRequest().setAttribute("currentLocale", userLocale);
        }
        else {
            ctx.getRequest().setAttribute("currentLocale", "none");
        }
    }

    private Map buildImageMap() {
        Map retval = new LinkedHashMap();
        LocalizationService ls = LocalizationService.getInstance();
        List locales = ls.getConfiguredLocales();
        for (Iterator iter = locales.iterator(); iter.hasNext();) {
            String locale = (String) iter.next();
            StringBuffer buf = new StringBuffer();
            buf.append("/img/i18n/").append(locale);
            buf.append(".gif");
            LangDisplayBean ldb = new LangDisplayBean();
            ldb.setImageUri(buf.toString());
            ldb.setLanguageCode(locale);
            ldb.setLocalizedName(ls.getMessage("preferences.jsp.lang." + locale));
            retval.put(locale, ldb);
        }
        return retval;
    }

    private List getTimeZones() {
        List dataList = UserManager.lookupAllTimeZones();
        List displayList = new ArrayList();
        for (int i = 0; i < dataList.size(); i++) {
            String display = LocalizationService.getInstance()
                .getMessage(((RhnTimeZone)dataList.get(i)).getOlsonName());
            String value = String.valueOf(((RhnTimeZone)dataList.get(i)).getTimeZoneId());
            displayList.add(createDisplayMap(display, value));
        }
        return displayList;
    }

    private Map createDisplayMap(String display, String value) {
        Map selection = new HashMap();
        selection.put("display", display);
        selection.put("value", value);
        return selection;
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
