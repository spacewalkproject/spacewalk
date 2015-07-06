/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.org.test;

import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.test.ChannelFamilyFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.MultiOrgUserOverview;
import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.dto.OrgEntitlementDto;
import com.redhat.rhn.frontend.xmlrpc.InvalidEntitlementException;
import com.redhat.rhn.frontend.xmlrpc.MigrationToSameOrgException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchOrgException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchSystemException;
import com.redhat.rhn.frontend.xmlrpc.OrgNotInTrustException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.ValidationException;
import com.redhat.rhn.frontend.xmlrpc.org.OrgHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class OrgHandlerTest extends BaseHandlerTestCase {

    private OrgHandler handler = new OrgHandler();

    private static final String LOGIN = "fakeadmin";
    private static final String PASSWORD = "fakeadmin";
    private static final String FIRST = "Bill";
    private static final String LAST = "FakeAdmin";
    private static final String EMAIL = "fakeadmin@example.com";
    private static final String PREFIX = "Mr.";
    private String[] orgName = {"Test Org 1", "Test Org 2"};
    private ChannelFamily channelFamily = null;


    public void setUp() throws Exception {
        super.setUp();
        admin.addPermanentRole(RoleFactory.SAT_ADMIN);
        for (int i = 0; i < orgName.length; i++) {
            orgName[i] = "Test Org " + TestUtils.randomString();
        }
        TestUtils.saveAndFlush(admin);

        channelFamily = ChannelFamilyFactoryTest.createTestChannelFamily(
                admin,
                ChannelFamilyFactoryTest.ENTITLEMENT_ALLOCATION,
                ChannelFamilyFactoryTest.FLEX_ALLOCATION,
                true);
    }

    public void testCreate() throws Exception {
        handler.create(admin, orgName[0], "fakeadmin", "password", "Mr.", "Bill",
                "FakeAdmin", "fakeadmin@example.com", Boolean.FALSE);
        Org testOrg = OrgFactory.lookupByName(orgName[0]);
        assertNotNull(testOrg);
    }

    public void testCreateShortOrgName() throws Exception {
        String shortName = "aa"; // Must be at least 3 characters in UI
        try {
            handler.create(admin, shortName, "fakeadmin", "password", "Mr.", "Bill",
                    "FakeAdmin", "fakeadmin@example.com", Boolean.FALSE);
            fail();
        }
        catch (ValidationException e) {
            // expected
        }
    }

    public void testCreateDuplicateOrgName() throws Exception {
        String dupOrgName = "Test Org " + TestUtils.randomString();
        handler.create(admin, dupOrgName, "fakeadmin1", "password", "Mr.", "Bill",
                "FakeAdmin", "fakeadmin1@example.com", Boolean.FALSE);
        try {
            handler.create(admin, dupOrgName, "fakeadmin2", "password", "Mr.", "Bill",
                    "FakeAdmin", "fakeadmin2@example.com", Boolean.FALSE);
            fail();
        }
        catch (ValidationException e) {
            // expected
        }
    }

    public void testListOrgs() throws Exception {
        Org testOrg = createOrg();
        OrgDto dto = OrgManager.toDetailsDto(testOrg);
        List <OrgDto> orgs = handler.listOrgs(admin);
        assertTrue(orgs.contains(dto));
    }

    public void testDeleteNoSuchOrg() throws Exception {
        try {
            handler.delete(admin, new Integer(-1));
            fail();
        }
        catch (NoSuchOrgException e) {
            // expected
        }
    }

    public void testDelete() throws Exception {
        Org testOrg = createOrg();
        handler.delete(admin, new Integer(testOrg.getId().intValue()));
        testOrg = OrgFactory.lookupByName(orgName[0]);
        assertNull(testOrg);
    }

    public void testListActiveUsers() throws Exception {
        Org testOrg = createOrg();
        List <MultiOrgUserOverview> users = handler.listUsers(admin,
                                                testOrg.getId().intValue());
        assertTrue(users.size() == 1);
        User user = UserFactory.lookupByLogin(
                testOrg.getActiveOrgAdmins().get(0).getLogin());
        assertEquals(users.get(0).getId(), user.getId());
    }

    public void testGetDetails() throws Exception {
        Org testOrg = createOrg();
        OrgDto actual = handler.getDetails(admin, testOrg.getId().intValue());
        OrgDto expected = OrgManager.toDetailsDto(testOrg);
        assertNotNull(actual);
        compareDtos(expected, actual);

        actual = handler.getDetails(admin, testOrg.getName());
        assertNotNull(actual);
        compareDtos(expected, actual);
    }

    public void testUpdateName() throws Exception {
        Org testOrg = createOrg();
        String newName = "Foo" + TestUtils.randomString();
        OrgDto dto = handler.updateName(admin, testOrg.getId().intValue(), newName);
        assertEquals(newName, dto.getName());
        assertNotNull(OrgFactory.lookupByName(newName));
    }

    private void compareDtos(OrgDto expected, OrgDto actual) {
        assertEquals(expected.getId(), actual.getId());
        assertEquals(expected.getName(), actual.getName());
        assertEquals(expected.getActivationKeys(), actual.getActivationKeys());
        assertEquals(expected.getSystems(), actual.getSystems());
        assertEquals(expected.getKickstartProfiles(), actual.getKickstartProfiles());
        assertEquals(expected.getUsers(), actual.getUsers());
        assertEquals(expected.getServerGroups(), actual.getServerGroups());
        assertEquals(expected.getConfigChannels(), actual.getConfigChannels());
    }

    private Org createOrg() {
        return createOrg(0);
    }

    private Org createOrg(int index) {
        return createOrg(orgName[index], LOGIN + TestUtils.randomString(),
                PASSWORD, PREFIX, FIRST, LAST, EMAIL, false);
    }

    private Org createOrg(String name, String login,
                        String password, String prefix, String first,
                        String last, String email, boolean usePam) {
        handler.create(admin, name, login, password, prefix, first,
                                                    last, email, usePam);
        Org org =  OrgFactory.lookupByName(name);
        assertNotNull(org);
        return org;
    }

    public void testSetSystemEntitlements() throws Exception {
        Org testOrg = createOrg();

        String systemEnt = EntitlementManager.ENTERPRISE_ENTITLED;
        int result = handler.setSystemEntitlements(admin,
                new Integer(testOrg.getId().intValue()), systemEnt, new Integer(1));
        assertEquals(1, result);

        systemEnt = EntitlementManager.PROVISIONING_ENTITLED;
        result = handler.setSystemEntitlements(admin,
                new Integer(testOrg.getId().intValue()), systemEnt, new Integer(1));
        assertEquals(1, result);

        systemEnt = EntitlementManager.VIRTUALIZATION_ENTITLED;
        result = handler.setSystemEntitlements(admin,
                new Integer(testOrg.getId().intValue()), systemEnt, new Integer(1));
        assertEquals(1, result);

        systemEnt = EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED;
        result = handler.setSystemEntitlements(admin,
                new Integer(testOrg.getId().intValue()), systemEnt, new Integer(1));
        assertEquals(1, result);

        assertOrgSystemEntitlementCount(testOrg.getId(), systemEnt, 1);
    }

    public void testSetSystemEntitlementsNoSuchOrgOrFamily() throws Exception {
        Org testOrg = createOrg();
        String systemEnt = EntitlementManager.PROVISIONING_ENTITLED;
        try {
            handler.setSystemEntitlements(admin,
                    new Integer(testOrg.getId().intValue()), "nosuchentitlement",
                    new Integer(1));
            fail();
        }
        catch (InvalidEntitlementException e) {
            // expected
        }

        try {
            handler.setSystemEntitlements(admin,
                    new Integer(-1), systemEnt, new Integer(1));
            fail();
        }
        catch (NoSuchOrgException e) {
            // expected
        }
    }

    public void testSetSystemEntitlementsDefaultOrg() throws Exception {
        String systemEnt = EntitlementManager.PROVISIONING_ENTITLED;
        try {
            handler.setSystemEntitlements(admin,
                    new Integer(1), systemEnt, new Integer(10));
            fail();
        }
        catch (IllegalArgumentException e) {
            // expected
        }
    }

    public void testListSystemEntitlements() throws Exception {
        Org testOrg = createOrg();
        String systemEnt = EntitlementManager.ENTERPRISE_ENTITLED;

        // test the entitlement api before the entitlement has been assigned to the org
        List<Map> entitlementCounts = null;

        entitlementCounts = handler.listSystemEntitlements(admin, systemEnt,
            Boolean.TRUE);
        // since includeUnentitled=TRUE, we should find an entry for the org w/ 0 ents
        assertOrgSystemEntitlement(testOrg.getId(), systemEnt,
            entitlementCounts, 0, true);

        entitlementCounts = handler.listSystemEntitlements(admin, systemEnt,
           Boolean.FALSE);
        // since includeUnentitled=FALSE, we shouldn't be able to locate the org
        assertOrgSystemEntitlement(testOrg.getId(), systemEnt,
           entitlementCounts, 0, false);

        int result = handler.setSystemEntitlements(admin,
            new Integer(testOrg.getId().intValue()), systemEnt, new Integer(1));
        assertEquals(1, result);

        // now that the org has the entitlement, we should find it entitled with
        // both variations of the api call
        entitlementCounts = handler.listSystemEntitlements(admin, systemEnt,
            Boolean.TRUE);
        assertOrgSystemEntitlement(testOrg.getId(), systemEnt,
            entitlementCounts, 1, true);

        entitlementCounts = handler.listSystemEntitlements(admin, systemEnt,
            Boolean.FALSE);
        assertOrgSystemEntitlement(testOrg.getId(), systemEnt,
            entitlementCounts, 1, true);
    }

    private void assertOrgSystemEntitlement(Long orgId, String systemEntitlmentLabel,
            List<Map> entitlementCounts, int expectedAllocation, boolean orgShouldExist) {

        boolean found = false;

        for (Map counts : entitlementCounts) {
            Integer lookupOrgId = (Integer)counts.get("org_id");
            if (lookupOrgId.longValue() != orgId.longValue()) {
                continue;
            }
            // Found our org, check it's allocation:
            found = true;
            Integer total = (Integer)counts.get("allocated");
            assertEquals(new Integer(expectedAllocation), total);
        }
        if (!found && orgShouldExist) {
            fail("unable to find org: " + orgId);
        }
    }

    /**
     * Test both list entitlement calls by verifying the given org has the
     * expected allocation for the given system entitlement.
     *
     * @param orgId orgId to lookup allocations for
     * @param systemEntitlementLabel system entitlement label
     * @param expectedAllocation expected allocation
     */
    private void assertOrgSystemEntitlementCount(Long orgId,
            String systemEntitlementLabel, int expectedAllocation) {
        List<Map> entitlementCounts = handler.listSystemEntitlements(admin,
                systemEntitlementLabel);
        boolean found = false;

        for (Map counts : entitlementCounts) {
            Integer lookupOrgId = (Integer)counts.get("org_id");
            if (lookupOrgId.longValue() != orgId.longValue()) {
                continue;
            }
            // Found our org, check it's allocation:
            found = true;
            Integer total = (Integer)counts.get("allocated");
            assertEquals(new Integer(expectedAllocation), total);
        }
        if (!found) {
            fail("unable to find org: " + orgId);
        }

        // Repeat for the "by org" list:
        List<OrgEntitlementDto> counts2 = handler.listSystemEntitlementsForOrg(admin,
                new Integer(orgId.intValue()));
        found = false;

        for (OrgEntitlementDto dto : counts2) {
            String lookupLabel = dto.getEntitlement().getLabel();
            if (!lookupLabel.equals(systemEntitlementLabel)) {
                continue;
            }
            // Found our channel family label, check it's allocation:
            found = true;
            Integer total = new Integer(dto.getMaxEntitlements().intValue());
            assertEquals(new Integer(expectedAllocation), total);
        }
        if (!found) {
            fail("unable to find channel family: " + systemEntitlementLabel);
        }
    }

    public void testMigrateSystem() throws Exception {
        User newOrgAdmin = UserTestUtils.findNewUser("newAdmin", "newOrg", true);
        newOrgAdmin.getOrg().getTrustedOrgs().add(admin.getOrg());
        OrgFactory.save(newOrgAdmin.getOrg());

        Server server = ServerTestUtils.createTestSystem(admin);
        assertNotNull(server.getOrg());
        List<Integer> servers = new LinkedList<Integer>();
        servers.add(new Integer(server.getId().intValue()));
        // Actual migration is tested internally, just make sure the API call doesn't
        // error out:
        handler.migrateSystems(admin, newOrgAdmin.getOrg().getId().intValue(), servers);
    }

    public void testMigrateInvalid() throws Exception {

        User orgAdmin1 = UserTestUtils.findNewUser("orgAdmin1", "org1", true);
        orgAdmin1.getOrg().getTrustedOrgs().add(admin.getOrg());

        User orgAdmin2 = UserTestUtils.findNewUser("orgAdmin2", "org2", true);

        Server server = ServerTestUtils.createTestSystem(admin);
        List<Integer> servers = new LinkedList<Integer>();
        servers.add(new Integer(server.getId().intValue()));

        // attempt migration where user is not a satellite admin and orginating
        // org is not the same as the user's.
        try {
            handler.migrateSystems(orgAdmin2, orgAdmin1.getOrg().getId().intValue(),
                    servers);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            // expected
        }

        // attempt to migrate systems to an org that does not exist
        try {
            handler.migrateSystems(admin, new Integer(-1), servers);
            fail();
        }
        catch (NoSuchOrgException e) {
            // expected
        }

        // attempt to migrate systems from/to the same org
        try {
            handler.migrateSystems(admin, admin.getOrg().getId().intValue(), servers);
            fail();
        }
        catch (MigrationToSameOrgException e) {
            // expected
        }

        // attempt to migrate systems to an org that isn't defined in trust
        try {
            handler.migrateSystems(admin, orgAdmin2.getOrg().getId().intValue(),
                    servers);
            fail();
        }
        catch (OrgNotInTrustException e) {
            // expected
        }

        // attempt to migrate systems that do not exist
        List<Integer> invalidServers = new LinkedList<Integer>();
        invalidServers.add(new Integer(-1));
        try {
            handler.migrateSystems(admin, orgAdmin1.getOrg().getId().intValue(),
                    invalidServers);
            fail();
        }
        catch (NoSuchSystemException e) {
            // expected
        }
    }
}
