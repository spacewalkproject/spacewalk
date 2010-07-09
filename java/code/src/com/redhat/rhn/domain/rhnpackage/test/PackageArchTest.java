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

import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * PackageArchTest
 * @version $Rev$
 */
public class PackageArchTest extends RhnBaseTestCase {
    /**
     * Simple test to make sure we can lookup PackageArchs from
     * the db. Turn on hibernate.show_sql to make sure hibernate
     * is only going to the db once.
     * @throws Exception HibernateException
     */
    public void testPackageArch() throws Exception {

        Long testid = new Long(100);
        String query = "PackageArch.findById";
        PackageArch p1 = (PackageArch) TestUtils.lookupFromCacheById(testid, query);
        PackageArch p2 = (PackageArch) TestUtils.lookupFromCacheById(p1.getId(), query);

        assertNotNull(p1.getArchType());
        assertEquals(p1.getLabel(), p2.getLabel());
    }
}
