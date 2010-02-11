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

import com.redhat.rhn.domain.rhnpackage.PackageCapability;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * PackageCapabilityTest
 * @version $Rev$
 */
public class PackageCapabilityTest extends RhnBaseTestCase {
    
    /**
     * Simple test to make sure we can create 
     * PackageCapabilities and write them to the db.
     * @throws Exception Exception
     */
    public void testPackageCapability() throws Exception {

        PackageCapability p = createTestCapability();
        assertNotNull(p);
        assertNotNull(p.getId());

    }
    
    /**
     * Create a test PackageCapability
     * @return Returns a committed test PackageCapability
     * @throws Exception
     */
    public static PackageCapability createTestCapability() throws Exception {
        return createTestCapability("Test Name " + TestUtils.randomString());
    }
    
    /**
     * Create a test PackageCapability
     * @return Returns a committed test PackageCapability
     * @throws Exception
     */
    public static PackageCapability createTestCapability(String capabilityName) 
    throws Exception {
        PackageCapability p = new PackageCapability();
        p.setName(capabilityName);
        p.setVersion("-1.0");
        p.setCreated(new Date());
        p.setModified(new Date());
        
        TestUtils.saveAndFlush(p);
        return p;
    }

}
