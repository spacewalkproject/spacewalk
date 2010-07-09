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
package com.redhat.rhn.frontend.servlets;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.manager.session.SessionManager;

import org.apache.commons.lang.StringUtils;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;


/**
 * A PxtCookieManager creates, retrieves, and parses pxt cookies. For a general overview of
 * the pxt cookie, see
 * <a href="http://wiki.rhndev.redhat.com/wiki/SSO#What_is_the_pxt_cookie.3F">
 *   What is the pxt cookie?
 * </a>
 *
 * <br/><br/>
 *
 * This class is thread-safe.
 *
 * @version $Rev$
 */
public class PxtCookieManager {

    /**
     * The name of the pxt session cookie
     */
    public static final String PXT_SESSION_COOKIE_NAME = "pxt-session-cookie";

    public static final String DEFAULT_PATH = "/";

    /**
     * Creates a new pxt cookie with the specified session id and timeout.
     *
     * @param pxtSessionId The id of the pxt session for which the cookie is being created.
     *
     * @param request The current request.
     *
     * @param timeout The max age of the cookie in seconds.
     *
     * @return a new pxt cookie.
     */
    public Cookie createPxtCookie(Long pxtSessionId, HttpServletRequest request,
            int timeout) {

        String cookieName = getCookieName(request);
        String cookieValue = pxtSessionId + "x" +
            SessionManager.generateSessionKey(pxtSessionId.toString());

        Cookie pxtCookie = new Cookie(cookieName, cookieValue);
        // BZ #454876
        // when not using setDomain, default "Host" will be set for the cookie
        // there's no need to use domain and besides that it causes trouble,
        //  when accessing the server within the local network (without FQDN)
        // pxtCookie.setDomain(request.getServerName());
        pxtCookie.setMaxAge(timeout);
        pxtCookie.setPath(DEFAULT_PATH);
        pxtCookie.setSecure(ConfigDefaults.get().isSSLAvailable());

        return pxtCookie;
    }

    /**
     * Retrieves the pxt cookie from the request if one is included in the request.
     *
     * @param request The current request.
     *
     * @return The pxt cookie included in the request, or <code>null</code> if no cookie is
     * found.
     */
    public Cookie getPxtCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();

        if (cookies == null) {
            return null;
        }

        String pxtCookieName = getCookieName(request);

        for (int i = 0; i < cookies.length; ++i) {
            if (pxtCookieName.equals(cookies[i].getName())) {
                return cookies[i];
            }
        }

        return null;
    }

    /**
     * Determines the pxt cookie name. The name will include the server name from the
     * request if the <code>web.allow_pxt_personalities</code> property in rhn.conf is set.
     *
     * @param request The current request.
     *
     * @return The pxt cookie name.
     */
    protected String getCookieName(HttpServletRequest request) {
        Config c = Config.get();
        int personality = c.getInt(ConfigDefaults.WEB_ALLOW_PXT_PERSONALITIES);

        if (personality > 0) {
            String[] name = StringUtils.split(request.getServerName(), '.');
            return name[0] + "-" + PXT_SESSION_COOKIE_NAME;
        }

        return PXT_SESSION_COOKIE_NAME;
    }

}
