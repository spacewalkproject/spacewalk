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
import com.redhat.rhn.domain.server.Ram;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * DeviceTest
 * @version $Rev$
 */
public class RamTest extends RhnBaseTestCase {
    
    public void testRam() throws Exception {
        
        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(u);
        assertNotNull(server);
        assertNotNull(server.getId());

        Ram ram = new Ram();
        ram.setServer(server);
        ram.setRam(1024);
        ram.setSwap(256);
        
        TestUtils.saveAndFlush(ram);
        verifyInDb(ram.getId(),  1024, 256);
        assertEquals(1, TestUtils.removeObject(ram));
        // can't seem to be able to delete a server, would be nice
        // to be able to clean up after ourselves.
        //assertEquals(1, TestUtils.removeObject(server));
    }
    
  
    private void verifyInDb(Long id, long ram, long swap) throws Exception {
        // Now lets manually test to see if the user got updated
        Session session = null;
        Connection c = null;
        ResultSet rs = null;
        PreparedStatement ps = null;
        try {
            session = HibernateFactory.getSession();
            c = session.connection();
            assertNotNull(c);
            ps = c.prepareStatement(
                "SELECT ID, RAM, SWAP FROM RHNRAM " +
                "  WHERE ID = " + id);
            rs = ps.executeQuery();
            rs.next();

            assertEquals(id.longValue(), rs.getLong("ID"));
            assertEquals(ram, rs.getLong("RAM"));
            assertEquals(swap, rs.getLong("SWAP"));
        }
        finally {
            rs.close();
            ps.close();
        }
    }
    

}
