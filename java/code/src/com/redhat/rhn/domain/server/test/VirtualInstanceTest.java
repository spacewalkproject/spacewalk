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

import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.testing.Sequence;

import com.gargoylesoftware.base.testing.EqualsTester;

import junit.framework.TestCase;


/**
 * VirtualInstanceTest
 * @version $Rev$
 */
public class VirtualInstanceTest extends TestCase {

    private class GuestStub extends VirtualInstance {
        public GuestStub(Long id) {
            super(id);
        }
    }

    private Sequence idSequence;

    protected void setUp() throws Exception {
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


    public void testEqualsAndHashCode() {
        VirtualInstance guestA = new GuestStub(idSequence.nextLong());
        VirtualInstance guestB = new GuestStub(guestA.getId());
        VirtualInstance guestC = new GuestStub(idSequence.nextLong());

        new EqualsTester(guestA, guestB, guestC, new Object());
    }

    public void testGetNullInfo() {
        VirtualInstance instance = new GuestStub(idSequence.nextLong());
        instance.getName();
    }


}
