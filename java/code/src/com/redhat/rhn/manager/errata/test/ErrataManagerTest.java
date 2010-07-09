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
package com.redhat.rhn.manager.errata.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.impl.PublishedBug;
import com.redhat.rhn.domain.errata.impl.PublishedErrata;
import com.redhat.rhn.domain.errata.impl.UnpublishedBug;
import com.redhat.rhn.domain.errata.impl.UnpublishedErrata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.test.ErrataCacheManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.time.StopWatch;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * ErrataManagerTest
 * @version $Rev$
 */
public class ErrataManagerTest extends RhnBaseTestCase {

    public void testPublish() throws Exception {
        User user = UserTestUtils.findNewUser();
        Errata e = ErrataFactoryTest.createTestUnpublishedErrata(user.getOrg().getId());
        assertFalse(e.isPublished()); //should be unpublished
      //publish errata and store back into self
        e = ErrataManager.publish(e, new HashSet(), user);
        assertTrue(e.isPublished());  //should be published
    }

    public void testStore() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        e.setAdvisoryName(TestUtils.randomString());
        ErrataManager.storeErrata(e);

        Errata e2 = ErrataManager.lookupErrata(e.getId(), user);
        assertEquals(e.getAdvisoryName(), e2.getAdvisoryName());
    }

    public void testCreate() {
        Errata e = ErrataManager.createNewErrata();
        assertTrue(e instanceof UnpublishedErrata);

        Bug b = ErrataManager.createNewUnpublishedBug(new Long(87), "test bug");
        assertTrue(b instanceof UnpublishedBug);

        Bug b2 = ErrataManager.createNewPublishedBug(new Long(42), "test bug");
        assertTrue(b2 instanceof PublishedBug);
    }

    public void testSearchByPackagesIds() throws Exception {
        Package p = PackageTest.createTestPackage();
        // errata search is done by the search-server. The search
        // in ErrataManager is to load ErrataOverview objects from
        // the results of the search-server searches.
        Bug b1 = ErrataManager.createNewPublishedBug(new Long(42), "test bug");
        assertTrue(b1 instanceof PublishedBug);
        Errata e = ErrataManager.createNewErrata();
        assertTrue(e instanceof UnpublishedErrata);
        e.setAdvisory("ZEUS-2007");
        e.setAdvisoryName("ZEUS-2007");
        e.setAdvisoryRel(new Long(1));
        e.setAdvisoryType("Security Advisory");
        e.setProduct("Red Hat Enterprise Linux");
        e.setSynopsis("Just a test errata");
        e.setSolution("This errata fixes nothing, it's just a damn test.");
        e.setIssueDate(new Date());
        e.setUpdateDate(e.getIssueDate());
        e.addPackage(p);
        e = ErrataManager.publish(e);
        assertTrue(e instanceof PublishedErrata);

        WebSession session = WebSessionFactory.createSession();
        WebSessionFactory.save(session);
        assertNotNull(session.getId());

        // for package search, we need to insert an entry into rhnVisibleObjects
        WriteMode mode = ModeFactory.getWriteMode(
                "test_queries", "insert_into_visibleobjects");
        Map params = new HashMap();
        //"sessionid, obj_id, obj_type"
        params.put("sessionid", session.getId());
        params.put("obj_id", e.getId());
        params.put("obj_type", "errata");
        mode.executeUpdate(params);

        // now test for errata
        List pids = new ArrayList();
        pids.add(p.getId());
        List<ErrataOverview> eos = ErrataManager.searchByPackageIds(pids);
        assertNotNull(eos);
        assertEquals(1, eos.size());
        ErrataOverview eo = eos.get(0);
        assertNotNull(eo);
        assertEquals(e.getAdvisory(), eo.getAdvisory());
    }

    public void testSearch() throws Exception {
        // errata search is done by the search-server. The search
        // in ErrataManager is to load ErrataOverview objects from
        // the results of the search-server searches.
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Package p = PackageTest.createTestPackage();
        Errata e = ErrataManager.createNewErrata();
        assertTrue(e instanceof UnpublishedErrata);
        e.setAdvisory("ZEUS-2007");
        e.setAdvisoryName("ZEUS-2007");
        e.setAdvisoryRel(new Long(1));
        e.setAdvisoryType("Security Advisory");
        e.setProduct("Red Hat Enterprise Linux");
        e.setSynopsis("Just a test errata");
        e.setSolution("This errata fixes nothing, it's just a damn test.");
        e.setIssueDate(new Date());
        e.setUpdateDate(e.getIssueDate());
        e.addPackage(p);

        Channel baseChannel = ChannelTestUtils.createBaseChannel(user);
        Errata publish = ErrataFactory.publishToChannel(e, baseChannel, user);
        assertTrue(publish instanceof PublishedErrata);

        List eids = new ArrayList();
        eids.add(publish.getId());
        List<ErrataOverview> eos = ErrataManager.search(eids, user.getOrg());
        assertNotNull(eos);
        assertEquals(1, eos.size());
    }

    public void testAllErrataList() {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        DataResult errata = ErrataManager.allErrata(user);
        assertNotNull(errata);
        assertTrue(errata.size() <= 20);
    }

    public void testRelevantErrataList() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        ErrataCacheManagerTest.createServerNeededPackageCache(user,
                ErrataFactory.ERRATA_TYPE_BUG);
        DataResult errata = ErrataManager.relevantErrata(user);
        assertNotNull(errata);
        assertTrue(errata.size() >= 1);
    }

    public void testRelevantErrataByTypeList() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        ErrataCacheManagerTest.createServerNeededPackageCache(user,
                ErrataFactory.ERRATA_TYPE_BUG);
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(20);
        DataResult errata =
            ErrataManager.relevantErrataByType(user, pc, ErrataFactory.ERRATA_TYPE_BUG);
        assertNotNull(errata);
        assertTrue(errata.size() >= 1);
    }

    public void testUnpublishedErrata() {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        DataResult errata = ErrataManager.unpublishedOwnedErrata(user);
        assertNotNull(errata);
        assertTrue(errata.size() <= 20);
    }

    public void testUnpublishedInSet() {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(20);
        DataResult errata = ErrataManager.unpublishedInSet(user, pc, "errata_to_delete");
        assertNotNull(errata);
        assertTrue(errata.isEmpty());
        assertFalse(errata.size() > 0);
    }

    public void testLookupErrata() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        // Check for the case where the errata belongs to the users org
        Errata check = ErrataManager.lookupErrata(errata.getId(), user);
        assertTrue(check.getAdvisory().equals(errata.getAdvisory()));
        assertTrue(check.getId().equals(errata.getId()));

        /*
         * Bugzilla: 168292
         * Make sure we handle the case when returnedErrata.getOrg == null without throwing
         * an NPE.
         */
        errata.setOrg(null);
        ErrataManager.storeErrata(errata);

        try {
            check = ErrataManager.lookupErrata(errata.getId(), user);
            fail();
        }
        catch (LookupException e) {
            //This means we hit the returnedErrata.getOrg == null path successfully
        }
        Org org2 = OrgFactory.lookupById(UserTestUtils.createOrg("testOrg2"));
        errata.setOrg(org2);
        ErrataManager.storeErrata(errata);

        try {
            check = ErrataManager.lookupErrata(errata.getId(), user);
        }
        catch (LookupException e) {
            //This means we hit returnedErrata.getOrg().getId() != user.getOrg().getId()
        }

        // Check for non-existant errata
        try {
            check = ErrataManager.lookupErrata(new Long(-1234), user);
            fail();
        }
        catch (LookupException e) {
            //This means we hit the returnedErrata == null path successfully
        }
    }

    public void testSystemsAffected() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(5);

        Errata a = ErrataFactoryTest.createTestErrata(UserTestUtils.createOrg("testOrg"));

        DataResult systems = ErrataManager.systemsAffected(user, a.getId(), pc);
        assertNotNull(systems);
        assertTrue(systems.isEmpty());
        assertFalse(systems.size() > 0);

        DataResult systems2 = ErrataManager.systemsAffected(user, new Long(-2), pc);
        assertTrue(systems2.isEmpty());
    }

    public void testAdvisoryNameUnique() throws Exception {
        Errata e1 = ErrataFactoryTest.createTestErrata(UserTestUtils.createOrg("testOrg"));
        Thread.sleep(100); //sleep for a bit to make sure we get unique advisoryNames
        Errata e2 = ErrataFactoryTest.createTestErrata(UserTestUtils.createOrg("testOrg"));

        assertFalse(e1.getId().equals(e2.getId())); //make sure adv names are different
        assertTrue(ErrataManager.advisoryNameIsUnique(e2.getId(), e2.getAdvisoryName()));
        assertFalse(ErrataManager.advisoryNameIsUnique(e2.getId(), e1.getAdvisoryName()));
    }

    // Don't need this test to actually run right now.  Its experimental.
    public void xxxxLookupErrataByAdvisoryType() throws IOException {

        String bugfix = "Bug Fix Advisory";
        String pea = "Product Enhancement Advisory";
        String security = "Security Advisory";

        StopWatch st = new StopWatch();
        st.start();
        List erratas = ErrataManager.lookupErrataByType(bugfix);
        outputErrataList(erratas);
        System.out.println("Got bugfixes: "  + erratas.size() + " time: " + st);
        assertTrue(erratas.size() > 0);
        erratas = ErrataManager.lookupErrataByType(pea);
        outputErrataList(erratas);
        System.out.println("Got pea enhancments: "  + erratas.size() + " time: " + st);
        assertTrue(erratas.size() > 0);
        erratas = ErrataManager.lookupErrataByType(security);
        outputErrataList(erratas);
        assertTrue(erratas.size() > 0);
        System.out.println("Got security advisories: "  + erratas.size() + " time: " + st);
        st.stop();
        System.out.println("TIME: " + st.getTime());
    }

    private void outputErrataList(List erratas) throws IOException {
        StringBuffer output = new StringBuffer();
        Iterator i = erratas.iterator();
        while (i.hasNext()) {
            Errata e = (Errata) i.next();
            output.append(e.toString());
        }
        FileWriter fr = new FileWriter(new File("errataout" + erratas.size() +  ".txt"));
        fr.write(output.toString());
        fr.close();
    }

    public void testErrataInSet() throws Exception {
        User user = UserTestUtils.findNewUser();

        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        e = (Errata) TestUtils.saveAndReload(e);
        RhnSet set = RhnSetDecl.ERRATA_TO_REMOVE.get(user);
        set.add(e.getId());
        RhnSetManager.store(set);

        List<ErrataOverview> list = ErrataManager.errataInSet(user, set.getLabel());
        boolean found = false;
        for (ErrataOverview item : list) {
            if (item.getId().equals(e.getId())) {
                found = true;
            }
        }
        assertTrue(found);

    }

    /**
     * TODO: need to put this test back in when we put back errata management.
     */
    /*public void aTestClonableErrata() {
        Long cid = new Long(231);
        Long orgid = new Long(1);
        DataResult dr = ErrataManager.clonableErrata(cid, orgid, null);
        System.out.println("Size [" + dr.size() + "]");
    }*/
}
