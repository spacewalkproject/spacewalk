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
package com.redhat.rhn.manager.errata.cache.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.ErrataCacheDto;
import com.redhat.rhn.frontend.events.test.UpdateErrataCacheEventTest;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * ErrataFactoryTest
 * @version $Rev$
 */
public class ErrataCacheManagerTest extends RhnBaseTestCase {

    public void testCount() {
        // setup the test
        Org org = UserTestUtils.findNewOrg("testOrg");
        insertRowIntoErrataCacheQueue(org);

        // let's see if we find the right data.
        int cnt = ErrataCacheManager.countServersInQueue(org);

        assertEquals(3, cnt);
    }

    public void testDeleteErrataCacheQueue() {
        // setup the test
        Org org = UserTestUtils.findNewOrg("testOrg");
        insertRowIntoErrataCacheQueue(org);

        // let's see if we find the right data.
        int rows = ErrataCacheManager.deleteErrataCacheQueue(org);
        assertEquals(1, rows);

        int cnt = ErrataCacheManager.countServersInQueue(org);
        assertEquals(0, cnt);
    }

    public static Long insertRowIntoErrataCacheQueue(Org orgIn) {
        Long oid = orgIn.getId();
        WriteMode m = ModeFactory.getWriteMode("test_queries", "ready_errata_cache_queue");
        Map params = new HashMap();
        params.put("org_id", oid);
        params.put("server_count", new Integer(3));
        params.put("processed", new Integer(0));
        int i = m.executeUpdate(params);
        assertEquals(1, i);
        return oid;
    }

    public void aTestNewPackages() {
        DataResult dr = ErrataCacheManager.newPackages(
                new Long(1000089925));

        assertFalse(dr.isEmpty());

        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            ErrataCacheDto ecd = (ErrataCacheDto) itr.next();
            System.out.println(ecd.toString());
        }
    }

    public void testInsertNeededPackageCache() throws Exception {

        // create a lot of stuff to test this simple insert.
        Long oid = UserTestUtils.createOrg("testOrg");
        Org org = OrgFactory.lookupById(oid);
        User user = UserTestUtils.createUser("testUser", oid);
        Server server = ServerFactoryTest.createTestServer(user);
        Package pkg = PackageTest.createTestPackage(org);
        Errata e = ErrataFactoryTest.createTestErrata(oid);
        Long sid = server.getId();
        Long eid = e.getId();
        Long pid = pkg.getId();

        // insert record into table
        int rows = ErrataCacheManager.insertNeededPackageCache(
                sid, eid, pid);
        assertEquals(1, rows);

        // verify what was inserted
        Session session = HibernateFactory.getSession();
        Connection conn = session.connection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
                "select * from rhnServerNeededPackageCache where server_id = " +
                sid.toString());
        assertTrue(rs.next());
        assertEquals(sid.longValue(), rs.getLong("server_id"));
        assertEquals(eid.longValue(), rs.getLong("errata_id"));
        assertEquals(pid.longValue(), rs.getLong("package_id"));

        // make sure we don't have more
        assertFalse(rs.next());
    }

    public static Map createServerNeededPackageCache(User userIn,
            String errataType) throws Exception {
        Map retval = new HashMap();
        Errata e = ErrataFactoryTest.createTestErrata(userIn.getOrg().getId());
        e.setAdvisoryType(errataType);
        e = (Errata) TestUtils.saveAndReload(e);
        retval.put("errata", e);
        Server s = ServerFactoryTest.createTestServer(userIn);
        ServerFactory.save(s);
        TestUtils.flushAndEvict(s);
        retval.put("server", s);
        Package p = PackageTest.createTestPackage(userIn.getOrg());
        PackageEvr evr = PackageEvrFactory.createPackageEvr(p.getPackageEvr().getEpoch(),
                p.getPackageEvr().getVersion(), "2");
        evr = (PackageEvr) TestUtils.saveAndReload(evr);
        Package newPackage = PackageTest.createTestPackage(userIn.getOrg());
        newPackage.setPackageName(p.getPackageName());
        newPackage.setPackageEvr(evr);
        newPackage = (Package) TestUtils.saveAndReload(newPackage);

        InstalledPackage ip = new InstalledPackage();
        ip.setServer(s);
        ip.setArch(p.getPackageArch());
        ip.setEvr(p.getPackageEvr());
        ip.setName(p.getPackageName());

        HibernateFactory.getSession().save(ip);

        retval.put("package", p);
        retval.put("newpackage", newPackage);
        userIn.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(userIn);
        TestUtils.flushAndEvict(userIn);
        int rows = ErrataCacheManager.insertNeededPackageCache(
                s.getId(), e.getId(), p.getId());
        assertEquals(1, rows);
        return retval;
    }

    public void testDeleteNeededPackageCache() throws Exception {
        // create a lot of stuff to test this simple insert.
        Long oid = UserTestUtils.createOrg("testOrg");
        Org org = OrgFactory.lookupById(oid);
        User user = UserTestUtils.createUser("testUser", oid);
        Server server = ServerFactoryTest.createTestServer(user);
        Package pkg = PackageTest.createTestPackage(org);
        Errata e = ErrataFactoryTest.createTestErrata(oid);
        Long sid = server.getId();
        Long eid = e.getId();
        Long pid = pkg.getId();

        // insert record into table
        int rows = ErrataCacheManager.insertNeededPackageCache(
                sid, eid, pid);
        assertEquals(1, rows);

        // verify what was inserted
        Session session = HibernateFactory.getSession();
        Connection conn = session.connection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
                "select * from rhnServerNeededPackageCache where server_id = " +
                sid.toString());
        assertTrue(rs.next());
        assertEquals(sid.longValue(), rs.getLong("server_id"));
        assertEquals(eid.longValue(), rs.getLong("errata_id"));
        assertEquals(pid.longValue(), rs.getLong("package_id"));

        // make sure we don't have more
        assertFalse(rs.next());

        // now let's delete the above record
        rows = ErrataCacheManager.deleteNeededPackageCache(sid, eid, pid);
        assertEquals(1, rows);

        rs = stmt.executeQuery(
                "select * from rhnServerNeededPackageCache where server_id = " +
                sid.toString());
        assertFalse(rs.next());
    }

    public static Server createServerNeedintErrataCache(User userIn) throws Exception {
        // create a lot of stuff to test this simple insert.
        Long oid = userIn.getOrg().getId();
        Server server = ServerFactoryTest.createTestServer(userIn);
        Errata e = ErrataFactoryTest.createTestErrata(oid);

        e = (Errata) TestUtils.reload(e);
        Long sid = server.getId();
        Long eid = e.getId();

        Package p = (Package) e.getPackages().iterator().next();
        // insert record into table
        int rows = ErrataCacheManager.insertNeededErrataCache(sid, eid, p.getId());

        assertEquals(1, rows);
        return server;
    }

    public void testInsertNeededErrataCache() throws Exception {
        // create a lot of stuff to test this simple insert.
        Long oid = UserTestUtils.createOrg("testOrg");
        User user = UserTestUtils.createUser("testUser", oid);
        Server server = ServerFactoryTest.createTestServer(user);
        Errata e = ErrataFactoryTest.createTestErrata(oid);
        Long sid = server.getId();

        e = (Errata) TestUtils.saveAndReload(e);
        Long eid = e.getId();

        Package p = (Package) e.getPackages().iterator().next();

        // insert record into table
        int rows = ErrataCacheManager.insertNeededErrataCache(sid, eid, p.getId());
        assertEquals(1, rows);

        // verify what was inserted
        Session session = HibernateFactory.getSession();
        Connection conn = session.connection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
                "select * from rhnServerNeededErrataCache where server_id = " +
                sid.toString());
        assertTrue(rs.next());
        assertEquals(sid.longValue(), rs.getLong("server_id"));
        assertEquals(eid.longValue(), rs.getLong("errata_id"));

        // make sure we don't have more
        assertFalse(rs.next());
    }

    public void testDeleteNeededErrataCache() throws Exception {
        // create a lot of stuff to test this simple insert.
        Long oid = UserTestUtils.createOrg("testOrg");
        User user = UserTestUtils.createUser("testUser", oid);
        Server server = ServerFactoryTest.createTestServer(user);
        Errata e = ErrataFactoryTest.createTestErrata(oid);
        Long sid = server.getId();
        Long eid = e.getId();

        Package p = (Package) e.getPackages().iterator().next();

        // insert record into table
        int rows = ErrataCacheManager.insertNeededErrataCache(sid, eid, p.getId());
        assertEquals(1, rows);

        // verify what was inserted
        Session session = HibernateFactory.getSession();
        Connection conn = session.connection();
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(
                "select * from rhnServerNeededErrataCache where server_id = " +
                sid.toString());
        assertTrue(rs.next());
        assertEquals(sid.longValue(), rs.getLong("server_id"));
        assertEquals(eid.longValue(), rs.getLong("errata_id"));

        // make sure we don't have more
        assertFalse(rs.next());

        // now let's delete the above record
        rows = ErrataCacheManager.deleteNeededErrataCache(sid, eid);
        assertEquals(1, rows);

        rs = stmt.executeQuery(
                "select * from rhnServerNeededErrataCache where server_id = " +
                sid.toString());
        assertFalse(rs.next());
    }

    public void testPackagesNeedingUpdates() throws Exception {
        // create a lot of stuff to test this simple insert.
        Long oid = UserTestUtils.createOrg("testOrg");
        Org org = OrgFactory.lookupById(oid);
        User user = UserTestUtils.createUser("testUser", oid);
        Server server = ServerFactoryTest.createTestServer(user);
        Package pkg = PackageTest.createTestPackage(org);
        Errata e = ErrataFactoryTest.createTestErrata(oid);
        Long sid = server.getId();
        Long eid = e.getId();
        Long pid = pkg.getId();

        // insert record into table
        int rows = ErrataCacheManager.insertNeededPackageCache(
                sid, eid, pid);
        assertEquals(1, rows);

        DataResult dr = ErrataCacheManager.packagesNeedingUpdates(
                server.getId());

        assertFalse(dr.isEmpty());
        assertEquals(1, dr.size());

        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            ErrataCacheDto ecd = (ErrataCacheDto) itr.next();
            assertNotNull(ecd);
            assertEquals(server.getId(), ecd.getServerId());
            assertEquals(pkg.getId(), ecd.getPackageId());
            assertEquals(e.getId(), ecd.getErrataId());
        }
    }


    public void testUpdatePackageErrataForChannel() throws Exception {
        // I want to explicitly point out that the UpdateErrataCacheEventTest
        // actually tests the:
        //   ErrataCacheManager.updateErrataAndPackageCacheForChannel(()
        // method so instead of copy-pasting or refactoring all the code in
        // the below test we will just run it and indicate the coverage here.
        UpdateErrataCacheEventTest test = new UpdateErrataCacheEventTest();
        test.setUp();
        test.testUpdateCacheForChannel();
    }

    public void testAllServerIdsForOrg() throws Exception {
        // create a lot of stuff to test this simple insert.
        Long oid = UserTestUtils.createOrg("testOrg");
        Org org = OrgFactory.lookupById(oid);
        User user = UserTestUtils.createUser("testUser", oid);
        ServerFactoryTest.createTestServer(user);

        DataResult dr = ErrataCacheManager.allServerIdsForOrg(org);
        assertFalse(dr.isEmpty());
        assertTrue(dr.size() >= 1);
    }




}
