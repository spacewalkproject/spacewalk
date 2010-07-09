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
package com.redhat.rhn.frontend.xmlrpc.serializer;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.server.Network;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

import org.apache.commons.lang.StringUtils;

import java.io.IOException;
import java.io.Writer;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import redstone.xmlrpc.XmlRpcCustomSerializer;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ServerSerializer: Converts a Server object for representation as an XMLRPC struct.
 * Includes full server details, which may be more data than some calls would like.
 * @version $Rev$
 *
 *
 * @xmlrpc.doc
 *  #struct("server details")
 *         #prop_desc("int", "id", "System id")
 *         #prop("string", "profile_name")
 *         #prop_desc("string", "base_entitlement", "System's base entitlement label.
 *                      (enterprise_entitled or sw_mgr_entitled)")
 *
 *         #prop_array("string", "addon_entitlements","System's addon entitlements labels,
 *                       including monitoring_entitled, provisioning_entitled,
 *                                 virtualization_host, virtualization_host_platform")
 *          #prop_desc("boolean", "auto_update", "True if system has auto errata updates
 *                                          enabled.")
 *          #prop_desc("string", "release", "The Operating System release (i.e. 4AS,
 *                      5Server")
 *          #prop("string", "address1")
 *          #prop("string", "address2")
 *          #prop("string", "city")
 *          #prop("string", "state")
 *          #prop("string", "country")
 *          #prop("string", "building")
 *          #prop("string", "room")
 *          #prop("string", "rack")
 *          #prop("string", "description")
 *          #prop("string", "hostname")
 *          #prop($date, "last_boot")
 *          #prop_desc("string", "osa_status", "Either 'unknown', 'offline', or 'online'.")
 *          #prop_desc("boolean", "lock_status", "True indicates that the system is locked.
 *           False indicates that the system is unlocked.")
 *  #struct_end()
 */
public class ServerSerializer implements XmlRpcCustomSerializer {

    /**
     * {@inheritDoc}
     */
    public Class getSupportedClass() {
        return Server.class;
    }

    /**
     * {@inheritDoc}
     */
    public void serialize(Object value, Writer output, XmlRpcSerializer builtInSerializer)
        throws XmlRpcException, IOException {

        Server server = (Server)value;

        SerializerHelper helper = new SerializerHelper(builtInSerializer);
        helper.add("id", server.getId());
        helper.add("profile_name", server.getName());

        Set networks = server.getNetworks();
        if (networks != null && !networks.isEmpty()) {
            // we only care about the first one
            Network net = (Network) networks.iterator().next();
            helper.add("hostname", net.getHostname());
        }
        else {
            helper.add("hostname", LocalizationService.getInstance().getMessage(
                    "sdc.details.overview.unknown"));
        }

        // Find this server's base entitlement:
        String baseEntitlement = EntitlementManager.UNENTITLED;
        List<String> addonEntitlements = new LinkedList<String>();
        for (Entitlement ent : server.getEntitlements()) {
            if (ent.isBase()) {
                baseEntitlement = ent.getLabel();
            }
            else {
                addonEntitlements.add(ent.getLabel());
            }
        }
        helper.add("base_entitlement", baseEntitlement);
        helper.add("addon_entitlements", addonEntitlements);

        Boolean autoUpdate = Boolean.FALSE;
        if (server.getAutoUpdate().equals("Y")) {
            autoUpdate = Boolean.TRUE;
        }
        helper.add("auto_update", autoUpdate);

        helper.add("description", StringUtils.defaultString(server.getDescription()));

        String address1 = "";
        String address2 = "";
        String city = "";
        String state = "";
        String country = "";
        String building = "";
        String room = "";
        String rack = "";
        if (server.getLocation() != null) {
            address1 = StringUtils.defaultString(server.getLocation().
                    getAddress1());
            address2 = StringUtils.defaultString(server.getLocation().
                    getAddress2());
            city = StringUtils.defaultString(server.getLocation().
                    getCity());
            state = StringUtils.defaultString(server.getLocation().
                    getState());
            country = StringUtils.defaultString(server.getLocation().
                    getCountry());
            building = StringUtils.defaultString(server.getLocation().
                    getBuilding());
            room = StringUtils.defaultString(server.getLocation().
                    getRoom());
            rack = StringUtils.defaultString(server.getLocation().
                    getRack());
        }
        helper.add("address1", address1);
        helper.add("address2", address2);
        helper.add("city", city);
        helper.add("state", state);
        helper.add("country", country);
        helper.add("building", building);
        helper.add("room", room);
        helper.add("rack", rack);

        helper.add("release", server.getRelease());
        helper.add("last_boot", server.getLastBootAsDate());

        if (server.getPushClient() != null) {
            helper.add("osa_status", server.getPushClient().getState().getName());
        }
        else {
            helper.add("osa_status", LocalizationService.getInstance().getMessage(
                    "sdc.details.overview.unknown"));
        }

        Boolean locked = Boolean.FALSE;
        if (server.getLock() != null) {
            locked = Boolean.TRUE;
        }
        helper.add("lock_status", locked);

        helper.writeTo(output);
    }
}
