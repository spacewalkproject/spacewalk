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
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.domain.iss.IssMasterOrg;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.sync.master.MasterHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.testing.TestUtils;

public class MasterHandlerTest extends BaseHandlerTestCase {

    private MasterHandler handler = new MasterHandler();
    private String[] masterOrgNames = {"masterOrg01", "masterOrg02", "masterOrg03"};
    private String masterName;

    public void setUp() throws Exception {
        super.setUp();
        masterName = "testMaster" + TestUtils.randomString();
        admin.addRole(RoleFactory.SAT_ADMIN);
    }

    public void testCreate() {
        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster master = handler.create(regularKey, masterName);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster master = handler.create(adminKey, masterName);
            assertEquals(masterName, master.getLabel());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
   }

    public void testUpdate() {
        IssMaster master = handler.create(adminKey, masterName);

        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster updMaster = handler.update(regularKey,
                    master.getId().intValue(),
                    "new_" + masterName);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster updMaster = handler.update(adminKey, master.getId().intValue(),
                    "new_" + masterName);
            assertEquals("new_" + masterName, updMaster.getLabel());
            assertEquals(master.getId(), updMaster.getId());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testCaCert() {
        IssMaster master = handler.create(adminKey, masterName);
        Integer mstrId = master.getId().intValue();

        // Make sure that non-sat-admin users cannot access
        try {
            int rc = handler.setCaCert(regularKey, mstrId, "/tmp/foo");
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            int rc = handler.setCaCert(adminKey, mstrId, "/tmp/foo");
            IssMaster gotMaster = handler.getMaster(adminKey, mstrId);
            assertEquals("/tmp/foo", gotMaster.getCaCert());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testMasterDefault() {
        String masterName1 = "testMaster" + TestUtils.randomString();
        String masterName2 = "testMaster" + TestUtils.randomString();
        String masterName3 = "testMaster" + TestUtils.randomString();

        IssMaster master1 = handler.create(adminKey, masterName1);
        IssMaster master2 = handler.create(adminKey, masterName2);
        IssMaster master3 = handler.create(adminKey, masterName3);

        // Make sure that non-sat-admin users cannot do any of the
        // master-default APIs
        try {
            IssMaster retMaster = handler.getDefaultMaster(regularKey);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            // success
        }
        try {
            int rc = handler.makeDefault(regularKey, master1.getId().intValue());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            // success
        }

        try {
            int rc = handler.unsetDefaultMaster(regularKey);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            // success
        }

        // Make sure satellite-admin can
        try {
            IssMaster defaultMaster = handler.getDefaultMaster(adminKey);

            int rc = handler.makeDefault(adminKey, master1.getId().intValue());
            assertEquals(1, rc);
            IssMaster retMaster = handler.getDefaultMaster(adminKey);
            assertNotNull(retMaster);
            assertTrue(retMaster.getId().equals(master1.getId()));

            rc = handler.makeDefault(adminKey, master3.getId().intValue());
            assertEquals(1, rc);
            retMaster = handler.getDefaultMaster(adminKey);
            assertNotNull(retMaster);
            assertTrue(retMaster.getId().equals(master3.getId()));

            retMaster = handler.getMaster(adminKey, master1.getId().intValue());
            assertNotNull(retMaster);
            assertFalse(retMaster.isDefaultMaster());

            rc = handler.unsetDefaultMaster(adminKey);
            assertEquals(1, rc);
            retMaster = handler.getMaster(adminKey, master3.getId().intValue());
            assertNotNull(retMaster);
            assertFalse(retMaster.isDefaultMaster());

            retMaster = handler.getDefaultMaster(adminKey);
            assertNull(retMaster);

            if (defaultMaster != null) {
                handler.makeDefault(adminKey, defaultMaster.getId().intValue());
            }
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testDelete() {
        IssMaster master = handler.create(adminKey, masterName);
        Long mstrId = master.getId();

        // Make sure that non-sat-admin users cannot access
        try {
            int rmvd = handler.delete(regularKey, master.getId().intValue());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            int rmvd = handler.delete(adminKey, master.getId().intValue());
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
        IssMaster master = handler.create(adminKey, masterName);
        Integer mstrId = master.getId().intValue();

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
            assertEquals(mstrId.intValue(), gotMaster.getId().intValue());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testGetMasterByLabel() {
        IssMaster master = handler.create(adminKey, masterName);

        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster gotMaster = handler.getMasterByLabel(regularKey, masterName);
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster gotMaster = handler.getMasterByLabel(adminKey, masterName);
            assertNotNull(gotMaster);
            assertEquals(masterName, gotMaster.getLabel());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testGetMasterOrgs() {
        IssMaster master = handler.create(adminKey, masterName);

        // Make sure that non-sat-admin users cannot access
        try {
            List<IssMasterOrg> orgs = handler.getMasterOrgs(regularKey,
                    master.getId().intValue());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            List<IssMasterOrg> orgs = handler.getMasterOrgs(adminKey,
                    master.getId().intValue());
            assertNotNull(orgs);
            assertEquals(0, orgs.size());
            assertEquals(master.getNumMasterOrgs(), orgs.size());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testMappedMasterOrgs() {
        IssMaster master = handler.create(adminKey, masterName);
        addOrgsTo(master, false);
        assertEquals(0, master.getNumMappedMasterOrgs());
        assertEquals(masterOrgNames.length, master.getNumMasterOrgs());

        // Make sure that non-sat-admin users cannot access
        try {
            List<IssMasterOrg> orgs = handler.getMasterOrgs(regularKey,
                    master.getId().intValue());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        List<IssMasterOrg> orgs = null;
        try {
            orgs = handler.getMasterOrgs(adminKey, master.getId().intValue());
            assertNotNull(orgs);
            assertEquals(masterOrgNames.length, orgs.size());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }

        // OK, we got access - none of these IssMasterOrgs should be mapped
        for (IssMasterOrg o : orgs) {
            assertNull(o.getLocalOrg());
        }

        // OK, they're not mapped.  Map them, and try again
        for (IssMasterOrg o : orgs) {
            o.setLocalOrg(admin.getOrg());
        }

        master.resetMasterOrgs(new HashSet<IssMasterOrg>(orgs));

        orgs = handler.getMasterOrgs(adminKey, master.getId().intValue());
        for (IssMasterOrg o : orgs) {
            assertEquals(o.getLocalOrg().getId(), admin.getOrg().getId());
        }

    }

    public void testSetMasterOrgs() {
        IssMaster master = handler.create(adminKey, masterName);

        List<IssMasterOrg> someOrgs = getBareOrgs(true);

        // Make sure that non-sat-admin users cannot access
        try {
            IssMaster m = handler.getMaster(adminKey, master.getId().intValue());
            assertNotNull(m);
            List<IssMasterOrg> orgs = handler.getMasterOrgs(regularKey,
                    master.getId().intValue());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }

        // Make sure satellite-admin can
        try {
            IssMaster m = handler.getMaster(adminKey, master.getId().intValue());
            assertNotNull(m);
            assertEquals(0, m.getNumMasterOrgs());
            int rc = handler.setMasterOrgs(adminKey, m.getId().intValue(),
                    orgsToMaps(someOrgs));
            assertEquals(1, rc);
            IssMaster m2 = handler.getMaster(adminKey, master.getId().intValue());
            assertEquals(someOrgs.size(), m2.getNumMasterOrgs());
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }

        // Make sure setting to one-new-one, really sets to one
        IssMasterOrg org = new IssMasterOrg();
        org.setMasterOrgName("newMasterOrg");
        org.setMasterOrgId(1013L);
        List<Map<String, Object>> mapOrgs = new ArrayList();
        mapOrgs.add(orgToMap(org));
        IssMaster m3 = handler.getMaster(adminKey, master.getId().intValue());
        int rc = handler.setMasterOrgs(adminKey,
                m3.getId().intValue(),
                mapOrgs);
        assertEquals(1, rc);
        List<IssMasterOrg> orgSet = handler.getMasterOrgs(adminKey,
                master.getId().intValue());
        assertNotNull(orgSet);
        assertEquals(1, orgSet.size());

        // Make sure resetting to "empty" works
        IssMaster m4 = handler.getMaster(adminKey, master.getId().intValue());
        rc = handler.setMasterOrgs(adminKey,
                m4.getId().intValue(),
                new ArrayList<Map<String, Object>>());
        assertEquals(1, rc);
        orgSet = handler.getMasterOrgs(adminKey, master.getId().intValue());
        assertNotNull(orgSet);
        assertEquals(0, orgSet.size());

    }

    public void testAddOrg() {
        IssMaster master = handler.create(adminKey, masterName);
        IssMasterOrg org = new IssMasterOrg();
        org.setMasterOrgName("newMasterOrg");
        org.setMasterOrgId(1001L);

        // Make sure that non-sat-admin users cannot access
        try {
            int rc = handler.addToMaster(regularKey, master.getId().intValue(),
                    orgToMap(org));
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        // Make sure satellite-admin can
        try {
            int rc = handler.addToMaster(adminKey, master.getId().intValue(),
                    orgToMap(org));
            assertEquals(1, rc);
            List<IssMasterOrg> orgs = handler.getMasterOrgs(adminKey,
                    master.getId().intValue());
            boolean found = false;
            for (IssMasterOrg o : orgs) {
                found |= (1001L == o.getMasterOrgId() &&
                    "newMasterOrg".equals(o.getMasterOrgName()));
            }
            assertTrue(found);
        }
        catch (PermissionCheckFailureException e) {
            fail();
        }
    }

    public void testMapToLocal() {
        IssMaster master = new IssMaster();
        master.setLabel(masterName);
        IssFactory.save(master);
        addOrgsTo(master, false);

        IssMasterOrg masterOrg = null;

        for (IssMasterOrg o : master.getMasterOrgs()) {
            if (masterOrgNames[1].equals(o.getMasterOrgName())) {
                masterOrg = o;
            }
        }

        // Make sure that non-sat-admin users cannot access
        try {
            int rc = handler.mapToLocal(regularKey, master.getId().intValue(),
                    masterOrg.getMasterOrgId().intValue(),
                    admin.getOrg().getId().intValue());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            //success
        }
        // Make sure satellite-admin can
        try {
            int rc = handler.mapToLocal(adminKey, master.getId().intValue(),
                    masterOrg.getMasterOrgId().intValue(),
                    admin.getOrg().getId().intValue());
            assertEquals(1, rc);
            for (IssMasterOrg o : master.getMasterOrgs()) {
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
        List<IssMasterOrg> orgs = getBareOrgs(map);
        master.resetMasterOrgs(new HashSet<IssMasterOrg>(orgs));
        IssFactory.save(master);
    }

    private List<IssMasterOrg> getBareOrgs(boolean map) {
        long id = 1001L;
        List<IssMasterOrg> orgs = new ArrayList();
        for (String name : masterOrgNames) {
            IssMasterOrg org = new IssMasterOrg();
            org.setMasterOrgName(name);
            org.setMasterOrgId(id++);
            if (map) {
                org.setLocalOrg(admin.getOrg());
            }
            orgs.add(org);
        }
        return orgs;
    }

    // "masterId", "masterOrgId", "masterOrgName", "localOrgId"
    private List<Map<String, Object>> orgsToMaps(List<IssMasterOrg> orgs) {
        List<Map<String, Object>> maps = new ArrayList<Map<String, Object>>();
        for (IssMasterOrg org : orgs) {
            Map<String, Object> orgMap =  orgToMap(org);
            maps.add(orgMap);
        }
        return maps;
    }

    private Map<String, Object> orgToMap(IssMasterOrg org) {
        Map<String, Object> orgMap = new HashMap<String, Object>();

        orgMap.put("masterOrgId", org.getMasterOrgId().intValue());
        orgMap.put("masterOrgName", org.getMasterOrgName());
        if (org.getLocalOrg() != null) {
            orgMap.put("localOrgId", org.getLocalOrg().getId().intValue());
        }
        return orgMap;
    }
}
