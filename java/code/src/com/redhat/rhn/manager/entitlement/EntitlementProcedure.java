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
package com.redhat.rhn.manager.entitlement;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.PrivateChannelFamily;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.frontend.xmlrpc.SatelliteOrgException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.ChannelProcedure;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * EntitlementProcedure
 *
 * Entitlement related procedures
 * @version $Rev$
 */
public class EntitlementProcedure {


    private static final EntitlementProcedure INSTANCE = new EntitlementProcedure();

    private EntitlementProcedure() {

    }

    /**
     * @return an instance of the EntitlementProcedure object
     */
    public static EntitlementProcedure getInstance() {
        return INSTANCE;
    }

    /**
     * Remove All entitlements from an org
     *  Just handles the math logic, doesn't actually unsubscribe any systems
     * @param orgId The orgId
     */
    public void removeOrgEntitlements(Long orgId) {
        if (orgId.equals(1L)) {
            throw new SatelliteOrgException();
        }


        Org org = OrgFactory.lookupById(orgId);
        Org masterOrg = OrgFactory.lookupById(1L);


        //For each Entitlement take the Max for the org, and return it to the
        //   master org, locking both rows since we update and read them both.
        List<EntitlementServerGroup> systemEnts =
            ServerGroupFactory.listEntitlementGroups(org);
        for (EntitlementServerGroup sysEnt : systemEnts) {
            EntitlementServerGroup masterEnt = ServerGroupFactory.lookupEntitled(
                    masterOrg, sysEnt.getGroupType());
            ServerGroupFactory.lockEntitledServerGroup(sysEnt);
            ServerGroupFactory.lockEntitledServerGroup(masterEnt);
            masterEnt.setMaxMembers(masterEnt.getMaxMembers() + sysEnt.getMaxMembers());
            sysEnt.setMaxMembers(0L);
        }


        //Do the same for the Channel entitlements
        List<PrivateChannelFamily> privChannels =
            ChannelFamilyFactory.listPrivateChannelFamiles(org);
        for (PrivateChannelFamily priv : privChannels) {
            if (priv.getChannelFamily().getOrg() != null) {
                continue;
            }
            PrivateChannelFamily masterFam =
                priv.getChannelFamily().getChannelFamilyAllocationFor(masterOrg);
            ChannelFactory.lockPrivateChannelFamily(priv);
            ChannelFactory.lockPrivateChannelFamily(masterFam);
            masterFam.setMaxMembers(masterFam.getMaxMembers() + priv.getMaxMembers());
            priv.setMaxMembers(0L);
        }

    }

    /**
     *     -- *******************************************************************
     * PROCEDURE: repoll_virt_guest_entitlements
     *
     *   Whenever we add/remove a virtualization_host* entitlement from
     *   a host, we can call this procedure to update what type of slots
     *   the guests are consuming.
     *
     *   If you're removing the entitlement, it's
     *   possible the guests will become unentitled if you don't have enough
     *   physical slots to cover them.
           -- All channel families associated with the guests of server_id_in
     *
     *   If you're adding the entitlement, you end up freeing up physical
     *   slots for other systems.
     * @param sid the server Id
     */
    public void repollGuestVirtEntitlements(Long sid) {

        List<PrivateChannelFamily> chanFamilies =
            ChannelFamilyFactory.listGuestChannelFamiles(sid);
        List<EntitlementServerGroup> sysEntitlements =
            ServerGroupFactory.listGuestsServerGroups(sid);

        for (PrivateChannelFamily family : chanFamilies) {
            Long physicalMembers =
                ChannelProcedure.getInstance().computeCurrentMemberCounts(
                    family.getChannelFamily(), family.getOrg());

            if (physicalMembers > family.getMaxMembers()) {
                List<Long> idsToRemove = ServerFactory.listGuestIdsForRemoval(
                  family.getChannelFamily(), physicalMembers.longValue() -
                  family.getMaxMembers().longValue(), sid);
                for (Long toRemove : idsToRemove) {
                    unsubscribeServerFromFamily(toRemove,
                            family.getChannelFamily().getId());
                }

                /*
                 * update current_members for the family.  This will set the value
                 * to reflect adding/removing the entitlement.
                 */
                ChannelManager.updateChannelFamilyCounts(family);

            }
        }

        for (EntitlementServerGroup group : sysEntitlements) {
            ServerGroupFactory.lockEntitledServerGroup(group);
            Long physicalCount = getCurrentServerGroupCount(group);
            if (physicalCount > group.getMaxMembers()) {
                List<Long> idsToRemove = ServerFactory.listGuestIdsForRemoval(group,
                        physicalCount.longValue() - group.getMaxMembers().longValue(),
                        sid);
                for (Long guestId : idsToRemove) {
                    removeServerEntitlement(guestId, group.getGroupType().getLabel());
                    physicalCount--;
                }
                updateServerGroupCurrentMembers(physicalCount, group);
            }

        }


    }

    private void unsubscribeServerFromFamily(Long sid, Long familyId) {
        CallableMode m = ModeFactory.getCallableMode("Procedure_queries",
            "unsubscribe_server_from_family");
        Map params = new HashMap();
        params.put("sid", sid);
        params.put("fam_id", familyId);
        m.execute(params, new HashMap());

    }


    private void removeServerEntitlement(Long sid, String groupType) {
        CallableMode m = ModeFactory.getCallableMode("Procedure_queries",
                "remove_server_entitlement");
        Map params = new HashMap();
        params.put("sid", sid);
        params.put("group_type", groupType);
        m.execute(params, new HashMap());
    }


    private void updateServerGroupCurrentMembers(
                    Long currentMembers, EntitlementServerGroup group) {
        WriteMode m = ModeFactory.getWriteMode("Procedure_queries",
                "update_group_current_members");
        Map params = new HashMap();
        params.put("sgid", group.getId());
        params.put("current_members", currentMembers);
        m.executeUpdate(params);
    }

    /**
     * Calculates the actual current_members value
     *    (the number of systems using that entitlement)
     */
    private Long getCurrentServerGroupCount(EntitlementServerGroup group) {
        SelectMode m = ModeFactory.getMode("Procedure_queries",
            "compute_physical_server_group_count");
        Map params = new HashMap();
        params.put("sgid", group.getId());
        DataResult<Map<String, Object>> dr = m.execute(params);
        return (Long) dr.get(0).get("count");
    }

}
