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

import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * PackageNameTest
 * @version $Rev$
 */
public class PackageNameTest extends RhnBaseTestCase {
    /**
     * Simple test to make sure we can create
     * PackageNames and write them to the db.
     * @throws Exception Exception
     */
    public void testPackageName() throws Exception {
        PackageName p = createTestPackageName();
        assertNotNull(p);
        //make sure we got committed to the db.
        assertNotNull(p.getId());
    }

    /**
     * Create a test PackageName
     * @return a test PackageName object.
     * @throws Exception
     */
    public static PackageName createTestPackageName() throws Exception {
        PackageName p = new PackageName();
        p.setName("00JavaTest" + TestUtils.randomString());
        TestUtils.saveAndFlush(p);
        return p;
    }
}
