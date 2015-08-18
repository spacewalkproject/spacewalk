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
package com.redhat.rhn.frontend.security;


import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;

import org.apache.commons.collections.set.UnmodifiableSet;
import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.util.Set;
import java.util.TreeSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PxtAuthenticationService
 * @version $Rev$
 */
public class PxtAuthenticationService extends BaseAuthenticationService {

    public static final long MAX_URL_LENGTH = 2048;

    private static final Set UNPROTECTED_URIS;
    private static final Set POST_UNPROTECTED_URIS;
    private static final Set LOGIN_URIS;

    static {
        TreeSet set = new TreeSet();
        set.add("/rhn/Login");
        set.add("/rhn/ReLogin");
        set.add("/rhn/newlogin/");

        LOGIN_URIS = UnmodifiableSet.decorate(set);

        set = new TreeSet(set);
        set.add("/rhn/rpc/api");
        set.add("/rhn/help/");
        set.add("/rhn/apidoc");
        set.add("/rhn/kickstart/DownloadFile");
        set.add("/rhn/ty/TinyUrl");
        set.add("/css");
        set.add("/img");
        set.add("/favicon.ico");
        set.add("/rhn/common/DownloadFile");
        // password-reset-link destination
        set.add("/rhn/ResetLink");
        set.add("/rhn/ResetPasswordSubmit");

        UNPROTECTED_URIS = UnmodifiableSet.decorate(set);

        set = new TreeSet(set);
        set.add("/rhn/common/DownloadFile");
        // search (safe to be unprotected, since it has no modifying side-effects)
        set.add("/rhn/Search.do");

        POST_UNPROTECTED_URIS = UnmodifiableSet.decorate(set);
    }

    private PxtSessionDelegate pxtDelegate;

    protected PxtAuthenticationService() {
    }

    @Override
    protected Set getLoginURIs() {
        return LOGIN_URIS;
    }

    @Override
    protected Set getUnprotectedURIs() {
        return UNPROTECTED_URIS;
    }

    @Override
    protected Set getPostUnprotectedURIs() {
        return POST_UNPROTECTED_URIS;
    }

    /**
     * "Wires up" the PxtSessionDelegate that this service object will use. Note that this
     * method should be invoked by a factory that creates instances of this class, such as
     * a dependency injection container...should one be used (/me/hopes/).
     *
     * @param delegate The PxtSessionDelegate to be used.
     */
    public void setPxtSessionDelegate(PxtSessionDelegate delegate) {
        pxtDelegate = delegate;
    }

    /**
     * {@inheritDoc}
     */
    public boolean skipCsfr(HttpServletRequest request) {
        return requestURIdoesLogin(request) || requestPostCsfrWhitelist(request);
    }

    /**
     * {@inheritDoc}
     */
    public boolean validate(HttpServletRequest request, HttpServletResponse response) {
        if (requestURIRequiresAuthentication(request)) {
            if (isAuthenticationRequired(request)) {
                invalidate(request, response);
                return false;
            }
            // If URL requires auth and we are authenticated refresh the session.
            // We don't refresh when the URL doesn't require auth because
            // that may invalidate our old session
            pxtDelegate.refreshPxtSession(request, response);
        }
        return true;
    }

    private boolean isAuthenticationRequired(HttpServletRequest request) {
        return (!pxtDelegate.isPxtSessionKeyValid(request) ||
               pxtDelegate.isPxtSessionExpired(request) ||
               pxtDelegate.getWebUserId(request) == null);
    }

    /**
     * {@inheritDoc}
     */
    public void redirectToLogin(HttpServletRequest request, HttpServletResponse response)
        throws ServletException {

        try {
            StringBuffer redirectURI = new StringBuffer(request.getRequestURI());
            String params = ServletUtils.requestParamsToQueryString(request);
            // don't want to put the ? in the url if there are no params
            if (!StringUtils.isEmpty(params)) {
                redirectURI.append("?");
                redirectURI.append(params);
            }
            String urlBounce = redirectURI.toString();
            if (redirectURI.length() > MAX_URL_LENGTH) {
                urlBounce = LoginAction.DEFAULT_URL_BOUNCE;
            }

            // in case of logout, let's redirect to Login2.go
            // not to be immediately logged in via Kerberos ticket
            if (urlBounce.equals("/rhn/")) {
                response.sendRedirect("/rhn/Login2.do");
                return;
            }
            response.sendRedirect("/rhn/Login.do?url_bounce=" + urlBounce +
                    "&request_method=" + request.getMethod());
        }
        catch (IOException e) {
            throw new ServletException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void redirectTo(HttpServletRequest request, HttpServletResponse response,
            String path)
        throws ServletException {
            response.setHeader("Location", path);
            response.setStatus(response.SC_SEE_OTHER);
    }

    /**
     * {@inheritDoc}
     */
    public void invalidate(HttpServletRequest request, HttpServletResponse response) {
        pxtDelegate.invalidatePxtSession(request, response);
    }
}
