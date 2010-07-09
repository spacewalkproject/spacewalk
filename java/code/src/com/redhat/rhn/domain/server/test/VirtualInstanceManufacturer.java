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

import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;
import com.redhat.rhn.domain.server.VirtualInstanceState;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.TestUtils;

/**
 * A factory for VirtualInstance objects.
 *
 * @version $Rev$
 */
public class VirtualInstanceManufacturer {

    private User user;
    private static final int DEFAULT_GUEST_RAM_MB = 256;

    public VirtualInstanceManufacturer(User theUser) {
        this.user = theUser;
    }

    public VirtualInstance newUnregisteredGuest() throws Exception {
        VirtualInstance guest = createVirtualInstance(
                VirtualInstanceFactory.getInstance().getRunningState());
        guest.setHostSystem(ServerFactoryTest.createTestServer(user));

        return guest;
    }

    private VirtualInstance createVirtualInstance(VirtualInstanceState state) {
        VirtualInstance guest = new VirtualInstance();
        String unique = TestUtils.randomString();
        guest.setUuid(unique);
        guest.setName(unique);
        guest.setType(VirtualInstanceFactory.getInstance().getParaVirtType());
        guest.setTotalMemory(new Long(1024 * DEFAULT_GUEST_RAM_MB));
        guest.setState(state);
        guest.setNumberOfCPUs(new Integer(1));

        return guest;
    }

    public VirtualInstance newRegisteredGuestWithoutHost() throws Exception {
        VirtualInstance guest = createVirtualInstance(
                VirtualInstanceFactory.getInstance().getRunningState());
        guest.setGuestSystem(ServerFactoryTest.createTestServer(user));
        return guest;
    }

    public VirtualInstance newRegisteredGuestWithoutHost(VirtualInstanceState state)
        throws Exception {
        VirtualInstance guest = createVirtualInstance(state);
        guest.setGuestSystem(ServerFactoryTest.createTestServer(user));

        return guest;
    }

    public VirtualInstance newRegisteredGuestWithHost() throws Exception {
        VirtualInstance guest = newRegisteredGuestWithoutHost();
        guest.setHostSystem(ServerFactoryTest.createTestServer(user));

        return guest;
    }

}
