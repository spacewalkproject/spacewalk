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

import com.redhat.rhn.FaultException;
import com.redhat.rhn.domain.rhnpackage.ChangeLogEntry;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.ChangeLogEntryTest;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.packages.PackagesHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;
import java.util.List;
import java.util.Map;

public class PackagesHandlerTest extends BaseHandlerTestCase {

    private PackagesHandler handler = new PackagesHandler();
    
    public void testGetDetails() throws Exception {

        Package pkg = PackageTest.createTestPackage(admin.getOrg());
        assertNotNull(pkg.getOrg().getId());
        
        Map details = handler.getDetails(adminKey, new Integer(pkg.getId().intValue()));
        assertNotNull(details);
        assertTrue(details.containsKey("name"));
        
        try {
            handler.getDetails(adminKey, new Integer(-213344));
            fail("handler.getDetails didn't throw FaultException for non-existant package");
        }
        catch (FaultException e) {
            //success
        }
    }
    
    public void testListChangeLog() throws Exception {
        // TODO: GET THIS WORKING
        // if (Config.get().isSatellite()) {
        if (true) {
            return;
        }
        
        Package pkg = PackageTest.createTestPackage(admin.getOrg());
        assertNotNull(pkg.getOrg().getId());
        
        Object[] changelog = handler.listChangelog(adminKey, 
                                                   new Integer(pkg.getId().intValue()));
        
        assertEquals(pkg.getChangeLog().size(), changelog.length);
        
        ChangeLogEntry change1 = ChangeLogEntryTest.
            createTestChangeLogEntry(pkg, new Date());
        pkg.addChangeLogEntry(change1);
        
        changelog = handler.listChangelog(adminKey, new Integer(pkg.getId().intValue()));
        
        assertEquals(pkg.getChangeLog().size(), changelog.length);
    }
    
    public void testListFiles() throws Exception {
        User user = UserTestUtils.createUser("testUser", admin.getOrg().getId());
        Package pkg = PackageTest.createTestPackage(user.getOrg());
        
        Object[] files = handler.listFiles(adminKey, 
                new Integer(pkg.getId().intValue()));
        
        // PackageTest.populateTestPackage populates a test package with 2 associated files
        assertEquals(2, files.length);
        
                               
        //TODO: Once we work out the mappings between packages -> files -> capabilities
        //we should do some more exhaustive testing of this method. 
    }
 
    public void testListProvidingErrata() throws Exception {
        User user = UserTestUtils.createUser("testUser", admin.getOrg().getId());
        Package pkg = PackageTest.createTestPackage(user.getOrg());
        
        Object[] result = handler.listProvidingErrata(adminKey, 
                                                      new Integer(pkg.getId().intValue()));
        assertEquals(0, result.length);        
    }
    
    public void testListProvidingChannels() throws Exception {
        User user = UserTestUtils.createUser("testUser", admin.getOrg().getId());
        Package pkg = PackageTest.createTestPackage(user.getOrg());
        
        Object[] result = handler.listProvidingChannels(adminKey,
                                                       new Integer(pkg.getId().intValue()));
        //test package shouldn't be "provided" by any channel yet
        assertEquals(0, result.length);
    }
    
    public void testListDependencies() throws Exception {
      //TODO: Once we work out the mappings between packages -> dependencies  
      //      we should do some more exhaustive testing of this method. 
      User user = UserTestUtils.createUser("testUser", admin.getOrg().getId());
      Package pkg = PackageTest.createTestPackage(user.getOrg());
      
      Object[] result = handler.listDependencies(adminKey,
                                                     new Integer(pkg.getId().intValue()));
      //test package shouldn't have any deps yet
      assertEquals(0, result.length);
    }
    
    public void testRemovePackage() throws Exception {
        User user = UserTestUtils.createUser("testUser", admin.getOrg().getId());
        Package pkg = PackageTest.createTestPackage(user.getOrg());
        handler.removePackage(adminKey, new Integer(pkg.getId().intValue()));
    }
    
    
    public void testFindByNevra() throws Exception {
        Package p = PackageTest.createTestPackage(admin.getOrg());
        
        List<Package> newP = handler.findByNvrea(adminKey, p.getPackageName().getName(), 
                p.getPackageEvr().getVersion(), p.getPackageEvr().getRelease(), 
                p.getPackageEvr().getEpoch(), p.getPackageArch().getLabel());
        assertTrue(newP.size() == 1);
        assertEquals(p, newP.get(0));
        newP = handler.findByNvrea(adminKey, p.getPackageName().getName(), 
                p.getPackageEvr().getVersion(), p.getPackageEvr().getRelease(), 
                "", p.getPackageArch().getLabel());
        assertTrue(newP.size() == 1);
        assertEquals(p, newP.get(0));
    }
    
}
