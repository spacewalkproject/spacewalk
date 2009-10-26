/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.kickstart.profile.software.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartPackage;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.frontend.xmlrpc.kickstart.profile.software.SoftwareHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * SoftwareHandlerTest
 * @version $Rev$
 */
public class SoftwareHandlerTest extends BaseHandlerTestCase {
    
    private SoftwareHandler handler = new SoftwareHandler();

    public void testGetSoftwareList() throws Exception {
        
        KickstartData ksProfile  = KickstartDataTest.createKickstartWithProfile(admin);

        List<String> packages = handler.getSoftwareList(adminKey, ksProfile.getLabel());

        // Note: the test profile created should have had at least 1 package listed
        assertTrue(ksProfile.getKsPackages().size() > 0);
        assertEquals(ksProfile.getKsPackages().size(), packages.size());
    }
    
    public void testSetSoftwareList() throws Exception {
        
        KickstartData ksProfile  = KickstartDataTest.createKickstartWithProfile(admin);

        List<String> packages = new ArrayList<String>();
        packages.add("gcc");
        
        int result = handler.setSoftwareList(adminKey, ksProfile.getLabel(), packages);
        
        boolean pkgFound = false;
        for (Iterator<KickstartPackage> itr = ksProfile.getKsPackages().iterator();
             itr.hasNext();) {
              KickstartPackage pkg = (KickstartPackage) itr.next(); 
              if (pkg.getPackageName().getName().equals("gcc")) {
                  pkgFound = true;
                  
              }
        }
        assertEquals(1, result);
        assertEquals(ksProfile.getKsPackages().size(), 1);
        assertEquals(pkgFound, true);
    }
    
    public void testAppendToSoftwareList() throws Exception {
        
        KickstartData ksProfile  = KickstartDataTest.createKickstartWithProfile(admin);

        int numPackagesInitial = ksProfile.getKsPackages().size();
        
        List<String> packages = new ArrayList<String>();
        packages.add("bash");
        packages.add("gcc");
        
        int result = handler.appendToSoftwareList(adminKey, ksProfile.getLabel(), packages);

        assertEquals(1, result);
        assertEquals(numPackagesInitial + packages.size(), 
                ksProfile.getKsPackages().size());
        
        // attempt to add the same packages again and verify that the list did not change
        // (i.e. we don't allow duplicates)
        result = handler.appendToSoftwareList(adminKey, ksProfile.getLabel(), packages);

        assertEquals(1, result);
        assertEquals(numPackagesInitial + packages.size(), 
                ksProfile.getKsPackages().size());
    }
}
