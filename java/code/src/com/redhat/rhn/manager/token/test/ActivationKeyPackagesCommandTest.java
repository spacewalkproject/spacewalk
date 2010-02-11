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
package com.redhat.rhn.manager.token.test;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.TokenPackage;
import com.redhat.rhn.domain.token.test.ActivationKeyTest;
import com.redhat.rhn.domain.token.test.TokenPackageTest;
import com.redhat.rhn.manager.token.ActivationKeyPackagesCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

/**
 * ActivationKeyPackagesCommandTest
 * @version $Rev$
 */
public class ActivationKeyPackagesCommandTest extends BaseTestCaseWithUser {

    public void testPopulatePackages() throws Exception {

        // setup
        ActivationKey key = ActivationKeyTest.createTestActivationKey(user);
        TokenPackage pkg1 = TokenPackageTest.createTestPackage(user, key);
        TokenPackage pkg2 = TokenPackageTest.createTestPackage(user, key);
        TokenPackage pkg3 = TokenPackageTest.createTestPackage(user, key);

        TestUtils.flushAndEvict(pkg1);
        TestUtils.flushAndEvict(pkg2);
        TestUtils.flushAndEvict(pkg3);

        assertEquals(3, key.getPackages().size());

        ActivationKeyPackagesCommand command = new ActivationKeyPackagesCommand(key);

        // execute
        String populated = command.populatePackages();

        // verify
        assertNotNull(populated);

        assertTrue(populated.contains(pkg1.getPackageName().getName() + "." +
                                      pkg1.getPackageArch().getLabel() + "\n"));

        assertTrue(populated.contains(pkg2.getPackageName().getName() + "." +
                                      pkg2.getPackageArch().getLabel() + "\n"));

        assertTrue(populated.contains(pkg3.getPackageName().getName() + "." +
                                      pkg3.getPackageArch().getLabel() + "\n"));


    }
    public void testParseAndUpdate() throws Exception {

        // setup
        StringBuilder pkgs = new StringBuilder();
        pkgs.append("pkg1.i386").append("\n");
        pkgs.append("pkg2").append("\n");

        ActivationKey key = ActivationKeyTest.createTestActivationKey(user);
        ActivationKeyPackagesCommand command = new ActivationKeyPackagesCommand(key);
        int numPkgsBefore = key.getPackages().size();

        // execute
        ValidatorError result = command.parseAndUpdatePackages(pkgs.toString());
        command.store();

        // verify
        assertNull(result);  // no error returned
        assertEquals(numPkgsBefore + 2, key.getPackages().size());

        boolean foundPkg1 = false, foundPkg2 = false;
        for (TokenPackage pkg : key.getPackages()) {

            if (pkg.getPackageName().getName().equals("pkg1") &&
                pkg.getPackageArch().getLabel().equals("i386") &&
                pkg.getToken().equals(key.getToken())) {
                foundPkg1 = true;
            }
            else if (pkg.getPackageName().getName().equals("pkg2") &&
                     (pkg.getPackageArch() == null) &&
                     pkg.getToken().equals(key.getToken())) {
                foundPkg2 = true;
            }
         }
         assertTrue(foundPkg1);
         assertTrue(foundPkg2);
    }
}
