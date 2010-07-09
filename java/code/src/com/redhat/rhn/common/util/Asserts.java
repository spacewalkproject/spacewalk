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
package com.redhat.rhn.common.util;

import java.util.Collection;

/**
 * Assertions that should be used to check parameters on public methods.
 * Note that, as opposed to the <code>assert</code> keyword, these checks
 * can not and should not be turned off.
 *
 * <p> See <a href="http://java.sun.com/docs/books/jls/assert-spec.html">Sun's
 * assert specification</a> for recommended best practices.
 * @version $Rev$
 */
public final class Asserts {

    private Asserts() {
        // Only used for static methods
    }

    /**
     * Assert that an arbitrary condition is true and throw an exception if the
     * condition is false.
     *
     * @param cond condition to assert
     * @throws IllegalStateException if condition is <code>false</code>
     */
    public static void assertTrue(boolean cond) throws IllegalStateException {
        assertTrue(cond, "");
    }

    /**
     * Assert that an arbitrary condition is true throw an exception with
     * message <code>msg</code> if the condition is false.
     *
     * @param cond condition to assert
     * @param msg failure message
     * @throws IllegalStateException if condition is <code>false</code>
     */
    public static void assertTrue(boolean cond, String msg)
        throws IllegalStateException {
        if (!cond) {
            throw new IllegalStateException("Assertion failed: " + msg);
        }
    }

    /**
     * Verify that a parameter is not null and throw a runtime exception if so.
     * @param o the object that should not be <code>null</code>
     * @throws IllegalStateException if <code>o</code> is null
     */
    public static void assertNotNull(Object o) throws IllegalStateException {
        assertNotNull(o, "");
    }

    /**
     * Verify that a parameter is not null and throw a runtime exception if so.
     * @param o the object that should not be <code>null</code>
     * @param label the label for <code>o</code> to include in the error
     * message
     * @throws IllegalStateException if <code>o</code> is null
     */
    public static void assertNotNull(Object o, String label)
        throws IllegalStateException {
        if (o == null) {
            assertTrue(o != null, "Value of " + label + " is null.");
        }
    }

    /**
     * Verify that a string is not empty and throw a runtime exception if so. A
     * parameter is considered empty if it is null, or if it does not contain
     * any characters that are non-whitespace.
     * @param s the string to check for emptiness
     * @throws IllegalStateException if <code>s</code> is an empty string
     */
    public static void assertNotEmpty(String s) throws IllegalStateException {
        assertNotEmpty(s, "");
    }

    /**
     * Verify that a string is not empty and throw a runtime exception if so. A
     * parameter is considered empty if it is null, or if it does not contain
     * any characters that are non-whitespace.
     * @param s the string to check for emptiness
     * @param label the label for <code>s</code> to include in the error
     * message
     * @throws IllegalStateException if <code>s</code> is an empty string
     */
    public static void assertNotEmpty(String s, String label)
        throws IllegalStateException {
        if (s == null || s.trim().length() == 0) {
            assertTrue(s != null && s.trim().length() > 0,
                    "Value of " + label + " is empty.");
        }
    }

    /**
     * Verify that two values are equal (according to their equals method,
     * unless expected is null, then according to ==).
     *
     * @param expected Expected value.
     * @param actual Actual value.
     * @throws IllegalStateException if <code>expected</code> is not
     * equal to <code>actual</code>
     */
    public static void assertEquals(Object expected, Object actual)
        throws IllegalStateException {
        assertEquals(expected, actual, "expected", "actual");
    }

    /**
     * Verify that two values are equal (according to their equals method,
     * unless expected is null, then according to ==).
     *
     * @param expected Expected value.
     * @param actual Actual value.
     * @param expectedLabel Label for first (generally expected) value.
     * @param actualLabel Label for second (generally actual) value.
     * @throws IllegalStateException condition was false
     */
    public static void assertEquals(Object expected, Object actual,
            String expectedLabel, String actualLabel)
        throws IllegalStateException {
        if (expected == null) {
            assertTrue(expected == actual, "Values not equal, " + expectedLabel +
                    " '" + expected + "', " + actualLabel + " '" + actual +
                    "'");
        }
        else if (!expected.equals(actual)) {
            assertTrue(expected.equals(actual), "Values not equal, " +
                    expectedLabel + " '" + expected + "', " + actualLabel +
                    " '" + actual + "'");
        }
    }

    /**
     * Verify that two values are equal.
     *
     * @param expected Expected value.
     * @param actual Actual value.
     * @throws IllegalStateException if <code>expected != actual</code>
     */
    public static void assertEquals(int expected, int actual)
        throws IllegalStateException {
        assertEquals(expected, actual, "expected", "actual");
    }

    /**
     * Verify that two values are equal.
     *
     * @param expected Expected value.
     * @param actual Actual value.
     * @param expectedLabel Label for first (generally expected) value.
     * @param actualLabel Label for second (generally actual) value.
     * @throws IllegalStateException if <code>expected != actual</code>
     */
    public static void assertEquals(int expected, int actual,
            String expectedLabel, String actualLabel)
        throws IllegalStateException {
        if (expected != actual) {
            assertTrue(expected == actual, "Values not equal, " + expectedLabel +
                    " '" + expected + "', " + actualLabel + " '" + actual +
                    "'");
        }
    }

    /**
     * Assert that <code>coll</code> contains <code>elem</code>
     * @param coll a collection
     * @param elem the element that should be in the collection
     */
    public static void assertContains(Collection coll, Object elem) {
        if (!coll.contains(elem)) {
            fail("Expected " + elem + " to be in " + coll);
        }
    }

    /**
     * This is the equivalent of assertTrue(false, msg).
     *
     * @param msg A string describing the condition of failure.
     * @throws IllegalStateException always
     */
    public static void fail(String msg) throws IllegalStateException {
        assertTrue(false, msg);
    }
}
