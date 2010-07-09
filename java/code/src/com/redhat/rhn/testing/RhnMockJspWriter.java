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

import com.mockobjects.servlet.MockJspWriter;

import java.io.IOException;

/**
 * JMockJspWriter - Simple abstract class that defines a default no arg constructor so
 * JMock will be happy.
 * @version $Rev$
 */
public class RhnMockJspWriter extends MockJspWriter {

    /**
     * A stringbuffer to to capture what's being printed.
     * The StringWriter in MockJspWriter is freakin private
     * and there's no getters to access it.
     */
    private StringBuffer buf = new StringBuffer();

    /**
     * {@inheritDoc}
     */
    public void clear() {
        // Do nothing
    }

    /**
     * {@inheritDoc}
     */
    public void clearBuffer() {
        // Do nothing
    }

    /**
     *
     * {@inheritDoc}
     */
    public void print(String stringIn) {
        buf.append(stringIn);
        super.println(stringIn);
    }

    /**
     * {@inheritDoc}
     */
    public void println(String stringIn) {
        buf.append(stringIn);
        buf.append("\n");
        super.println(stringIn);
    }

    /**
     *
     * {@inheritDoc}
     */
    public String toString() {
        return buf.toString();
    }

    /**
     *
     * {@inheritDoc}
     */
    public void println(Object anObject) {
        buf.append(anObject);
        buf.append("\n");
        super.println(anObject);
    }

    /**
     *
     * {@inheritDoc}
     */
    public void write(String str) throws IOException {
        buf.append(str);
        super.write(str);
    }
}
