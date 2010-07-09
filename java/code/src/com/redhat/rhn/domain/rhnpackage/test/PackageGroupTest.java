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

import com.redhat.rhn.domain.rhnpackage.PackageGroup;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * PackageGroupTest
 * @version $Rev$
 */
public class PackageGroupTest extends RhnBaseTestCase {

    /**
     * Simple test to make sure we can create PackageGroups
     * and write them to the db.
     * @throws Exception
     */
    public void testPackageGroup() throws Exception {
        PackageGroup p = createTestPackageGroup();
        assertNotNull(p);
        //make sure we got committed to the db.
        assertNotNull(p.getId());
    }

    /**
     * Create a test PackageGroup
     * @return Returns a commited PackageGroup object
     * @throws Exception
     */
    public static PackageGroup createTestPackageGroup() throws Exception {
        String name = TestUtils.randomString();

        PackageGroup p = new PackageGroup();
        p.setName(name);
        p.setCreated(new Date());
        p.setModified(new Date());

        TestUtils.saveAndFlush(p);
        return p;
    }
}
