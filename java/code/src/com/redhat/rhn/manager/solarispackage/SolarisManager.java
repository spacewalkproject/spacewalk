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
package com.redhat.rhn.manager.solarispackage;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.BaseManager;

import java.util.HashMap;
import java.util.Map;

/**
 * SolarisManager
 * @version $Rev: 53093 $
 */
public class SolarisManager extends BaseManager {
    /**
     * Helper method to get various solaris packages, patches and patch clusters
     * @param sid Server
     * @param pc PageControl
     * @param mode DataSource mode name
     * @return list of packages, patches or patch clusters
     */
    private static DataResult solarisPackageHelper(Long sid, PageControl pc, String mode) {
        SelectMode m = ModeFactory.getMode("Package_queries", mode);
        Map params = new HashMap();
        params.put("sid", sid);
        return makeDataResult(params, params, pc, m);
    }

    /**
     * Returns list of available solaris package(s) for given server
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of solaris packages for given server
     */
    public static DataResult systemAvailablePackageList(Long sid, PageControl pc) {
        return solarisPackageHelper(sid, pc, "system_available_solaris_package_list");
    }

    /**
     * Returns list of upgradable solaris package(s) for given server
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of solaris packages for given server
     */
    public static DataResult systemUpgradablePackageList(Long sid, PageControl pc) {
        return solarisPackageHelper(sid, pc, "system_upgradable_solaris_package_list");
    }

    /**
     * Returns list of installed solaris package(s) for given server
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of solaris packages for given server
     */
    public static DataResult systemPackageList(Long sid, PageControl pc) {
        return solarisPackageHelper(sid, pc, "system_solaris_package_list");
    }

    /**
     * Returns list of installed solaris patch(es) for given server
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of solaris packages for given server
     */
    public static DataResult systemPatchList(Long sid, PageControl pc) {
        return solarisPackageHelper(sid, pc, "system_patch_list");
    }

    /**
     * Returns list of available solaris patch(es) for given server
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of solaris packages for given server
     */
    public static DataResult systemAvailablePatchList(Long sid, PageControl pc) {
        return solarisPackageHelper(sid, pc, "system_available_patch_list");
    }

    /**
     * Returns list of patches in removable set
     * @param label list label
     * @param pc PageControl
     * @param user Logged in User
     * @return list of packages, patches or patch clusters
     */
    public static DataResult patchesInSet(User user, PageControl pc, String label) {
        SelectMode m = ModeFactory.getMode("Package_queries", "patches_in_set");
        Map params = new HashMap();
        Map elabParams = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", label);
        //elabParams.put("", sid);
        return makeDataResult(params, elabParams, pc, m);
    }
}
