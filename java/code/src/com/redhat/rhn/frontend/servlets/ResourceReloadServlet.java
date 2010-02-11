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

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.log4j.Logger;

import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * A basic servlet class that reloads resources.  For now this just reloads the
 * LocalizationService resource files.
 *
 * @version $Rev: 51618 $
 */
public class ResourceReloadServlet extends HttpServlet {
    private static Logger log = Logger.getLogger(ResourceReloadServlet.class);


    /**
     * initialize the servlet
     */
    public void init() {
    }
    
    /**
     * executed when a get request happens
     *
     * @param request the request object
     * @param response the response object
     * @throws ServletException if an error occurs
     * @throws IOException if an error occurs
     */
    public void doGet(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

        reloadStringResources(response);
    }

    /**
     * executed when a post request happens
     *
     * @param request the request object
     * @param response the response object
     * @throws ServletException if a read error occurs
     * @throws IOException if a read error occurs
     */
    public void doPost(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {
        reloadStringResources(response);
    }
    
    private void reloadStringResources(HttpServletResponse response) 
        throws ServletException, IOException {
        
        response.setContentType("text/plain");
        boolean reloaded = LocalizationService.getInstance().reloadResourceFiles();
        OutputStream out = response.getOutputStream();
        try {
            String results = "Reloaded resource files: [" + reloaded + "]";
            response.setContentLength(results.length());
            if (log.isDebugEnabled()) {
                log.debug("Reloaded result [" + new String(results) + "]");
            }
            out.write(results.getBytes());
            out.flush();
        }
        // Lazy here since this is just a dev Servlet.
        catch (Exception e) {
            log.error("Exception trying to reload.", e);
            throw new ServletException("Throwable from ResourceReloadServlet", e);
        }

    }
}
