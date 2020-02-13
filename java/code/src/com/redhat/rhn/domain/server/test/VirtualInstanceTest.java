/**
 * Copyright (c) 2009--2017 Red Hat, Inc.
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
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.Sequence;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;


/**
 * VirtualInstanceTest
 * @version $Rev$
 */
public class VirtualInstanceTest extends RhnBaseTestCase {

    private class GuestStub extends VirtualInstance {
        GuestStub(Long id) {
            super(id);
        }
    }

    private Sequence idSequence;

    protected void setUp() throws Exception {
        super.setUp();
        idSequence = new Sequence();
    }

    public void testIsRegisteredGuest() {
        VirtualInstance virtualInstance = new VirtualInstance();
        virtualInstance.setGuestSystem(ServerFactory.createServer());

        assertTrue(virtualInstance.isRegisteredGuest());
    }

    public void testIsNotRegisteredGuest() {
        assertFalse(new VirtualInstance().isRegisteredGuest());
    }

    public void testEqualsAndHashCode() throws Exception {
        Server host = ServerTestUtils.createTestSystem();
        Server guest = ServerTestUtils.createTestSystem();
        String uuid1 = TestUtils.randomString();
        String uuid2 = TestUtils.randomString();

        VirtualInstance refGuest = createVirtualInstance(host, guest, uuid1);

        assertEquals(refGuest, createVirtualInstance(host, guest, uuid1));
        assertFalse(refGuest.equals(createVirtualInstance(host, guest, uuid2)));
    }

    private VirtualInstance createVirtualInstance(Server host, Server guest, String uuid) {
        VirtualInstance virtualInstance = new VirtualInstance();
        virtualInstance.setHostSystem(host);
        virtualInstance.setGuestSystem(guest);
        virtualInstance.setUuid(uuid);
        return virtualInstance;
    }

    public void testGetNullInfo() {
        VirtualInstance instance = new GuestStub(idSequence.nextLong());
        instance.getName();
    }


}
