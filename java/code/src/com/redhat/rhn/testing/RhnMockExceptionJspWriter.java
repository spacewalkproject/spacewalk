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

import javax.servlet.jsp.JspWriter;

/**
 * RhnMockExceptionJspWriter is a mock implementation of
 * a J2EE JspWriter which throws an IOException for EVERY
 * method.  This class should be used to test exception
 * handling code in your taglibs.
 * @version $Rev$
 */
public class RhnMockExceptionJspWriter extends JspWriter {

    /**
     * Always throws an exception.Constructor
     */
    public RhnMockExceptionJspWriter() {
        super(0, false);
    }

    /**
     * Always throws an exception.
     * @throws java.io.IOException Always throws an exception.
     */
    public void newLine() throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 boolean to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(boolean arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 char to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(char arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 int to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(int arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 long to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(long arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 float to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(float arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 double to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(double arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 character array to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(char[] arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 String to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(String arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 Object to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void print(Object arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @throws java.io.IOException Always throws an exception.
     */
    public void println() throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 boolean to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(boolean arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 char to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(char arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 int to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(int arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 long to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(long arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 float to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(float arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 double to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(double arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 character array to print
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(char[] arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 String to print.
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(String arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @param arg0 Object to print.
     * @throws java.io.IOException Always throws an exception.
     */
    public void println(Object arg0) throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @throws java.io.IOException Always throws an exception.
     */
    public void clear() throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @throws java.io.IOException Always throws an exception.
     */
    public void clearBuffer() throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @throws java.io.IOException Always throws an exception.
     */
    public void flush() throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @throws java.io.IOException Always throws an exception.
     */
    public void close() throws IOException {
        throw new IOException("");

    }
    /**
     * Always throws an exception.
     * @return int Returns 0
     */
    public int getRemaining() {
        return 0;
    }
    /**
     * Always throws an exception.
     * @param cbuf character buffer
     * @param off offset in character buffer.
     * @param len length of buffer to write.
     * @throws java.io.IOException Always throws an exception.
     */
    public void write(char[] cbuf, int off, int len) throws IOException {
        throw new IOException("");

    }

}
