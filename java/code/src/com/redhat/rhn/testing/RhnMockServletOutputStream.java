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
package com.redhat.rhn.testing;

import java.io.IOException;

import javax.servlet.ServletOutputStream;

/**
 * RhnMockServletOutputStream - simple mock of an output stream
 * @version $Rev$
 */
public class RhnMockServletOutputStream extends ServletOutputStream {
    private StringBuffer contents;

    /**
     * Default no arg constructor
     */
    public RhnMockServletOutputStream() {
        contents = new StringBuffer();
    }

    /**
     * {@inheritDoc}
     */
    public void println(String s) throws IOException {
        super.println(s);
        contents.append(s);
    }

    /**
     * {@inheritDoc}
     */
    public void write(byte[] b) throws IOException {
        contents.append(new String(b));
    }

    /**
     * Get what has been written to the outputstream
     * @return String contents
     */
    public String getContents() {
        return contents.toString();
    }

    /**
     * {@inheritDoc}
     */
    public void write(int b) throws IOException {
        contents.append(b + "");
    }

    /**
     * {@inheritDoc}
     */
    public void write(byte[] b, int off, int len) throws IOException {
        String bytes = new String(b);
        contents.append(bytes.toCharArray(), off, len);
    }

}
