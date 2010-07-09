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

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PatchSet;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

/**
 * PatchSetTest
 * @version $Rev$
 */
public class PatchSetTest extends PackageTest {

    public void testPatchSet() throws Exception {
        PatchSet patchSet = createTestPatchSet();
        assertNotNull(patchSet);
        //make sure we got written to the db
        assertNotNull(patchSet.getId());
        assertEquals("sparc-solaris-patch-cluster",
            patchSet.getPackageArch().getLabel());
    }

    public static PatchSet createTestPatchSet() throws Exception {
        PatchSet patchSet = new PatchSet();
        Org org = OrgFactory.lookupById(UserTestUtils.createOrg("testOrg"));
        populateTestPackage(patchSet, org);

        String query = "PackageArch.findByLabel";
        PackageArch parch =
            (PackageArch) TestUtils.
                lookupFromCacheByLabel("sparc-solaris-patch-cluster", query);
        patchSet.setPackageArch(parch);

        patchSet.setSetDate(new Date());
        TestUtils.saveAndFlush(patchSet);

        return patchSet;
    }
}
