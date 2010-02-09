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

import com.redhat.rhn.common.util.RpmVersionComparator;

import junit.framework.TestCase;

/**
 * RpmVersionComparatorTest
 * @version $Rev$
 */
public class RpmVersionComparatorTest extends TestCase {

    private RpmVersionComparator cmp;

    protected void setUp() throws Exception {
        super.setUp();
        cmp = new RpmVersionComparator();
    }

    protected void tearDown() throws Exception {
        cmp = null;
        super.tearDown();
    }

    public void testBasicComparisons() {
        // Some equality
        assertCompareSymm(0, "0", "0");
        assertCompareSymm(0, "1-a.1", "1-a.1");
        assertCompareSymm(0, "1-a.1", "1.a-1");
        assertCompareSymm(0, "", "");

        // Some asymmetry .. not really a total ordering
        assertCompareAsym(-1, "-", ".");
        assertCompareAsym(-1, "--", "-");
        assertCompareAsym(-1, "1-1-", "1-1.");

        assertCompareSymm(1, "1.1", "1a");
        assertCompareSymm(-1, "9", "10");
        assertCompareSymm(-1, "00009", "0010");
    }

    public void testBugzilla50977() {
        // From comment #2
        assertCompareSymm(1, "10mdk", "10");
        assertCompareSymm(-1, "10mdk", "10.1mdk");
        assertCompareSymm(1, "9", "ximian.1");

        // From comment #19
        assertCompareSymm(-1, "1.4snap", "1.4.5");
        assertCompareSymm(-1, "4.0x", "4.0.36");
        assertCompareSymm(-1, "p19", "2.0.0");
        assertCompareSymm(0, "2.0e", "2.0e");
        assertCompareSymm(-1, "2.0e", "2.0.11");
    }

    public void testBugzilla82639() {
        // Some test cases from that bz. Note that the
        // results being tested for are not necessarily the ones from
        // bz, but whatever rpmvercmp in RHEL3 returns
        assertCompareSymm(1, "1", "asp1.7x.2");
        assertCompareSymm(1, "ipl4mdk", "alt0.8");
        assertCompareSymm(-1, "alt0.8", "ipl4mdk");
        assertCompareSymm(1, "1asp", "alt1");

    }

    private void assertCompareAsym(int exp, String v1, String v2) {
        assertCompare(exp, v1, v2);
        assertCompare(exp, v2, v1);
    }

    private void assertCompareSymm(int exp, String v1, String v2) {
        assertCompare(exp, v1, v2);
        assertCompare(-exp, v2, v1);
    }

    private void assertCompare(int exp, String v1, String v2) {
        assertEquals(exp, cmp.compare(v1, v2));
        assertEquals(0, cmp.compare(v1, v1));
        assertEquals(0, cmp.compare(v2, v2));
    }
}
