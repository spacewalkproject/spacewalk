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

package com.redhat.rhn.frontend.action.renderers.io;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

/**
 * Wraps a HttpServletResponse and uses a CachingOutputStream
 * to intercept all generated content
 * 
 * @version $Rev$
 */
public class CachingResponseWrapper extends HttpServletResponseWrapper {
    
    private CachingOutputStream stream = new CachingOutputStream();
    private PrintWriter writer = new PrintWriter(stream);
    
    /**
     * constructor
     * @param response HttpServletResponse
     */
    public CachingResponseWrapper(HttpServletResponse response) {
        super(response);
    }

    /**
     * {@inheritDoc}
     */
    public ServletOutputStream getOutputStream() throws IOException {
        return stream;
    }

    /**
     * {@inheritDoc}
     */
    public PrintWriter getWriter() throws IOException {
        return writer;
    }
    
    /**
     * @return all generated content as a string
     * @throws IOException if something goes wrong with the underlying stream
     */
    public String getCachedContent() throws IOException {
        writer.flush();
        stream.flush();
        return stream.getCachedContent();
    }
}
