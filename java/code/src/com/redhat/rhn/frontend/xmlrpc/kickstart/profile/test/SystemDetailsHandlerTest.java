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

package com.redhat.rhn.frontend.xmlrpc.kickstart.profile.test;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.SELinuxMode;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.kickstart.crypto.test.CryptoTest;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.frontend.xmlrpc.InvalidLocaleCodeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidKickstartLabelException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.KickstartHandler;
import com.redhat.rhn.frontend.xmlrpc.kickstart.profile.SystemDetailsHandler;
import com.redhat.rhn.frontend.xmlrpc.kickstart.profile.ProfileHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.kickstart.SystemDetailsCommand;
import com.redhat.rhn.manager.kickstart.KickstartCryptoKeyCommand;
import com.redhat.rhn.testing.TestUtils;


/**
 * @author paji
 *
 */
public class SystemDetailsHandlerTest  extends BaseHandlerTestCase {
    
    private SystemDetailsHandler handler = new SystemDetailsHandler();
    private ProfileHandler profileHandler = new ProfileHandler();
        
    public void testSetAdvancedOptions() throws Exception {
        KickstartData profile = createProfile();
        
        List l = new ArrayList(); 
        Map m = new HashMap();
        m.put("id", 30);
        m.put("arguments", "--url /rhn/kickstart/ks-rhel-i386-kkk");
        l.add(m);
        Map m1 = new HashMap();
        m1.put("id", 63);
        m1.put("arguments", "xxxxx");
        l.add(m1);
        
        profileHandler.setAdvancedOptions(adminKey, profile.getLabel(), l);
        System.out.println(profile.getOptions());
               
        Object[] s = profileHandler.getAdvancedOptions(adminKey, profile.getLabel());
        assertEquals( profile.getOptions().toArray(), s);
    }
    
    
    
    public void testSELinux() throws Exception {
        KickstartData profile = createProfile();
        handler.setSELinux(adminKey, profile.getLabel(), SELinuxMode.DISABLED.getValue());
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profile.getLabel(), admin.getOrg().getId());
        assertEquals(SELinuxMode.DISABLED, newKsProfile.getSELinuxMode());
        try {
            handler.setSELinux(adminKey, profile.getLabel(), "HOHOHOH!!!");
            fail("No exception thrown on invlaid input for SE linux mode..");
        }
        catch (Exception e) {
            //successful this Correctly fail since there is no se linux mode called HOHOHOH
        }
    }
    
    public void testConfigMgmt() throws Exception {
        KickstartData profile = createProfile();
        handler.enableConfigManagement(adminKey, profile.getLabel());
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profile.getLabel(), admin.getOrg().getId());
        assertEquals(true, newKsProfile.isConfigManageable());
        handler.disableConfigManagement(adminKey, profile.getLabel());
        newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profile.getLabel(), admin.getOrg().getId());  
        assertEquals(false, newKsProfile.isConfigManageable());
    }
    
    public void testRemoteCommands() throws Exception {
        KickstartData profile = createProfile();
        handler.enableRemoteCommands(adminKey, profile.getLabel());
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profile.getLabel(), admin.getOrg().getId());
        assertEquals(true, newKsProfile.isRemoteCommandable());
        handler.disableRemoteCommands(adminKey, profile.getLabel());
        newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profile.getLabel(), admin.getOrg().getId());  
        assertEquals(false, newKsProfile.isRemoteCommandable());
    }    
    
    public void testNetworkConnection() throws Exception {
        KickstartData profile = createProfile();
        String interfaceName = "eth0";
        handler.setNetworkConnection(adminKey, profile.getLabel(), true, interfaceName);
        profile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profile.getLabel(), admin.getOrg().getId());
        assertEquals(SystemDetailsCommand.DHCP_NETWORK_TYPE + ":" + interfaceName,
                                                            profile.getStaticDevice());
        handler.setNetworkConnection(adminKey, profile.getLabel(), false, interfaceName);
        assertEquals(SystemDetailsCommand.STATIC_NETWORK_TYPE + ":" + interfaceName,
                                                    profile.getStaticDevice());        
    }
    
    public void testGetLocale() throws Exception {
        
        KickstartData newProfile = createProfile();

        try {
            handler.getLocale(adminKey, "InvalidProfile");
            fail("SystemDetailsHandler.getLocale allowed execution with invalid " +
                    "profile label");
        }
        catch (InvalidKickstartLabelException e) {
            //success
        }
       
        handler.setLocale(adminKey, newProfile.getLabel(), "America/Guayaquil", 
                Boolean.TRUE);

        Map locale = handler.getLocale(adminKey, newProfile.getLabel());
        
        assertEquals(locale.size(), 2);
        assertEquals(locale.get("locale"), "America/Guayaquil");
        assertEquals(locale.get("useUtc"), Boolean.TRUE);
    }

    public void testSetLocale() throws Exception {
        
        KickstartData newProfile = createProfile();

        try {
            handler.setLocale(adminKey, "InvalidProfile", "Pacific/Galapagos", 
                    Boolean.TRUE);
            fail("SystemDetailsHandler.setLocale allowed execution with invalid " +
                    "profile label");
        }
        catch (InvalidKickstartLabelException e) {
            //success
        }
        
        try {
            handler.setLocale(adminKey, newProfile.getLabel(), "InvalidLocale", 
                    Boolean.TRUE);
            fail("SystemDetailsHandler.setLocale allowed setting invalid locale.");
        }
        catch (InvalidLocaleCodeException e) {
            //success
        }
        
        handler.setLocale(adminKey, newProfile.getLabel(), "America/Guayaquil", 
                Boolean.TRUE);
        
        KickstartData profile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                newProfile.getLabel(), admin.getOrg().getId());
        
        assertEquals(profile.getTimezone(), "America/Guayaquil");
        
        assertTrue(profile.isUsingUtc());
    }

    private KickstartData createProfile() throws Exception {
        KickstartHandler kh = new KickstartHandler();
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin); 
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);

        String profileLabel = "new-ks-profile" + TestUtils.randomString();
        kh.createProfile(adminKey, profileLabel, "none", 
                testTree.getLabel(), "localhost", "rootpw");
        
        KickstartData newKsProfile = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                profileLabel, admin.getOrg().getId());
        assertNotNull(newKsProfile);
        assertTrue(newKsProfile.getCommand("url").getArguments().contains("http")); 
        return newKsProfile;
    }
    
    public void testListAssociatedKeys() throws Exception {
        // Setup
        
        //   Create key to associate
        CryptoKey key = CryptoTest.createTestKey(regular.getOrg());
        KickstartFactory.saveCryptoKey(key);
        assertNotNull(KickstartFactory.lookupCryptoKeyById(key.getId(), key.getOrg()));
        flushAndEvict(key);
        
        //   Create profile to associate the key with
        KickstartData profile = createProfile();
        
        //   Associate the key with the profile
        KickstartCryptoKeyCommand command =
            new KickstartCryptoKeyCommand(profile.getId(), regular);
        List keyList = new ArrayList();
        keyList.add(key.getDescription());
        command.addKeysByDescriptionAndOrg(keyList, regular.getOrg());
        command.store();
        
        // Test
        Set associatedKeys = handler.listAssociatedKeys(regularKey, profile.getLabel());
        
        // Verify
        assertNotNull(associatedKeys);
        assertEquals(associatedKeys.size(), 1);
        
        CryptoKey foundKey = (CryptoKey)associatedKeys.iterator().next();
        assertEquals(key.getDescription(), foundKey.getDescription());
    }
    
    public void testListAssociatedKeysNoKeys() throws Exception {
        // Setup
        KickstartData profile = createProfile();
        
        // Test
        Set associatedKeys = handler.listAssociatedKeys(regularKey, profile.getLabel());

        // Verify
        assertNotNull(associatedKeys);
        assertEquals(associatedKeys.size(), 0);
    }
    
    public void testAssociateKeys() throws Exception {
        // Setup

        //   Create key to associate
        CryptoKey key = CryptoTest.createTestKey(regular.getOrg());
        KickstartFactory.saveCryptoKey(key);
        assertNotNull(KickstartFactory.lookupCryptoKeyById(key.getId(), key.getOrg()));
        flushAndEvict(key);
        
        //   Create profile to associate the key with
        KickstartData profile = createProfile();

        // Test
        List descriptions = new ArrayList();
        descriptions.add(key.getDescription());
        int result = handler.associateKeys(regularKey, profile.getLabel(), descriptions);
        
        // Verify
        assertEquals(result, 1);
        
        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(profile.getLabel(), 
                regular.getOrg().getId());

        Set foundKeys = data.getCryptoKeys();
        
        assertNotNull(foundKeys);
        assertEquals(foundKeys.size(), 1);
        
        CryptoKey foundKey = (CryptoKey)foundKeys.iterator().next();
        assertEquals(key.getDescription(), foundKey.getDescription());
    }
}
