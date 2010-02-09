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

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.util.Enumeration;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * DumpFilter dumps the current request and response to the log file.
 * Useful for debugging filter and servlet development.
 * @version $Rev$
 */
public class DumpFilter implements Filter {
    private static Logger log = Logger.getLogger(DumpFilter.class);

    /** {@inheritDoc} */
    public void doFilter(ServletRequest req,
            ServletResponse resp,
            FilterChain chain)
            throws IOException, ServletException {
        
        if (log.isDebugEnabled()) {
        // handle request        
        HttpServletRequest request = (HttpServletRequest) req;
            log.debug("Entered doFilter() ===================================");
            log.debug("AuthType: " + request.getAuthType());
            log.debug("Method: " + request.getMethod());
            log.debug("PathInfo: " + request.getPathInfo());
            log.debug("Translated path: " + request.getPathTranslated());
            log.debug("ContextPath: " + request.getContextPath());
            log.debug("Query String: " + request.getQueryString());
            log.debug("Remote User: " + request.getRemoteUser());
            log.debug("Remote Host: " + request.getRemoteHost());
            log.debug("Remote Addr: " + request.getRemoteAddr());
            log.debug("SessionId: " + request.getRequestedSessionId());
            log.debug("uri: " + request.getRequestURI());
            log.debug("url: " + request.getRequestURL().toString());
            log.debug("Servlet path: " + request.getServletPath());
            log.debug("Server Name: " + request.getServerName());
            log.debug("Server Port: " + request.getServerPort());
            log.debug("RESPONSE encoding: " + resp.getCharacterEncoding());
            log.debug("REQUEST encoding: " + request.getCharacterEncoding());
            log.debug("JVM encoding: " + System.getProperty("file.encoding"));
            logSession(request.getSession());
            logHeaders(request);
            logCookies(request.getCookies());
            logParameters(request);
            logAttributes(request);
            log.debug("Calling chain.doFilter() -----------------------------");
        }
        
        chain.doFilter(req, resp);
        
        if (log.isDebugEnabled()) {
            log.debug("Returned from chain.doFilter() -----------------------");
            log.debug("Handle Response, not much to print");
            log.debug("Response: " + resp.toString());
            log.debug("Leaving doFilter() ===================================");
        }
    }
    
    /** {@inheritDoc} */
    public void destroy() {
        // nop
    }

    /** {@inheritDoc} */
    public void init(FilterConfig filterConfig) {
        // nop
    }
    
    private void logCookies(Cookie[] cookies) {
        if (cookies == null) {
            log.debug("There are NO cookies to log");
            return;
        }
        
        for (int i = 0; i < cookies.length; i++) {
            log.debug(ReflectionToStringBuilder.toString(cookies[i]));
        }
    }
    
    private void logHeaders(HttpServletRequest req) {
        Enumeration items = req.getHeaderNames();
        while (items.hasMoreElements()) {
            String name = (String) items.nextElement();
            Enumeration hdrs = req.getHeaders(name);
            while (hdrs.hasMoreElements()) {
                log.debug("Header: name [" + name + "] value [" +
                        (String) hdrs.nextElement() + "]");    
            }
            
        }
    }
    
    private void logSession(HttpSession session) {
        log.debug(ReflectionToStringBuilder.toString(session));
    }
    
    private void logParameters(HttpServletRequest req) {
        Enumeration items = req.getParameterNames();
        while (items.hasMoreElements()) {
            String name = (String) items.nextElement();
            String[] values = req.getParameterValues(name);
            for (int i = 0; i < values.length; i++) {
                log.debug("Parameter: name [" + name + "] value [" +
                        values[i] + "]");
            }
        }
    }
    
    private void logAttributes(HttpServletRequest req) {
        Enumeration items = req.getAttributeNames();
        while (items.hasMoreElements()) {
            String name = (String) items.nextElement();
            Object obj = req.getAttribute(name);
            if (obj != null) {
                log.debug("Attribute: name [" + name + "] value [" +
                    ReflectionToStringBuilder.toString(obj) + "]");
            } 
            else {
                log.debug("Attribute: name [" + name + "] value [null]");
            }
        }
    }
}
