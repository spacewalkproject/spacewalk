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
package com.redhat.rhn.manager.org;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.xmlrpc.SatelliteOrgException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.entitlement.EntitlementProcedure;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * OrgProcedure
 *
 * Organization related procedures
 *
 * @version $Rev$
 */
public class OrgProcedure {


    private static final OrgProcedure INSTANCE = new OrgProcedure();

    private OrgProcedure() {

    }

    /**
     * @return an instance of the OrgProcedure object
     */
    public static OrgProcedure getInstance() {
        return INSTANCE;
    }



    /**
     * Delete an Org
     * @param org The org to delete
     */
    public static void deleteOrg(Org org) {

        if (org.getId() == 1) {
            throw new SatelliteOrgException();
        }

        List<User> users = UserFactory.getInstance().findAllUsers(org);
        for (User u : users) {
            CallableMode m = ModeFactory.getCallableMode("User_queries",
            "delete_user");
            Map inParams = new HashMap();
            Map outParams = new HashMap();
            inParams.put("user_id", u.getId());
            m.execute(inParams, outParams);
        }

        List<SystemOverview> systems = SystemManager.systemListShort(org, null);
        for (SystemOverview sys : systems) {
            ServerFactory.delete(sys.getId());
        }

        List<ConfigChannel> configChannels = ConfigurationFactory.listConfigChannels(org);
        for (ConfigChannel config : configChannels) {
            ConfigurationFactory.removeConfigChannel(config);
        }

        List<ChannelOverview> channels =
            ChannelManager.channelsOwnedByOrg(org.getId(), null);
        for (ChannelOverview chan : channels) {
            deleteCustomChannelAssociations(chan.getId());
        }


        List<Long> errata = ErrataFactory.listErrataIds(org);
        for (Long e : errata) {
            deleteErrataPackage(e);
        }

        EntitlementProcedure.getInstance().removeOrgEntitlements(org.getId());

        String[] modes = {"delete_org_channels",
                        "delete_org_daily_summary",
                        "delete_org_qutoa",
                        "delete_org_info",
                        "delete_org_file_list",
                        "delete_org_server_group",
                        "delete_org_check_suites",
                        "delete_org_command_target",
                        "delete_org_contact_group",
                        "delete_org_notif_format",
                        "delete_org_probe",
                        "delete_org_redirect",
                        "delete_org_sat_cluster",
                        "delete_org_schedule",
                        "delete_org"};

        Map params = new HashMap();
        params.put("oid", org.getId());
        for (String mode : modes) {
            WriteMode m = ModeFactory.getWriteMode("Procedure_queries", mode);
            m.executeUpdate(params);
        }


    }

    private static void deleteCustomChannelAssociations(Long cid) {
        String[] modes = {"unsubscribe_custom_channels",
                "delete_server_packge_profiles_for_channel",
                "delete_server_profiles_for_channel"};

        Map params = new HashMap();
        params.put("cid", cid);
        for (String mode : modes) {
            WriteMode m = ModeFactory.getWriteMode("Procedure_queries", mode);
            m.executeUpdate(params);
        }
    }

    private static void deleteErrataPackage(Long eid) {
        Map params = new HashMap();
        params.put("eid", eid);
        WriteMode m = ModeFactory.getWriteMode("Procedure_queries",
                "delete_errata_packages");
        m.executeUpdate(params);
    }

}
