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

import org.apache.commons.collections.CollectionUtils;

import java.util.Set;
import java.util.TreeSet;

import junit.framework.Assert;


/**
 * ServletTestUtils
 * @version $Rev$
 */
public class ServletTestUtils extends Assert {

    /**
     * Asserts that two query strings are equal. Order of parameters is not checked. A query
     * string should look like <code>param1=value1&param2=value2</code>. Note that because
     * the parameters in a query string are basically an unordered collection of name/value
     * pairs, the following two query strings would be considered equal:
     *
     * <br/><br/>
     *
     * <code>param1=value1&param2=value2</code><br/>
     * <code>param2=value2&param1=value1</code>
     *
     * @param expected The expcected query string.
     *
     * @param actual The actual query string.
     */
    public static void assertQueryStringEquals(String expected, String actual) {
        Set expectedParams = createQueryStringParameterSet(expected);
        Set actualParams = createQueryStringParameterSet(actual);

        assertEquals(expectedParams, actualParams);
    }

    private static Set createQueryStringParameterSet(String queryString) {
        Set parameterSet = new TreeSet();
        CollectionUtils.addAll(parameterSet, queryString.split("&"));

        return parameterSet;
    }
}
