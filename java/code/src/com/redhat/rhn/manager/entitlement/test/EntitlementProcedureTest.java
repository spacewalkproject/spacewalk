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
package com.redhat.rhn.manager.entitlement.test;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.org.test.OrgFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.test.HostBuilder;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.entitlement.EntitlementProcedure;
import com.redhat.rhn.manager.org.UpdateOrgSoftwareEntitlementsCommand;
import com.redhat.rhn.manager.org.UpdateOrgSystemEntitlementsCommand;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.RandomStringUtils;

import java.util.HashMap;
import java.util.Map;


public class EntitlementProcedureTest extends RhnBaseTestCase {


    public void testRepollGuestVirtEntitlements() throws Exception {
        OrgFactoryTest test = new OrgFactoryTest();
        Org org = UserTestUtils.createNewOrgFull(RandomStringUtils.randomAlphabetic(10));
        User user = UserTestUtils.createUser(RandomStringUtils.randomAlphabetic(10),
                org.getId());
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        Long ents = 3L;
        Long guestsToCreate = 6L;

        //Give it some system entitlements
        UpdateOrgSystemEntitlementsCommand cmd1 = new UpdateOrgSystemEntitlementsCommand(
                EntitlementManager.MANAGEMENT, org, ents);
        cmd1.store();

        UpdateOrgSoftwareEntitlementsCommand cmd2
            = new UpdateOrgSoftwareEntitlementsCommand("rhel-server", org, ents);
        cmd2.store();
        OrgFactory.getSession().clear();


        HostBuilder builder = new HostBuilder(org.getActiveOrgAdmins().get(0));
        builder.createVirtHost().withGuests(guestsToCreate.intValue());
        Server host = builder.build();


        ServerFactory.save(host);
        Channel rhelServer = ChannelFactory.lookupByLabel("rhel-i386-server-5");
        SystemManager.subscribeServerToChannel(user, host, rhelServer);
        //SystemManager.entitleServer(host, EntitlementManager.MANAGEMENT);
        ServerFactory.save(host);
        for (VirtualInstance inst : host.getGuests()) {
            SystemManager.subscribeServerToChannel(user,
                    inst.getGuestSystem(), rhelServer);
            SystemManager.entitleServer(inst.getGuestSystem(),
                    EntitlementManager.MANAGEMENT);
            ServerFactory.save(inst.getGuestSystem());
        }

        OrgFactory.getSession().clear();

        //Verify everything is as it should be
        EntitlementServerGroup mgmnt =
            ServerGroupManager.getInstance().lookupEntitled(
                EntitlementManager.MANAGEMENT, user);
        assertEquals(new Long(1L), mgmnt.getCurrentMembers());
        ChannelFamily family = ChannelFamilyFactory.lookupByLabel("rhel-server", org);
        assertEquals(new Long(1L), family.getCurrentMembers(org));


        OrgFactory.getSession().clear();

        EntitlementProcedure.getInstance().repollGuestVirtEntitlements(host.getId());


        //verify that after repolling with no changes, eerything is teh same
        mgmnt = ServerGroupManager.getInstance().lookupEntitled(
                EntitlementManager.MANAGEMENT, user);
        assertEquals(new Long(1L), mgmnt.getCurrentMembers());
        family = ChannelFamilyFactory.lookupByLabel("rhel-server", org);
        assertEquals(new Long(1L), family.getCurrentMembers(org));


        //Now clear the virtualization entitlements without going through stored proc
        // (To test repoll)
        removeServerEntitlement(host.getId(),
                ServerGroupManager.getInstance().lookupEntitled(
                EntitlementManager.VIRTUALIZATION, user).getGroupType().getLabel());

        EntitlementProcedure.getInstance().repollGuestVirtEntitlements(host.getId());

        OrgFactory.getSession().clear();

        mgmnt = ServerGroupManager.getInstance().lookupEntitled(
                EntitlementManager.MANAGEMENT, user);
        assertEquals(ents, mgmnt.getCurrentMembers());
        family = ChannelFamilyFactory.lookupByLabel("rhel-server", org);
        assertEquals(ents, family.getCurrentMembers(org));

        host = ServerFactory.lookupById(host.getId());
        int groupUnent = 0;
        int familyUnent = 0;
        for (VirtualInstance virt : host.getGuests()) {
            if (virt.getGuestSystem().getBaseEntitlement() == null) {
                groupUnent++;
            }
            if (virt.getGuestSystem().getBaseChannel() == null) {
                familyUnent++;
            }

        }


        //The number of unentitled guests should be the number of guests
        //   - the number of open slots (leaving one out for the host)
        assertEquals(guestsToCreate.intValue() - (ents.intValue() - 1), groupUnent);
        assertEquals(guestsToCreate.intValue() - (ents.intValue() - 1), familyUnent);


    }


    private static void removeServerEntitlement(Long sid, String groupType) {
        CallableMode m = ModeFactory.getCallableMode("Procedure_queries",
                "remove_server_entitlement");

       // SelectMode m = ModeFactory.getMode("Procedure_queries",
      //  "remove_server_entitlement");

        Map params = new HashMap();
        params.put("sid", sid);
        params.put("group_type", groupType);


        m.execute(params, new HashMap());
      //  m.execute(params);
    }
}
