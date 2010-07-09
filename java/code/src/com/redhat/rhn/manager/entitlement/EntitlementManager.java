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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.ManagementEntitlement;
import com.redhat.rhn.domain.entitlement.MonitoringEntitlement;
import com.redhat.rhn.domain.entitlement.NonLinuxEntitlement;
import com.redhat.rhn.domain.entitlement.ProvisioningEntitlement;
import com.redhat.rhn.domain.entitlement.UpdateEntitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationPlatformEntitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.manager.BaseManager;

import org.apache.log4j.Logger;

import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;


/**
 * EntitlementManager
 * @version $Rev$
 */
public class EntitlementManager extends BaseManager {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(EntitlementManager.class);

    //  ENTITLEMENTS
    public static final Entitlement UPDATE = new UpdateEntitlement();
    public static final Entitlement MANAGEMENT = new ManagementEntitlement();
    public static final Entitlement PROVISIONING = new ProvisioningEntitlement();
    public static final Entitlement MONITORING = new MonitoringEntitlement();
    public static final Entitlement NONLINUX = new NonLinuxEntitlement();
    public static final Entitlement VIRTUALIZATION = new VirtualizationEntitlement();
    public static final Entitlement VIRTUALIZATION_PLATFORM =
        new VirtualizationPlatformEntitlement();

    public static final String UNENTITLED = "unentitled";
    public static final String SW_MGR_ENTITLED = "sw_mgr_entitled";
    public static final String ENTERPRISE_ENTITLED = "enterprise_entitled";
    public static final String PROVISIONING_ENTITLED = "provisioning_entitled";
    public static final String NONLINUX_ENTITLED = "nonlinux_entitled";
    public static final String MONITORING_ENTITLED = "monitoring_entitled";
    public static final String VIRTUALIZATION_ENTITLED = "virtualization_host";
    public static final String VIRTUALIZATION_PLATFORM_ENTITLED
        = "virtualization_host_platform";

    private static final Set <Entitlement> ADDON_ENTITLEMENTS;
    private static final Set <Entitlement> BASE_ENTITLEMENTS;
    static {
        ADDON_ENTITLEMENTS = new LinkedHashSet<Entitlement>();
        ADDON_ENTITLEMENTS.add(MONITORING);
        ADDON_ENTITLEMENTS.add(PROVISIONING);
        ADDON_ENTITLEMENTS.add(VIRTUALIZATION);
        ADDON_ENTITLEMENTS.add(VIRTUALIZATION_PLATFORM);

        BASE_ENTITLEMENTS = new LinkedHashSet<Entitlement>();
        BASE_ENTITLEMENTS.add(MANAGEMENT);
    }


    // SERVICES
    public static final String SVC_UPDATES = "updates";
    public static final String SVC_MANAGEMENT = "management";
    public static final String SVC_PROVISIONING = "provisioning";
    public static final String SVC_MONITORING = "monitoring";
    public static final String SVC_NONLINUX = "nonlinux";

    /**
     * Returns the entitlement whose name matches the given <code>name</code>
     * @param name Name of Entitlement.
     * @return the entitlement whose name matches the given name.
     */
    public static Entitlement getByName(String name) {
        if (SW_MGR_ENTITLED.equals(name)) {
            return UPDATE;
        }
        else if (ENTERPRISE_ENTITLED.equals(name)) {
            return MANAGEMENT;
        }
        else if (PROVISIONING_ENTITLED.equals(name)) {
            return PROVISIONING;
        }
        else if (NONLINUX_ENTITLED.equals(name)) {
            return NONLINUX;
        }
        else if (MONITORING_ENTITLED.equals(name)) {
            return MONITORING;
        }
        else if (VIRTUALIZATION_ENTITLED.equals(name)) {
            return VIRTUALIZATION;
        }
        else if (VIRTUALIZATION_PLATFORM_ENTITLED.equals(name)) {
            return VIRTUALIZATION_PLATFORM;
        }
        return null;
    }

    /**
     * Get count of avail ents for the given entitlement and org.  NULL
     * if unlimited or not found.
     *
     * @param ent to lookup
     * @param orgIn to query
     * @return long count of avail ents
     */
    public static Long getAvailableEntitlements(Entitlement ent, Org orgIn) {
        Long available = null;
        if (log.isDebugEnabled()) {
            log.debug("getAvailableEntitlements.label: " + ent.getLabel());
        }
        SelectMode m =
            ModeFactory.getMode("General_queries", "server_group_membership");

        Map params = new HashMap();
        params.put("org_id", orgIn.getId());
        params.put("label", ent.getLabel());

        DataResult dr = m.execute(params);
        if (dr.size() > 0) {
            Map row = (Map) dr.get(0);
            Long max = (Long) row.get("max_members");
            Long current = (Long) row.get("current_members");
            available = new Long(max.longValue() - current.longValue());
        }
        else {
            log.debug("something weird, we didnt get a SG.");
        }
        return available;
    }

    /**
     * Returns the static set of addon entitlements.
     * @return Unmodifiable set.
     */
    public static Set<Entitlement> getAddonEntitlements() {
        return Collections.unmodifiableSet(ADDON_ENTITLEMENTS);
    }

    /**
     * Returns the static set of base entitlements.
     * @return Unmodifiable set.
     */
    public static Set<Entitlement>  getBaseEntitlements() {
        return Collections.unmodifiableSet(BASE_ENTITLEMENTS);
    }

    /**
     * Check the count of used entitlements for the passed in ent and org.
     * @param ent to check
     * @param org to check
     * @return Long count, null of unlimited.
     */
    public static Long getUsedEntitlements(Entitlement ent, Org org) {
        EntitlementServerGroup sg = ServerGroupFactory.lookupEntitled(ent, org);
        if (sg != null) {
            return sg.getCurrentMembers();
        }
        else {
            return null;
        }
    }

    /**
     * Check the count of max entitlements for the passed in ent and org.
     * @param ent to check
     * @param org to check
     * @return Long count, null of unlimited.
     */
    public static Long getMaxEntitlements(Entitlement ent, Org org) {
        EntitlementServerGroup sg = ServerGroupFactory.lookupEntitled(ent, org);
        if (sg != null) {
            return sg.getMaxMembers();
        }
        else {
            return null;
        }
    }
}
