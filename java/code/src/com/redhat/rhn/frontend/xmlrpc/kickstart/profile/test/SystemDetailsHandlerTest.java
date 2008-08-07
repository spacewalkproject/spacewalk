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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.SELinuxMode;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.frontend.xmlrpc.kickstart.KickstartHandler;
import com.redhat.rhn.frontend.xmlrpc.kickstart.profile.SystemDetailsHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.kickstart.SystemDetailsCommand;
import com.redhat.rhn.testing.TestUtils;


/**
 * @author paji
 *
 */
public class SystemDetailsHandlerTest  extends BaseHandlerTestCase {
    
    private SystemDetailsHandler handler = new SystemDetailsHandler();
    
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
}
