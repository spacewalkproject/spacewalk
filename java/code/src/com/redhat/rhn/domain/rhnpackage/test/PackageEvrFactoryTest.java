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

import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * PackageEvrTest
 * @version $Rev$
 */
public class PackageEvrFactoryTest extends RhnBaseTestCase {
    
    /**
     * Simple test to make sure we can create 
     * PackageEvrs and write them to the db.
     * @throws Exception Exception
     */    
    public void testCreate() throws Exception {
       
       PackageEvr evr = createTestPackageEvr();
       assertNotNull(evr.getId());
       
       //Make sure it got into the db
       PackageEvr evr2 = PackageEvrFactory.lookupPackageEvrById(evr.getId());
       assertNotNull(evr2);
       assertEquals(evr.getEpoch(), evr2.getEpoch());     
    }
    
    /**
     * Test method to create a test PackageEvr
     * @return Returns a test PackageEvr
     */
    public static PackageEvr createTestPackageEvr() {
        String epoch = "1"; 
        String version = "1.0.0";
        String release = "1";
        
        return PackageEvrFactory.createPackageEvr(epoch, version, release);
    }
}
