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

import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.server.SatelliteServer;
import com.redhat.rhn.testing.RhnBaseTestCase;

public class SatelliteServerTest extends RhnBaseTestCase {

    public void testSatServer() throws Exception {
        /* This test and class are pending removal...
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled(),
                ServerFactoryTest.TYPE_SERVER_SATELLITE);
        //flushAndEvict(server);
        Server s = ServerFactory.lookupById(server.getId());
        assertNotNull("Server not found", s);
        assertTrue("Server object returned is NOT a SpacewalkServer",
                s instanceof SatelliteServer);
        assertTrue(s.isSatellite());
        assertFalse(s.isProxy());
        */
    }

    public void testSetVersion() {
        SatelliteServer ss = new SatelliteServer();
        ss.setVersion("4.1.0");
        PackageEvr evr = ss.getVersion();
        assertNotNull(evr);
        assertNull(evr.getEpoch());
        assertEquals("4.1.0", evr.getVersion());
        assertEquals("1", evr.getRelease());
    }
}
