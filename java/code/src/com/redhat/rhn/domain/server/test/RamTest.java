/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RamTest extends RhnBaseTestCase {

    public void testRam() throws Exception {

        User u = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        Server server = ServerFactoryTest.createTestServer(u);
        assertNotNull(server);
        assertNotNull(server.getId());

        server.setRam(1024);
        server.setSwap(256);

        TestUtils.saveAndFlush(server);
        verifyInDb(server.getId(), 1024, 256);

        server.setRam(2048);
        server.setSwap(512);

        TestUtils.saveAndFlush(server);
        verifyInDb(server.getId(), 2048, 512);

        assertEquals(1, TestUtils.removeObject(server));
    }


    private void verifyInDb(Long serverId, long ram, long swap) throws Exception {
        HibernateFactory.getSession().doWork(connection -> {
            ResultSet rs = null;
            PreparedStatement ps = null;
            try {
                ps = connection.prepareStatement("SELECT id, ram, swap FROM rhnRam " +
                   "  WHERE server_id = " + serverId);
                rs = ps.executeQuery();
                rs.next();

                assertEquals(ram, rs.getLong("RAM"));
                assertEquals(swap, rs.getLong("SWAP"));
            }
            finally {
                rs.close();
                ps.close();
            }
        });
    }
}
