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
package com.redhat.rhn.frontend.action.user.test;

import com.redhat.rhn.frontend.action.user.UserLocalePrefAction;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import java.util.List;
import java.util.Map;

public class UserLocalePrefTest extends RhnMockStrutsTestCase {

    public void testDisplay() {
        setRequestPathInfo("/account/LocalePreferences.do");
        actionPerform();
        Map locales = (Map) getRequest().getAttribute("supportedLocales");
        List timezones = (List) getRequest().getAttribute("timezones");
        assertTrue(locales != null);
        assertTrue(timezones != null);
        assertTrue(locales.size() > 0);
        assertTrue(timezones.size() > 0);
    }

    public void testSubmit() {
        clearRequestParameters();
        List timezones = UserManager.lookupAllTimeZones();
        setRequestPathInfo("/account/LocalePreferences.do");
        addRequestParameter(UserLocalePrefAction.SUBMITTED, "true");
        addRequestParameter("preferredLocale", "pt_BR");
        addRequestParameter("timezone", timezones.get(0).toString());
        actionPerform();
        verifyNoActionErrors();
    }
}
