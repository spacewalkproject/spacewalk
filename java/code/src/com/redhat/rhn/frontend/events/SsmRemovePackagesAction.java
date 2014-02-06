/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.events;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.manager.action.ActionChainManager;

/**
 * Handles removing packages from servers in the SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmRemovePackagesEvent
 */
public class SsmRemovePackagesAction extends SsmPackagesAction {
    private static Logger log = Logger.getLogger(SsmRemovePackagesAction.class);

    protected String getOperationName() {
        return "ssm.package.remove.operationname";
    }

    protected List<Long> getAffectedServers(SsmPackageEvent event, User u) {
        SsmRemovePackagesEvent srpe = (SsmRemovePackagesEvent) event;
        List<Long> sids = new ArrayList<Long>();
        List<Map> result = srpe.getResult();
        for (Map data : result) {
            Long sid = (Long) data.get("id");
            sids.add(sid);
        }
        return sids;
    }

    protected List<Action> doSchedule(SsmPackageEvent event, User user, List<Long> sids,
        Date earliest, ActionChain actionChain) {

        SsmRemovePackagesEvent srpe = (SsmRemovePackagesEvent) event;

        List<Map> result = srpe.getResult();

        /*
         * 443500 - The following was changed to be able to stuff all of the package
         * removals into a single action. The schedule package removal page will display a
         * fine grained mapping of server to package removed (taking into account to only
         * show packages that exist on the server).
         *
         * However, there is no issue in requesting a client delete a package it doesn't
         * have. So when we create the action, populate it with all packages and for every
         * server to which any package removal applies. This will let us keep all of the
         * removals coupled under a single scheduled action and won't cause an issue on
         * the client when the scheduled removals are picked up.
         *
         * jdobies, Apr 8, 2009
         */

        // The package collection is a set to prevent duplicates when keeping a running
        // total of all packages selected
        Set<PackageListItem> allPackages = new HashSet<PackageListItem>();

        Set<Long> allServerIds = new HashSet<Long>();

        // Iterate the data, which is essentially each unique package/server combination
        // to remove. Note that this is only for servers that we have marked as having the
        // package installed.
        log.debug("Iterating data.");

        // Add action for each package found in the elaborator
        for (Map data : result) {
            // Load the server
            Long sid = (Long) data.get("id");
            allServerIds.add(sid);

            // Get the packages out of the elaborator
            List<Map> elabList = (List<Map>) data.get("elaborator0");
            if (elabList != null) {
                for (Map elabMap : elabList) {
                    String idCombo = (String) elabMap.get("id_combo");
                    PackageListItem item = PackageListItem.parse(idCombo);
                    allPackages.add(item);
                }
            }
        }

        log.debug("Converting data to maps.");
        List<PackageListItem> allPackagesList = new ArrayList<PackageListItem>(allPackages);
        List<Map<String, Long>> packageListData = PackageListItem
                .toKeyMaps(allPackagesList);

        log.debug("Scheduling package removals.");
        List<Action> actions = ActionChainManager.schedulePackageRemoval(user,
            allServerIds, packageListData, earliest, actionChain);

        log.debug("Done.");
        return actions;
    }

}
