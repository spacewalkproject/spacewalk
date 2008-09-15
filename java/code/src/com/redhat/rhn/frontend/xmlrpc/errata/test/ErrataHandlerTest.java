/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.impl.PublishedBug;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.errata.ErrataHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;
 
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
        }
        catch (FaultException e) {
            //success
        }
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
        errataInfo.put("synopsis", TestUtils.randomString());
        errataInfo.put("advisory_name", advisoryName);
        errataInfo.put("advisory_release", new Integer(2));
        errataInfo.put("advisory_type", "Bug Fix Advisory");
        errataInfo.put("product", TestUtils.randomString());
        errataInfo.put("topic", TestUtils.randomString());
        errataInfo.put("description", TestUtils.randomString());
        errataInfo.put("solution", TestUtils.randomString());
        errataInfo.put("references", TestUtils.randomString());
        errataInfo.put("notes", TestUtils.randomString());
                
        ArrayList packages = new ArrayList();
        ArrayList bugs = new ArrayList();
        ArrayList keywords = new ArrayList();
        ArrayList channels = new ArrayList();
        channels.add(channel.getLabel());
        
        Errata errata = handler.create(adminKey, errataInfo, 
                bugs, keywords, packages, true, channels);
        
        assertEquals(errata, ErrataFactory.lookupByAdvisory(advisoryName));
        
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
