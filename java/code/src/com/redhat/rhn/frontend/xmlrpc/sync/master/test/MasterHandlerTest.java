/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.sync.master.test;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssMasterOrgs;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.sync.master.MasterHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

public class MasterHandlerTest extends BaseHandlerTestCase {

    private MasterHandler handler = new MasterHandler();
    private String[] masterOrgNames = {"masterOrg01", "masterOrg02", "masterOrg03"};

    public void setUp() throws Exception {
        super.setUp();
        admin.addRole(RoleFactory.SAT_ADMIN);
    }

    public void testCreate() {
        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster master = handler.create(regularKey, "testCreate");
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster master = handler.create(adminKey, "testCreate");
            assertEquals("testCreate", master.getLabel());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
   }

    public void testUpdate() {
        IssMaster master = handler.create(adminKey, "testCreate");

        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster updMaster = handler.update(regularKey,
                    master.getId(),
                    "testCreateNew");
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster updMaster = handler.update(adminKey, master.getId(), "testCreateNew");
            assertEquals("testCreateNew", updMaster.getLabel());
            assertEquals(master.getId(), updMaster.getId());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testDelete() {
        IssMaster master = handler.create(adminKey, "testCreate");
        Long mstrId = master.getId();

        // Make sure that non-sat-admin users cannot access
        try {
            int rmvd = handler.delete(regularKey, master.getId());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            int rmvd = handler.delete(adminKey, master.getId());
            assertEquals(1, rmvd);
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }

        // Make sure it's actually gone
        IssMaster mstr = IssFactory.lookupMasterById(mstrId);
        assertNull(mstr);
    }

    public void testGetMaster() {
        IssMaster master = handler.create(adminKey, "testCreate");
        Long mstrId = master.getId();

        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster gotMaster = handler.getMaster(regularKey, mstrId);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster gotMaster = handler.getMaster(adminKey, mstrId);
            assertEquals(mstrId, gotMaster.getId());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testGetMasterByLabel() {
        IssMaster master = handler.create(adminKey, "testCreate");

        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster gotMaster = handler.getMasterByLabel(regularKey, "testCreate");
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster gotMaster = handler.getMasterByLabel(adminKey, "testCreate");
            assertNotNull(gotMaster);
            assertEquals("testCreate", gotMaster.getLabel());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testGetMasterOrgs() {
        IssMaster master = handler.create(adminKey, "testCreate");

        // Make sure that non-sat-admin users cannot access
        try {
            List<IssMasterOrgs> orgs = handler.getMasterOrgs(regularKey, master.getId());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            List<IssMasterOrgs> orgs = handler.getMasterOrgs(adminKey, master.getId());
            assertNotNull(orgs);
            assertEquals(0, orgs.size());
            assertEquals(master.getNumMasterOrgs(), orgs.size());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testMappedMasterOrgs() {
        IssMaster master = handler.create(adminKey, "testCreate");
        addOrgsTo(master, false);
        assertEquals(0, master.getNumMappedMasterOrgs());
        assertEquals(masterOrgNames.length, master.getNumMasterOrgs());

        // Make sure that non-sat-admin users cannot access
        try {
            List<IssMasterOrgs> orgs = handler.getMasterOrgs(regularKey, master.getId());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        List<IssMasterOrgs> orgs = null;
        try {
            orgs = handler.getMasterOrgs(adminKey, master.getId());
            assertNotNull(orgs);
            assertEquals(masterOrgNames.length, orgs.size());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }

        // OK, we got access - none of these IssMasterOrgs should be mapped
        for (IssMasterOrgs o : orgs) {
            assertNull(o.getLocalOrg());
        }

        // OK, they're not mapped.  Map them, and try again
        for (IssMasterOrgs o : orgs) {
            o.setLocalOrg(admin.getOrg());
        }

        master.setMasterOrgs(new HashSet<IssMasterOrgs>(orgs));

        orgs = handler.getMasterOrgs(adminKey, master.getId());
        for (IssMasterOrgs o : orgs) {
            assertEquals(o.getLocalOrg().getId(), admin.getOrg().getId());
        }

    }

    public void testSetMasterOrgs() {
        IssMaster master = handler.create(adminKey, "testCreate");

        List<IssMasterOrgs> someOrgs = getBareOrgs(true);

        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster m = handler.getMaster(adminKey, master.getId());
            assertNotNull(m);
            List<IssMasterOrgs> orgs = handler.getMasterOrgs(regularKey, master.getId());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster m = handler.getMaster(adminKey, master.getId());
            assertNotNull(m);
            assertEquals(0, m.getNumMasterOrgs());
            int rc = handler.setMasterOrgs(adminKey, m.getId(), someOrgs);
            assertEquals(1, rc);
            IssMaster m2 = handler.getMaster(adminKey, master.getId());
            assertEquals(someOrgs.size(), m2.getNumMasterOrgs());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }

        // Make sure resetting to "empty" works
        IssMaster m = handler.getMaster(adminKey, master.getId());
        int rc = handler.setMasterOrgs(adminKey,
                m.getId(),
                new ArrayList<IssMasterOrgs>());
        assertEquals(1, rc);
        List<IssMasterOrgs> orgSet = handler.getMasterOrgs(adminKey, master.getId());
        assertNotNull(orgSet);
        assertEquals(0, orgSet.size());

    }

    public void testAddOrg() {
        IssMaster master = handler.create(adminKey, "testCreate");
        IssMasterOrgs org = new IssMasterOrgs();
        org.setMasterOrgName("newMasterOrg");
        org.setMasterOrgId(1001L);

        // Make sure that non-sat-admin users cannot access
        try {
            int rc = handler.addToMaster(regularKey, master.getId(), org);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        // Make sure satellite-admin can
        try {
            int rc = handler.addToMaster(adminKey, master.getId(), org);
            assertEquals(1, rc);
            List<IssMasterOrgs> orgs = handler.getMasterOrgs(adminKey, master.getId());
            assertTrue(orgs.contains(org));
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testMapToLocal() {
        IssMaster master = new IssMaster();
        master.setLabel("testCreate");
        IssFactory.save(master);
        addOrgsTo(master, false);

        IssMasterOrgs masterOrg = null;

        for (IssMasterOrgs o : master.getMasterOrgs()) {
            if (masterOrgNames[1].equals(o.getMasterOrgName())) {
                masterOrg = o;
            }
        }

        // Make sure that non-sat-admin users cannot access
        try {
            int rc = handler.mapToLocal(regularKey, master.getId(),
                    masterOrg.getMasterOrgId(),
                    admin.getOrg().getId());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        // Make sure satellite-admin can
        try {
            int rc = handler.mapToLocal(adminKey, master.getId(),
                    masterOrg.getMasterOrgId(),
                    admin.getOrg().getId());
            assertEquals(1, rc);
            for (IssMasterOrgs o : master.getMasterOrgs()) {
                if (masterOrgNames[1].equals(o.getMasterOrgName())) {
                    assertEquals(o.getLocalOrg(), admin.getOrg());
                }
            }
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    private void addOrgsTo(IssMaster master, boolean map) {
        List<IssMasterOrgs> orgs = getBareOrgs(map);
        for (IssMasterOrgs o : orgs) {
            o.setMaster(master);
        }
        master.setMasterOrgs(new HashSet<IssMasterOrgs>(orgs));
        IssFactory.save(master);
    }

    private List<IssMasterOrgs> getBareOrgs(boolean map) {
        long id = 1001L;
        List<IssMasterOrgs> orgs = new ArrayList();
        for (String name : masterOrgNames) {
            IssMasterOrgs org = new IssMasterOrgs();
            org.setMasterOrgName(name);
            org.setMasterOrgId(id++);
            if (map) {
                org.setLocalOrg(admin.getOrg());
            }
            orgs.add(org);
        }
        return orgs;
    }
}
