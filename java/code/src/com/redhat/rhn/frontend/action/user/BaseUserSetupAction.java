/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.user.UserManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * User locale override stuff
 *
 * @version $Rev $
 */
public class BaseUserSetupAction extends RhnAction {

    /**
     * Builds LangDisplayBean for none locale
     * @return LangDisplayBean
     */
    public LangDisplayBean buildNoneLocale() {
        LocalizationService ls =
            LocalizationService.getInstance();
        LangDisplayBean ldb = new LangDisplayBean();
        ldb.setLanguageCode("none");
        ldb.setLocalizedName(ls.getMessage("preferences.jsp.lang.none"));
        return ldb;
    }

    /**
     * Sets user's locale to the provided request context
     * @param ctx RequestContext
     * @param user User
     */
    public void setCurrentLocale(RequestContext ctx, User user) {
        String userLocale = user.getPreferredLocale();

        // If user has locale set, then just use that
        if (userLocale != null) {
            ctx.getRequest().setAttribute("currentLocale", userLocale);
        }
        else {
            ctx.getRequest().setAttribute("currentLocale", "none");
        }
    }

    /**
     * Builds Map of configured locales and locale image uris
     * @return Map of configured locales and locale image uris
     */
    public Map buildImageMap() {
        Map retval = new LinkedHashMap();
        LocalizationService ls = LocalizationService.getInstance();
        List locales = ls.getConfiguredLocales();
        for (Iterator iter = locales.iterator(); iter.hasNext();) {
            String locale = (String) iter.next();
            LangDisplayBean ldb = new LangDisplayBean();
            ldb.setLanguageCode(locale);
            ldb.setLocalizedName(ls.getMessage("preferences.jsp.lang." + locale));
            retval.put(locale, ldb);
        }
        return retval;
    }

    /**
     * Lists available time zones
     * @return List of available time zones
     */
    public List getTimeZones() {
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
}
