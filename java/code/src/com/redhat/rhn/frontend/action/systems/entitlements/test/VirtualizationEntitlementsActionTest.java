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
package com.redhat.rhn.frontend.action.systems.entitlements.test;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.action.systems.entitlements.VirtualizationEntitlementsAction;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;

import java.util.List;


/**
 * VirtualizationEntitlementsActionTest
 * @version $Rev$
 */
public class VirtualizationEntitlementsActionTest extends RhnMockStrutsTestCase {

    public void testLimitedExecute() throws Exception {
        // Create a host with virt + 5 guests
        Server server = ServerTestUtils.createVirtHostWithGuests(user, 1);
        for (int i = 0; i < 4; i++) {
            ServerTestUtils.addGuestToServer(user, server);
        }
        TestUtils.saveAndFlush(server);

        setRequestPathInfo("/systems/entitlements/GuestLimitedHosts");
        actionPerform();
        List pageList = (List) getRequest().
            getAttribute(VirtualizationEntitlementsAction.PAGELIST);
        assertNotNull(pageList);
        assertTrue(pageList.size() > 0);
    }

    public void testListGuestUnlimited() throws Exception {

        Server server = ServerTestUtils.createVirtPlatformHostWithGuest(user);

        for (int i = 0; i < 3; ++i) {
            ServerTestUtils.addGuestToServer(user, server);
        }

        TestUtils.saveAndFlush(server);

        setRequestPathInfo("/systems/entitlements/GuestUnlimitedHosts");
        actionPerform();

        List pageList = (List)getRequest().getAttribute(
                VirtualizationEntitlementsAction.PAGELIST);

        assertNotNull(pageList);
        assertTrue(pageList.size() > 0);
    }

    public void testPhysicalExecute() throws Exception {
        // Create a host with 1 guest
        Server server = ServerTestUtils.createVirtHostWithGuests(user, 1);
        SystemManager.removeServerEntitlement(server.getId(),
                EntitlementManager.VIRTUALIZATION);
        TestUtils.saveAndFlush(server);

        setRequestPathInfo("/systems/entitlements/PhysicalHosts");
        actionPerform();
        List pageList = (List) getRequest().
            getAttribute(VirtualizationEntitlementsAction.PAGELIST);
        assertNotNull(pageList);
        assertTrue(pageList.size() > 0);
    }
}
