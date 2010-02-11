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
package com.redhat.rhn.frontend.dto.test;

import com.redhat.rhn.frontend.dto.PackageMetadata;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * PackageMetadataTest
 * @version $Rev$
 */
public class PackageMetadataTest extends RhnBaseTestCase {

    /*
     * @see RhnBaseTestCase#setUp()
     */
    protected void setUp() throws Exception {
        super.setUp();
    }

    public void testParameterizedCtor() {
        PackageMetadata pm = new PackageMetadata(null, null);
        
        assertNull(pm.getSystem());
        assertNull(pm.getOther());
        assertEquals(PackageMetadata.KEY_NO_DIFF, pm.getComparisonAsInt());
        assertEquals(PackageMetadata.ACTION_NONE, pm.getActionStatusAsInt());
        
        assertEquals("", pm.getActionStatus());
        assertEquals("", pm.getComparison());
        assertNotNull(pm.toString());
        assertEquals("", pm.getName());
        assertNull(pm.getNameId());
        assertNull(pm.getEvrId());
        
        pm.updateActionStatus();
        assertEquals(PackageMetadata.ACTION_NONE, pm.getActionStatusAsInt());
    }
    
    public void testDefaultCtor() {
        PackageMetadata pm = new PackageMetadata();
        
        assertNotNull(pm.getSystem());
        assertNotNull(pm.getOther());
        assertEquals(PackageMetadata.KEY_NO_DIFF, pm.getComparisonAsInt());
        assertEquals(PackageMetadata.ACTION_NONE, pm.getActionStatusAsInt());
        
        assertEquals("", pm.getActionStatus());
        assertEquals("", pm.getComparison());
        assertNotNull(pm.toString());
        assertNull(pm.getName());
        assertNull(pm.getNameId());
        assertNull(pm.getEvrId());
        
        pm.updateActionStatus();
        assertEquals(PackageMetadata.ACTION_NONE, pm.getActionStatusAsInt());
    }
    
    public void testGetActionStatusAsInt() {
        PackageMetadata pm = new PackageMetadata();
        pm.setComparison(PackageMetadata.KEY_OTHER_NEWER);
        pm.updateActionStatus();
        assertEquals(PackageMetadata.ACTION_UPGRADE, pm.getActionStatusAsInt());
        
        pm.setComparison(PackageMetadata.KEY_THIS_ONLY);
        pm.updateActionStatus();
        assertEquals(PackageMetadata.ACTION_REMOVE, pm.getActionStatusAsInt());
        
        pm.setComparison(PackageMetadata.KEY_THIS_NEWER);
        pm.updateActionStatus();
        assertEquals(PackageMetadata.ACTION_DOWNGRADE, pm.getActionStatusAsInt());
        
        pm.setComparison(PackageMetadata.KEY_OTHER_ONLY);
        pm.updateActionStatus();
        assertEquals(PackageMetadata.ACTION_INSTALL, pm.getActionStatusAsInt());
    }
    
    public void testGetComparison() {
        PackageMetadata pm = new PackageMetadata();
        
        pm.setComparison(PackageMetadata.KEY_OTHER_NEWER);
        assertEquals("Profile newer", pm.getComparison());
        pm.setCompareParam("foo");
        assertEquals("foo newer", pm.getComparison());
        
        pm.setCompareParam(null);
        pm.setComparison(PackageMetadata.KEY_THIS_ONLY);
        assertEquals("This system only", pm.getComparison());
        pm.setCompareParam("foo");
        assertEquals("This system only", pm.getComparison());
        
        pm.setCompareParam(null);
        pm.setComparison(PackageMetadata.KEY_THIS_NEWER);
        assertEquals("This system newer", pm.getComparison());
        pm.setCompareParam("foo");
        assertEquals("This system newer", pm.getComparison());
        
        pm.setCompareParam(null);
        pm.setComparison(PackageMetadata.KEY_OTHER_ONLY);
        assertEquals("Profile only", pm.getComparison());
        pm.setCompareParam("foo");
        assertEquals("foo only", pm.getComparison());
    }
}
