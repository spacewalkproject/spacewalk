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
package com.redhat.rhn.manager.entitlement.test;

import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * EntitlementManagerTest
 * @version $Rev$
 */
public class EntitlementManagerTest extends RhnBaseTestCase {

    public void testGetEntitlementByName() {
        assertNull(EntitlementManager.getByName(null));
        assertNull(EntitlementManager.getByName("foo"));
        
        Entitlement ent = EntitlementManager.getByName(
                    EntitlementManager.SW_MGR_ENTITLED); 
        assertNotNull(ent);
        assertEquals(EntitlementManager.UPDATE, ent);
        
        ent = EntitlementManager.getByName("enterprise_entitled"); 
        assertNotNull(ent);
        assertEquals(EntitlementManager.MANAGEMENT, ent);
        
    }
    
    public void testGetVirtEnt() {
        Entitlement ent = EntitlementManager.getByName(
                EntitlementManager.VIRTUALIZATION_ENTITLED); 
        assertNotNull(ent);
        assertEquals(EntitlementManager.VIRTUALIZATION, ent);

        Entitlement entplat = EntitlementManager.getByName(
                EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED); 
        assertNotNull(entplat);
        assertEquals(EntitlementManager.VIRTUALIZATION_PLATFORM, entplat);

    }
    
    public void testGetUsedEntitlements() {
        assertNotNull(EntitlementManager.
                getUsedEntitlements(EntitlementManager.MANAGEMENT,
                        OrgFactory.getSatelliteOrg()));
    }
}
