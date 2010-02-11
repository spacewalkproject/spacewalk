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
package com.redhat.rhn.manager.solarispatchset;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.BaseManager;

import java.util.HashMap;
import java.util.Map;

/**  
 * SolarisPatchSetManager
 * @version $Rev$
 */
public class SolarisPatchSetManager extends BaseManager {
    /**
     * Helper method to get various solaris patch clusters
     * @param sid Server
     * @param pc PageControl
     * @return list of patch clusters 
     */
    private static DataResult solarisPackageHelper(Long sid, PageControl pc, String mode) {
        SelectMode m = ModeFactory.getMode("Package_queries", mode);
        Map params = new HashMap();
        Map elabParams = new HashMap();
        params.put("sid", sid);
        elabParams.put("sid", sid);

        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns list of available solaris patch clusters for given server
     * This list will include patch clusters that are already installed
     * @param sid Server Id
     * @param pc PageControl can also be null.
     * @return list of solaris packages for given server
     */
    public static DataResult systemAvailablePatchSetList(Long sid, PageControl pc) {
        return solarisPackageHelper(sid, pc, "system_available_solaris_patchset_list");
    }

}
