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

import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.TestUtils;

import java.util.Collection;
import java.util.HashSet;


/**
 * ServerGroupFactoryTest
 * @version $Rev$
 */
public class ServerGroupFactoryTest extends BaseTestCaseWithUser {
    private ManagedServerGroup managedGroup;
    
    public void setUp() throws Exception {
        super.setUp();
        managedGroup = ServerGroupFactory.create(
                            ServerGroupTestUtils.NAME, 
                            ServerGroupTestUtils.DESCRIPTION, 
                            user.getOrg());
    }
    public void testCreate() throws Exception {
        String name = ServerGroupTestUtils.NAME;
        String description = ServerGroupTestUtils.DESCRIPTION;
        
        assertNotNull(managedGroup);
        assertTrue(managedGroup.getName().startsWith(name));
        assertTrue(managedGroup.getDescription().startsWith(description));
        assertEquals(user.getOrg(), managedGroup.getOrg());

        name += "1";
        managedGroup = ServerGroupFactory.create(name, description, 
                user.getOrg());
        managedGroup = (ManagedServerGroup) reload(managedGroup);
        assertNotNull(managedGroup);
        System.out.println("Name: " + managedGroup.getName());
        System.out.println("Desc: " + managedGroup.getDescription());
        assertTrue(managedGroup.getName().startsWith(name));
        assertTrue(managedGroup.getDescription().startsWith(description));
        assertEquals(user.getOrg(), managedGroup.getOrg());
       
    }
    
    public void testSave() throws Exception {
        EntitlementServerGroup sg = ServerGroupFactory.lookupEntitled(user.getOrg(), 
                    ServerConstants.getServerGroupTypeUpdateEntitled());
        sg.setMaxMembers(new Long(10));
        ServerGroupFactory.save(sg);
        TestUtils.saveAndFlush(sg);
    }

    public void testLookup() throws Exception {
        TestUtils.flushAndEvict(managedGroup);
        ServerGroup sg1 = ServerGroupFactory.lookupByIdAndOrg(managedGroup.getId(), 
                                                    managedGroup.getOrg());
        assertEquals(managedGroup, sg1);
    }
    
    public void testListNoAssociatedAdmins() throws Exception {
        TestUtils.flushAndEvict(managedGroup);
        Collection groups = ServerGroupFactory.listNoAdminGroups(managedGroup.getOrg());
        int initSize = groups.size();
        ServerGroup sg1 = ServerGroupFactory.create(ServerGroupTestUtils.NAME + "ALPHA", 
                ServerGroupTestUtils.DESCRIPTION, 
                user.getOrg());
        Collection groups1 = ServerGroupFactory.listNoAdminGroups(sg1.getOrg());
        assertEquals(initSize + 1, groups1.size());
        groups.add(sg1);
        assertEquals(new HashSet(groups), new HashSet(groups1));
    }    
    
    public void testRemove() throws Exception {
        ServerGroupFactory.remove(managedGroup);
        TestUtils.flushAndEvict(managedGroup);
        ServerGroup sg1 = ServerGroupFactory.lookupByIdAndOrg(managedGroup.getId(), 
                                                    managedGroup.getOrg());
        assertNull(sg1);        
    }
    
    public void testListAdministrators() {
        
    }
}
