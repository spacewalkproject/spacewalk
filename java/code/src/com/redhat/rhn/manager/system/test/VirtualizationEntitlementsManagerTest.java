/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.manager.system.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.channel.test.ChannelFamilyFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.test.HostBuilder;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.ChannelFamilySystemGroup;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.org.UpdateOrgSoftwareEntitlementsCommand;
import com.redhat.rhn.manager.org.UpdateOrgSystemEntitlementsCommand;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.VirtualizationEntitlementsManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.RandomStringUtils;

import java.util.List;


/**
 * VirtualizationEntitlementsManagerTest
 * @version $Rev$
 */
public class VirtualizationEntitlementsManagerTest extends RhnBaseTestCase {

    public void testListFlexGuests() throws Exception {
        Org org = UserTestUtils.createNewOrgFull(RandomStringUtils.randomAlphabetic(10));
        User user = UserTestUtils.createUser(RandomStringUtils.randomAlphabetic(10),
                org.getId());
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        long ents = 3;
        int guestsToCreate = 6;
        long flexEnts = guestsToCreate;
        long sysEnts = guestsToCreate + 1; // 1 for host
        //Give it some system entitlements
        UpdateOrgSystemEntitlementsCommand cmd1 = new UpdateOrgSystemEntitlementsCommand(
                EntitlementManager.MANAGEMENT, org, sysEnts);
        assertNull(cmd1.store());
        
        ChannelFamily rhelFamily = ChannelFamilyFactoryTest.createTestChannelFamily(
                UserFactory.findRandomOrgAdmin(OrgFactory.getSatelliteOrg()),
                            ents, flexEnts);
        assertEquals(Long.valueOf(flexEnts),
                    rhelFamily.getMaxFlex(OrgFactory.getSatelliteOrg()));
        UpdateOrgSoftwareEntitlementsCommand cmd2 = new 
                            UpdateOrgSoftwareEntitlementsCommand(rhelFamily.getLabel(), 
                                            org, ents, flexEnts);
        assertNull(cmd2.store());
         Channel rhelChannel =  ChannelFactoryTest.createBaseChannel(user, rhelFamily);
         
         
         HibernateFactory.getSession().clear();
         rhelChannel =  ChannelFactory.lookupById(rhelChannel.getId());
         assertNotNull(rhelChannel.getId());
         assertNotNull(rhelChannel);
         
         rhelFamily = ChannelFamilyFactory.lookupById(rhelFamily.getId());
         assertNotNull(rhelFamily);
         assertNotNull(rhelFamily.getMaxFlex(org));
         assertEquals(Long.valueOf(flexEnts), rhelFamily.getMaxFlex(org));
         
         HostBuilder builder = new HostBuilder(org.getActiveOrgAdmins().get(0));
         builder.createNonVirtHost().withGuests(guestsToCreate);
         Server host = builder.build();
         ServerFactory.save(host);
         
         SystemManager.subscribeServerToChannel(user, host, rhelChannel);         
         
         ServerFactory.save(host);

         for (VirtualInstance inst : host.getGuests()) {
             SystemManager.subscribeServerToChannel(user,
                     inst.getGuestSystem(), rhelChannel);
             SystemManager.entitleServer(inst.getGuestSystem(),
                     EntitlementManager.MANAGEMENT);
             ServerFactory.save(inst.getGuestSystem());
         }

         HibernateFactory.getSession().clear();
         
         
         //Verify everything is as it should be
         EntitlementServerGroup mgmnt =
             ServerGroupManager.getInstance().lookupEntitled(
                 EntitlementManager.MANAGEMENT, user);
         assertEquals(Long.valueOf(sysEnts), mgmnt.getCurrentMembers());
         
         rhelFamily = ChannelFamilyFactory.lookupById(rhelFamily.getId());
         assertEquals(Long.valueOf(1), rhelFamily.getCurrentMembers(org));
         assertEquals(Long.valueOf(guestsToCreate), rhelFamily.getCurrentFlex(org));
         
         List<ChannelFamilySystemGroup> l = VirtualizationEntitlementsManager.getInstance().
                                                             listFlexGuests(user);
         assertTrue(!l.isEmpty());
         assertEquals(1, l.size());
         assertEquals(guestsToCreate, l.get(0).expand().size());
    }
    
    public void testListEligibleFlexGuests() throws Exception {
        Org org = UserTestUtils.createNewOrgFull(RandomStringUtils.randomAlphabetic(10));
        User user = UserTestUtils.createUser(RandomStringUtils.randomAlphabetic(10),
                org.getId());
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        int guestsToCreate = 6;
        long flexEnts = guestsToCreate;
        long ents = guestsToCreate + 1; //+ 1 for host
        long sysEnts = guestsToCreate + 1; //+ 1 for host
        //Give it some system entitlements
        UpdateOrgSystemEntitlementsCommand cmd1 = new UpdateOrgSystemEntitlementsCommand(
                EntitlementManager.MANAGEMENT, org, sysEnts);
        assertNull(cmd1.store());
        
        ChannelFamily rhelFamily = ChannelFamilyFactoryTest.createTestChannelFamily(
                UserFactory.findRandomOrgAdmin(OrgFactory.getSatelliteOrg()),
                            ents, flexEnts);
        assertEquals(Long.valueOf(flexEnts),
                    rhelFamily.getMaxFlex(OrgFactory.getSatelliteOrg()));
        
        //No flex initially
        UpdateOrgSoftwareEntitlementsCommand cmd2 = new 
                            UpdateOrgSoftwareEntitlementsCommand(rhelFamily.getLabel(), 
                                            org, ents, 0L);
        assertNull(cmd2.store());
         Channel rhelChannel =  ChannelFactoryTest.createBaseChannel(user, rhelFamily);
         
         
         HibernateFactory.getSession().clear();
         rhelChannel =  ChannelFactory.lookupById(rhelChannel.getId());
         assertNotNull(rhelChannel.getId());
         assertNotNull(rhelChannel);
         
         rhelFamily = ChannelFamilyFactory.lookupById(rhelFamily.getId());
         assertNotNull(rhelFamily);
         assertNotNull(rhelFamily.getMaxFlex(org));
         assertEquals(Long.valueOf(0), rhelFamily.getMaxFlex(org));
         
         HostBuilder builder = new HostBuilder(org.getActiveOrgAdmins().get(0));
         builder.createNonVirtHost().withGuests(guestsToCreate);
         Server host = builder.build();
         ServerFactory.save(host);
         
         SystemManager.subscribeServerToChannel(user, host, rhelChannel);         
         
         ServerFactory.save(host);
         for (VirtualInstance inst : host.getGuests()) {
             SystemManager.subscribeServerToChannel(user,
                     inst.getGuestSystem(), rhelChannel);
             SystemManager.entitleServer(inst.getGuestSystem(),
                     EntitlementManager.MANAGEMENT);
             ServerFactory.save(inst.getGuestSystem());
         }

         HibernateFactory.getSession().clear();
         
         
         //Verify everything is as it should be
         EntitlementServerGroup mgmnt =
             ServerGroupManager.getInstance().lookupEntitled(
                 EntitlementManager.MANAGEMENT, user);
         assertEquals(Long.valueOf(sysEnts), mgmnt.getCurrentMembers());
         
         rhelFamily = ChannelFamilyFactory.lookupById(rhelFamily.getId());
         assertEquals(Long.valueOf(ents), rhelFamily.getCurrentMembers(org));
         assertEquals(Long.valueOf(0), rhelFamily.getCurrentFlex(org));
         
         assertTrue(VirtualizationEntitlementsManager.getInstance().
                                             listFlexGuests(user).isEmpty());
         
         //Now Uodate the rhenChannelFamily's flex entitlements
         
         cmd2 = new UpdateOrgSoftwareEntitlementsCommand(rhelFamily.getLabel(), 
                 org, ents, flexEnts);
         assertNull(cmd2.store());
         HibernateFactory.getSession().clear();
         
         rhelFamily = ChannelFamilyFactory.lookupById(rhelFamily.getId());
         assertEquals(Long.valueOf(flexEnts), rhelFamily.getMaxFlex(org));
         
         List<ChannelFamilySystemGroup> l = VirtualizationEntitlementsManager.
                                         getInstance().listEligibleFlexGuests(user);
         
         
         assertTrue(!l.isEmpty());
         assertEquals(1, l.size());
         assertEquals(guestsToCreate, l.get(0).expand().size());         
    }    
    
    
}
