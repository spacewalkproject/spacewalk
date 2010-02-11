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

package com.redhat.rhn.frontend.context;

import com.redhat.rhn.common.localization.LocalizationService;

import java.util.Locale;
import java.util.TimeZone;

/**
 * Context class used to get information about a given Thread's 
 * decorations starting with Locale.  This class allows global
 * static access to the current running Thread's Context object.
 * If one isn't found an Exception is thrown.
 * @version $Rev$
 */
public class Context {
    
    // The locale associated with the given context.
    private Locale locale;
    private Locale originalLocale;
    private String activeLocaleLabel;
    private TimeZone timezone;
    
    private static ThreadLocal currentContext = new ThreadLocal();

    private Context() {
    }

    /**
     * set the Locale for this thread 
     * @param localeIn Locale for this thread.
     */
    public void setLocale(Locale localeIn) {
        this.locale = localeIn;
        LocalizationService ls = LocalizationService.getInstance();

        if (ls.hasMessage("preferences.jsp.lang." + localeIn.toString())) {
            activeLocaleLabel = ls.getMessage("preferences.jsp.lang." + 
                    localeIn.toString(), localeIn);
        }
        else {
            // default to en_US
            // the localeIn will be default to en_US if the LS doesn't
            // find a supported bundle, so we're safe there.
            activeLocaleLabel = ls.getMessage("preferences.jsp.lang.en_US", localeIn);
        }
    }
    
    /**
     * The localized display "label" for the currently
     * active locale
     * @return localized string
     */
    public String getActiveLocaleLabel() {
        return this.activeLocaleLabel;
    }

    /**
     * get the locale for the current Thread 
     * or return the default locale if one isn't set
     * @return current locale for Thread.
     */
    public Locale getLocale() {
        if (this.locale == null) {
            return LocalizationService.DEFAULT_LOCALE;
        }
        else {
            return this.locale;
        }
    }

    /**
     * Stores the original locale for a given request
     * This _might not_ be the same locale which is 
     * ultimately used for translating application text
     * @param localeIn locale
     */
    public void setOriginalLocale(Locale localeIn) {
        originalLocale = localeIn;
    }

    /**
     * Returns the original locale for a given request
     * This _might not_ be the same locale which is 
     * ultimately used for translating application text
     * @return Locale
     */
    public Locale getOriginalLocale() {
        return originalLocale;
    }

    /**
     * @return Returns the timezone.
     */
    public TimeZone getTimezone() {
        return timezone;
    }

    /**
     * @param timezoneIn The timezone to set.
     */
    public void setTimezone(TimeZone timezoneIn) {
        this.timezone = timezoneIn;
    }

    /** 
     * Get the current context for the current 
     * running Thread.  This may return null
     * @return Current context.
     */
    public static Context getCurrentContext() {
        
        Context retval = (Context) currentContext.get();
        if (retval == null) {
            currentContext.set(new Context());
            retval = (Context) currentContext.get();
        }
        return retval;
    }

    /**
     * Frees the Context object assigned to the 
     * executing thread
     */
    public static void freeCurrentContext() {
        currentContext.set(null);
    }
    
}
