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

import com.redhat.rhn.domain.server.CPU;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * CPUTest
 * @version $Rev$
 */
public class CPUTest extends RhnBaseTestCase {
    
    public static final String ARCH_NAME = "athlon";
    public static final String FAMILY = "Laconia";
    public static final String MODEL = "Inevitable";
    public static final String MHZ = "500";
    public static final long MHZ_NUMERIC = 500;
    
    public void testCreateLookup() throws Exception {
        CPU unit = createTestCpu();
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(user);
        
        unit.setServer(server);
        server.setCpu(unit);
        
        ServerFactory.save(server);
        flushAndEvict(server);
        
        assertNotNull(unit.getId());
        Server server2 = ServerFactory.lookupByIdAndOrg(server.getId(), 
                user.getOrg());
        assertNotNull(server2.getCpu());
        assertEquals(unit.getFamily(), server2.getCpu().getFamily());
        assertEquals(unit.getArch(), server2.getCpu().getArch());
    }
    
    /**
     * Helper method to create a test CPU object
     * @return Returns test CPU object
     * @throws Exception
     */
    public static CPU createTestCpu() throws Exception {
        CPU cpu = new CPU();
        User user = UserTestUtils.createUser("testuser",
                UserTestUtils.createOrg("testorg"));
        Server s = ServerFactoryTest.createTestServer(user);
        cpu.setArch(ServerFactory.lookupCPUArchByName(ARCH_NAME));
        cpu.setServer(s);
        cpu.setFamily(FAMILY);
        cpu.setMHz(MHZ);
        cpu.setModel(MODEL);
        
        assertNull(cpu.getId());
        TestUtils.saveAndFlush(cpu);
        assertNotNull(cpu.getId());
        
        return cpu;
    }

}
