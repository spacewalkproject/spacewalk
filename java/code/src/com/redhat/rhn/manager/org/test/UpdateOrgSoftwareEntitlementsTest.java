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
package com.redhat.rhn.manager.org.test;

import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.PrivateChannelFamily;
import com.redhat.rhn.domain.channel.test.ChannelFamilyFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.org.UpdateOrgSoftwareEntitlementsCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.Iterator;


/**
 * UpdateOrgSystemEntitlements
 * @version $Rev$
 */
public class UpdateOrgSoftwareEntitlementsTest extends BaseTestCaseWithUser {
    
    private ChannelFamily fam;
    
    public void setUp() throws Exception {
        super.setUp();
        fam = ChannelFamilyFactoryTest.createTestChannelFamily(
                UserFactory.findRandomOrgAdmin(OrgFactory.getSatelliteOrg()));
    }
    
    private void reloadFamilies() {
        fam = (ChannelFamily) reload(fam);
        Iterator i = fam.getPrivateChannelFamilies().iterator();
        while (i.hasNext()) {
            TestUtils.reload(i.next());
        }
    }

    public void testUpdateEntitlements() throws Exception {
        
        Long origValue = fam.getMaxMembers(OrgFactory.getSatelliteOrg());
        
        UpdateOrgSoftwareEntitlementsCommand cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(1));
        assertNull(cmd.store());
        reloadFamilies();
        
        assertEquals(1, fam.getMaxMembers(user.getOrg()).longValue());
        assertEquals(origValue.longValue() - 1, 
                fam.getMaxMembers(OrgFactory.getSatelliteOrg()).longValue());
        
    }
    
    public void testUpdateTooMany() throws Exception {
        UpdateOrgSoftwareEntitlementsCommand cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(Integer.MAX_VALUE));
        assertNotNull(cmd.store());
    }
    
    public void testReUpdateToConsumeAll() throws Exception {
        Long firstAllocation = ChannelFamilyFactoryTest.ENTITLEMENT_ALLOCATION / 2;
        UpdateOrgSoftwareEntitlementsCommand cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), firstAllocation);
        assertNull(cmd.store());
        TestUtils.reload(fam);
        for (PrivateChannelFamily privFam : fam.getPrivateChannelFamilies()) {
            if (privFam.getOrg().getId().equals(OrgFactory.getSatelliteOrg().getId())) {
                TestUtils.reload(privFam);
            }
        }
        
        // Now give the remaining:
        cmd = new UpdateOrgSoftwareEntitlementsCommand(fam.getLabel(), user.getOrg(), 
                ChannelFamilyFactoryTest.ENTITLEMENT_ALLOCATION);
        assertNull(cmd.store());
    }
    
    public void testLowerEntitlements() throws Exception {
        Long orig = fam.getMaxMembers(OrgFactory.getSatelliteOrg());
        
        UpdateOrgSoftwareEntitlementsCommand cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(1));
        assertNull(cmd.store());
        reloadFamilies();
        Long now = fam.getMaxMembers(OrgFactory.getSatelliteOrg()).longValue();
        assertEquals(orig.longValue() - 1, now.longValue());
        cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(1));
        assertNull(cmd.store());
        reloadFamilies();
        assertEquals(orig.longValue() - 1, now.longValue());
        cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(0));
        cmd.store();
        reloadFamilies();
        now = fam.getMaxMembers(OrgFactory.getSatelliteOrg()).longValue();
        assertEquals(orig.longValue(), now.longValue());
    }
    
    public void testUpdateEntitlementsByOne() throws Exception {
        
        Long origValue = fam.getMaxMembers(OrgFactory.getSatelliteOrg());
        
        UpdateOrgSoftwareEntitlementsCommand cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(1));
        assertNull(cmd.store());
        reloadFamilies();
        cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(2));
        assertNull(cmd.store());
        reloadFamilies();
        assertEquals(2, fam.getMaxMembers(user.getOrg()).longValue());
        assertEquals(origValue.longValue() - 2, 
                fam.getMaxMembers(OrgFactory.getSatelliteOrg()).longValue());
    }

    public void testNullChanFam() throws Exception {
        Iterator i = fam.getPrivateChannelFamilies().iterator();
        while (i.hasNext()) {
            PrivateChannelFamily p = (PrivateChannelFamily) i.next();
            if (p.getOrg().getId().equals(user.getOrg().getId())) {
                p.setMaxMembers(null);
            }
        }
        UpdateOrgSoftwareEntitlementsCommand cmd = new UpdateOrgSoftwareEntitlementsCommand(
                fam.getLabel(), user.getOrg(), new Long(1));
        assertNull(cmd.store());
        
    }
    
}

