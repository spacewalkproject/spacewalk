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

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

import javax.servlet.ServletOutputStream;

/**
 * Buffers servlet output rather than streaming it to the client
 *
 * @version $Rev $
 */
class BufferedServletOutputStream extends ServletOutputStream {

    private ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    /**
     * ${@inheritDoc}
     */
    public void write(int b) throws IOException {
        buffer.write(b);
    }

    /**
     * ${@inheritDoc}
     */
    public void flush() throws IOException {
        buffer.flush();
    }

    /**
     * Gets buffered content as UTF-8 encoded string
     * @return String
     * @throws UnsupportedEncodingException
     */
    public String getBufferedContent() throws UnsupportedEncodingException {
        return new String(buffer.toByteArray(), "UTF-8");
    }
}
