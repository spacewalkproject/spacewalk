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
package com.redhat.rhn.domain.errata.test;

import com.redhat.rhn.common.security.errata.PublishedOnlyException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.ErrataFile;
import com.redhat.rhn.domain.errata.impl.PublishedBug;
import com.redhat.rhn.domain.errata.impl.PublishedErrata;
import com.redhat.rhn.domain.errata.impl.PublishedErrataFile;
import com.redhat.rhn.domain.errata.impl.UnpublishedBug;
import com.redhat.rhn.domain.errata.impl.UnpublishedErrata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;

/**
 * ErrataTest
 * @version $Rev$
 */
public class ErrataTest extends RhnBaseTestCase {
    
    public void testNotificationQueue() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel c = ChannelFactoryTest.createBaseChannel(user);
        Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        e.addChannel(c);
        ErrataManager.storeErrata(e);
        Long id = e.getId(); //get id for later
        e.addNotification(new Date()); //add one
        e.addNotification(new Date()); //add another
        assertEquals(1, e.getNotificationQueue().size()); //should be only 1
        //save errata and evict
        ErrataManager.storeErrata(e);
        flushAndEvict(e);
        
        Errata e2 = ErrataManager.lookupErrata(id, user); //lookup the errata
        assertEquals(1, e2.getNotificationQueue().size()); //should be only 1
        
        //Let's make sure we can't add notifications to unpublished erratas
        Errata e3 = ErrataFactoryTest.createTestUnpublishedErrata(
                                          UserTestUtils.createOrg("testOrg"));
        try {
            e3.addNotification(new Date());
            fail();
        }
        catch (PublishedOnlyException ex) {
            //Success!!!
        }
    }
    
    /**
     * Test the bugs set in the Errata class. Make sure we can
     * add and store bugs.
     * @throws Exception
     */
    public void testBugs() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());

        Bug bug1 = new PublishedBug();
        bug1.setId(new Long(1001));
        bug1.setSummary("This is a test summary");
        
        Bug bug2 = new PublishedBug();
        bug2.setId(new Long(1002));
        bug2.setSummary("This is another test summary");
        
        errata.addBug(bug1);
        errata.addBug(bug2);
        
        assertEquals(errata.getBugs().size(), 2);
        ErrataFactory.save(errata);
        Long id = errata.getId();
        
        //Evict so we know we're going to the db for the next one
        flushAndEvict(errata);
        Errata errata2 = ErrataManager.lookupErrata(id, user);
        
        assertEquals(id, errata2.getId());
        assertEquals(errata2.getBugs().size(), 2);
        errata2.removeBug(bug1.getId());
        assertEquals(errata2.getBugs().size(), 1);
    }
    
    /**
     * Test unpublished bugs
     * @throws Exception
     */
    public void testBugsUnpublished() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata errata = ErrataFactoryTest
                .createTestUnpublishedErrata(user.getOrg().getId());

        Bug bug1 = new UnpublishedBug();
        bug1.setId(new Long(1003));
        bug1.setSummary("This is a test summary");
        
        Bug bug2 = new UnpublishedBug();
        bug2.setId(new Long(1004));
        bug2.setSummary("This is another test summary");
        
        errata.addBug(bug1);
        errata.addBug(bug2);
        
        assertEquals(errata.getBugs().size(), 2);
        
        ErrataFactory.save(errata);
        Long id = errata.getId();
        
        //Evict so we know we're going to the db for the next one
        flushAndEvict(errata);
        Errata errata2 = ErrataManager.lookupErrata(id, user);
        
        assertEquals(errata2.getId(), id);
        assertEquals(errata2.getBugs().size(), 2);
    }
    
    /**
     * Test the keywords set in the Errata class. Make sure we
     * can add and store keywords.
     * @throws Exception
     */
    //published
    public void testPublishedKeywords() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        assertTrue(errata instanceof PublishedErrata);
        runKeywordsTest(errata, user);
    }
    //unpublished
    public void testUnpublishedKeywords() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata errata = ErrataFactoryTest
                .createTestUnpublishedErrata(user.getOrg().getId());
        assertTrue(errata instanceof UnpublishedErrata);
        runKeywordsTest(errata, user);
    }
    private void runKeywordsTest(Errata errata, User user) throws Exception {
        errata.addKeyword("yankee");
        errata.addKeyword("hotel");
        errata.addKeyword("foxtrot");
        
        assertEquals(errata.getKeywords().size(), 3);
        ErrataFactory.save(errata);
        Long id = errata.getId();
        
        //Evict so we know we're going to the db for the next one
        flushAndEvict(errata);
        Errata errata2 = ErrataManager.lookupErrata(id, user);
        
        assertEquals(id, errata2.getId());
        assertEquals(3, errata2.getKeywords().size());
    }
    
    /**
     * Test the packages set in 
     * @throws Exception
     */
    //published
    public void testPublishedPackage() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        assertTrue(errata instanceof PublishedErrata);
        runPackageTest(errata, user);
    }
    //unpublished
    public void testUnpublishedPackage() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Errata errata = ErrataFactoryTest
                .createTestUnpublishedErrata(user.getOrg().getId());
        assertTrue(errata instanceof UnpublishedErrata);
        runPackageTest(errata, user);
    }
    
    public void testAddChannelsToErrata() throws Exception {
        User user = UserTestUtils.findNewUser();
        Errata e = ErrataFactoryTest.createTestPublishedErrata(
                user.getOrg().getId());
        assertTrue(e.getFiles().size() > 0);
        assertTrue(e.getPackages().size() > 0);
        Channel c = ChannelTestUtils.createTestChannel(user);
        Package p = PackageManagerTest.addPackageToChannel("some-errata-package", c);
        c = (Channel) reload(c);
        
        // Add the package to an errataFile
        ErrataFile ef;
        ef = ErrataFactory.createPublishedErrataFile(ErrataFactory.
                lookupErrataFileType("RPM"),
                    "SOME FAKE CHECKSUM",
                    "testAddChannelsToErrata" + TestUtils.randomString(), new HashSet());
        ef.addPackage(p);
        e.addFile(ef);
        
        e.addPackage(p);
        e.addChannel(c);
        
        ErrataFactory.save(e);
        e = (Errata) reload(e);
        
        assertEquals(1, e.getChannels().size());
        
        
        
        // Now test clearing it out
        e.clearChannels();
        e = (Errata) TestUtils.saveAndReload(e);
        assertTrue(e.getChannels() == null || e.getChannels().size() == 0);
        Iterator i = e.getFiles().iterator();
        boolean matched = false;
        while (i.hasNext()) {
            PublishedErrataFile f1 = (PublishedErrataFile) i.next();
            assertNotNull(f1.getChannels());
            assertTrue(f1.getChannels() == null || f1.getChannels().size() == 0);
            matched = true;
        }
        assertTrue("didnt match the erratafile", matched);
    }
    

    
    private void runPackageTest(Errata errata, User user) throws Exception {
        Package pkg = PackageTest.createTestPackage();
        errata.addPackage(pkg);
        
        assertEquals(2, errata.getPackages().size());
        ErrataFactory.save(errata);
        Long id = errata.getId();
        //Evict so we know we're going to the db for the next one
        flushAndEvict(errata);
        Errata errata2 = ErrataManager.lookupErrata(id, user);
        
        assertEquals(errata2.getId(), id);
        assertEquals(2, errata2.getPackages().size());
        
        //Remove the package and make sure db is updated
        Package removeme = (Package) errata2.getPackages().toArray()[0];
        errata2.removePackage(removeme);
        assertEquals(1, errata2.getPackages().size());
        
        flushAndEvict(errata2);
        Errata errata3 = ErrataManager.lookupErrata(id, user);
        assertEquals(1, errata3.getPackages().size());
    }

    /**
     * Test bean methods of Errata class
     */
    //published
    public void testBeanMethodsPublished() throws Exception {
        Errata err = ErrataFactoryTest.createTestPublishedErrata(
                                           UserTestUtils.createOrg("testOrg"));
        assertTrue(err instanceof PublishedErrata);
        assertTrue(err.isPublished());
        runBeanMethodsTest(err);
    }
    //unpublished
    public void testBeanMethodsUnpublished() throws Exception {
        Errata err = ErrataFactoryTest.createTestUnpublishedErrata(
                                           UserTestUtils.createOrg("testOrg"));
        assertTrue(err instanceof UnpublishedErrata);
        assertFalse(err.isPublished());
        runBeanMethodsTest(err);
    }
    private void runBeanMethodsTest(Errata err) throws Exception {
        Long one = new Long(3475);
        Long two = new Long(5438);
        String foo = "foo";
        String product = "Product Enhancement Advisory";
        String security = "Security Advisory";
        String bug = "Bug Fix Advisory";
        Date now = new Date();
        Org org1 = OrgFactory.lookupById(UserTestUtils.createOrg("TBM1"));
        OrgFactory.lookupById(UserTestUtils.createOrg("TBM2"));
        Channel c1 = ChannelFactoryTest.createTestChannel();
        
        err.setId(one);
        assertTrue(err.getId().equals(one));
        assertFalse(err.getId().equals(two));
        err.setId(null);
        assertNull(err.getId());
        
        err.setAdvisory(foo);
        assertTrue(err.getAdvisory().equals("foo"));
        err.setAdvisory(null);
        assertNull(err.getAdvisory());
        
        err.setAdvisoryName(foo);
        assertTrue(err.getAdvisoryName().equals("foo"));
        err.setAdvisoryName(null);
        assertNull(err.getAdvisoryName());
        
        err.setAdvisoryRel(one);
        assertTrue(err.getAdvisoryRel().equals(one));
        assertFalse(err.getAdvisoryRel().equals(two));
        err.setAdvisoryRel(null);
        assertNull(err.getAdvisoryRel());
        
        err.setAdvisoryType(foo);
        assertTrue(err.getAdvisoryType().equals("foo"));
        assertFalse(err.isBugFix());
        assertFalse(err.isProductEnhancement());
        assertFalse(err.isSecurityAdvisory());
        err.setAdvisoryType(bug);
        assertTrue(err.isBugFix());
        assertFalse(err.isProductEnhancement());
        err.setAdvisoryType(product);
        assertTrue(err.isProductEnhancement());
        assertFalse(err.isSecurityAdvisory());
        err.setAdvisoryType(security);
        assertTrue(err.isSecurityAdvisory());
        assertFalse(err.isBugFix());
        err.setAdvisoryType(null);
        assertNull(err.getAdvisoryType());
        assertFalse(err.isSecurityAdvisory());
        
        err.setDescription(foo);
        assertTrue(err.getDescription().equals("foo"));
        err.setDescription(null);
        assertNull(err.getDescription());
        
        err.setIssueDate(now);
        assertTrue(err.getIssueDate().equals(now));
        err.setIssueDate(null);
        assertNull(err.getIssueDate());
        
        err.setLastModified(now);
        assertTrue(err.getLastModified().equals(now));
        err.setLastModified(null);
        assertNull(err.getLastModified());
        
        err.setLocallyModified(Boolean.TRUE);
        assertTrue(err.getLocallyModified().booleanValue());
        err.setLocallyModified(Boolean.FALSE);
        assertFalse(err.getLocallyModified().booleanValue());
        
        err.setNotes(foo);
        assertTrue(err.getNotes().equals("foo"));
        err.setNotes(null);
        assertNull(err.getNotes());
        
        err.setOrg(org1);
        assertTrue(err.getOrg().equals(org1));
        err.setOrg(null);
        assertNull(err.getOrg());
        
        err.setProduct(foo);
        assertTrue(err.getProduct().equals("foo"));
        err.setProduct(null);
        assertNull(err.getProduct());
        
        err.setRefersTo(foo);
        assertTrue(err.getRefersTo().equals("foo"));
        err.setRefersTo(null);
        assertNull(err.getRefersTo());
        
        err.setSolution(foo);
        assertTrue(err.getSolution().equals("foo"));
        err.setSolution(null);
        assertNull(err.getSolution());
        
        err.setSynopsis(foo);
        assertTrue(err.getSynopsis().equals("foo"));
        err.setSynopsis(null);
        assertNull(err.getSynopsis());
        
        err.setTopic(foo);
        assertTrue(err.getTopic().equals("foo"));
        err.setTopic(null);
        assertNull(err.getTopic());
        
        err.setUpdateDate(now);
        assertTrue(err.getUpdateDate().equals(now));
        err.setUpdateDate(null);
        assertNull(err.getUpdateDate());
        
        if (err.isPublished()) {
            err.addChannel(c1);
            assertEquals(1, err.getChannels().size());
            err.setChannels(null);
            assertNull(err.getChannels());
        }
        else {
            try {
                err.addChannel(c1);
                fail();
            }
            catch (PublishedOnlyException poex) {
                //Success!!!
            }
        }
    }
}
