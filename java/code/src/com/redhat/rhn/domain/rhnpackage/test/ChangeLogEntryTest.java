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

import com.redhat.rhn.domain.rhnpackage.ChangeLogEntry;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

public class ChangeLogEntryTest extends RhnBaseTestCase {

    public void testChangeLogEntry() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Package pkg = PackageTest.createTestPackage(user.getOrg());

        ChangeLogEntry change1 = createTestChangeLogEntry(pkg, new Date());
        assertEquals(pkg.getId(), change1.getRhnPackage().getId());

        ChangeLogEntry change2 = createTestChangeLogEntry(pkg,
                new Date(System.currentTimeMillis() + 1000));
        assertFalse(change1.equals(null));
        assertFalse(change1.equals("foo"));
        assertFalse(change1.equals(change2));
        change2.setTime(change1.getTime());
        assertTrue(change1.equals(change2));
    }

    public static ChangeLogEntry createTestChangeLogEntry(Package pkg,
            Date timeIn) {
        ChangeLogEntry change = new ChangeLogEntry();
        change.setRhnPackage(pkg);
        change.setName("testuser");
        change.setText("Some test text for a test package");
        change.setTime(timeIn);

        TestUtils.saveAndFlush(change);
        return change;
    }
}
