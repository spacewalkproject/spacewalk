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
package com.redhat.rhn.frontend.action.systems.sdc.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.frontend.action.systems.sdc.SystemDetailsEditAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.util.LabelValueBean;

import java.util.Iterator;
import java.util.List;

/**
 * SystemDetailsEditActionTest
 * @version $Rev$
 */
public class SystemDetailsEditActionTest extends RhnMockStrutsTestCase {

    protected Server s;

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/details/Edit");
        UserTestUtils.addProvisioning(user.getOrg());
        TestUtils.saveAndFlush(user.getOrg());

        /*s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());*/
        s = ServerTestUtils.createTestSystem(user);
        ChannelTestUtils.setupBaseChannelForVirtualization(user, s.getBaseChannel());

        UserTestUtils.addProvisioning(user.getOrg());
        UserTestUtils.addMonitoring(user.getOrg());
        UserTestUtils.addVirtualization(user.getOrg());
        UserTestUtils.addVirtualizationPlatform(user.getOrg());
        TestUtils.saveAndFlush(user.getOrg());

        request.addParameter("sid", s.getId().toString());
    }

    public void testBasicFormSubmission() throws Exception {
        request.addParameter(SystemDetailsEditAction.NAME, "Augustus");
        request.addParameter(SystemDetailsEditAction.DESCRIPTION, "First Emperor");
        request.addParameter(SystemDetailsEditAction.ADDRESS_ONE, "Palatine Hill");
        request.addParameter(SystemDetailsEditAction.ADDRESS_TWO, "Forum Romanum");
        request.addParameter(SystemDetailsEditAction.CITY, "Rome");
        request.addParameter(SystemDetailsEditAction.COUNTRY, "it");
        request.addParameter(SystemDetailsEditAction.BUILDING, "Imperial Palace");
        request.addParameter(SystemDetailsEditAction.ROOM, "Imperial Throne Room");
        request.addParameter(SystemDetailsEditAction.RACK, "Imperial PC Rack");
        request.addParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        actionPerform();
        TestUtils.reload(s);
        verifyActionMessage("sdc.details.edit.propertieschanged");
        verifyForwardPath("/systems/details/Overview.do?sid=" + s.getId());
        assertEquals("Augustus", s.getName());
        assertEquals("First Emperor", s.getDescription());
        assertEquals("Palatine Hill", s.getLocation().getAddress1());
        assertEquals("Forum Romanum", s.getLocation().getAddress2());
        assertEquals("Rome", s.getLocation().getCity());
        assertEquals("it", s.getLocation().getCountry());
        assertEquals("Imperial Palace", s.getLocation().getBuilding());
        assertEquals("Imperial Throne Room", s.getLocation().getRoom());
        assertEquals("Imperial PC Rack", s.getLocation().getRack());
    }

    public void testInvalidFormSubmission() throws Exception {
        String originalName = s.getName();
        request.addParameter(SystemDetailsEditAction.NAME, "ha");
        request.addParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        actionPerform();
        verifyForward("error");
        /* Verifying nothing changed */
        assertEquals(originalName, s.getName());
    }

    public void testBaseEntitlementListForEntitledSystem() throws Exception {
        actionPerform();
        verifyForward("default");
        List options = (List) request
                              .getAttribute(SystemDetailsEditAction
                                            .BASE_ENTITLEMENT_OPTIONS);

        boolean unentitledValueFound = false;

        Iterator i = options.iterator();

        while (i.hasNext()) {
            LabelValueBean bean = (LabelValueBean) i.next();

            if (bean.getValue().equals("unentitle")) {
                unentitledValueFound = true;
            }
        }

        assertTrue(unentitledValueFound);
    }

    public void testAddonEntitlemntsList() throws Exception {
        actionPerform();
        assertNotNull(request.getAttribute(SystemDetailsEditAction.ADDON_ENTITLEMENTS));
        List addons = (List)
            request.getAttribute(SystemDetailsEditAction.ADDON_ENTITLEMENTS);
        assertTrue(addons.size() > 0);
    }

    public void testBaseEntitlementListForUnetitledSystem() throws Exception {
        SystemManager.removeAllServerEntitlements(s.getId());
        TestUtils.saveAndFlush(s);
        actionPerform();
        verifyForward("default");
        List options = (List) request
                              .getAttribute(SystemDetailsEditAction
                                            .BASE_ENTITLEMENT_OPTIONS);

        boolean unentitledValueFound = false;

        Iterator i = options.iterator();

        while (i.hasNext()) {
            LabelValueBean bean = (LabelValueBean) i.next();

            if (bean.getValue().equals("none")) {
                unentitledValueFound = true;
            }
        }

        assertTrue(unentitledValueFound);
    }

    public void testAddEntitlement() throws Exception {
        //add the base entitlement to the request to make sure we can
        // process both base and addon.  See BZ 229448
        request.addParameter(SystemDetailsEditAction.BASE_ENTITLEMENT,
                EntitlementManager.MANAGEMENT.getLabel());

        addRequestParameter(EntitlementManager.PROVISIONING_ENTITLED,
                Boolean.TRUE.toString());
        addRequestParameter(EntitlementManager.VIRTUALIZATION_ENTITLED,
                Boolean.TRUE.toString());
        request.addParameter(SystemDetailsEditAction.NAME, s.getName());

        addSubmitted();
        actionPerform();
        s = (Server) TestUtils.reload(s);
        assertTrue(s.getAddOnEntitlements().contains(EntitlementManager.PROVISIONING));
    }

    public void testSetBaseEntitlement() throws Exception {
        UserTestUtils.addManagement(user.getOrg());
        Long id = s.getId();
        String name = s.getName();
        HibernateFactory.getSession().clear();
        SystemManager.removeAllServerEntitlements(id);
        s = ServerFactory.lookupById(id);
        assertTrue(s.getBaseEntitlement() == null);

        request.addParameter(SystemDetailsEditAction.NAME, name);
        request.addParameter(SystemDetailsEditAction.BASE_ENTITLEMENT,
                EntitlementManager.MANAGEMENT.getLabel());
        addSubmitted();
        actionPerform();
        s = ServerFactory.lookupById(id);
        assertTrue(s.getBaseEntitlement().equals(EntitlementManager.MANAGEMENT));
    }

    public void testUnentitle() throws Exception {
        request.addParameter(SystemDetailsEditAction.NAME, s.getName());
        assertTrue(s.getBaseEntitlement().equals(EntitlementManager.MANAGEMENT));
        request.addParameter(SystemDetailsEditAction.BASE_ENTITLEMENT,
                "unentitle");
        addSubmitted();
        actionPerform();
        s = (Server) TestUtils.reload(s);

        assertTrue("we shouldnt have a base entitlement", s.getBaseEntitlement() == null);
    }


    public void testCheckboxesTrue() throws Exception {
        Iterator i = s.getValidAddonEntitlementsForServer().iterator();

        while (i.hasNext()) {
            Entitlement e = (Entitlement) i.next();
            if (!e.equals(EntitlementManager.VIRTUALIZATION_PLATFORM)) {
                assertFalse(s.hasEntitlement(e));
                request.addParameter(e.getLabel(), Boolean.TRUE.toString());
                System.out.println("added: " + e.getLabel());
            }
        }

        s.setAutoUpdate("N");
        request.addParameter(SystemDetailsEditAction.AUTO_UPDATE,
                             Boolean.TRUE.toString());
        request.addParameter(SystemDetailsEditAction.NAME, s.getName());
        request.addParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        TestUtils.saveAndFlush(s);
        actionPerform();
        verifyForwardPath("/systems/details/Overview.do?sid=" + s.getId());
        /* here we look the server back up since entitling a server involves
         * a stored procedure call
         */
        TestUtils.flushAndEvict(s);
        s = ServerFactory.lookupById(s.getId());
        i = s.getValidAddonEntitlementsForServer().iterator();

        while (i.hasNext()) {
            Entitlement e = (Entitlement) i.next();
            if (!(e instanceof VirtualizationEntitlement)) {
                assertTrue("Didnt find entitlement in server: " + e.getLabel(),
                        s.hasEntitlement(e));
            }
        }
        assertTrue(s.hasEntitlement(EntitlementManager.VIRTUALIZATION) ||
                s.hasEntitlement(EntitlementManager.VIRTUALIZATION_PLATFORM));

        assertEquals("Y", s.getAutoUpdate());
    }

    public void testCheckboxesFalse() throws Exception {
        Iterator i = s.getValidAddonEntitlementsForServer().iterator();

        while (i.hasNext()) {
            Entitlement e = (Entitlement) i.next();
            SystemManager.entitleServer(s, e);
            TestUtils.flushAndEvict(s);
            s = ServerFactory.lookupById(s.getId());
            request.addParameter(e.getLabel(), Boolean.FALSE.toString());
        }

        s.setAutoUpdate("Y");
        request .addParameter(SystemDetailsEditAction.AUTO_UPDATE,
                              Boolean.FALSE.toString());
        request.addParameter(SystemDetailsEditAction.NAME, s.getName());
        request.addParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        TestUtils.saveAndFlush(s);
        actionPerform();
        verifyForwardPath("/systems/details/Overview.do?sid=" + s.getId());
        TestUtils.flushAndEvict(s);
        s = ServerFactory.lookupById(s.getId());
        i = s.getValidAddonEntitlementsForServer().iterator();

        while (i.hasNext()) {
            Entitlement e = (Entitlement) i.next();
            assertFalse("does have: " + e, s.hasEntitlement(e));
        }

        assertTrue(s.getAutoUpdate().equals("Y"));
    }
}
