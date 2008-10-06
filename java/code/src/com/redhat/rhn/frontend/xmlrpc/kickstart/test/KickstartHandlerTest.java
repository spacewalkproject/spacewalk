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
package com.redhat.rhn.frontend.xmlrpc.kickstart.test;

import java.util.List;
import java.util.ArrayList;
import java.util.Set;
import java.util.Map;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.test.ActivationKeyTest;
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidKickstartLabelException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidVirtualizationTypeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.KickstartHandler;
import com.redhat.rhn.frontend.xmlrpc.kickstart.NoSuchKickstartTreeException;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.manager.token.ActivationKeyManager;
import com.redhat.rhn.testing.TestUtils;


/**
 * KickstartHandlerTest
 * @version $Rev$
 */
public class KickstartHandlerTest extends BaseHandlerTestCase {
    
    private KickstartHandler handler = new KickstartHandler();
       
    
    public void testSetKickstartTree() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);    
              
        String profileLabel = "new-ks-profile";
        handler.createProfile(adminKey, profileLabel, "none", 
                testTree.getLabel(), "localhost", "rootpw");
        
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profileLabel, admin.getOrg().getId());
        assertNotNull(newKsProfile);
        assertTrue(newKsProfile.getCommand("url").getArguments().contains("http"));
               
        KickstartableTree anotherTestTree = KickstartableTreeTest.
        createTestKickstartableTree(baseChan);
        int result = handler.setKickstartTree(adminKey, profileLabel, 
                anotherTestTree.getLabel());
        
        assertEquals(1, result);
    }
    
    
    public void testSetChildChannels() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);    
              
        String profileLabel = "new-ks-profile";
        handler.createProfile(adminKey, profileLabel, "none", 
             testTree.getLabel(), "localhost", "rootpw");
        
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
             profileLabel, admin.getOrg().getId());
        assertNotNull(newKsProfile);
        assertTrue(newKsProfile.getCommand("url").getArguments().contains("http"));
        
        Channel c1 = ChannelFactoryTest.createTestChannel(admin);
        Channel c2 = ChannelFactoryTest.createTestChannel(admin);
        assertFalse(c1.getLabel().equals(c2.getLabel()));
        
        List<String> channelsToSubscribe = new ArrayList<String>();
        channelsToSubscribe.add(c1.getLabel());
        channelsToSubscribe.add(c2.getLabel());
        
        int result = handler.setChildChannels(adminKey, profileLabel, channelsToSubscribe);
        assertEquals(1, result);
    }
    
        
    public void testListKickstartableChannels() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin);
        Object [] ksChannels = handler.listKickstartableChannels(adminKey);
        assertTrue(ksChannels.length > 0);

        boolean found = false;
        for (int i = 0; i < ksChannels.length; i++) {
            Channel c = (Channel)ksChannels[i];
            if (c.getId().equals(baseChan.getId())) {
                found = true;
                break;
            }
        }
        assertTrue(found);
    }
    
    public void testListKickstartableTrees() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        Object [] ksTrees = handler.listKickstartableTrees(adminKey, 
                baseChan.getLabel());
        assertTrue(ksTrees.length > 0);
        
        boolean found = false;
        for (int i = 0; i < ksTrees.length; i++) {
            KickstartableTree t = (KickstartableTree)ksTrees[i];
            if (t.getId().equals(testTree.getId())) {
                found = true;
                break;
            }
        }
        assertTrue(found);
    }
    
    public void testListKickstartableTreesByNonExistentChannelLabel() throws Exception {
        try {
            handler.listKickstartableTrees(adminKey, 
                    "no such label");
            fail();
        }
        catch (Exception e) {
            // expected
        }
    }
    
    public void testFullImport() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        runImport(adminKey, testTree.getLabel());
    }
    
    public void testInvalidKickstartLabel() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        String kickstartFileContents = TestUtils.readAll(TestUtils.findTestData(
                "samplekickstart1.ks"));
                
        try {
            handler.importFile(adminKey, "a", "none", 
                    testTree.getLabel(), kickstartFileContents);
            fail();
        }
        catch (InvalidKickstartLabelException e) {
            // expected
        }
    }
    
    public void runImport(String sessionKey, String treeLabel) throws Exception {
        
        String newKsProfileLabel = "test-" + TestUtils.randomString();
        String kickstartFileContents = TestUtils.readAll(TestUtils.findTestData(
                "samplekickstart1.ks"));
        handler.importFile(sessionKey, newKsProfileLabel, "none", 
                treeLabel, kickstartFileContents);
        
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                newKsProfileLabel, admin.getOrg().getId());
        assertNotNull(newKsProfile);
    }
    
    public void testImportAsRegularUser() throws Exception {
        // Imports should require the same permissions as create, org or config admin.
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        try {
            runImport(regularKey, testTree.getLabel());
            fail();
        }
        catch (PermissionCheckFailureException e) {
            // expected
        }
    }
    
    public void testNoSuchKickstartTreeLabel() throws Exception {
        try {
            runImport(adminKey, "nosuchlabel");
            fail();
        }
        catch (NoSuchKickstartTreeException e) {
            // expected
        }
    }
    
    public void testCreate() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);

        String profileLabel = "new-ks-profile";
        handler.createProfile(adminKey, profileLabel, "none", 
                testTree.getLabel(), "localhost", "rootpw");
        
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profileLabel, admin.getOrg().getId());
        assertNotNull(newKsProfile);
        assertTrue(newKsProfile.getCommand("url").getArguments().contains("http"));
    }
    
    public void testCreateWithInvalidRoles() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);

        String profileLabel = "new-ks-profile";
        try {
            handler.createProfileWithCustomUrl(regularKey, profileLabel, "none", 
                    testTree.getLabel(), "default", "rootpw");
            fail();
        }
        catch (PermissionCheckFailureException e) {
            // expected
        }
    }
    
    public void testCreateWithInvalidKickstartLabel() throws Exception {
        String profileLabel = "new-ks-profile";
        try {
            handler.createProfileWithCustomUrl(adminKey, profileLabel, "none", 
                    "nosuchtree", "default", "rootpw");
            fail();
        }
        catch (NoSuchKickstartTreeException e) {
            // expected
        }
    }
    
    public void testCreateWithInvalidLabel() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);

        String profileLabel = "short";
        try {
            handler.createProfileWithCustomUrl(adminKey, profileLabel, "none", 
                    testTree.getLabel(), "default", "rootpw");
            fail();
        }
        catch (InvalidKickstartLabelException e) {
            // expected
        }
    }
    
    public void testCreateWithInvalidVirtType() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);

        String profileLabel = "test-ks-profile";
        try {
            handler.createProfileWithCustomUrl(adminKey, profileLabel, 
                    "fakevirttype", testTree.getLabel(), "default", "rootpw");
            fail();
        }
        catch (InvalidVirtualizationTypeException e) {
            // expected
        }
    }
    
    public void testListKickstarts() throws Exception {
        KickstartData ks  = KickstartDataTest.createKickstartWithProfile(admin);
        String label = ks.getLabel();
        KickstartFactory.saveKickstartData(ks);
        ks = (KickstartData) TestUtils.reload(ks);
       
        List<KickstartDto> list = handler.listKickstarts(adminKey);
        boolean foundKs = false;
        for (KickstartDto ksDto : list) {
            if (ksDto.getLabel().equals(label)) {
                foundKs = true;
            }
        }
        assertTrue(foundKs);
    }
    
    public void testListScript() throws Exception {
        KickstartData ks  = KickstartDataTest.createTestKickstartData(admin.getOrg());
        int id = handler.addScript(adminKey, ks.getLabel(), "This is a script", "", 
                "post", true);
        ks = (KickstartData) HibernateFactory.reload(ks);
        boolean found = false;
        
        
        for (KickstartScript script : handler.listScripts(adminKey, ks.getLabel())) {
            if (script.getId().intValue() == id && script.getDataContents().equals(
                    "This is a script")) {
                found = true;
            }
        }
        assertTrue(found);
        
    }  
    
    
    public void testAddScript() throws Exception {
        KickstartData ks  = KickstartDataTest.createTestKickstartData(admin.getOrg());
        int id = handler.addScript(adminKey, ks.getLabel(), "This is a script", "", 
                "post", true);
        ks = (KickstartData) HibernateFactory.reload(ks);
        boolean found = false;
        for (KickstartScript script : ks.getScripts()) {
            if (script.getId().intValue() == id && 
                    script.getDataContents().equals("This is a script")) {
                found = true;
            }
        }
        assertTrue(found);
        
    }
    
    public void testRemoveScript() throws Exception {
        KickstartData ks  = KickstartDataTest.createTestKickstartData(admin.getOrg());
        
        KickstartScript script = new KickstartScript();
        script.setKsdata(ks);
        script.setChroot("Y");
        script.setData(new String("blah").getBytes());
        script.setInterpreter("/bin/bash");
        script.setScriptType("post");
        script.setPosition(new Long(0));
        script = (KickstartScript) TestUtils.saveAndReload(script);
        
        assertEquals(1, handler.removeScript(adminKey, ks.getLabel(), 
                script.getId().intValue()));
        ks = (KickstartData) TestUtils.saveAndReload(ks);
       
        boolean found = false;
        for (KickstartScript scriptTmp : ks.getScripts()) {
            if (script.getId().equals(scriptTmp.getId())) {
                found = true;
            }
        }
        assertFalse(found);
    }
    
    public void testDownloadKickstart() throws Exception {
        KickstartData ks1  = KickstartDataTest.createKickstartWithProfile(admin);
        ks1.addPackageName(PackageFactory.lookupOrCreatePackageByName(
                "blahPackage"));
        
        ActivationKey key = ActivationKeyTest.createTestActivationKey(admin);
        ks1.addDefaultRegToken(key.getToken());
        ks1 = (KickstartData) TestUtils.saveAndReload(ks1);
        
        String file = handler.downloadKickstart(adminKey, ks1.getLabel(), "hostName");
        assertTrue(file.contains("rhnreg_ks --activationkey=\"" + key.getKey() + "\""));
        assertTrue(file.contains("blahPackage"));
        
    }
    
    private KickstartData setupIpRanges() throws Exception {
        KickstartData ks1  = KickstartDataTest.createKickstartWithProfile(admin);
        KickstartIpRange range = new KickstartIpRange();
        range.setMax(new IpAddress("192.168.0.10").getNumber());
        range.setMin(new IpAddress("192.168.0.1").getNumber());
        range.setKsdata(ks1);
        range.setOrg(admin.getOrg());
        ks1.getIps().add(range);   
        KickstartFactory.saveKickstartData(ks1);
        return ks1;
    }
    
    public void testListAllIpRanges() throws Exception {
        KickstartData ks1 = setupIpRanges();
        List list = handler.listAllIpRanges(adminKey);
        assertContains(list, ks1.getIps().iterator().next());
    }
    
    public void testListIpRanges() throws Exception {
        KickstartData ks1 = setupIpRanges();
        KickstartData ks2 = setupIpRanges();
        Set set = handler.listIpRanges(adminKey, ks1.getLabel());
        
        assertTrue(set.contains(ks1.getIps().iterator().next()));
        assertFalse(set.contains(ks2.getIps().iterator().next()));
        
    }
    
    public void testAddIpRange() throws Exception {
        KickstartData ks1 = setupIpRanges();
        handler.addIpRange(adminKey, ks1.getLabel(), "192.168.1.1", "192.168.1.10");
        ks1 = KickstartFactory.lookupKickstartDataByLabelAndOrgId(ks1.getLabel(), 
                admin.getOrg().getId());
        assertTrue(ks1.getIps().size() == 2);        
    }
    
    public void testAddIpRange1() throws Exception {
        KickstartData ks1 = setupIpRanges();
        boolean caught = false;
        try {
            handler.addIpRange(adminKey, ks1.getLabel(), "192.168.0.3", "192.168.1.10");
        }
        catch (Exception e) {
            caught = true;
        }
        assertTrue(caught);
        ks1 = KickstartFactory.lookupKickstartDataByLabelAndOrgId(ks1.getLabel(), 
                admin.getOrg().getId());
        assertTrue(ks1.getIps().size() == 1);        
    }
    
    
    public void testFindKickstartForIp() throws Exception {
        KickstartData ks1 = setupIpRanges();
        String label = handler.findKickstartForIp(adminKey, "192.168.0.5");
        assertEquals(label, ks1.getLabel());
        
        
    }
    
    public void testRemoveIpRange() throws Exception {
        KickstartData ks1 = setupIpRanges();
        handler.removeIpRange(adminKey, ks1.getLabel(), "192.168.0.1");
        ks1 = KickstartFactory.lookupKickstartDataByLabelAndOrgId(ks1.getLabel(), 
                admin.getOrg().getId());
        assertTrue(ks1.getIps().size() == 0);
        
    }
    
    public void testDeleteProfile() throws Exception {
        String label = "testLabelkdjfkjd";
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = 
            KickstartableTreeTest.createTestKickstartableTree(baseChan);    
        handler.createProfile(adminKey, label, "none", 
                testTree.getLabel(), "localhost", "redhat");
        Integer i = handler.deleteProfile(adminKey, label);
        assertEquals(new Integer(1), i);
    }
    
    public void testCompareActivationKeys() throws Exception {
        // Setup
        KickstartData ks1 = KickstartDataTest.createKickstartWithProfile(admin);
        KickstartData ks2 = KickstartDataTest.createKickstartWithProfile(admin);
        
        ActivationKeyManager manager = ActivationKeyManager.getInstance();
        ActivationKey activationKey1 = manager.createNewActivationKey(admin, "Test1");
        ActivationKey activationKey2 = manager.createNewActivationKey(admin, "Test2");
        ActivationKey activationKey3 = manager.createNewActivationKey(admin, "Test3");
        
        ks1.getDefaultRegTokens().add(activationKey1.getToken());
        ks1.getDefaultRegTokens().add(activationKey2.getToken());
        
        ks2.getDefaultRegTokens().add(activationKey1.getToken());
        ks2.getDefaultRegTokens().add(activationKey3.getToken());
        
        KickstartFactory.saveKickstartData(ks1);
        KickstartFactory.saveKickstartData(ks2);
        
        // Test
        Map<String, List<ActivationKey>> keysDiff =
            handler.compareActivationKeys(adminKey, ks1.getLabel(), ks2.getLabel());
        
        // Verify
        assertNotNull(keysDiff);

        List<ActivationKey> ks1KeyList = keysDiff.get(ks1.getLabel());
        assertNotNull(ks1KeyList);
        assertEquals(ks1KeyList.size(), 1);
        
        ActivationKey ks1DiffKey = ks1KeyList.iterator().next();
        assertEquals(ks1DiffKey.getToken(), activationKey2.getToken());
        
        List<ActivationKey> ks2KeyList = keysDiff.get(ks2.getLabel());
        assertNotNull(ks2KeyList);
        assertEquals(ks2KeyList.size(), 1);
        
        ActivationKey ks2DiffKey = ks2KeyList.iterator().next();
        assertEquals(ks2DiffKey.getToken(), activationKey3.getToken());
    }
    
    public void testCompareActivationKeysSameProfile() throws Exception {
        // Setup
        KickstartData ks1 = KickstartDataTest.createKickstartWithProfile(admin);
        
        ActivationKeyManager manager = ActivationKeyManager.getInstance();
        ActivationKey activationKey1 = manager.createNewActivationKey(admin, "Test1");
        
        ks1.getDefaultRegTokens().add(activationKey1.getToken());
        
        KickstartFactory.saveKickstartData(ks1);
        
        // Test
        Map<String, List<ActivationKey>> keysDiff =
            handler.compareActivationKeys(adminKey, ks1.getLabel(), ks1.getLabel());
        
        // Verify
        assertNotNull(keysDiff);

        List<ActivationKey> ks1KeyList = keysDiff.get(ks1.getLabel());
        assertNotNull(ks1KeyList);
        assertEquals(ks1KeyList.size(), 0);
    }
    
    public void testCompareActivationKeysNoKeys() throws Exception {
        // Setup
        KickstartData ks1 = KickstartDataTest.createKickstartWithProfile(admin);
        KickstartData ks2 = KickstartDataTest.createKickstartWithProfile(admin);
        
        KickstartFactory.saveKickstartData(ks1);
        KickstartFactory.saveKickstartData(ks2);
        
        // Test
        Map<String, List<ActivationKey>> keysDiff =
            handler.compareActivationKeys(adminKey, ks1.getLabel(), ks2.getLabel());
        
        // Verify
        assertNotNull(keysDiff);

        List<ActivationKey> ks1KeyList = keysDiff.get(ks1.getLabel());
        assertNotNull(ks1KeyList);
        assertEquals(ks1KeyList.size(), 0);
    }
    
    public void testComparePackages() throws Exception {
        // Setup
        
        //   Clear any packages on the profile so we have a known starting state
        KickstartData ks1 = KickstartDataTest.createKickstartWithProfile(admin);
        ks1.getPackageNames().clear();
        
        KickstartData ks2 = KickstartDataTest.createKickstartWithProfile(admin);
        ks2.getPackageNames().clear();
        
        Package package1 = PackageTest.createTestPackage(admin.getOrg());
        Package package2 = PackageTest.createTestPackage(admin.getOrg());
        Package package3 = PackageTest.createTestPackage(admin.getOrg());
        
        ks1.addPackageName(package1.getPackageName());
        ks1.addPackageName(package2.getPackageName());

        ks2.addPackageName(package1.getPackageName());
        ks2.addPackageName(package3.getPackageName());
        
        KickstartFactory.saveKickstartData(ks1);
        KickstartFactory.saveKickstartData(ks2);
        
        // Test
        Map<String, Set<String>> packagesDiff =
            handler.comparePackages(adminKey, ks1.getLabel(), ks2.getLabel());
        
        // Verify
        assertNotNull(packagesDiff);

        Set<String> ks1PackageNameList = packagesDiff.get(ks1.getLabel());
        assertNotNull(ks1PackageNameList);
        assertEquals(1, ks1PackageNameList.size());
        
        String ks1PackageName = ks1PackageNameList.iterator().next();
        assertEquals(package2.getPackageName().getName(), ks1PackageName);
        
        Set<String> ks2PackageNameList = packagesDiff.get(ks2.getLabel());
        assertNotNull(ks2PackageNameList);
        assertEquals(1, ks2PackageNameList.size());
        
        String ks2PackageName = ks2PackageNameList.iterator().next();
        assertEquals(package3.getPackageName().getName(), ks2PackageName);
    }
    
    public void testComparePackagesSameProfile() throws Exception {
        // Setup
        
        //   Clear any packages on the profile so we have a known starting state
        KickstartData ks1 = KickstartDataTest.createKickstartWithProfile(admin);
        ks1.getPackageNames().clear();
                
        Package package1 = PackageTest.createTestPackage(admin.getOrg());
        
        ks1.addPackageName(package1.getPackageName());

        KickstartFactory.saveKickstartData(ks1);
        
        // Test
        Map<String, Set<String>> packagesDiff =
            handler.comparePackages(adminKey, ks1.getLabel(), ks1.getLabel());
        
        // Verify
        assertNotNull(packagesDiff);

        Set<String> ks1PackageNameList = packagesDiff.get(ks1.getLabel());
        assertNotNull(ks1PackageNameList);
        assertEquals(0, ks1PackageNameList.size());
    }
    
    public void testComparePackagesNoPackages() throws Exception {
        // Setup
        
        //   Clear any packages on the profile so we have a known starting state
        KickstartData ks1 = KickstartDataTest.createKickstartWithProfile(admin);
        ks1.getPackageNames().clear();
        
        KickstartData ks2 = KickstartDataTest.createKickstartWithProfile(admin);
        ks2.getPackageNames().clear();
        
        KickstartFactory.saveKickstartData(ks1);
        KickstartFactory.saveKickstartData(ks2);
        
        // Test
        Map<String, Set<String>> packagesDiff =
            handler.comparePackages(adminKey, ks1.getLabel(), ks2.getLabel());
        
        // Verify
        assertNotNull(packagesDiff);

        Set<String> ks1PackageNameList = packagesDiff.get(ks1.getLabel());
        assertNotNull(ks1PackageNameList);
        assertEquals(0, ks1PackageNameList.size());
        
        Set<String> ks2PackageNameList = packagesDiff.get(ks2.getLabel());
        assertNotNull(ks2PackageNameList);
        assertEquals(0, ks2PackageNameList.size());
    }
}
