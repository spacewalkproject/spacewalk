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

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * ServerGroupTest
 * @version $Rev$
 */
public class ServerGroupTest extends RhnBaseTestCase {

    
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
                EntitlementServerGroup group = new EntitlementServerGroup();
                group.setMaxMembers(new Long(10));
                group.setName(typeIn.getName());
                group.setDescription(typeIn.getName());
                group.setOrg(org);
                ServerGroupFactory.save(group);
                return updateGroupType(group, typeIn);
            }
            
        }
        ManagedServerGroup sg = ServerGroupFactory.create("NewGroup", 
                                                            "RHN Managed Group", 
                                                            org);
        assertNotNull(sg.getId());
        return sg;
    }
    

    private  static EntitlementServerGroup updateGroupType(EntitlementServerGroup sg,
                                                            ServerGroupType type)
        throws SQLException {
        
        WriteMode m = ModeFactory.getWriteMode("test_queries",
                                                    "update_group_type");
        Map params = new HashMap();
        params.put("sgid", sg.getId());
        params.put("type_id", type.getId());
        m.executeUpdate(params);
        return (EntitlementServerGroup) TestUtils.reload(sg);
    }
    
    public void testGetServerGroupTypeFeatures() throws Exception {
        Org org1 = UserTestUtils.findNewOrg("testOrg");
        assertTrue(org1.getEntitledServerGroups().size() > 0);
        assertNotNull(org1.getEntitledServerGroups().get(0).getGroupType().getFeatures());
        assertTrue(org1.getEntitledServerGroups().get(0).getGroupType().
                                                        getFeatures().size() > 0);
    }
    
}
