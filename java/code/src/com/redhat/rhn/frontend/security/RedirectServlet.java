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

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RedirectServlet redirects GET requests. All requests whose URI starts with
 * <code>/rhn/Redirect</code> will be processed by this servlet. The redirect URL will
 * consist of the full URL including the query string, except that the <code>/rhn/Redirect
 * </code> portion of the URI will be stripped out. This is best illustrated with an
 * example:
 *
 * <br/><br/>
 *
 * Request URL:
 * <code>https://somehost.redhat.com/rhn/Redirect/rhn/systems/Overview.do</code>
 *
 * <br/><br/>
 *
 * Redirect URL: <code>https://somehost.redhat.com/rhn/systems/Overview.do</code>
 *
 * <br/><br/>
 *
 * The use case for RedirectServlet is for supporting perl in a hosted environment when
 * SSO authentication is enabled. The SSO authentication logic has not and will not be
 * ported to the perl code base; consequently, perl will continue to rely solely on the PXT
 * authentication model. This is fine since the SSO authentication service will create,
 * refresh, and invalidate the PXT session as necessary. A problem exists though in the
 * following scenario in which a request does not go through the servlet filters:
 *
 * <ul>
 *   <li>User goes to https://somehost/dev/index.pxt.</li>
 *   <li>Since the user has not logged in, she is redirected to the SSO app.</li>
 *   <li>
 *     User logs in through SSO and is redirected back to https://somehost/dev/index.pxt.
 *   </li>
 *   <li>
 *     The PXT session has not been created, so the user will again be redirected back to
 *     SSO.
 *   </li>
 * </ul>
 *
 * If PXT authentication fails, perl can redirect the request to SSO. RedirectServlet should
 * be included in the callback URL as described above. This will ensure that when SSO
 * redirects the client that the request will be filtered by the appropriate servlet
 * filters, ensuring that the PXT session is created. RedirectServlet will then handle
 * redirecting the request back to the originally requested perl page.
 *
 * @version $Rev$
 */
public class RedirectServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String REDIRECT_URI = "/rhn/Redirect";

    /**
     *
     */
    public RedirectServlet() {
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        StringBuffer requestURL = request.getRequestURL();
        int redirectIndex = requestURL.indexOf(REDIRECT_URI);
        String queryString = request.getQueryString();

        requestURL.delete(redirectIndex, redirectIndex + REDIRECT_URI.length());

        if (queryString != null) {
            requestURL.append("?").append(queryString);
        }

        response.sendRedirect(requestURL.toString());
    }

}
