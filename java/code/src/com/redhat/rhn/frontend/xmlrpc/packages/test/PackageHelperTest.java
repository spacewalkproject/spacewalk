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
package com.redhat.rhn.frontend.xmlrpc.packages.test;

import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.packages.PackageHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Collections;
import java.util.Map;

public class PackageHelperTest extends RhnBaseTestCase {

    private void assertKey(Map map, String key, Object value) {
        assertTrue(map.containsKey(key));
        assertEquals(value, map.get(key));
    }

    public void testPackageToMap() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Package pkg = PackageTest.createTestPackage(user.getOrg());

        Map map = PackageHelper.packageToMap(pkg, user);

        assertKey(map, "name", pkg.getPackageName().getName());
        assertKey(map, "id", pkg.getId());
        assertKey(map, "epoch", pkg.getPackageEvr().getEpoch());
        assertKey(map, "version", pkg.getPackageEvr().getVersion());
        assertKey(map, "release", pkg.getPackageEvr().getRelease());
        assertKey(map, "arch_label", pkg.getPackageArch().getLabel());
        assertKey(map, "build_host", pkg.getBuildHost());
        assertKey(map, "description", pkg.getDescription());
        assertKey(map, "checksum", pkg.getChecksum().getChecksum());
        assertKey(map, "checksum_type", pkg.getChecksum().getChecksumType().getLabel());
        assertKey(map, "vendor", pkg.getVendor());
        assertKey(map, "summary", pkg.getSummary());
        assertKey(map, "cookie", pkg.getCookie());
        assertKey(map, "license", pkg.getCopyright());
        assertKey(map, "file", pkg.getFile());
        assertKey(map, "build_date", pkg.getBuildTime().toString());
        assertKey(map, "last_modified_date", pkg.getLastModified().toString());
        assertKey(map, "size", pkg.getPackageSize().toString());
        assertKey(map, "payload_size", pkg.getPayloadSize().toString());

        assertKey(map, "providing_channels", Collections.EMPTY_LIST);
    }

    public void testPackage2MapWithNulls() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Package pkg = PackageTest.createTestPackage(user.getOrg());

        // DO NOT delete this, otherwise Hibernate tries to freakin
        // store the object with nulls and blows up. We don't care
        // about the DB at this point, just need an object to read.
        TestUtils.flushAndEvict(pkg);

        // modify the input for negative testing
        pkg.setBuildTime(null);
        pkg.setLastModified(null);
        pkg.setPackageSize(null);
        pkg.setPayloadSize(null);
        pkg.setPackageName(null);
        pkg.setPackageEvr(null);
        pkg.setPackageArch(null);

        Map map = PackageHelper.packageToMap(pkg, user);
        assertKey(map, "build_date", "");
        assertKey(map, "last_modified_date", "");
        assertKey(map, "size", "");
        assertKey(map, "payload_size", "");
        assertKey(map, "name", "");
        assertKey(map, "epoch", "");
        assertKey(map, "version", "");
        assertKey(map, "release", "");
        assertKey(map, "arch_label", "");
    }

}
