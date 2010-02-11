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

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * HelpDocServlet is a basic servlet that takes a request URI for documentation and
 * redirects it to the appropriate URI defined in the rhn.conf for that document.
 * For example,
 *
 * <br/><br/>
 *
 * Request URL:
 * <code>https://somehost/rhn/help/dispatcher/reference_guide</code>
 *
 * <br/><br/>
 *
 * Redirect URL:
 * <code>https://shomehost/rhn/help/reference/index.jsp</code>
 *
 * <br/><br/>
 *
 * Where rhn.conf contains:
 * <code>docs.reference_guide=/rhn/help/reference/index.jsp</code>
 *
 * @version $Rev$
 */
public class HelpDocServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String REDIRECT_URI = "/rhn/help/dispatcher";

    /**
     *
     */
    public HelpDocServlet() {
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        StringBuffer requestURL = request.getRequestURL();

        // obtain from the URI the key to be translated
        int docIndex = requestURL.indexOf(REDIRECT_URI) + REDIRECT_URI.length() + 1;
        String docRequest = requestURL.substring(docIndex);

        // obtain from config the URI that the request should be translated to
        String docRedirect = Config.get().getString("docs." + docRequest);

        if (docRedirect != null && docRedirect.trim().length() > 0) {
            requestURL.replace(0, requestURL.length(), docRedirect);
        }

        response.sendRedirect(requestURL.toString());
    }
}
