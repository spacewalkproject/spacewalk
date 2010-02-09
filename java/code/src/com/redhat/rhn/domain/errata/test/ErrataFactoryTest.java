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

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.ClonedErrata;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.ErrataFile;
import com.redhat.rhn.domain.errata.impl.PublishedErrata;
import com.redhat.rhn.domain.errata.impl.PublishedErrataFile;
import com.redhat.rhn.domain.errata.impl.UnpublishedErrata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ErrataFactoryTest
 * @version $Rev$
 */
public class ErrataFactoryTest extends BaseTestCaseWithUser {
    
    public void testPublish() throws Exception {
        Errata e = ErrataFactoryTest.createTestUnpublishedErrata(user.getOrg().getId());
        //add bugs, keywords, and packages so we have something to work with...
        e.addBug(ErrataManager.createNewUnpublishedBug(new Long(42), "test bug 1"));
        e.addBug(ErrataManager.createNewUnpublishedBug(new Long(43), "test bug 2"));
        e.addPackage(PackageTest.createTestPackage());
        e.addKeyword("foo");
        e.addKeyword("bar");
        ErrataManager.storeErrata(e); //save changes

        //make sure e is not published
        assertFalse(e.isPublished());

        //store some attributes for later comparison
        Long id = e.getId();
        String advisory = e.getAdvisory();
        int bugSize = e.getBugs().size();
        int keySize = e.getKeywords().size();
        int pkgSize = e.getPackages().size();

        //publish the errata back into Errata object e
        e = ErrataFactory.publish(e);

        //make sure e is now published
        assertTrue(e.isPublished());
        
        //make sure attrs were copied ok
        assertFalse(id.equals(e.getId())); //e should now have a different id
        assertEquals(advisory, e.getAdvisory());
        assertEquals(bugSize, e.getBugs().size());
        assertEquals(keySize, e.getKeywords().size());
        assertEquals(pkgSize, e.getPackages().size());
        
        //try looking up an errata with the old id... shouldn't exist
        HibernateFactory.getSession().flush();
        
        
        try { 
            ErrataManager.lookupErrata(id, user);
            fail("Should not be able to find errata " + id);
        }
        catch (LookupException ex) {
            // Expected
        }
    }
    
    
    public void testPublishToChannel()  throws Exception {
        Errata e = ErrataFactoryTest.createTestUnpublishedErrata(user.getOrg().getId());
        //add bugs, keywords, and packages so we have something to work with...
        e.addBug(ErrataManager.createNewUnpublishedBug(new Long(42), "test bug 1"));
        e.addBug(ErrataManager.createNewUnpublishedBug(new Long(43), "test bug 2"));
        e.addPackage(PackageTest.createTestPackage());
        e.addKeyword("foo");
        e.addKeyword("bar");
        ErrataManager.storeErrata(e); //save changes
        
        
        
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        channel.setOrg(user.getOrg());
        
        Package errataPack = PackageTest.createTestPackage(user.getOrg());
        Package chanPack = PackageTest.createTestPackage(user.getOrg());
        //we have to set the 2nd package to a different EVR to not violate a 
        //      unique constraint
        PackageEvr evr =  PackageEvrFactory.createPackageEvr("45", "99", "983");
        chanPack.setPackageName(errataPack.getPackageName());
        chanPack.setPackageEvr(evr);
        
        channel.addPackage(chanPack);
        e.addPackage(errataPack);
        
        Errata published = ErrataFactory.publishToChannel(e, channel, user);
        assertTrue(channel.getPackages().contains(errataPack));
        List<PublishedErrataFile> errataFile = 
            ErrataFactory.lookupErrataFilesByErrataAndFileType(published.getId(), "RPM");
        assertTrue(errataFile.get(0).getPackages().contains(errataPack));
        
    }
    
    
    public void testCreateAndLookupErrata() throws Exception {
        //published
        Errata published = createTestPublishedErrata(user.getOrg().getId());
        assertTrue(published instanceof PublishedErrata);
        assertNotNull(published.getId());
        Long pubid = published.getId();
        String pubname = published.getAdvisoryName();
        //unpublished
        Errata unpublished = createTestUnpublishedErrata(user.getOrg().getId());
        assertTrue(unpublished instanceof UnpublishedErrata);
        assertNotNull(unpublished.getId());
        Long unpubid = unpublished.getId();
        String unpubname = unpublished.getAdvisoryName();
        
        //Lookup the published errata
        Errata errata = ErrataFactory.lookupById(pubid);
        assertTrue(errata instanceof PublishedErrata);
        assertEquals(pubid, errata.getId());
        errata = ErrataFactory.lookupByAdvisory(pubname);
        assertTrue(errata instanceof PublishedErrata);
        assertEquals(pubname, errata.getAdvisoryName());
        
        //Lookup the unpublished errata
        errata = ErrataFactory.lookupById(unpubid);
        assertTrue(errata instanceof UnpublishedErrata);
        assertEquals(unpubid, errata.getId());
        errata = ErrataFactory.lookupByAdvisory(unpubname);
        assertTrue(errata instanceof UnpublishedErrata);
        assertEquals(unpubid, errata.getId());
    }

    public void testLastModified() throws Exception {
        Errata published = createTestPublishedErrata(user.getOrg().getId());
        published = (Errata) reload(published);
        assertNotNull(published.getLastModified());
    }
    
    public void testBugs() throws Exception {
        //test unpublished
        Errata e = createTestUnpublishedErrata(user.getOrg().getId());
        assertTrue(e.getBugs() == null || e.getBugs().size() == 0);
        e.addBug(ErrataFactory.createUnpublishedBug(new Long(123), "test bug"));
        assertEquals(1, e.getBugs().size());
        
        //test published
        e = createTestPublishedErrata(user.getOrg().getId());
        assertTrue(e.getBugs() == null || e.getBugs().size() == 0);
        e.addBug(ErrataFactory.createPublishedBug(new Long(123), "test bug"));
        assertEquals(1, e.getBugs().size());
    }
    
    public void testFiles() throws Exception {
        //test unpublished
        Errata e = createTestUnpublishedErrata(user.getOrg().getId());
        Set errataFilePackages = new HashSet();
        errataFilePackages.add(PackageTest.createTestPackage());
        ErrataFile ef = ErrataFactory.createUnpublishedErrataFile(ErrataFactory.
                                                              lookupErrataFileType("RPM"),
                                                                  "SOME FAKE CHECKSUM",
                                                                  "test erratafile " + 
                                                                  TestUtils.randomString(),
                                                                  errataFilePackages);
        
        assertEquals(1, e.getFiles().size());
        assertNull(ef.getId());
        
        e.addFile(ef);
        TestUtils.saveAndFlush(e);
        
        assertNotNull(ef.getId());
        assertEquals(2, e.getFiles().size());
        assertNotNull(ef.getPackages());
        assertEquals(1, ef.getPackages().size());
        
        //test published
        e = createTestPublishedErrata(user.getOrg().getId());
        ef = ErrataFactory.createPublishedErrataFile(ErrataFactory.
                                                     lookupErrataFileType("RPM"),
                                                     "SOME FAKE CHECKSUM",
                                                     "test erratafile " + 
                                                     TestUtils.randomString(),
                                                     errataFilePackages);
        assertEquals(1, e.getFiles().size());
        assertNull(ef.getId());
        assertNotNull(ef.getPackages());
        assertEquals(1, ef.getPackages().size());
        
        e.addFile(ef);
        TestUtils.saveAndFlush(e);
        
        assertNotNull(ef.getId());
        assertEquals(2, e.getFiles().size());
    }
    /**
     * Create an Errata for testing and commit it to the DB.
     * @param orgId the Org who owns this Errata
     * @return Errata created
     * @throws Exception 
     */
    public static Errata createTestErrata(Long orgId) throws Exception {
        Errata e = ErrataFactory.createPublishedErrata();
        fillOutErrata(e, orgId);
        ErrataFactory.save(e);
        return e;
    }

    /**
     * Creates and persists an errata that will be flagged as critical.
     * 
     * @param orgId the org under which the errata exists
     * @return created errata
     * @throws Exception if the errata cannot be created
     */
    public static Errata createCriticalTestErrata(Long orgId) throws Exception {
        Errata e = ErrataFactory.createPublishedErrata();
        fillOutErrata(e, orgId);
        e.setAdvisoryType(ErrataFactory.ERRATA_TYPE_SECURITY);
        ErrataFactory.save(e);
        return e;
    }
    
    public static Errata createTestPublishedErrata(Long orgId) throws Exception {
        //just pass to createTestErrata since published is the default
        return createTestErrata(orgId);
    }
      
    public static Errata createTestUnpublishedErrata(Long orgId) throws Exception {
        Errata e = ErrataFactory.createUnpublishedErrata();
        fillOutErrata(e, orgId);
        ErrataFactory.save(e);
        return e;
    }
    
    private static void fillOutErrata(Errata e, Long orgId) throws Exception {
        String name = "JAVA Test " + TestUtils.randomString();
        if (orgId != null) {
            e.setOrg(OrgFactory.lookupById(orgId));
        }
        e.setAdvisory(name);
        e.setAdvisoryType(ErrataFactory.ERRATA_TYPE_BUG);
        e.setProduct("Red Hat Linux");
        e.setDescription("Test desc ..");
        e.setSynopsis("Test synopsis");
        e.setSolution("Test solution");
        e.setNotes("Test notes for test errata");
        e.setTopic("test topic");
        e.setRefersTo("rhn unit tests");
        e.setUpdateDate(new Date());
        e.setIssueDate(new Date());
        e.setAdvisoryName(name);
        e.setAdvisoryRel(new Long(2));
        e.setLocallyModified(Boolean.FALSE);
        Package testPackage = PackageTest.createTestPackage();
        
        ErrataFile ef;
        Set errataFilePackages = new HashSet();
        errataFilePackages.add(testPackage);
        e.addPackage(testPackage);
        if (e.isPublished()) {
            ef = ErrataFactory.createPublishedErrataFile(ErrataFactory.
                    lookupErrataFileType("RPM"),
                        "SOME FAKE CHECKSUM",
                        "test errata file" + TestUtils.randomString(), errataFilePackages);
        }
        else {
            ef = ErrataFactory.createUnpublishedErrataFile(ErrataFactory.
                    lookupErrataFileType("RPM"),
                        "SOME FAKE CHECKSUM",
                        "test errata file", errataFilePackages);
        }

        e.addFile(ef);
        
    }
    
    public void testCreateClone() throws Exception {
       
       Errata published = createTestPublishedErrata(user.getOrg().getId());
       Channel baseChannel = ChannelTestUtils.createBaseChannel(user);
       published.addChannel(baseChannel);
       Errata clone = ErrataFactory.createClone(user.getOrg(), published);
       String clonedAdvisoryName = "CL" + published.getAdvisoryName().substring(3);
       String clonedAdvisory = "CL" + published.getAdvisory().substring(3);
        
       assertNotNull(clone.getId());
       assertFalse(published.isCloned());
       assertTrue(clone.isCloned());
       assertEquals(published.getProduct(), clone.getProduct());
       assertEquals(published.getDescription(), clone.getDescription());
       assertEquals(published.getSynopsis(), clone.getSynopsis());
       assertEquals(published.getSolution(), clone.getSolution());
       assertEquals(published.getNotes(), clone.getNotes());
       assertEquals(published.getTopic(), clone.getTopic());
       assertEquals(published.getRefersTo(), clone.getRefersTo());
       assertEquals(published.getUpdateDate(), clone.getUpdateDate());
       assertEquals(published.getIssueDate(), clone.getIssueDate());
       assertEquals(published.getAdvisoryType(), clone.getAdvisoryType());
       assertEquals(published.getAdvisoryRel(), clone.getAdvisoryRel());
       assertEquals(published.getLocallyModified(), clone.getLocallyModified());
       assertEquals(clonedAdvisoryName, clone.getAdvisoryName());
       assertEquals(clonedAdvisory, clone.getAdvisory());

       /* Create a 2nd clone and make sure that the cloning function
        * does not create a clone whose name collides with the already
        * existing clone
        */
       clone = ErrataFactory.createClone(user.getOrg(), published);
       
       assertEquals(clone.getAdvisoryName(), clonedAdvisoryName + "-1");
       assertEquals(clone.getAdvisory(), clonedAdvisory + "-1");
       
    }
    
    public static void updateNeedsErrataCache(Long packageId, Long serverId, 
            Long errataId) {
        WriteMode m = 
            ModeFactory.
                getWriteMode("test_queries", "insert_into_rhnServerNeededPackageCache");
        Map params = new HashMap();
        params.put("package_id", packageId);
        params.put("server_id", serverId);
        params.put("errata_id", errataId);
        m.executeUpdate(params);
    }
    
    public static void testLookupByOriginal() throws Exception {
        
        Long orgId = UserTestUtils.createOrg("testOrg");
        Org org = OrgFactory.lookupById(orgId);
        Errata published = createTestPublishedErrata(orgId);
        ClonedErrata clone = (ClonedErrata) ErrataFactory.createClone(org, published);
        
        List list = ErrataFactory.lookupByOriginal(org, published);
        
        assertEquals(1, list.size());
        clone = (ClonedErrata) list.get(0);
        assertTrue(clone.getOriginal().equals(published));
    }
    
    public void listErrataChannelPackages() {
        try {
            Channel chan = ChannelTestUtils.createBaseChannel(user);
            Errata e = ErrataFactoryTest.createTestErrata(user.getId());
            Package p = PackageTest.createTestPackage();
            chan.getErratas().add(e);
            chan.getPackages().add(p);
            e.getPackages().add(p);
            ChannelFactory.save(chan);
            
            chan = (Channel) TestUtils.saveAndReload(chan);
            e = (Errata) TestUtils.saveAndReload(e);
            p = (Package) TestUtils.saveAndReload(p);
            
            
            List<Long> list = ErrataFactory.listErrataChannelPackages(chan.getId(), 
                    e.getId());
            assertContains(list, p.getId());            
            
        }
        catch (Exception e) {
            assertTrue(false);
        }        
    }
    
}

