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
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.collections.CollectionUtils;
import org.hibernate.Session;

import java.util.HashSet;
import java.util.Set;

/**
 * VirtualInstanceFactoryTest
 * @version $Rev$
 */
public class VirtualInstanceFactoryTest extends RhnBaseTestCase {

    private VirtualInstanceFactory virtualInstanceDAO;
    private User user;
    private GuestBuilder builder;

    protected void setUp() throws Exception {
        super.setUp();

        virtualInstanceDAO = new VirtualInstanceFactory();
        user = UserTestUtils.findNewUser("testUser", "testOrg");
        builder = new GuestBuilder(user);
    }

    private void assertGuestDeleted(VirtualInstance guest) {
        assertNull(virtualInstanceDAO.lookupById(guest.getId()));
    }

    private void assertGuestDeleted(VirtualInstance guest, Server guestSystem) {
        assertNull(ServerFactory.lookupById(guestSystem.getId()));
        assertGuestDeleted(guest);
    }

    private void flushAndEvictGuest(VirtualInstance guest) {
        Session session = VirtualInstanceFactory.getSession();

        flushAndEvict(guest);

        if (guest.isRegisteredGuest()) {
            session.evict(guest.getGuestSystem());
        }

        if (guest.getHostSystem() != null) {
            session.evict(guest.getHostSystem());
        }
    }

    /**
     * @param name
     */
    public VirtualInstanceFactoryTest(String name) {
        super(name);
    }

    public void testSaveUnregisteredGuestAndLoadById() throws Exception {
        VirtualInstance guest = builder.createUnregisteredGuest()
                .withVirtHost().build();

        virtualInstanceDAO.saveVirtualInstance(guest);

        flushAndEvictGuest(guest);

        VirtualInstance retrievedVirtualInstance = virtualInstanceDAO
                .lookupById(guest.getId());

        assertEquals(guest, retrievedVirtualInstance);
    }

    public void testSaveRegisteredGuestAndLoadById() throws Exception {
        VirtualInstance guest = builder.createGuest().withVirtHost().build();
        Server guestSystem = guest.getGuestSystem();

        virtualInstanceDAO.saveVirtualInstance(guest);

        flushAndEvict(guest);

        VirtualInstance retrievedGuest = virtualInstanceDAO.lookupById(guest
                .getId());

        assertEquals(guest, retrievedGuest);
        assertEquals(guestSystem, retrievedGuest.getGuestSystem());
    }

    public void testDeleteUnregisteredGuest() throws Exception {
        // step 1 - create a guest in the database
        VirtualInstance guest = builder.createUnregisteredGuest()
                .withVirtHost().build();
        virtualInstanceDAO.saveVirtualInstance(guest);
        flushAndEvictGuest(guest);

        // step 2 - fetch the guest from the database so that it is attached to the session
        VirtualInstance retrievedGuest = virtualInstanceDAO.lookupById(guest
                .getId());

        // step 3 - delete the guest
        virtualInstanceDAO.deleteVirtualInstance(retrievedGuest);
        flushAndEvictGuest(retrievedGuest);

        assertGuestDeleted(guest);
    }

    public void testGetGuestsAndNotHost() throws Exception {

        VirtualInstance vi = builder.createUnregisteredGuest()
            .withVirtHost().build();
        virtualInstanceDAO.saveVirtualInstance(vi);
        Long sid = vi.getHostSystem().getId();
        flushAndEvictGuest(vi);

        //step 2 - fetch the guest from the database so that it is attached to the session
        VirtualInstance retrievedGuest = virtualInstanceDAO.lookupById(vi
                .getId());

        assertNotNull(retrievedGuest.getHostSystem());

        Server s = ServerFactory.lookupById(sid);
        assertEquals(1, s.getGuests().size());

    }

    public void testDeleteRegisteredGuestWithVirtHost() throws Exception {
        // step 1 - create a guest in the database
        VirtualInstance guest = builder.createGuest().withVirtHost().build();
        //Server guestSystem = guest.getGuestSystem();
        virtualInstanceDAO.saveVirtualInstance(guest);
        flushAndEvictGuest(guest);
        flushAndEvict(guest.getHostSystem());

        // step 2 - fetch the guest so that it is attached to the session
        VirtualInstance retrievedGuest = virtualInstanceDAO.lookupById(guest
                .getId());
        Server guestSystem = retrievedGuest.getGuestSystem();

        // step 3 - delete the guest
        virtualInstanceDAO.deleteVirtualInstance(retrievedGuest);
        flushAndEvictGuest(retrievedGuest);
        flushAndEvict(retrievedGuest.getHostSystem());

        assertGuestDeleted(guest, guestSystem);
    }

    public void testDeleteGuestWithoutAHost() throws Exception {
        // step 1 - create a guest in the database
        VirtualInstance guest = builder.createGuest().withPersistence().build();

        // step 2 - fetch the guest so it is attached to the session
        VirtualInstance retrievedGuest = virtualInstanceDAO.lookupById(guest
                .getId());
        Server guestSystem = retrievedGuest.getGuestSystem();

        // step 3 - delete the guest
        virtualInstanceDAO.deleteVirtualInstance(retrievedGuest);
        flushAndEvict(guest);

        assertGuestDeleted(guest, guestSystem);
    }

    public void testSaveAndRetrieveInfo() throws Exception {
        VirtualInstance guest = builder.createUnregisteredGuest()
                .withVirtHost().withName("the_virtual_one").asParaVirtGuest()
                .inStoppedState().build();

        virtualInstanceDAO.saveVirtualInstance(guest);
        flushAndEvict(guest);

        VirtualInstance retrievedGuest = virtualInstanceDAO.lookupById(guest
                .getId());

        assertEquals(guest.getName(), retrievedGuest.getName());
        assertEquals(guest.getType(), retrievedGuest.getType());
        assertEquals(guest.getState(), retrievedGuest.getState());
        assertEquals(guest.getTotalMemory(), retrievedGuest.getTotalMemory());
        assertEquals(guest.getNumberOfCPUs(), retrievedGuest.getNumberOfCPUs());
    }

    /**
     * Commeting out test for satellite.
    public void testFindGuestsWithNonVirtHostByOrg() throws Exception {
        Set expectedViews = new HashSet();

        expectedViews.add(builder.createGuest().withNonVirtHost()
                .withPersistence().build().asGuestAndNonVirtHostView());
        expectedViews.add(builder.createGuest().withNonVirtHost()
                .withPersistence().build().asGuestAndNonVirtHostView());
        expectedViews.add(builder.createGuest().withNonVirtHostInAnotherOrg()
                .withPersistence().build().asGuestAndNonVirtHostView());
        expectedViews.add(builder.createGuest().withVirtHostInAnotherOrg()
                .withPersistence().build().asGuestAndNonVirtHostView());

        builder.createGuest().withVirtHost().withPersistence().build();
        builder.createGuest().withVirtPlatformHost().withPersistence().build();
        builder.createGuest().withPersistence().build();

        Set actualViews = virtualInstanceDAO
                .findGuestsWithNonVirtHostByOrg(user.getOrg());

        assertTrue(CollectionUtils
                .isEqualCollection(expectedViews, actualViews));
    }*/


    public void testFindGuestsWithoutAHostByOrg() throws Exception {
        Set expectedViews = new HashSet();

        expectedViews.add(builder.createGuest().withPersistence().build()
                .asGuestAndNonVirtHostView());
        expectedViews.add(builder.createGuest().withPersistence().build()
                .asGuestAndNonVirtHostView());

        builder.createGuest().withNonVirtHostInAnotherOrg().withPersistence().build();
        builder.createGuest().withNonVirtHost().withPersistence().build();
        builder.createGuest().withVirtHost().withPersistence().build();
        builder.createGuest().withVirtPlatformHost().withPersistence().build();

        Set actualViews = virtualInstanceDAO.findGuestsWithoutAHostByOrg(user
                .getOrg());

        assertTrue(CollectionUtils
                .isEqualCollection(expectedViews, actualViews));
    }

    public void testGetParaVirt() {
        assertEquals("Para-Virtualized", VirtualInstanceFactory.getInstance().
                getParaVirtType().getName());
        assertEquals("para_virtualized", VirtualInstanceFactory.getInstance().
                getParaVirtType().getLabel());
    }

    public void testFullyVirt() {
        assertEquals("Fully Virtualized", VirtualInstanceFactory.getInstance().
                getFullyVirtType().getName());
        assertEquals("fully_virtualized", VirtualInstanceFactory.getInstance().
                getFullyVirtType().getLabel());
    }

    public void testGetRunning() {
        assertEquals("running", VirtualInstanceFactory.getInstance()
                .getRunningState().getLabel());
        assertEquals("Running", VirtualInstanceFactory.getInstance()
                .getRunningState().getName());
    }

    public void testGetStopped() {
        assertEquals("stopped", VirtualInstanceFactory.getInstance()
                .getStoppedState().getLabel());
        assertEquals("Stopped", VirtualInstanceFactory.getInstance()
                .getStoppedState().getName());
    }

    public void testGetCrashed() {
        assertEquals("crashed", VirtualInstanceFactory.getInstance()
                .getCrashedState().getLabel());
        assertEquals("Crashed", VirtualInstanceFactory.getInstance()
                .getCrashedState().getName());
    }

    public void testGetPaused() {
        assertEquals("paused", VirtualInstanceFactory.getInstance()
                .getPausedState().getLabel());
        assertEquals("Paused", VirtualInstanceFactory.getInstance()
                .getPausedState().getName());
    }

    public void testGetUnknown() {
        assertEquals("unknown", VirtualInstanceFactory.getInstance()
                .getUnknownState().getLabel());
        assertEquals("Unknown", VirtualInstanceFactory.getInstance()
                .getUnknownState().getName());
    }

    public void testSetState() throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuest();
        VirtualInstance vi = ((VirtualInstance) host.getGuests().iterator().next());
        vi.setState(VirtualInstanceFactory.getInstance().getRunningState());
        TestUtils.saveAndFlush(vi);
        assertTrue(vi.getState() != null);
    }

}
