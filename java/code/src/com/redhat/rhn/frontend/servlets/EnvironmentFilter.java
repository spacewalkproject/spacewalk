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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * EnvironmentFilter
 * @version $Rev$
 */
public class EnvironmentFilter implements Filter {

    private static Logger log = Logger.getLogger(EnvironmentFilter.class);

    private static String[] nosslurls = {"/rhn/kickstart/DownloadFile",
                                         "/rhn/common/DownloadFile",
                                         "/rhn/rpc/api",
                                         "/rhn/ty/TinyUrl"};

    // It is ok to maintain an instance because PxtSessionDelegate does not maintain client
    // state.
    private PxtSessionDelegate pxtDelegate;

    /**
     * {@inheritDoc}
     */
    public void init(FilterConfig arg0) throws ServletException {
        PxtSessionDelegateFactory pxtDelegateFactory =
            PxtSessionDelegateFactory.getInstance();

        pxtDelegate = pxtDelegateFactory.newPxtSessionDelegate();
    }

    /**
     * {@inheritDoc}
     */
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
        throws IOException, ServletException {

        HttpServletRequest hreq = new
                             RhnHttpServletRequest((HttpServletRequest)request);
        HttpServletResponse hres = new RhnHttpServletResponse(
                                                (HttpServletResponse)response,
                                                hreq);

        boolean sslAvail = ConfigDefaults.get().isSSLAvailable();

        // There are a list of pages that don't require SSL, that list should
        // be called out here.
        String path = hreq.getRequestURI();
        // Have to make this decision here, because once we pass the request
        // off to the next filter, that filter can do work that sends data to
        // the client, meaning that we can't redirect.
        if (RhnHelper.pathNeedsSecurity(nosslurls, path) &&
                !hreq.isSecure() && sslAvail) {
            if (log.isDebugEnabled()) {
                log.debug("redirecting to secure: " + path);
            }
            redirectToSecure(hreq, hres);
            return;
        }

        // Set request attributes we may need later
        HttpServletRequest req = (HttpServletRequest) request;
        request.setAttribute(RequestContext.REQUESTED_URI, req.getRequestURI());

        if (log.isDebugEnabled()) {
            log.debug("set REQUESTED_URI: " + req.getRequestURI());
        }

        // add messages that were put on the request path.
        addParameterizedMessages(req);

        // Done, go up chain
        chain.doFilter(hreq, hres);
    }

    private void addParameterizedMessages(HttpServletRequest req) {
        String messageKey = req.getParameter("message");
        if (messageKey != null) {
            ActionMessages msg = new ActionMessages();
            String param1 = req.getParameter("messagep1");
            String param2 = req.getParameter("messagep2");
            String param3 = req.getParameter("messagep3");

            Object[] args = new Object[3];
            args[0] = StringEscapeUtils.escapeHtml(param1);
            args[1] = StringEscapeUtils.escapeHtml(param2);
            args[2] = StringEscapeUtils.escapeHtml(param3);

            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(messageKey, args));
            StrutsDelegate.getInstance().saveMessages(req, msg);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void destroy() {
      // Nothing to do here
    }

    private void redirectToSecure(HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        String originalUrl = request.getRequestURL().toString();
        String secureUrl = "https://" + originalUrl.substring(7);
        response.sendRedirect(secureUrl);
        return;
    }
}
