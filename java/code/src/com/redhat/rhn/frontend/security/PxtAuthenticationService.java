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
package com.redhat.rhn.frontend.security;


import com.redhat.rhn.common.util.ServletUtils;
import com.redhat.rhn.frontend.action.LoginAction;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;

import org.apache.commons.collections.set.UnmodifiableSet;
import org.apache.commons.lang.StringUtils;

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

    private static final Set UNPROTECTED_URIS;
    private static final Set POST_UNPROTECTED_URIS;
    private static final Set LOGIN_URIS;
    private static final Set RESRTICTED_WHITELIST_URIS;

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

        UNPROTECTED_URIS = UnmodifiableSet.decorate(set);

        set = new TreeSet(set);
        set.add("/rhn/common/DownloadFile");

        POST_UNPROTECTED_URIS = UnmodifiableSet.decorate(set);

        set = new TreeSet();
        // base and add on entitlements
        set.add("/rhn/systems/details/Edit.do");
        set.add("/rhn/systems/SystemEntitlementsSubmit.do");
        // org system entitlements
        set.add("/rhn/admin/multiorg/OrgSystemSubscriptions.do");
        // org software channel entitlements
        set.add("/rhn/admin/multiorg/OrgSoftwareSubscriptions.do");
        // delete system(s)
        set.add("/rhn/systems/details/DeleteConfirm.do");
        set.add("/rhn/systems/ssm/DeleteConfirm.do");
        set.add("/rhn/systems/DuplicateIPList.do");
        set.add("/rhn/systems/DuplicateIPv6List.do");
        set.add("/rhn/systems/DuplicateHostName.do");
        set.add("/rhn/systems/DuplicateMacAddress.do");
        // migrate to another org
        set.add("/rhn/admin/multiorg/OrgTrusts.do");
        set.add("/rhn/systems/details/SystemMigrate.do");
        set.add("/rhn/systems/ssm/MigrateSystems.do");
        // change channel subscription
        set.add("/rhn/systems/details/SystemChannels.do");
        set.add("/rhn/channel/ssm/BaseChannelSubscribe.do");
        set.add("/rhn/channel/ssm/ChildSubscriptions.do");
        // change flex -> regular entitlemnts
        set.add("/rhn/systems/entitlements/");
        // upload certificate
        set.add("/rhn/admin/config/CertificateConfig.do");
        // select systems
        set.add("/rhn/systems/Overview.do");
        set.add("/rhn/systems/SystemList.do");
        set.add("/rhn/systems/VirtualSystemsListSubmit.do");
        set.add("/rhn/systems/OutOfDate.do");
        set.add("/rhn/systems/RequiringReboot.do");
        set.add("/rhn/systems/ExtraPackagesSystems.do");
        set.add("/rhn/systems/Unentitled.do");
        set.add("/rhn/systems/Ungrouped.do");
        set.add("/rhn/systems/Inactive.do");
        set.add("/rhn/systems/Registered.do");
        set.add("/rhn/systems/ProxyList.do");
        set.add("/rhn/systems/SystemCurrency.do");
        // system search
        set.add("/rhn/systems/Search.do");

        RESRTICTED_WHITELIST_URIS = UnmodifiableSet.decorate(set);
    }

    private PxtSessionDelegate pxtDelegate;

    protected PxtAuthenticationService() {
    }

    protected Set getLoginURIs() {
        return LOGIN_URIS;
    }

    protected Set getUnprotectedURIs() {
        return UNPROTECTED_URIS;
    }

    protected Set getPostUnprotectedURIs() {
        return POST_UNPROTECTED_URIS;
    }

    protected Set getRestrictedWhitelistURIs() {
        return RESRTICTED_WHITELIST_URIS;
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
    public boolean postOnRestrictedWhitelist(HttpServletRequest request) {
        return requestRestrictedWhitelist(request);
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
            String requestMethod = request.getMethod();
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

            request.setAttribute("request_method", requestMethod);

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
