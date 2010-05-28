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

import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.PrivateChannelFamily;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.frontend.xmlrpc.SatelliteOrgException;

import java.util.List;

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

}
