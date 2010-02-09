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
package com.redhat.rhn.manager.token.test;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelListProcessor;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenPackage;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.token.ActivationKeyManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.HashSet;
import java.util.Set;


/**
 * ActivationKeyManagerTest
 * @version $Rev$
 */
public class ActivationKeyManagerTest extends BaseTestCaseWithUser {
    private ActivationKeyManager manager;
    
    public void setUp() throws Exception {
        super.setUp();
        manager = ActivationKeyManager.getInstance();
    }
    public void testDelete() throws Exception {
        user.addRole(RoleFactory.ACTIVATION_KEY_ADMIN);
        ActivationKey key = manager.createNewActivationKey(user, "Test");
        ActivationKey temp = manager.lookupByKey(key.getKey(), user);
        assertNotNull(temp);
        manager.remove(temp, user);
        try {
            temp = manager.lookupByKey(key.getKey(), user);
            String msg = "NUll lookup failed, because this object should exist!";
            fail(msg);
        }
        catch (Exception e) {
         // great!.. Exception for null lookpu is controvoersial but convenient..
        }
    }
    public void testDeployConfig() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.ACTIVATION_KEY_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        
        //need a tools channel for config deploy
        Channel base = ChannelTestUtils.createBaseChannel(user);
        ChannelTestUtils.setupBaseChannelForVirtualization(user, base);
        
        ActivationKey key = createActivationKey();
        //Create a config channel
        ConfigChannel cc = ConfigTestUtils.createConfigChannel(user.getOrg());
        key.addEntitlement(ServerConstants.getServerGroupTypeProvisioningEntitled());
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        proc.add(key.getConfigChannelsFor(user), cc);
        key.setDeployConfigs(true);
        ActivationKeyFactory.save(key);
        assertTrue(key.getDeployConfigs());
        assertFalse(key.getChannels().isEmpty());
        assertFalse(key.getPackages().isEmpty());
    }
    public void testConfigPermissions() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.ACTIVATION_KEY_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        ActivationKey key = createActivationKey();
        
        //need a tools channel for config deploy
        Channel base = ChannelTestUtils.createBaseChannel(user);
        ChannelTestUtils.setupBaseChannelForVirtualization(user, base);
        
        
        try {
            key.setDeployConfigs(true);
            fail("Permission exception not raised");
        }
        catch (PermissionException pe) {
            //success
        }
        key.addEntitlement(ServerConstants.getServerGroupTypeProvisioningEntitled());
        key.setDeployConfigs(true);
        //Create a config channel
        ConfigChannel cc = ConfigTestUtils.createConfigChannel(user.getOrg());
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        proc.add(key.getConfigChannelsFor(user), cc);
        ActivationKeyFactory.save(key);
        assertTrue(key.getDeployConfigs());
        assertFalse(key.getChannels().isEmpty());
        assertFalse(key.getPackages().isEmpty());
        assertTrue(key.getConfigChannelsFor(user).contains(cc));
    }    
    
    public void testLookup() {
        //first lets just check on permissions...
        user.addRole(RoleFactory.ACTIVATION_KEY_ADMIN);
        final ActivationKey key = manager.createNewActivationKey(user, "Test");
        ActivationKey temp;
        //we make newuser
        // unfortunately satellite is NOT multiorg aware... 
        //So we can't check on the org clause 
        //so...
        User newUser = UserTestUtils.findNewUser("testUser2", "testOrg");
        try {
            manager.lookupByKey(key.getKey(), newUser);
            String msg = "Permission check failed :(.." +
                            "Activation key should not have gotten found out" +
                         " because the user does not have activation key admin role";
                         
            fail(msg);
        }
        catch (Exception e) {
            // great!.. Exception for permission failure always welcome
        }        
        try {
            temp = manager.lookupByKey(key.getKey() + "FOFOFOFOFOFOF", user);
            String msg = "NUll lookup failed, because this object should NOT exist!";
            fail(msg);
        }
        catch (Exception e) {
         // great!.. Exception for null lookpu is controvoersial but convenient..
        }
        temp = manager.lookupByKey(key.getKey(), user);
        assertNotNull(temp);
        assertEquals(user.getOrg(), temp.getOrg());
    }
    
    public void testCreatePermissions() throws Exception {
        ActivationKey key;
        //test permissions
        try {
            key = manager.createNewActivationKey(user,  "Test");
            String msg = "Permission check failed :(.." +
                            "Activation key should not have gotten created" +
                            " because the user does not have activation key admin role";
            fail(msg);
        }
        catch (Exception e) {
            // great!.. Exception for permission failure always welcome
        }

        //test permissions
        try {
            String keyName = "I_RULE_THE_WORLD";
            Long usageLimit = new Long(1200); 
            Channel baseChannel = ChannelTestUtils.createBaseChannel(user);
            String note = "Test";    
            key = manager.createNewActivationKey(user, 
                                                    keyName, note, usageLimit, 
                                                    baseChannel, true);

            String msg = "Permission check failed :(.." +
                            "Activation key should not have gotten created" +
                            " becasue the user does not have activation key admin role";
            fail(msg);
        }
        catch (Exception e) {
            // great!.. Exception for permission failure always welcome
        }
        
    }
    
    public void testCreate() throws Exception {
        user.addRole(RoleFactory.ACTIVATION_KEY_ADMIN);
        String note = "Test";
        final ActivationKey key = manager.createNewActivationKey(user, note);
        assertEquals(user.getOrg(), key.getOrg());
        assertEquals(note, key.getNote());
        assertNotNull(key.getKey());
        Server server = ServerFactoryTest.createTestServer(user, true);
                
        final ActivationKey key1 = manager.createNewReActivationKey(user, server, note);
        assertEquals(server, key1.getServer());
        
        ActivationKey temp = manager.lookupByKey(key.getKey(), user);
        assertNotNull(temp);
        assertEquals(user.getOrg(), temp.getOrg());
        assertEquals(note, temp.getNote());
        
        String keyName = "I_RULE_THE_WORLD";
        Long usageLimit = new Long(1200); 
        Channel baseChannel = ChannelTestUtils.createBaseChannel(user);
        
        final ActivationKey key2 = manager.createNewReActivationKey(user, server,
                                                keyName, note, usageLimit, 
                                                baseChannel, true, null);
        
        
        temp = (ActivationKey)reload(key2);
        assertTrue(temp.getKey().endsWith(keyName));
        assertEquals(note, temp.getNote());
        assertEquals(usageLimit, temp.getUsageLimit());
        Set channels = new HashSet();
        channels.add(baseChannel);
        assertEquals(channels, temp.getChannels());
        
        //since universal default == true we have to 
        // check if the user org has it..        
        Token token = user.getOrg().getToken();
        assertEquals(channels, token.getChannels());
        assertEquals(usageLimit, token.getUsageLimit());
    }
    
    public ActivationKey createActivationKey() throws Exception {
        user.addRole(RoleFactory.ACTIVATION_KEY_ADMIN);
        return  manager.createNewActivationKey(user, TestUtils.randomString());
    }
    
    public void testVirtEnt() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.ACTIVATION_KEY_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        UserTestUtils.addVirtualization(user.getOrg());
        Channel baseChannel = ChannelTestUtils.createBaseChannel(user);
        Channel [] channels = 
            ChannelTestUtils.setupBaseChannelForVirtualization(user, baseChannel);
        
        checkVirtEnt(ServerConstants.getServerGroupTypeVirtualizationEntitled(),
                        channels[ChannelTestUtils.VIRT_INDEX],
                        channels[ChannelTestUtils.TOOLS_INDEX]);
        checkVirtEnt(ServerConstants.getServerGroupTypeVirtualizationPlatformEntitled(),
                channels[ChannelTestUtils.VIRT_INDEX],
                channels[ChannelTestUtils.TOOLS_INDEX]);
    }
    
    private void checkVirtEnt(ServerGroupType sgt, 
                Channel virt, Channel tools) throws Exception {
        ActivationKey key = createActivationKey();
        key.addEntitlement(sgt);
        assertTrue(key.getChannels().contains(tools));
        assertTrue(key.getChannels().contains(virt));
        assertTrue(!key.getPackages().isEmpty());
        TokenPackage pkg = key.getPackages().iterator().next();
        assertEquals(ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME,
                                                    pkg.getPackageName().getName());
    }
}
