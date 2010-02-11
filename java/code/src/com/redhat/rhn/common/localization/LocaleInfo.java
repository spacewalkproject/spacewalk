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
package com.redhat.rhn.common.localization;

import java.util.Locale;

/**
 * Links up potential locales with RHN supported ones
 * 
 * @version $Rev $
 */
class LocaleInfo {
    
    private String locale;
    private Locale supportedLocale;

    LocaleInfo(String localeIn) {
        this.locale = localeIn;
        this.supportedLocale = makeLocale(localeIn);
    }
    
    LocaleInfo(String localeIn, String supportedLocaleIn) {
        this.locale = localeIn;
        this.supportedLocale = makeLocale(supportedLocaleIn);
    }
    
    public boolean isAlias() {
        return !locale.equals(supportedLocale.toString());
    }
    
    String getLocale() {
        return locale;
    }
    
    Locale getSupportedLocale() {
        return supportedLocale;
    }
    
    private Locale makeLocale(String localeIn) {
        String[] parts = localeIn.split("_");
        switch(parts.length) {
            case 1:
                return new Locale(parts[0]);
            case 2:
                return new Locale(parts[0], parts[1]);
            case 3:
                return new Locale(parts[0], parts[1], parts[2]);
            default:
                return null;
        }
    }
}
