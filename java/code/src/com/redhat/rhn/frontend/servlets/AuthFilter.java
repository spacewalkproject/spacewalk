/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.security.CSRFTokenException;
import com.redhat.rhn.common.security.CSRFTokenValidator;
import com.redhat.rhn.frontend.security.AuthenticationService;
import com.redhat.rhn.frontend.security.AuthenticationServiceFactory;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.domain.common.LoggingFactory;
import com.redhat.rhn.domain.user.User;
import org.apache.log4j.Logger;
import org.apache.struts.Globals;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Date;
import java.util.Enumeration;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AuthFilter - a servlet filter to ensure authenticated user info is put at
 * request scope properly
 *
 * @version $Rev$
 */
public class AuthFilter implements Filter {

    private static Logger log = Logger.getLogger(AuthFilter.class);

    private AuthenticationService authenticationService;

    /**
     * This method is intended for testing purposes only so that a fake, mock, ect.
     * service can be used. This method should <strong>not</strong> be used to change
     * the service implementation used. That is the responsibility of
     * AuthenticationServiceFactory.
     *
     * @param service An AuthenticationService to use for testing.
     * @see AuthenticationServiceFactory
     */
    protected void setAuthenticationService(AuthenticationService service) {
        authenticationService = service;
    }

    /** {@inheritDoc} */
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {

        if (log.isDebugEnabled()) {
            log.debug("ENTER AuthFilter.doFilter: " + request.getRemoteAddr() +
                    " [" + new Date() + "] (" +
                    ((HttpServletRequest)(request)).getRequestURI() + ")");
        }

        if (authenticationService.validate((HttpServletRequest)request,
                (HttpServletResponse)response)) {

            HttpServletRequest hreq = new
                RhnHttpServletRequest((HttpServletRequest)request);


            if (hreq.getMethod().equals("POST")) {
                // validate security token to prevent CSRF type of attacks
                if (!authenticationService.skipCsfr((HttpServletRequest) request)) {
                    try {
                        CSRFTokenValidator.validate(hreq);
                    }
                    catch (CSRFTokenException e) {
                        // send HTTP 403 if security token validation failed
                        HttpServletResponse hres = (HttpServletResponse) response;
                        hres.sendError(HttpServletResponse.SC_FORBIDDEN,
                                e.getMessage());
                        return;
                    }
                }
            }
            User user = new RequestContext((HttpServletRequest)request).getCurrentUser();
            if (user != null) {
                LoggingFactory.setLogAuth(user.getId());
            }
            chain.doFilter(request, response);
        }
        else {
            authenticationService.redirectToLogin((HttpServletRequest)request,
                    (HttpServletResponse)response);
        }
    }

    private void addErrorMessage(HttpServletRequest hreq, String msgKey, String[] args) {
        ActionMessages ams = new ActionMessages();
        ams.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(msgKey, args));
        hreq.getSession().setAttribute(Globals.ERROR_KEY, ams);
    }

    /**
     * @param request
     * @param response
     * @param hreq
     * @throws MalformedURLException
     * @throws ServletException
     * @throws IOException
     */
    private URL getHttpRequestReferer(HttpServletRequest hreq) {
        Enumeration em = hreq.getHeaders("referer");
        URL url = null;
        while (em.hasMoreElements()) {
            String urlString = (String) em.nextElement();
            try {
                url = new URL(urlString);
            }
            catch (MalformedURLException e) {
                // it does not matter, if there's no referer
            }
        }
        return url;
    }

    /**
     * {@inheritDoc}
     */
    public void destroy() {
    }

    /**
     * {@inheritDoc}
     */
    public void init(FilterConfig arg0) throws ServletException {
        AuthenticationServiceFactory factory = AuthenticationServiceFactory.getInstance();
        authenticationService = factory.getAuthenticationService();
    }
}
