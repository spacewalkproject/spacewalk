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
package com.redhat.rhn.frontend.security;


import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;

import org.apache.commons.collections.set.UnmodifiableSet;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.util.Set;
import java.util.TreeSet;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PxtAuthenticationService
 * @version $Rev$
 */
public class PxtAuthenticationService extends BaseAuthenticationService {

    public static final long MAX_URL_LENGTH = 2048;

    private static final Logger LOG = Logger.getLogger(PxtAuthenticationService.class);

    private static final Set UNPROTECTED_URIS;

    static {
        TreeSet set = new TreeSet();
        set.add("/rhn/Login");
        set.add("/rhn/ReLogin");
        set.add("/rhn/newuser");
        set.add("/rhn/rpc/api");
        set.add("/rhn/servlet/");
        set.add("/rhn/services/");
        set.add("/rhn/help/");
        set.add("/rhn/newlogin/");
        set.add("/rhn/tnc/");       //TODO should tnc be here?
        set.add("/rhn/help/");
        set.add("/rhn/apidoc");
        set.add("/rhn/kickstart/DownloadFile");
        set.add("/rhn/ty/TinyUrl");
        set.add("/css");
        set.add("/img");
        set.add("/favicon.ico");
        set.add("/rhn/common/DownloadFile");

        UNPROTECTED_URIS = UnmodifiableSet.decorate(set);
    }

    private PxtSessionDelegate pxtDelegate;

    protected PxtAuthenticationService() {
    }

    protected Set getUnprotectedURIs() {
        return UNPROTECTED_URIS;
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
    public boolean validate(HttpServletRequest request, HttpServletResponse response) {
        //is authentication needed (i.e. is our session valid, and does the url
        //  we are hitting require auth)
        if (isAuthenticationRequired(request)) {
            invalidate(request, response);
            return false;
        }
        //if we are authenticated, and our URL requires auth, refresh
        //   The session.  If the url doesn't require auth
        //   Don't refresh it, because that may invalidate our old session
        if (requestURIRequiresAuthentication(request)) {
            pxtDelegate.refreshPxtSession(request, response);
        }
        return true;
    }

    private boolean isAuthenticationRequired(HttpServletRequest request) {
        return requestURIRequiresAuthentication(request) &&
               (!pxtDelegate.isPxtSessionKeyValid(request) ||
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
                redirectURI.append(ServletUtils.requestParamsToQueryString(request));
            }

            if (redirectURI.length() > MAX_URL_LENGTH) {
                request.setAttribute("url_bounce", LoginAction.DEFAULT_URL_BOUNCE);
            }
            else {
                request.setAttribute("url_bounce", redirectURI.toString());
            }

            RequestDispatcher dispatcher = request.getRequestDispatcher("/ReLogin.do");
            dispatcher.forward(request, response);
        }
        catch (IOException e) {
            throw new ServletException(e);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void invalidate(HttpServletRequest request, HttpServletResponse response) {
        pxtDelegate.invalidatePxtSession(request, response);
    }
}
