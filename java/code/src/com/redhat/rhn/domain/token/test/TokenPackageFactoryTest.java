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
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.TokenPackage;
import com.redhat.rhn.domain.token.TokenPackageFactory;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.List;

/**
 * TokenPackageFactoryTest
 * @version $Rev$
 */
public class TokenPackageFactoryTest extends BaseTestCaseWithUser {

    public void testLookupPackagesByToken() throws Exception {

        // setup
        ActivationKey key = ActivationKeyTest.createTestActivationKey(user);
        int numPkgsBefore = key.getPackages().size();

        TokenPackage pkg1 = TokenPackageTest.createTestPackage(user, key);
        assertNotNull(pkg1);
        pkg1.getPackageName().setName("cName");

        TokenPackage pkg2 = TokenPackageTest.createTestPackage(user, key);
        assertNotNull(pkg2);
        pkg2.getPackageName().setName("bName");

        TokenPackage pkg3 = TokenPackageTest.createTestPackage(user, key);
        assertNotNull(pkg3);
        pkg3.getPackageName().setName("aName");

        TestUtils.flushAndEvict(pkg1);
        TestUtils.flushAndEvict(pkg2);
        TestUtils.flushAndEvict(pkg3);

        //make sure we got written to the db
        assertNotNull(pkg1.getId());
        assertNotNull(pkg2.getId());
        assertNotNull(pkg3.getId());

        // execute
        List<TokenPackage> pkgs = TokenPackageFactory.lookupPackages(key.getToken());

        // verify
        assertNotNull(pkgs);
        assertEquals(numPkgsBefore + 3, pkgs.size());

        Object[] array = pkgs.toArray();
        assertEquals("aName", ((TokenPackage) array[0]).getPackageName().getName());
        assertEquals("bName", ((TokenPackage) array[1]).getPackageName().getName());
        assertEquals("cName", ((TokenPackage) array[2]).getPackageName().getName());
    }

    public void testLookupPackages() throws Exception {

        // setup
        ActivationKey key = ActivationKeyTest.createTestActivationKey(user);
        int numPkgsBefore = key.getPackages().size();

        TokenPackage pkg1 = TokenPackageTest.createTestPackage(user, key);
        assertNotNull(pkg1);

        // since createTestPackage randomly creates package names, we'll create
        // a second package manually.
        TokenPackage pkg2 = new TokenPackage();

        Long testid = new Long(101);
        String query = "PackageArch.findById";
        PackageArch parch = (PackageArch) TestUtils.lookupFromCacheById(testid, query);

        pkg2.setToken(key.getToken());
        pkg2.setPackageName(pkg1.getPackageName());
        pkg2.setPackageArch(parch);
        key.getPackages().add(pkg2);

        TestUtils.flushAndEvict(pkg1);
        TestUtils.flushAndEvict(pkg2);

        //make sure we got written to the db
        assertNotNull(pkg1.getId());
        assertNotNull(pkg2.getId());

        // execute
        List<TokenPackage> pkgs = TokenPackageFactory.lookupPackages(key.getToken(),
                pkg1.getPackageName());

        // verify
        assertNotNull(pkgs);
        assertEquals(numPkgsBefore + 2, pkgs.size());

        boolean foundPkg1 = false, foundPkg2 = false;
        for (TokenPackage pkg : pkgs) {
           if (pkg.getPackageName().equals(pkg1.getPackageName()) &&
               pkg.getPackageArch().equals(pkg1.getPackageArch()) &&
               pkg.getToken().equals(pkg1.getToken())) {
               foundPkg1 = true;
           }
           else if (pkg.getPackageName().equals(pkg2.getPackageName()) &&
                   pkg.getPackageArch().equals(pkg2.getPackageArch()) &&
                   pkg.getToken().equals(pkg2.getToken())) {
                   foundPkg2 = true;
           }
        }
        assertTrue(foundPkg1);
        assertTrue(foundPkg2);
    }

    public void testLookupPackage() throws Exception {

        // setup
        ActivationKey key = ActivationKeyTest.createTestActivationKey(user);
        TokenPackage pkg = TokenPackageTest.createTestPackage(user, key);
        assertNotNull(pkg);

        TestUtils.flushAndEvict(pkg);

        //make sure we got written to the db
        assertNotNull(pkg.getId());

        // execute
        TokenPackage lookup = TokenPackageFactory.lookupPackage(pkg.getToken(),
                pkg.getPackageName(), pkg.getPackageArch());

        // verify
        assertNotNull(lookup);
        assertEquals(pkg, lookup);
        assertNotNull(lookup.getToken());
        assertNotNull(lookup.getPackageName());
        assertNotNull(lookup.getPackageArch());
    }
}
