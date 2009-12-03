/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.frontend.security.AuthenticationService;
import com.redhat.rhn.frontend.security.AuthenticationServiceFactory;

import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.URL;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.RequestDispatcher;
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

            //Check the referrer and redirect to YourRhn.do if it doesn't match
            HttpServletRequest hreq = new
                RhnHttpServletRequest((HttpServletRequest)request);
            Enumeration em = hreq.getHeaders("referer");
            if (em.hasMoreElements()) {
                String urlString = (String) em.nextElement();
                URL url = new URL(urlString);
                List goodUrls = ConfigDefaults.get().getNonRefererUrls();
                if (!goodUrls.contains(hreq.getServletPath()) &&
                        !request.getLocalName().equals(url.getHost())) {
                    log.fatal("Referrer (" + url.getHost() + ") for url " +
                            hreq.getServletPath() +
                            " does not match.  Redirecting to /rhn/YourRhn.do.");
                    RequestDispatcher dispatcher = request.getRequestDispatcher(
                            "/YourRhn.do");
                    dispatcher.forward(request, response);
                    return;
                }
            }

            
            chain.doFilter(request, response);
        }
        else {
            authenticationService.redirectToLogin((HttpServletRequest)request, 
                    (HttpServletResponse)response);
        }
 
//        if (log.isDebugEnabled()) {
//            log.debug("EXIT AuthFilter.doFilter: " + request.getRemoteAddr() + 
//                    " [" + new Date() + "] (" + 
//                    ((HttpServletRequest)(request)).getRequestURI() + ")");
//        }        
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
