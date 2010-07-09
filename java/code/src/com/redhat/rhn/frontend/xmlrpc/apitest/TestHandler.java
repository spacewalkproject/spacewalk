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
package com.redhat.rhn.frontend.xmlrpc.apitest;

import com.redhat.rhn.frontend.xmlrpc.BaseHandler;

import org.apache.commons.lang.BooleanUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * TestHandler, this class is for internal use and will remain undocumented.
 * @version $Rev$
 * @xmlrpc.ignore
 */
public class TestHandler extends BaseHandler {
    /**
     * add list of numbers
     * @param numbers list of integers to be summed up.
     * @return sum of all numbers in list.
     */
    public int addition(int[] numbers) {
        if (numbers == null) {
            return 0;
        }

        int result = 0;

        for (int i = 0; i < numbers.length; i++) {
            result += numbers[i];
        }

        return result;
    }

    /**
     * Check whether the xmlrpc server env is hosted or not.
     *
     * @return 1 if system is a satellite.
     */
    public int envIsSatellite() {
        return BooleanUtils.toInteger(true);
    }

    /**
     * tests hash api definition stuff
     * @param testMap test map to see if we get a map coming in.
     * @return Map with key:foobar, value:baz   */
    public Map hashChecking(Map testMap) {
        Map result = new HashMap();
        result.put("foobar", "baz");
        return result;
    }

    /**
     * multiply list of numbers
     * @param numbers list of integers to be multiplied.
     * @return product of the given numbers.
     */
    public int multiplication(int[] numbers) {
        if (numbers == null || numbers.length < 1) {
            return 0;
        }

        int result = 1;
        for (int i = 0; i < numbers.length; i++) {
            result *= numbers[i];
        }
        return result;
    }

    /**
     * Returns the string passed to it
     * @param input String expected to be returned.
     * @return the string passed to it.
     */
    public String singleIdentityFunction(String input) {
        return input;
    }
}
