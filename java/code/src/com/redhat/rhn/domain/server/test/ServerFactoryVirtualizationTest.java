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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.collections.CollectionUtils;


/**
 * ServerFactoryVirtualizationTest
 * @version $Rev$
 */
public class ServerFactoryVirtualizationTest extends RhnBaseTestCase {

    private VirtualInstanceManufacturer virtualInstanceFactory;
    private User user;

    /**
     * @param name
     */
    public ServerFactoryVirtualizationTest(String name) {
        super(name);
    }

    protected void setUp() throws Exception {
        super.setUp();

        user = UserTestUtils.findNewUser("testUser", "testOrg");
        virtualInstanceFactory = new VirtualInstanceManufacturer(user);
    }

    public void testAddGuestToHostAndSaveHost() throws Exception {
        VirtualInstance virtualInstance =
                virtualInstanceFactory.newRegisteredGuestWithHost();
        Server host = virtualInstance.getHostSystem();
        ServerFactory.save(host);
        flushAndEvict(host);

        Server retrievedHost = ServerFactory.lookupById(host.getId());

        assertTrue(retrievedHost.getGuests().contains(virtualInstance));

        VirtualInstance retInstance = (VirtualInstance)
            retrievedHost.getGuests().iterator().next();

        assertEquals(retInstance.getHostSystem(), retrievedHost);
    }

    public void testDeleteGuestFromHostAndSaveHost() throws Exception {
        VirtualInstance guest =
                virtualInstanceFactory.newRegisteredGuestWithHost();
        Long guestId = guest.getGuestSystem().getId();
        Server host = guest.getHostSystem();
        ServerFactory.save(host);
        Long hostId = host.getId();

        HibernateFactory.getSession().save(guest);
        HibernateFactory.getSession().clear();

        Server retrievedHost = ServerFactory.lookupById(hostId);
        assertFalse(retrievedHost.getGuests().isEmpty());

        assertTrue(retrievedHost.deleteGuest(guest));

        HibernateFactory.getSession().clear();
        Server serverWithoutGuest = ServerFactory.lookupById(hostId);
        Server deletedGuest = ServerFactory.lookupById(guestId);

        assertFalse(serverWithoutGuest.getGuests().contains(deletedGuest));
        assertNull("guest system was not deleted", deletedGuest);
    }

    public void testDeleteGuestNotBelongingToHost() throws Exception {
        VirtualInstance virtualInstance =
                virtualInstanceFactory.newRegisteredGuestWithHost();

        Server otherHost = ServerFactory.createServer();

        assertFalse(otherHost.deleteGuest(virtualInstance));
        assertNotNull("guest system should not have been deleted",
                virtualInstance.getGuestSystem());
    }

    public void testUpdateGuestAndSaveHost() throws Exception {
        // testUpdateGuest() tests updating an already persistent guest. In order to do
        // this, we need to:
        //
        //     1) Add a guest to the server.
        //     2) Save the host (and the guest).
        //     3) Modify the guest outside of a hibernate session.
        //     4) Repeat step one.
        //     5) Retrieve the server and test that it contains the modified guest.

        Server host = ServerFactoryTest.createTestServer(user);

        host.addGuest(virtualInstanceFactory.newRegisteredGuestWithoutHost());

        ServerFactory.save(host);
        flushAndEvict(host);

        VirtualInstance virtualInstance = (VirtualInstance)CollectionUtils.get(
                host.getGuests(), 0);

        String uuid = "abcd";
        virtualInstance.setUuid(uuid);

        ServerFactory.save(host);
        flushAndEvict(host);

        Server retrievedHost = ServerFactory.lookupById(host.getId());

        assertTrue(retrievedHost.getGuests().contains(virtualInstance));
    }

    public void testSaveAndRetrieveGuestServerWithoutAHost() throws Exception {
        // There is a case in which it is possible to have a registered guest without
        // having its host registered. This is a test for this case.

        VirtualInstance virtualInstance =
                virtualInstanceFactory.newRegisteredGuestWithoutHost();

        Server guest = virtualInstance.getGuestSystem();

        ServerFactory.save(guest);
        flushAndEvict(guest);

        Server retrievedGuest = ServerFactory.lookupById(guest.getId());

        assertEquals(guest, retrievedGuest);
        assertEquals(virtualInstance, retrievedGuest.getVirtualInstance());
    }

    public void testSaveAndRetrieveGuestWithAHost() throws Exception {
        VirtualInstance virtualInstance =
                virtualInstanceFactory.newRegisteredGuestWithHost();

        Server guest = virtualInstance.getGuestSystem();
        Server host = virtualInstance.getHostSystem();

        ServerFactory.save(guest);
        flushAndEvict(guest);
        flushAndEvict(host);

        Server retrievedGuest = ServerFactory.lookupById(guest.getId());
        Server retrievedHost = ServerFactory.lookupById(host.getId());

        assertEquals(retrievedGuest, guest);
        assertEquals(virtualInstance, retrievedGuest.getVirtualInstance());
        assertEquals(host, retrievedHost);
    }

    public void testUpdateGuestWithoutAHost() throws Exception {
        VirtualInstance virtualInstance =
                virtualInstanceFactory.newRegisteredGuestWithoutHost();

        Server guest = virtualInstance.getGuestSystem();

        ServerFactory.save(guest);
        flushAndEvict(guest);
        flushAndEvict(virtualInstance);

        Server retrievedGuest = ServerFactory.lookupById(guest.getId());
        retrievedGuest.setName("the_guest");
        retrievedGuest.getVirtualInstance().setConfirmed(true);

        ServerFactory.save(retrievedGuest);
        flushAndEvict(retrievedGuest);

        Server updatedGuest = ServerFactory.lookupById(guest.getId());

        assertEquals(updatedGuest.getName(), retrievedGuest.getName());
        assertEquals(updatedGuest.getVirtualInstance().isConfirmed(),
                retrievedGuest.getVirtualInstance().isConfirmed());
    }

}
