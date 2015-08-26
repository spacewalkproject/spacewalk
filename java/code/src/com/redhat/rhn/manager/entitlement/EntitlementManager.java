/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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

import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.ManagementEntitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.manager.BaseManager;

import org.apache.log4j.Logger;

import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * EntitlementManager
 */
public class EntitlementManager extends BaseManager {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(EntitlementManager.class);

    //  ENTITLEMENTS
    public static final Entitlement MANAGEMENT = new ManagementEntitlement();
    public static final Entitlement VIRTUALIZATION = new VirtualizationEntitlement();

    public static final String UNENTITLED = "unentitled";
    public static final String ENTERPRISE_ENTITLED = "enterprise_entitled";
    public static final String VIRTUALIZATION_ENTITLED = "virtualization_host";

    private static final Set <Entitlement> ADDON_ENTITLEMENTS;
    private static final Set <Entitlement> BASE_ENTITLEMENTS;
    static {
        ADDON_ENTITLEMENTS = new LinkedHashSet<Entitlement>();
        ADDON_ENTITLEMENTS.add(VIRTUALIZATION);

        BASE_ENTITLEMENTS = new LinkedHashSet<Entitlement>();
        BASE_ENTITLEMENTS.add(MANAGEMENT);
    }

    /**
     * Returns the entitlement whose name matches the given <code>name</code>
     * @param name Name of Entitlement.
     * @return the entitlement whose name matches the given name.
     */
    public static Entitlement getByName(String name) {
        if (ENTERPRISE_ENTITLED.equals(name)) {
            return MANAGEMENT;
        }
        else if (VIRTUALIZATION_ENTITLED.equals(name)) {
            return VIRTUALIZATION;
        }
        return null;
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
}
