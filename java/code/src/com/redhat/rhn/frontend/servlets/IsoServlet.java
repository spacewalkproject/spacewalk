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

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet which streams ISO files. Should be mapped to "*.iso"
 *
 * @version $Rev $
 */
public class IsoServlet extends HttpServlet {

    private int chunkSize = -1;

    /**
     * {@inheritDoc}
     */
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        String configChunkSize = config.getInitParameter("chunk-size");
        if (configChunkSize != null) {
            try {
                chunkSize = Integer.parseInt(configChunkSize);
            }
            catch (NumberFormatException e) {
                chunkSize = 8192;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException {
        InputStream in = new FileInputStream("/test-iso" + request.getServletPath());
        byte[] chunk = new byte[this.chunkSize];
        int readsize = 0;
        response.setContentType("application/octet-stream");
        OutputStream out = response.getOutputStream();
        while ((readsize = in.read(chunk)) > 0) {
            out.write(chunk, 0, readsize);
        }
        response.flushBuffer();
    }
}
