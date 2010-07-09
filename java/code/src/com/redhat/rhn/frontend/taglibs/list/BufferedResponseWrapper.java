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

package com.redhat.rhn.frontend.taglibs.list;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

/**
 * Buffers servlet output
 * @version $Rev $
 */
class BufferedResponseWrapper extends HttpServletResponseWrapper {

   private BufferedServletOutputStream out = new BufferedServletOutputStream();
   private PrintWriter writer = new PrintWriter(out);

   /**
    * ${@inheritDoc}
    */
    public BufferedResponseWrapper(HttpServletResponse target) {
        super(target);
    }


    /**
     * ${@inheritDoc}
     */
    public ServletOutputStream getOutputStream() throws IOException {
        return out;
    }

    /**
     * ${@inheritDoc}
     */
    public PrintWriter getWriter() throws IOException {
        return writer;
    }

    /**
     * ${@inheritDoc}
     */
    public void flush() throws IOException {
        writer.flush();
        out.flush();
    }

    /**
     * Gets buffered content from underlying output stream
     * @return string
     * @throws UnsupportedEncodingException
     */
    public String getBufferedOutput() throws UnsupportedEncodingException {
        return out.getBufferedContent();
    }
}
