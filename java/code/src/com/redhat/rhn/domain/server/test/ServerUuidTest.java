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

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerUuid;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

/**
 * ServerUuidTest
 * @version $Rev$
 */
public class ServerUuidTest extends RhnBaseTestCase {

    public static final String UUID = "e280ccb0-1f31-11dc-9c52-00425200ea2f";
    
    /** 
     * Simple test to exercise codepaths in ServerUuid class
     * @throws Exception
     */
    public void testServerUuid() throws Exception {
        ServerUuid su1 = createTestServerUuid();
        ServerUuid su2 = new ServerUuid();
        
        assertFalse(su1.equals(su2));
        assertFalse(su1.equals(new Date()));
    }
    
    /**
     * Helper method to create a test ServerUuid object
     * @throws Exception
     */
    public static ServerUuid createTestServerUuid() throws Exception {
        ServerUuid su = new ServerUuid();
        su.setUuid(UUID);
        
        User user = UserTestUtils.createUser("testuser",
                UserTestUtils.createOrg("testorg"));
        
        Server s = ServerFactoryTest.createTestServer(user);
        su.setServer(s);
        
        assertNull(su.getId());
        TestUtils.saveAndFlush(su);
        assertNotNull(su.getId());
        
        return su;
    }
}
