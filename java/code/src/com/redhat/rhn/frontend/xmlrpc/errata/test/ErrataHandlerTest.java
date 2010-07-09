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
package com.redhat.rhn.frontend.xmlrpc.errata.test;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.Keyword;
import com.redhat.rhn.domain.errata.impl.PublishedBug;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidAdvisoryReleaseException;
import com.redhat.rhn.frontend.xmlrpc.errata.ErrataHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.RandomStringUtils;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class ErrataHandlerTest extends BaseHandlerTestCase {

    private ErrataHandler handler = new ErrataHandler();
    private User user;

    @Override
    public void setUp() throws Exception {
        // TODO Auto-generated method stub
        super.setUp();
        user = UserTestUtils.createUser("testUser", admin.getOrg().getId());
    }

    public void testGetDetails() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        Errata check = ErrataManager.lookupErrata(errata.getId(), user);
        assertTrue(check.getAdvisory().equals(errata.getAdvisory()));
        assertTrue(check.getId().equals(errata.getId()));

        Map details = handler.getDetails(adminKey, errata.getAdvisory());
        assertNotNull(details);

        try {
            details = handler.getDetails(adminKey, "foo" + TestUtils.randomString());
            fail("found invalid errata");
        }
        catch (FaultException e) {
            //success
        }
    }

    public void testSetDetailsAdvRelAboveMax() throws Exception {
        // setup
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        Map<String, Object> details = new HashMap<String, Object>();
        details.put("advisory_release", new Integer(10000));
        try {
            handler.setDetails(adminKey, errata.getAdvisory(), details);
            fail("invalid advisory of 10000 accepted");
        }
        catch (InvalidAdvisoryReleaseException iare) {
            // we expect this test to fail
            assertTrue(true);
        }
    }

    public void testSetDetails() throws Exception {
        // setup
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        // execute
        Map<String, Object> details = new HashMap<String, Object>();
        details.put("synopsis", "synopsis-1");
        details.put("advisory_name", "advisory-1");
        details.put("advisory_release", (Integer) 123);
        details.put("advisory_type", "Security Advisory");
        details.put("product", "product text");
        details.put("topic", "topic text");
        details.put("description", "description text");
        details.put("references", "references text");
        details.put("notes", "notes text");
        details.put("solution", "solution text");

        List<Map<String, Object>> bugs = new ArrayList<Map<String, Object>>();

        Map<String, Object> bug1 = new HashMap<String, Object>();
        bug1.put("id", 1);
        bug1.put("summary", "bug1 summary");
        bugs.add(bug1);

        Map<String, Object> bug2 = new HashMap<String, Object>();
        bug2.put("id", 2);
        bug2.put("summary", "bug2 summary");
        bugs.add(bug2);

        details.put("bugs", bugs);

        List<String> keywords = new ArrayList<String>();
        keywords.add("keyword1");
        keywords.add("keyword2");
        details.put("keywords", keywords);

        int result = handler.setDetails(adminKey, errata.getAdvisory(), details);

        // verify
        assertEquals(1, result);

        Errata updatedErrata = ErrataManager.lookupErrata(errata.getId(), user);

        assertEquals(errata.getSynopsis(), "synopsis-1");
        assertEquals(errata.getAdvisory(), "advisory-1-123");
        assertEquals(errata.getAdvisoryName(), "advisory-1");
        assertEquals(errata.getAdvisoryRel(), new Long(123));
        assertEquals(errata.getAdvisoryType(), "Security Advisory");
        assertEquals(errata.getProduct(), "product text");
        assertEquals(errata.getTopic(), "topic text");
        assertEquals(errata.getDescription(), "description text");
        assertEquals(errata.getRefersTo(), "references text");
        assertEquals(errata.getNotes(), "notes text");
        assertEquals(errata.getSolution(), "solution text");

        boolean foundBug1 = false, foundBug2 = false;
        for (Bug bug : (Set<Bug>) errata.getBugs()) {
            if (bug.getId().equals(new Long(1)) &&
                bug.getSummary().equals("bug1 summary")) {
                foundBug1 = true;
            }
            if (bug.getId().equals(new Long(2)) &&
                bug.getSummary().equals("bug2 summary")) {
                foundBug2 = true;
            }
        }
        assertTrue(foundBug1);
        assertTrue(foundBug2);

        boolean foundKeyword1 = false, foundKeyword2 = false;
        for (Keyword keyword : (Set<Keyword>) errata.getKeywords()) {
            if (keyword.getKeyword().equals("keyword1")) {
                foundKeyword1 = true;
            }
            if (keyword.getKeyword().equals("keyword2")) {
                foundKeyword2 = true;
            }
        }
        assertTrue(foundKeyword1);
        assertTrue(foundKeyword2);
    }

    public void testListAffectedSystems() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        Errata check = ErrataManager.lookupErrata(errata.getId(), user);
        assertTrue(check.getAdvisory().equals(errata.getAdvisory()));
        assertTrue(check.getId().equals(errata.getId()));

        Object[] systems = handler.listAffectedSystems(adminKey, errata.getAdvisory());
        assertNotNull(systems);
        assertTrue(systems.length == 0);
    }

    public void testBugzillaFixes() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        Bug bug1 = new PublishedBug();
        bug1.setId(new Long(1001));
        bug1.setSummary("This is a test summary");

        errata.addBug(bug1);

        ErrataManager.storeErrata(errata);

        int numBugs = errata.getBugs().size();

        Map bugs = handler.bugzillaFixes(adminKey, errata.getAdvisory());

        assertEquals(numBugs, bugs.size());

        //map should contain an 'id' key only
        Set keys = bugs.keySet();
        assertEquals(1, keys.size());
        assertEquals("This is a test summary", bugs.get(new Long(1001)));
    }

    public void testListKeywords() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        errata.addKeyword("foo");
        errata.addKeyword("bar");

        ErrataManager.storeErrata(errata);

        Object[] keywords = handler.listKeywords(adminKey, errata.getAdvisory());

        assertEquals(errata.getKeywords().size(), keywords.length);

    }

    public void testApplicableToChannels() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        DataResult dr = ErrataManager.applicableChannels(errata.getId(),
                            user.getOrg().getId(), null, Map.class);

        Object[] channels = handler.applicableToChannels(adminKey, errata.getAdvisory());
        assertEquals(dr.size(), channels.length);
    }

    public void testListCves() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        DataResult dr = ErrataManager.errataCVEs(errata.getId());

        List cves = handler.listCves(adminKey, errata.getAdvisory());

        assertEquals(dr.size(), cves.size());
    }

    public void testPackages() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        Package p = PackageTest.createTestPackage(user.getOrg());
        errata.addPackage(p);
        ErrataManager.storeErrata(errata);

        Object[] pkgs = handler.listPackages(adminKey, errata.getAdvisory());

        assertNotNull(pkgs);
        assertEquals(errata.getPackages().size(), pkgs.length);
        assertTrue(pkgs.length > 0);
        boolean found = false;
        for (int i = 0; i < pkgs.length; i++) {
            Map pkg = (Map) pkgs[i];
            if (pkg.get("id").equals(p.getId())) {
                assertEquals(p.getBuildHost(), pkg.get("build_host"));
                found = true;
            }
        }
        assertTrue(found);
    }

    public void testAddPackages() throws Exception {
        // setup
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        ErrataManager.storeErrata(errata);

        int initialNumPkgs = handler.listPackages(adminKey, errata.getAdvisory()).length;

        Package pkg1 = PackageTest.createTestPackage(user.getOrg());
        Package pkg2 = PackageTest.createTestPackage(user.getOrg());

        // execute
        List<Integer> pkgIds = new ArrayList<Integer>();
        pkgIds.add(pkg1.getId().intValue());
        pkgIds.add(pkg2.getId().intValue());
        int numPkgsAdded = handler.addPackages(adminKey, errata.getAdvisory(), pkgIds);

        // verify
        assertEquals(2, numPkgsAdded);

        int resultNumPkgs = handler.listPackages(adminKey, errata.getAdvisory()).length;
        assertEquals(initialNumPkgs + 2, resultNumPkgs);

        boolean found1 = false, found2 = false;
        for (Package pkg : (Set<Package>) errata.getPackages()) {
            if (pkg.getId().equals(pkg1.getId())) {
                found1 = true;
            }
            if (pkg.getId().equals(pkg2.getId())) {
                found2 = true;
            }
        }
        assertTrue(found1);
        assertTrue(found2);
    }

    public void testRemovePackages() throws Exception {
        // setup
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        Package pkg1 = PackageTest.createTestPackage(user.getOrg());
        Package pkg2 = PackageTest.createTestPackage(user.getOrg());
        errata.addPackage(pkg1);
        errata.addPackage(pkg2);
        ErrataManager.storeErrata(errata);

        int initialNumPkgs = handler.listPackages(adminKey, errata.getAdvisory()).length;

        // execute
        List<Integer> pkgIds = new ArrayList<Integer>();
        pkgIds.add(pkg2.getId().intValue());
        int numPkgsRemoved = handler.removePackages(adminKey, errata.getAdvisory(), pkgIds);

        // verify
        assertEquals(1, numPkgsRemoved);

        int resultNumPkgs = handler.listPackages(adminKey, errata.getAdvisory()).length;
        assertEquals(initialNumPkgs - 1, resultNumPkgs);

        boolean found1 = false, found2 = false;
        for (Package pkg : (Set<Package>) errata.getPackages()) {
            if (pkg.getId().equals(pkg1.getId())) {
                found1 = true;
            }
            if (pkg.getId().equals(pkg2.getId())) {
                found2 = true;
            }
        }
        assertTrue(found1);
        assertFalse(found2);
    }

    public void testCloneErrata() throws Exception {
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        channel.setOrg(admin.getOrg());

        Package errataPack = PackageTest.createTestPackage(admin.getOrg());
        Package chanPack = PackageTest.createTestPackage(admin.getOrg());
        //we have to set the 2nd package to a different EVR to not violate a
        //      unique constraint
        PackageEvr evr =  PackageEvrFactory.createPackageEvr("45", "99", "983");
        chanPack.setPackageName(errataPack.getPackageName());
        chanPack.setPackageEvr(evr);

        channel.addPackage(chanPack);

        Errata toClone = ErrataFactoryTest.createTestPublishedErrata(
                admin.getOrg().getId());
        toClone.addPackage(errataPack);

        ArrayList errata = new ArrayList();
        errata.add(toClone.getAdvisory());

        Object[] returnValue = handler.clone(adminKey,
                channel.getLabel(), errata);
        assertEquals(1, returnValue.length);

        Errata cloned = ErrataFactory.lookupById(((Errata)returnValue[0]).getId());
        assertNotSame(toClone.getId(), cloned.getId());

        Set channels = cloned.getChannels();
        assertEquals(1, channels.size());

        Channel sameChannel = ((Channel)channels.toArray()[0]);
        assertEquals(channel, sameChannel);

        Set packs = sameChannel.getPackages();
        assertEquals(packs.size(), 2);

       assertTrue(packs.contains(errataPack));
       assertTrue(packs.contains(chanPack));

    }

    public void testCreate() throws Exception {

        Channel channel = ChannelFactoryTest.createBaseChannel(admin);

        Map errataInfo = new HashMap();

        String advisoryName = TestUtils.randomString();
        populateErrataInfo(errataInfo);
        errataInfo.put("advisory_name", advisoryName);

        ArrayList packages = new ArrayList();
        ArrayList bugs = new ArrayList();
        ArrayList keywords = new ArrayList();
        ArrayList channels = new ArrayList();
        channels.add(channel.getLabel());

        Errata errata = handler.create(adminKey, errataInfo,
                bugs, keywords, packages, true, channels);

        Errata result = ErrataFactory.lookupByAdvisory(advisoryName);
        assertEquals(errata, result);
        assertEquals(advisoryName + "-" + errata.getAdvisoryRel().toString(),
                result.getAdvisory());

    }

    public void testDelete() throws Exception {
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        Errata check = ErrataManager.lookupErrata(errata.getId(), user);
        assertTrue(check.getAdvisory().equals(errata.getAdvisory()));
        assertTrue(check.getId().equals(errata.getId()));

        // delete a published erratum
        int result = handler.delete(adminKey, errata.getAdvisory());
        assertEquals(1, result);
        errata = (Errata) TestUtils.reload(errata);
        assertNull(errata);

        errata = ErrataFactoryTest.createTestUnpublishedErrata(user.getOrg().getId());
        check = ErrataManager.lookupErrata(errata.getId(), user);
        assertTrue(check.getAdvisory().equals(errata.getAdvisory()));
        assertTrue(check.getId().equals(errata.getId()));

        // delete an unpublished erratum
        result = handler.delete(adminKey, errata.getAdvisory());
        assertEquals(1, result);
        errata = (Errata) TestUtils.reload(errata);
        assertNull(errata);
    }

    private void populateErrataInfo(Map errataInfo) {
        errataInfo.put("synopsis", TestUtils.randomString());
        errataInfo.put("advisory_release", new Integer(2));
        errataInfo.put("advisory_type", "Bug Fix Advisory");
        errataInfo.put("product", TestUtils.randomString());
        errataInfo.put("topic", TestUtils.randomString());
        errataInfo.put("description", TestUtils.randomString());
        errataInfo.put("solution", TestUtils.randomString());
        errataInfo.put("references", TestUtils.randomString());
        errataInfo.put("notes", TestUtils.randomString());
    }

    public void testAdvisoryLength() throws Exception {
        Channel channel = ChannelFactoryTest.createBaseChannel(admin);

        Map errataInfo = new HashMap();


        String advisoryName = RandomStringUtils.random(37);
        populateErrataInfo(errataInfo);
        errataInfo.put("advisory_name", advisoryName);

        ArrayList packages = new ArrayList();
        ArrayList bugs = new ArrayList();
        ArrayList keywords = new ArrayList();
        ArrayList channels = new ArrayList();
        channels.add(channel.getLabel());

        try {
            Errata errata = handler.create(adminKey, errataInfo,
                bugs, keywords, packages, true, channels);
            fail("large advisory name was accepted");
        }
        catch (Exception e) {
            // we expect this to fail
            assertTrue(true);
        }
    }

    public void testAdvisoryReleaseAboveMax() throws Exception {
        Channel channel = ChannelFactoryTest.createBaseChannel(admin);

        Map errataInfo = new HashMap();

        String advisoryName = TestUtils.randomString();
        populateErrataInfo(errataInfo);
        errataInfo.put("advisory_name", advisoryName);
        errataInfo.put("advisory_release", new Integer(10000));

        ArrayList packages = new ArrayList();
        ArrayList bugs = new ArrayList();
        ArrayList keywords = new ArrayList();
        ArrayList channels = new ArrayList();
        channels.add(channel.getLabel());

        try {
            Errata errata = handler.create(adminKey, errataInfo,
                bugs, keywords, packages, true, channels);
            fail("large advisory release was accepted");
        }
        catch (InvalidAdvisoryReleaseException iare) {
            // we expect this to fail
            assertTrue(true);
        }
    }

    public void testAdvisoryReleaseAtMax() throws Exception {
        Channel channel = ChannelFactoryTest.createBaseChannel(admin);

        Map errataInfo = new HashMap();

        String advisoryName = TestUtils.randomString();
        populateErrataInfo(errataInfo);
        errataInfo.put("advisory_name", advisoryName);
        errataInfo.put("advisory_release", new Integer(9999));

        ArrayList packages = new ArrayList();
        ArrayList bugs = new ArrayList();
        ArrayList keywords = new ArrayList();
        ArrayList channels = new ArrayList();
        channels.add(channel.getLabel());

        Errata errata = handler.create(adminKey, errataInfo,
            bugs, keywords, packages, true, channels);

        assertEquals(ErrataManager.MAX_ADVISORY_RELEASE,
                errata.getAdvisoryRel().longValue());
    }

    public void testPublish() throws Exception {

        Errata unpublished = ErrataFactoryTest.createTestUnpublishedErrata(
                admin.getOrg().getId());
        Channel channel = ChannelFactoryTest.createBaseChannel(admin);
        ArrayList channels = new ArrayList();
        channels.add(channel.getLabel());
        Errata published = handler.publish(adminKey, unpublished.getAdvisoryName(),
                channels);

        assertTrue(published.isPublished());
        assertEquals(unpublished.getAdvisory(), published.getAdvisory());

    }

    public void testListByDate() throws Exception {

       Calendar cal = Calendar.getInstance();
       Date earlyDate = cal.getTime();
       cal.add(Calendar.YEAR, 5);
       Date laterDate = cal.getTime();

       assertTrue(earlyDate.before(laterDate));

       Errata earlyErrata = ErrataFactoryTest.createTestPublishedErrata(
               admin.getOrg().getId());
       Errata laterErrata = ErrataFactoryTest.createTestPublishedErrata(
               admin.getOrg().getId());

       Channel testChannel  = ChannelFactoryTest.createTestChannel(admin);

       earlyErrata.addChannel(testChannel);
       earlyErrata.setIssueDate(earlyDate);
       laterErrata.addChannel(testChannel);
       laterErrata.setIssueDate(laterDate);

       List test =  handler.listByDate(adminKey, testChannel.getLabel());

       assertEquals(2, test.size());
       Object[] array = test.toArray();
       assertEquals(array[0], earlyErrata);
       assertEquals(array[1], laterErrata);
    }
}
