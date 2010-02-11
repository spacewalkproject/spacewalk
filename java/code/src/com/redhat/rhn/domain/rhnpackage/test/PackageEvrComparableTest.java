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
package com.redhat.rhn.domain.rhnpackage.test;

import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.commons.lang.StringUtils;

/**
 * Test the compare() method in PackageEvr
 * @version $Rev$
 */
public class PackageEvrComparableTest extends RhnBaseTestCase {

    public void testEquality() {
        compare(0, "0-0-0", "0-0-0");
        compare(0, "null-0-0", "0-0-0");
        compare(0, "null-0-0", "null-0-0");
    }

    public void testFailure() {
        failure("0-null-0", IllegalStateException.class);
        failure("0-0-null", NullPointerException.class);
        failure("X-0-null", NumberFormatException.class);
    }

    public void testDifference() {
        compare(-1, "1-1-1", "2-5-7");
        compare(-1, "1-5-7", "2-5-7");
        compare(-1, "1-1-7", "1-5-7");
        compare(1, "1-1-7", "1-1-6");
    }

    private void failure(String evr, Class excClass) {
        try {
            compare(0, evr, evr);
            fail("Comparison of " + evr + " must fail");
        }
        catch (Exception e) {
            assertEquals(excClass, e.getClass());
        }
    }

    private void compare(int exp, String evrString1, String evrString2) {
        PackageEvr evr1 = create(evrString1);
        PackageEvr evr2 = create(evrString2);
        assertEquals(exp, evr1.compareTo(evr2));
        assertEquals(-exp, evr2.compareTo(evr1));
        assertEquals(0, evr1.compareTo(evr1));
        assertEquals(0, evr2.compareTo(evr2));
    }

    private PackageEvr create(String evr) {
        String[] values = split(evr);
        PackageEvr result = new PackageEvr();
        result.setEpoch(values[0]);
        result.setVersion(values[1]);
        result.setRelease(values[2]);
        return result;
    }

    private String[] split(String evr) {
        String[] values = StringUtils.split(evr, "-");
        for (int i = 0; i < values.length; i++) {
            if ("null".equals(values[i])) {
                values[i] = null;
            }
        }
        return values;
    }
}
