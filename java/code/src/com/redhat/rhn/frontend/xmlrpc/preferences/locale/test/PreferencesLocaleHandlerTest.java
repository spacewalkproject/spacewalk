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
package com.redhat.rhn.frontend.xmlrpc.preferences.locale.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.frontend.xmlrpc.InvalidLocaleCodeException;
import com.redhat.rhn.frontend.xmlrpc.InvalidTimeZoneException;
import com.redhat.rhn.frontend.xmlrpc.preferences.locale.PreferencesLocaleHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;


public class PreferencesLocaleHandlerTest extends BaseHandlerTestCase {

    private PreferencesLocaleHandler handler = new PreferencesLocaleHandler();
    
    public void testListTimeZone() {
        Object[] tzs = handler.listTimeZones();
        assertNotNull(tzs);
        assertTrue("TimeZone list is empty", tzs.length != 0);
        assertEquals(RhnTimeZone.class, tzs[0].getClass());
    }
    
    public void testSetTimeZoneInvalidId() {
        try {
            handler.setTimeZone(adminKey, admin.getLogin(), 0);
            fail("Expected an exception for timezoneid = 0");
        }
        catch (InvalidTimeZoneException itze) {
            // expected exception
        }
    }
    
    public void testSetTimeZone() {
        Object[] tzs = handler.listTimeZones();
        assertNotNull(tzs);
        assertTrue(tzs.length != 0);
        RhnTimeZone tz = (RhnTimeZone)tzs[0];

        assertEquals(1,
           handler.setTimeZone(adminKey, admin.getLogin(), tz.getTimeZoneId()));
        
        RhnTimeZone usersTz = admin.getTimeZone();
        assertNotNull(usersTz);
        assertEquals(tz.getTimeZoneId(), usersTz.getTimeZoneId());
    }
    
    public void testListLocales() {
        Object[] o = handler.listLocales();
        assertNotNull(o);
        String[] locales = Config.get().getStringArray("web.supported_locales");
        assertNotNull(locales);
        assertEquals(locales.length, o.length);
    }
    
    public void testSetLocaleInvalidLocale() {
        try {
            handler.setLocale(adminKey, admin.getLogin(), "rd_NK");
            fail("rd_NK should be an invalid locale");
        }
        catch (InvalidLocaleCodeException ilce) {
            // expected exception
        }
        
        try {
            handler.setLocale(adminKey, admin.getLogin(), null);
            fail("null should be an invalid locale");
        }
        catch (InvalidLocaleCodeException ilce) {
            // expected exception
        }
    }
    
    public void testSetLocale() {
        String l = admin.getPreferredLocale();
        assertNull(l);
        System.out.println(l);
        handler.setLocale(adminKey, admin.getLogin(), "en_US");
        assertEquals("en_US", admin.getPreferredLocale());        
    }
}
