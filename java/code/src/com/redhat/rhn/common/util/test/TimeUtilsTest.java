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
package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.TimeUtils;

import junit.framework.TestCase;

/**
 * TimeUtilsTest is the test class for TimeUtils.
 * @version $Rev$
 */
public class TimeUtilsTest extends TestCase {

    public void testCurrentTimeSeconds() {
        assertTrue(timeEquals((System.currentTimeMillis() / 1000),
                     TimeUtils.currentTimeSeconds()));
    }

    /**
     * Compare two longs representing time and make sure they
     * are about equal.  This is so unit tests don't randomly
     * fail when testing the equivalency of two times.
     * @param timeOne One time to compare
     * @param timeTwo Other time to compare
     * @return whether the times are 'equal'
     */
    public static boolean timeEquals(long timeOne, long timeTwo) {
        //how about within two units of time
        return (timeTwo > (timeOne - 2) && timeTwo < (timeOne + 2));
    }
}
