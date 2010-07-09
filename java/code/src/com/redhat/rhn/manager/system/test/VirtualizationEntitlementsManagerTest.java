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
import com.redhat.rhn.frontend.dto.ChannelFamilySystem;
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

import java.util.Collection;
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
        setupFlexGuestTest(user, false);
    }


    public void testListFlexGuestsOnVirtAddToHost() throws Exception {
        Org org = UserTestUtils.createNewOrgFull(RandomStringUtils.randomAlphabetic(10));
        User user = UserTestUtils.createUser(RandomStringUtils.randomAlphabetic(10),
                org.getId());
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);

        setupFlexGuestTest(user, true);
         List<ChannelFamilySystemGroup> l = VirtualizationEntitlementsManager.getInstance().
                                                             listFlexGuests(user);
         //NOW give Virt Entitlement to the Host
         // And make sure flex is not being consumed
         ChannelFamilySystemGroup g = l.get(0);
         ChannelFamilySystem cfs = g.expand().get(0);
         Server s = ServerFactory.lookupById(cfs.getId());
         assertNotNull(s);
         Server host = s.getVirtualInstance().getHostSystem();
         Long hostId = host.getId();
         assertNotNull(host);
         SystemManager.entitleServer(host, EntitlementManager.VIRTUALIZATION);
         HibernateFactory.getSession().clear();

         l = VirtualizationEntitlementsManager.getInstance().
                                                     listFlexGuests(user);
         assertTrue(l.isEmpty());


         //NOW do the opposite remove the  virt ent
         //and ensure the guests are consuming flex
         SystemManager.removeServerEntitlement(hostId, EntitlementManager.VIRTUALIZATION);
         HibernateFactory.getSession().clear();
         l = VirtualizationEntitlementsManager.getInstance().
                                                     listFlexGuests(user);
         assertTrue(!l.isEmpty());

    }

    public void setupFlexGuestTest(User user, boolean giveVirt) throws Exception {
        Org org = user.getOrg();
        long ents = 3;
        int guestsToCreate = 6;
        long flexEnts = guestsToCreate;
        long sysEnts = guestsToCreate + 1; // 1 for host
        //Give it some system entitlements
        UpdateOrgSystemEntitlementsCommand cmd1 = new UpdateOrgSystemEntitlementsCommand(
                EntitlementManager.MANAGEMENT, org, sysEnts);
        assertNull(cmd1.store());
        if (giveVirt) {
            UpdateOrgSystemEntitlementsCommand cmdVirt = new
                                        UpdateOrgSystemEntitlementsCommand(
                                        EntitlementManager.VIRTUALIZATION, org, sysEnts);
            assertNull(cmdVirt.store());
        }


        ChannelFamily rhelFamily = ChannelFamilyFactoryTest.createTestChannelFamily(
                UserFactory.findRandomOrgAdmin(OrgFactory.getSatelliteOrg()),
                            ents, flexEnts);
        assertEquals(Long.valueOf(flexEnts),
                    rhelFamily.getMaxFlex(OrgFactory.getSatelliteOrg()));
        UpdateOrgSoftwareEntitlementsCommand cmd2 = new
                            UpdateOrgSoftwareEntitlementsCommand(rhelFamily.getLabel(),
                                            org, ents, flexEnts);
        assertNull(cmd2.store());
         rhelFamily = setupGuests(org, user, guestsToCreate,
                flexEnts, rhelFamily, true);


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



    public void testNonVirtHostEligibleFlexGuests() throws Exception {
        executeEligibleGuestTests(false);
    }

    public void testOrphanedEligibleFlexGuests() throws Exception {
        executeEligibleGuestTests(true);
    }



    private void executeEligibleGuestTests(boolean isOrphaned) throws Exception {
        Org org = UserTestUtils.createNewOrgFull(RandomStringUtils.randomAlphabetic(10));
        User user = UserTestUtils.createUser(RandomStringUtils.randomAlphabetic(10),
                org.getId());
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        int guestsToCreate = 6;
        long flexEnts = guestsToCreate;
        long ents = guestsToCreate;
        long sysEnts = guestsToCreate; //+ 1 for host
        if (!isOrphaned) {
            ents++;
            sysEnts++;
        }
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
        rhelFamily = setupGuests(org, user, guestsToCreate, 0, rhelFamily, !isOrphaned);

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

    private ChannelFamily setupGuests(Org org, User user,
            int guestsToCreate, long flexEnts, ChannelFamily rhelFamily,
            boolean addNonVirtHost) throws Exception {
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
         Collection<VirtualInstance> guests = null;
         if (addNonVirtHost) {
             builder.createNonVirtHost();
             builder.withGuests(guestsToCreate);
         }
         else {
             guests = builder.withOrphanedGuests(guestsToCreate);
         }

         if (addNonVirtHost) {
             Server host = builder.build();
             ServerFactory.save(host);

             SystemManager.subscribeServerToChannel(user, host, rhelChannel);

             ServerFactory.save(host);
             guests = host.getGuests();
         }

         for (VirtualInstance inst : guests) {
             SystemManager.subscribeServerToChannel(user,
                     inst.getGuestSystem(), rhelChannel);
             SystemManager.entitleServer(inst.getGuestSystem(),
                     EntitlementManager.MANAGEMENT);
             ServerFactory.save(inst.getGuestSystem());
         }
         HibernateFactory.getSession().clear();
        return rhelFamily;
    }

}
