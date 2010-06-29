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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.org.UpdateOrgSystemEntitlementsCommand;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

/**
 * ServerGroupTest
 * @version $Rev$
 */
public class ServerGroupTest extends RhnBaseTestCase {
    public static final long DEFAULT_MAX_MEMBERS = 10;
    
    public void testEquals() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testorg");
        ServerGroup sg1 = ServerGroupTestUtils.createManaged(user);
        ServerGroup sg2 = new ServerGroup();
        
        assertFalse(sg1.equals(sg2));
        assertFalse(sg1.equals("foo"));
        
        Session session = HibernateFactory.getSession();
        sg2 = (ServerGroup) session.getNamedQuery("ServerGroup.lookupByIdAndOrg")
                                            .setParameter("id", sg1.getId())
                                            .setParameter("org", user.getOrg())
                                            .uniqueResult();
                                                
        assertEquals(sg1, sg2);
    }
    
    /* Commented out while we redo the virtualization entitlements
    public void testVirtServerGroup() {
        assertNotNull(ServerConstants.getServerGroupTypeVirtualizationEntitled());
    }*/
    
    /**
     * @param user
     */
    public static void checkSysGroupAdminRole(User user) {
        if (!user.hasRole(RoleFactory.SYSTEM_GROUP_ADMIN)) {
            user.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
        }
    }    
    
    public static ServerGroup createTestServerGroup(Org org,
                                            ServerGroupType typeIn) 
        throws Exception {
        
        if (typeIn != null) {
            EntitlementServerGroup existingGroup = 
                        ServerGroupFactory.lookupEntitled(org, typeIn);
            if (existingGroup != null) {
                return existingGroup;    
            }
            else {
                assertNull(new UpdateOrgSystemEntitlementsCommand(
                        typeIn.getAssociatedEntitlement(), org,
                        DEFAULT_MAX_MEMBERS).store());
                EntitlementServerGroup group = ServerGroupFactory.lookupEntitled(
                                            typeIn.getAssociatedEntitlement(), org); 
                assertNotNull(group);
                assertNotNull(group.getMaxMembers());
                assertTrue(group.getMaxMembers() > 0);
                assertTrue(group.getMaxMembers() - group.getCurrentMembers() > 0);
                assertNotNull(group.getGroupType().getAssociatedEntitlement());
                return group;
            }
            
        }
        ManagedServerGroup sg = ServerGroupFactory.create("NewGroup" +
                                                        TestUtils.randomString(), 
                                                            "RHN Managed Group", 
                                                            org);
        assertNotNull(sg.getId());
        return sg;
    }

    public void testGetServerGroupTypeFeatures() throws Exception {
        Org org1 = UserTestUtils.findNewOrg("testOrg");
        assertTrue(org1.getEntitledServerGroups().size() > 0);
        assertNotNull(org1.getEntitledServerGroups().get(0).getGroupType().getFeatures());
        assertTrue(org1.getEntitledServerGroups().get(0).getGroupType().
                                                        getFeatures().size() > 0);
    }
    
}
