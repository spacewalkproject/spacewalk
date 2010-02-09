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
package com.redhat.rhn.domain.token.test;

import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.rhnpackage.test.PackageNameTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.TokenPackage;
import com.redhat.rhn.domain.token.TokenPackageFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

/**
 * TokenPackageTest
 * @version $Rev$
 */
public class TokenPackageTest extends BaseTestCaseWithUser {

    public void setUp() throws Exception {
        super.setUp();
        user.addRole(RoleFactory.ORG_ADMIN);
    }

    public void testTokenPackage() throws Exception {

        ActivationKey key = ActivationKeyTest.createTestActivationKey(user);
        TokenPackage pkg = createTestPackage(user, key);
        assertNotNull(pkg);

        //make sure we got written to the db
        assertNotNull(pkg.getId());
        TestUtils.flushAndEvict(pkg);

        TokenPackage lookup = TokenPackageFactory.lookupPackage(pkg.getToken(),
                pkg.getPackageName(), pkg.getPackageArch());

        assertNotNull(lookup);
        assertEquals(pkg, lookup);
        assertNotNull(lookup.getToken());
        assertNotNull(lookup.getPackageName());
        assertNotNull(lookup.getPackageArch());
    }

    public static TokenPackage createTestPackage(User user, ActivationKey key)
        throws Exception {

        TokenPackage p = new TokenPackage();

        p = populateTestPackage(user, key, p);
        TestUtils.saveAndFlush(p);

        return p;
    }

    public static TokenPackage populateTestPackage(User user, ActivationKey key,
            TokenPackage p) throws Exception {

        PackageName pname = PackageNameTest.createTestPackageName();

        Long testid = new Long(100);
        String query = "PackageArch.findById";
        PackageArch parch = (PackageArch) TestUtils.lookupFromCacheById(testid, query);

        p.setToken(key.getToken());
        p.setPackageName(pname);
        p.setPackageArch(parch);
        key.getPackages().add(p);

        return p;
    }
}
