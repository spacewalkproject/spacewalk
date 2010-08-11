/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.struts;

import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


/**
 * Scrubber
 * @version $Rev$
 */
public class Scrubber {
    public static final String[] PROHIBITED_INPUT = {"<", ">", "\\(", "\\)", "\\{", "\\}"};
    private static final Scrubber INSTANCE = new Scrubber();

    private Scrubber() {
    }

    /**
     * @return an instance of scrubber
     */
    private static Scrubber getInstance() {
        return INSTANCE;
    }

    /**
     * If this scrubber can actually scrub the given value
     * @param value  value to be checked
     * @return true if this scrubber can actually scrub
     */
    public static boolean canScrub(Object value) {
        boolean retval = false;
        if (value != null &&
                (value instanceof String ||
                 value instanceof Collection ||
                 value.getClass().isArray())) {
            retval = true;
        }
        return retval;
    }

    /**
     * Given an input String/Map/List/Array
     * this method will scrub the input
     *  and return the scrubber output
     * @param value the value to be scrubbed
     * @return the scrubbed value
     */
    public static Object scrub(Object value) {
        return getInstance().doScrub(value);
    }

    private Object doScrub(Object value) {
        if (!canScrub(value)) {
            return value;
        }
        if (value == null) {
            return null;
        }

        if (value instanceof String) {
            return scrubString((String) value);
        }
        else if (value instanceof Map) {
            return scrubMap((Map) value);
        }
        else if (value instanceof List) {
            return scrubList((List) value);
        }
        else if (value.getClass().isArray()) {
            return scrubArray((Object[]) value);
        }
        else {
            return value;
        }
    }

    private Object scrubList(List value) {
        List retval = new LinkedList();
        for (Iterator iter = value.iterator(); iter.hasNext();) {
            retval.add(scrub(iter.next()));
        }
        return retval;
    }

    private Object scrubMap(Map value) {
        if (value == null || value.size() == 0) {
            return value;
        }
        for (Iterator iter = value.keySet().iterator(); iter.hasNext();) {
            Object k = iter.next();
            Object v = scrub(value.get(k));
            value.put(k, v);
        }
        return value;
    }

    private Object scrubArray(Object[] value) {
        Object[] v = value;
        if (v.length > 0) {
            for (int x = 0; x < v.length; x++) {
                v[x] = scrub(v[x]);
            }
        }
        return value;
    }

    private Object scrubString(String value) {
        for (int x = 0; x < PROHIBITED_INPUT.length; x++) {
            value = value.replaceAll(PROHIBITED_INPUT[x], "");
        }
        return value;
    }
}
