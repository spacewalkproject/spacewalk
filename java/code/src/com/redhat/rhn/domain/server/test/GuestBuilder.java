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
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

/**
 * GuestBuilder is a class based on the GoF Builder pattern that constructs
 * VirtualInstance guests.
 * 
 * @version $Rev$
 */
public class GuestBuilder {

    private User owner;
    private VirtualInstanceFactory guestDAO;
    private VirtualInstance guest;
    private boolean isSaveRequired;

    public GuestBuilder(User theOwner) {
        owner = theOwner;
        guestDAO = VirtualInstanceFactory.getInstance();
    }

    /**
     * This is the final step in building or compiling a guest. The builder does
     * not maintain a reference to a guest once it is built; so, calling
     * <code>build</code> successive times will simply return
     * <code>null</code>. One of the <i>create</i> methods must be called
     * before every invocation of this method.
     * 
     * @return The built virtual instance
     * 
     * @throws GuestBuilderException if the guest is not registered and has no
     * host.
     */
    public VirtualInstance build() throws GuestBuilderException {
        if (guest == null) {
            return null;
        }

        if (!guest.isRegisteredGuest() && guest.getHostSystem() == null) {
            throw new GuestBuilderException(
                    "Cannot build an unregistered guest " + "without a host.");
        }

        if (isSaveRequired) {
            save();
        }

        VirtualInstance compiledGuest = guest;
        guest = null;

        return compiledGuest;
    }

    private void save() {
        Session session = VirtualInstanceFactory.getSession();

        guestDAO.saveVirtualInstance(guest);
        session.flush();
        session.evict(guest);

        if (guest.isRegisteredGuest()) {
            session.evict(guest.getGuestSystem());
        }

        if (guest.getHostSystem() != null) {
            session.evict(guest.getHostSystem());
        }

        isSaveRequired = false;
    }

    /**
     * Creates a guest with a random uuid. An unregistered guest has no guest
     * system associated with it. Note that a host must be specified for the
     * unregistered guest under construction prior to calling {@link #build()}.
     * 
     * @param host A physical, host system
     * 
     * @return This builder
     */
    public GuestBuilder createUnregisteredGuest() {
        guest = new VirtualInstance();
        guest.setUuid(TestUtils.randomString());

        return this;
    }

    /**
     * Creates a guest with a random uuid and an associated registered virtual
     * system. The guest has no host.
     * 
     * @return This builder
     * 
     * @throws Exception if an error occurs
     */
    public GuestBuilder createGuest() throws Exception {
        guest = new VirtualInstance();
        guest.setUuid(TestUtils.randomString());
        guest.setGuestSystem(ServerFactoryTest.createTestServer(owner));

        return this;
    }

    /**
     * Tells the builder that the guest under construction should be persisted
     * to the database. This will also result in the hibernate session being
     * flushed, and the guest and its guest and host systems will be evicted
     * from the session.
     * 
     * @return This builder
     */
    public GuestBuilder withPersistence() {
        isSaveRequired = true;
        return this;
    }

    private GuestBuilder withHost(ServerGroupType groupType) throws Exception {
        Server host = ServerFactoryTest
                .createTestServer(owner, true, groupType);
        guest.setHostSystem(host);

        return this;
    }

    /**
     * Creates the host for the guest under construction. The host will have a
     * management entitlement. It will not have any virtualization entitlements.
     * 
     * @return This builder
     * 
     * @throws Exception if an error occurs.
     */
    public GuestBuilder withNonVirtHost() throws Exception {
        ServerGroupType groupType = ServerConstants
                .getServerGroupTypeEnterpriseEntitled();

        return withHost(groupType);
    }

    /**
     * Creates the host for the guest under construction. The host will have a
     * Virtualization Host entitlement.
     * 
     * @return This builder
     * 
     * @throws Exception if an error occurs.
     */
    public GuestBuilder withVirtHost() throws Exception {
        ServerGroupType groupType = ServerConstants
                .getServerGroupTypeVirtualizationEntitled();

        return withHost(groupType);
    }
    
    /**
     * Creates a host for the guest under construction. The host will be created in a
     * different org than the one the guest belongs to. The host will not have any
     * virtualization entitlements.
     * 
     * @return This builder
     * 
     * @throws Exception if an error occurs
     */
    public GuestBuilder withNonVirtHostInAnotherOrg() throws Exception {
        ServerGroupType groupType = ServerConstants
                .getServerGroupTypeEnterpriseEntitled();
        
        withHostInAnotherOrg(groupType);
        
        return this;    
    }
    
    public GuestBuilder withVirtHostInAnotherOrg() throws Exception {
        ServerGroupType groupType = ServerConstants
                .getServerGroupTypeVirtualizationEntitled();

        withHostInAnotherOrg(groupType);

        return this;
    }
    
    private void withHostInAnotherOrg(ServerGroupType groupType) throws Exception {
        Long orgId = UserTestUtils.createOrg("another-org-" + TestUtils.randomString());
        User otherUser = UserTestUtils.createUser("another-user" + TestUtils.randomString(),
                orgId);
        Server host = ServerFactoryTest.createTestServer(otherUser, true, groupType);
        
        guest.setHostSystem(host);
    }

    /**
     * Creates the host for the guest under construction. The host will have a
     * Virtualization Platform entitlement.
     * 
     * @return This builder
     * 
     * @throws Exception if an error occurs
     */
    public GuestBuilder withVirtPlatformHost() throws Exception {
        ServerGroupType groupType = ServerConstants
                .getServerGroupTypeVirtualizationPlatformEntitled();

        return withHost(groupType);
    }
    
    public GuestBuilder asParaVirtGuest() {
        guest.setType(guestDAO.getParaVirtType());
        return this;
    }

    public GuestBuilder asFullyVirtGuest() {
        guest.setType(guestDAO.getFullyVirtType());
        return this;
    }

    public GuestBuilder withName(String name) {
        guest.setName(name);
        return this;
    }

    public GuestBuilder withTotalMemory(Long memory) {
        guest.setTotalMemory(memory);
        return this;
    }

    public GuestBuilder withCPUs(Integer numberOfCPUs) {
        guest.setNumberOfCPUs(numberOfCPUs);
        return this;
    }

    public GuestBuilder inRunningState() {
        guest.setState(guestDAO.getRunningState());
        return this;
    }

    public GuestBuilder inStoppedState() {
        guest.setState(guestDAO.getStoppedState());
        return this;
    }

    public GuestBuilder inPausedState() {
        guest.setState(guestDAO.getPausedState());
        return this;
    }

    public GuestBuilder inCrashedState() {
        guest.setState(guestDAO.getCrashedState());
        return this;
    }

}
