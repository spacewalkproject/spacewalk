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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


/**
 * PackageFactoryTest
 * @version $Rev$
 */
public class PackageFactoryTest extends BaseTestCaseWithUser {

    /**
     * Test fetching a Package with the logged in User
     * @throws Exception
     */
    public void testLookupWithUser() throws Exception {
        Package pkg = PackageTest.createTestPackage();
        assertNotNull(pkg.getOrg().getId());

        User usr = UserTestUtils.createUser("testUser", pkg.getOrg().getId());
        Package pkg2 = PackageFactory.lookupByIdAndUser(pkg.getId(), usr);
        assertNotNull(pkg2);
        // Check to make sure it returns NULL
        // if we lookup with a User who isnt part of the
        // Org that owns that Action.  Ignore for 
        // Sat mode since there is only one Org.
    }
        
    public void testLookupPackageArchByLabel() {
        assertNull(PackageFactory.lookupPackageArchByLabel("biteme-arch"));
        assertNotNull(PackageFactory.lookupPackageArchByLabel("i386"));
    }

    public void testLookupByNameAndServer() throws Exception {
        Server testServer = ServerFactoryTest.createTestServer(user, true);
        
        Channel channel = ChannelFactoryTest.createBaseChannel(user);
        testServer.addChannel(channel);
        
        Package testPackage = PackageTest.createTestPackage(user.getOrg());

        //Test a package the satellite knows about
        InstalledPackage testInstPack = new InstalledPackage();
        testInstPack.setArch(testPackage.getPackageArch());
        testInstPack.setEvr(testPackage.getPackageEvr());
        testInstPack.setName(testPackage.getPackageName());
        testInstPack.setServer(testServer);        
        Set serverPackages = new HashSet();
        serverPackages.add(testInstPack);
        testServer.setPackages(serverPackages);

        ServerFactory.save(testServer);
        testServer = (Server) reload(testServer);
        
        InstalledPackage pack = PackageFactory.lookupByNameAndServer(
                testInstPack.getName().getName(), testServer);
        
        assertEquals(testInstPack, pack);
    }
    
    public void testPackageSearch() {
        List pids = new ArrayList();
        pids.add(2125L);
        pids.add(2915L);
        String[] arches = {"channel-ia32", "channel-ia64"};
        
        List<PackageOverview> results =
            PackageFactory.packageSearch(pids, Arrays.asList(arches));
        assertNotNull(results);
    }

    public void testPackageDelete() throws Exception {
        Package pkg = PackageTest.createTestPackage();
        Long id = pkg.getId();
        Org org = pkg.getOrg();
        com.redhat.rhn.testing.TestUtils.flushAndEvict(pkg);
        pkg = PackageFactory.lookupByIdAndOrg(id, org);
        PackageFactory.deletePackage(pkg);

        HibernateFactory.getSession().flush();

    }


   public void testPackageSourceLookup() throws Exception {
       Package pack = PackageTest.createTestPackage();

       List list = PackageFactory.lookupPackageSources(pack);
       assertTrue(list.size() > 0);

   }
}

