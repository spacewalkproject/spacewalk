/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.errata.ErrataAction;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
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
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.errata.cache.test.ErrataCacheManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.time.StopWatch;
import org.hibernate.criterion.Restrictions;

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
import java.util.Set;

import static com.redhat.rhn.testing.ErrataTestUtils.createLaterTestPackage;
import static com.redhat.rhn.testing.ErrataTestUtils.createTestInstalledPackage;
import static com.redhat.rhn.testing.ErrataTestUtils.createTestPackage;
import static com.redhat.rhn.testing.ErrataTestUtils.createTestServer;

/**
 * ErrataManagerTest
 * @version $Rev$
 */
public class ErrataManagerTest extends BaseTestCaseWithUser {

    public static Bug createNewPublishedBug(Long id, String summary) {
        return ErrataManager.createNewPublishedBug(id, summary,
                "https://bugzilla.redhat.com/show_bug.cgi?id=" + id);
    }

    public static Bug createNewUnpublishedBug(Long id, String summary) {
        return ErrataManager.createNewUnpublishedBug(id, summary,
                "https://bugzilla.redhat.com/show_bug.cgi?id=" + id);
    }

    public void testPublish() throws Exception {
        User user = UserTestUtils.findNewUser();
        Errata e = ErrataFactoryTest.createTestUnpublishedErrata(user.getOrg().getId());
        assertFalse(e.isPublished()); //should be unpublished
      //publish errata and store back into self
        e = ErrataManager.publish(e, new HashSet(), user);
        assertTrue(e.isPublished());  //should be published
    }

    public void testStore() throws Exception {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        e.setAdvisoryName(TestUtils.randomString());
        ErrataManager.storeErrata(e);

        Errata e2 = ErrataManager.lookupErrata(e.getId(), user);
        assertEquals(e.getAdvisoryName(), e2.getAdvisoryName());
    }

    public void testCreate() {
        Errata e = ErrataManager.createNewErrata();
        assertTrue(e instanceof UnpublishedErrata);

        Bug b = createNewUnpublishedBug(new Long(87), "test bug");
        assertTrue(b instanceof UnpublishedBug);

        Bug b2 = ErrataManagerTest.createNewPublishedBug(new Long(42), "test bug");
        assertTrue(b2 instanceof PublishedBug);
    }

    public void testSearchByPackagesIds() throws Exception {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        Package p = PackageTest.createTestPackage(user.getOrg());
        // errata search is done by the search-server. The search
        // in ErrataManager is to load ErrataOverview objects from
        // the results of the search-server searches.
        Bug b1 = ErrataManagerTest.createNewPublishedBug(new Long(42), "test bug");
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
        Map<String, Object> params = new HashMap<String, Object>();
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
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        Package p = PackageTest.createTestPackage(user.getOrg());
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
        List<Errata> errataList = new ArrayList<Errata>();
        errataList.add(e);
        List<Errata> publishedList = ErrataFactory.publishToChannel(errataList,
                baseChannel, user, false);
        Errata publish = publishedList.get(0);
        assertTrue(publish instanceof PublishedErrata);

        List eids = new ArrayList();
        eids.add(publish.getId());
        List<ErrataOverview> eos = ErrataManager.search(eids, user.getOrg());
        assertNotNull(eos);
        assertEquals(1, eos.size());
    }

    public void testAllErrataList() {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        DataResult errata = ErrataManager.allErrata(user);
        assertNotNull(errata);
        assertTrue(errata.size() <= 20);
    }

    public void testRelevantErrataList() throws Exception {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        ErrataCacheManagerTest.createServerNeededPackageCache(user,
                ErrataFactory.ERRATA_TYPE_BUG);
        DataResult errata = ErrataManager.relevantErrata(user);
        assertNotNull(errata);
        assertTrue(errata.size() >= 1);
    }

    public void testRelevantErrataByTypeList() throws Exception {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
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
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        DataResult errata = ErrataManager.unpublishedOwnedErrata(user);
        assertNotNull(errata);
        assertTrue(errata.size() <= 20);
    }

    public void testUnpublishedInSet() {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(20);
        DataResult errata = ErrataManager.unpublishedInSet(user, pc, "errata_to_delete");
        assertNotNull(errata);
        assertTrue(errata.isEmpty());
        assertFalse(errata.size() > 0);
    }

    public void testLookupErrata() throws Exception {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
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
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        PageControl pc = new PageControl();
        pc.setStart(1);
        pc.setPageSize(5);

        Errata a = ErrataFactoryTest.createTestErrata(UserTestUtils.createOrg("testOrg" +
                    this.getClass().getSimpleName()));

        DataResult systems = ErrataManager.systemsAffected(user, a.getId(), pc);
        assertNotNull(systems);
        assertTrue(systems.isEmpty());
        assertFalse(systems.size() > 0);

        DataResult systems2 = ErrataManager.systemsAffected(user, new Long(-2), pc);
        assertTrue(systems2.isEmpty());
    }

    public void testAdvisoryNameUnique() throws Exception {
        Errata e1 = ErrataFactoryTest.createTestErrata(UserTestUtils.createOrg("testOrg" +
                    this.getClass().getSimpleName()));
        Thread.sleep(100); //sleep for a bit to make sure we get unique advisoryNames
        Errata e2 = ErrataFactoryTest.createTestErrata(UserTestUtils.createOrg("testOrg" +
                    this.getClass().getSimpleName()));

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

    /**
     * Test only relevant errata per system.
     *
     * @throws Exception the exception
     */
    @SuppressWarnings("unchecked")
    public void testOnlyRelevantErrataPerSystem() throws Exception {

        Errata errata1 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        TestUtils.saveAndFlush(errata1);
        Errata errata2 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        TestUtils.saveAndFlush(errata2);
        Errata errata3 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        TestUtils.saveAndFlush(errata2);

        Channel channel1 = ChannelFactoryTest.createTestChannel(user);
        Channel channel2 = ChannelFactoryTest.createTestChannel(user);
        Channel channel3 = ChannelFactoryTest.createTestChannel(user);

        Set<Channel> server1Channels = new HashSet<Channel>();
        server1Channels.add(channel1);
        server1Channels.add(channel3);
        Server server1 = createTestServer(user, server1Channels);

        Set<Channel> server2Channels = new HashSet<Channel>();
        server2Channels.add(channel2);
        server2Channels.add(channel3);
        Server server2 = createTestServer(user, server2Channels);

        // server 1 has an errata for package1 available
        com.redhat.rhn.domain.rhnpackage.Package package1 =
                createTestPackage(user, channel1, "noarch");
        createTestInstalledPackage(package1, server1);
        createLaterTestPackage(user, errata1, channel1, package1);

        // server 2 has an errata for package2 available
        Package package2 = createTestPackage(user, channel2, "noarch");
        createTestInstalledPackage(package2, server2);
        createLaterTestPackage(user, errata2, channel2, package2);

        // errata in common for both servers
        Package package3 = createTestPackage(user, channel3, "noarch");
        createTestInstalledPackage(package3, server1);
        createTestInstalledPackage(package3, server2);
        createLaterTestPackage(user, errata3, channel3, package3);

        ErrataCacheManager.insertNeededErrataCache(
                server1.getId(), errata1.getId(), package1.getId());
        ErrataCacheManager.insertNeededErrataCache(
                server2.getId(), errata2.getId(), package2.getId());
        // Erata 3 is common to server 1 and server 2
        ErrataCacheManager.insertNeededErrataCache(
                server1.getId(), errata3.getId(), package3.getId());
        ErrataCacheManager.insertNeededErrataCache(
                server2.getId(), errata3.getId(), package3.getId());
        HibernateFactory.getSession().flush();

        List<Long> errataIds = new ArrayList<Long>();
        errataIds.add(errata1.getId());
        errataIds.add(errata2.getId());
        errataIds.add(errata3.getId());

        List<Long> serverIds = new ArrayList<Long>();
        serverIds.add(server1.getId());
        serverIds.add(server2.getId());

        ErrataManager.applyErrata(user, errataIds, new Date(), serverIds);

        // we want to check that no matter how many actions were scheduled for
        // server1, all the erratas included in those scheduled actions for
        // server1 do not contain the erratas for server2

        List<Action> actionsServer1 = ActionFactory.listActionsForServer(user, server1);
        Set<Long> server1ScheduledErrata = new HashSet<Long>();
        for (Action a : actionsServer1) {
            ErrataAction errataAction = errataActionFromAction(a);
            for (Errata e : errataAction.getErrata()) {
                server1ScheduledErrata.add(e.getId());
            }
        }

        List<Action> actionsServer2 = ActionFactory.listActionsForServer(user, server2);
        Set<Long> server2ScheduledErrata = new HashSet<Long>();
        for (Action a : actionsServer2) {
            ErrataAction errataAction = errataActionFromAction(a);
            for (Errata e : errataAction.getErrata()) {
                server2ScheduledErrata.add(e.getId());
            }
        }

        assertEquals("Server 1 Scheduled Erratas has 2 erratas (errata1 and errata3)",
                2, server1ScheduledErrata.size());
        assertFalse("Server 1 Scheduled Erratas do not include other server's errata",
                server1ScheduledErrata.contains(errata2.getId()));
        assertTrue("Server 1 Scheduled Erratas contain relevant erratas",
                server1ScheduledErrata.contains(errata1.getId()));
        assertTrue("Server 1 Scheduled Erratas contain relevant erratas",
                server1ScheduledErrata.contains(errata3.getId()));

        assertEquals("Server 2 Scheduled Erratas has 2 erratas (errata2 and errata3)",
                2, server2ScheduledErrata.size());
        assertFalse("Server 2 Scheduled Erratas do not include other server's errata",
                server2ScheduledErrata.contains(errata1.getId()));
        assertTrue("Server 2 Scheduled Erratas contain relevant erratas",
                server2ScheduledErrata.contains(errata2.getId()));
        assertTrue("Server 2 Scheduled Erratas contain relevant erratas",
                server2ScheduledErrata.contains(errata3.getId()));

    }

    /**
     * Test that with 2 software management stack erratas, where one system
     * is affected by one of them, and the other by both, they are scheduled
     * before other erratas, and bundled in a single action.
     *
     * @throws Exception the exception
     */
    @SuppressWarnings("unchecked")
    public void testPackageManagerErratas() throws Exception {

        Errata errata1 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        TestUtils.saveAndFlush(errata1);
        Errata errata2 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        TestUtils.saveAndFlush(errata2);
        Errata errata3 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        TestUtils.saveAndFlush(errata2);

        // software management stack erratas
        Errata yumErrata1 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        yumErrata1.addKeyword("restart_suggested");
        TestUtils.saveAndFlush(yumErrata1);
        Errata yumErrata2 = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        yumErrata2.addKeyword("restart_suggested");
        TestUtils.saveAndFlush(yumErrata2);


        Channel channel1 = ChannelFactoryTest.createTestChannel(user);
        Channel channel2 = ChannelFactoryTest.createTestChannel(user);
        Channel channel3 = ChannelFactoryTest.createTestChannel(user);

        Set<Channel> server1Channels = new HashSet<Channel>();
        server1Channels.add(channel1);
        server1Channels.add(channel3);
        Server server1 = createTestServer(user, server1Channels);

        Set<Channel> server2Channels = new HashSet<Channel>();
        server2Channels.add(channel2);
        server2Channels.add(channel3);
        Server server2 = createTestServer(user, server2Channels);

        // server 1 has an errata for package1 available
        com.redhat.rhn.domain.rhnpackage.Package package1 =
                createTestPackage(user, channel1, "noarch");
        createTestInstalledPackage(package1, server1);
        createLaterTestPackage(user, errata1, channel1, package1);

        // server 2 has an errata for package2 available
        Package package2 = createTestPackage(user, channel2, "noarch");
        createTestInstalledPackage(package2, server2);
        createLaterTestPackage(user, errata2, channel2, package2);

        // errata does not affect any system
        Package package3 = createTestPackage(user, channel3, "noarch");
        // they systems do not have package3 installed
        createLaterTestPackage(user, errata3, channel3, package3);

        // server1 is affected by both yum erratas
        // server2 only by one
        Package yumPackage1 = createTestPackage(user, channel3, "noarch");
        Package yumPackage2 = createTestPackage(user, channel3, "noarch");

        createTestInstalledPackage(yumPackage1, server1);
        createTestInstalledPackage(yumPackage2, server1);

        createTestInstalledPackage(yumPackage1, server2);

        // they systems do not have package3 installed
        createLaterTestPackage(user, yumErrata1, channel3, yumPackage1);
        createLaterTestPackage(user, yumErrata2, channel3, yumPackage2);


        ErrataCacheManager.insertNeededErrataCache(
                server1.getId(), errata1.getId(), package1.getId());
        ErrataCacheManager.insertNeededErrataCache(
                server2.getId(), errata2.getId(), package2.getId());

        ErrataCacheManager.insertNeededErrataCache(
                server1.getId(), yumErrata1.getId(), yumPackage1.getId());
        ErrataCacheManager.insertNeededErrataCache(
                server1.getId(), yumErrata2.getId(), yumPackage2.getId());
        ErrataCacheManager.insertNeededErrataCache(
                server2.getId(), yumErrata1.getId(), yumPackage1.getId());
        HibernateFactory.getSession().flush();

        List<Long> errataIds = new ArrayList<Long>();
        errataIds.add(errata1.getId());
        errataIds.add(errata2.getId());
        errataIds.add(errata3.getId());
        errataIds.add(yumErrata1.getId());
        errataIds.add(yumErrata2.getId());

        List<Long> serverIds = new ArrayList<Long>();
        serverIds.add(server1.getId());
        serverIds.add(server2.getId());

        ErrataManager.applyErrata(user, errataIds, new Date(), serverIds);

        // we want to check that no matter how many actions were scheduled for
        // server1, all the erratas included in those scheduled actions for
        // server1 do not contain the erratas for server2

        List<Action> actionsServer1 = ActionFactory.listActionsForServer(user, server1);
        Set<Long> server1ScheduledErrata = new HashSet<Long>();
        for (Action a : actionsServer1) {
            ErrataAction errataAction = errataActionFromAction(a);
            for (Errata e : errataAction.getErrata()) {
                server1ScheduledErrata.add(e.getId());
            }
        }

        List<Action> actionsServer2 = ActionFactory.listActionsForServer(user, server2);
        Set<Long> server2ScheduledErrata = new HashSet<Long>();
        for (Action a : actionsServer2) {
            ErrataAction errataAction = errataActionFromAction(a);
            for (Errata e : errataAction.getErrata()) {
                server2ScheduledErrata.add(e.getId());
            }
        }

        assertEquals("Server 1 Scheduled Erratas has 3 erratas (errata1 and both" +
                " yumErratas)", 3, server1ScheduledErrata.size());
        assertFalse("Server 1 Scheduled Erratas do not include irrelevant errata",
                server1ScheduledErrata.contains(errata3.getId()));
        assertTrue("Server 1 Scheduled Erratas contain relevant erratas",
                server1ScheduledErrata.contains(errata1.getId()));
        assertTrue("Server 1 Scheduled Erratas contain both yum erratas",
                server1ScheduledErrata.contains(yumErrata1.getId()));
        assertTrue("Server 1 Scheduled Erratas contain both yum erratas",
                server1ScheduledErrata.contains(yumErrata2.getId()));


        assertEquals("Server 2 Scheduled Erratas has 2 erratas (errata2 and yumErrata1)",
                2, server2ScheduledErrata.size());
        assertFalse("Server 2 Scheduled Erratas do not include irrelevant errata",
                server2ScheduledErrata.contains(errata3.getId()));
        assertTrue("Server 2 Scheduled Erratas contain relevant erratas",
                server2ScheduledErrata.contains(errata2.getId()));
        assertTrue("Server 2 Scheduled Erratas contain one yum errata",
                server2ScheduledErrata.contains(yumErrata1.getId()));
    }

    /**
     * Get an ErrataAction from an Action.
     * @param action the action
     * @return the errata action
     */
    private ErrataAction errataActionFromAction(Action action) {
        ErrataAction errataAction = (ErrataAction) HibernateFactory.getSession()
                .createCriteria(ErrataAction.class)
                .add(Restrictions.idEq(action.getId()))
                .uniqueResult();
        return errataAction;
    }
}
