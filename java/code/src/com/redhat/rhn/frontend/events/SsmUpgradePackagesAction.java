/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;

import com.redhat.rhn.common.localization.LocalizationService;

import com.redhat.rhn.common.messaging.EventMessage;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;

import com.redhat.rhn.frontend.dto.PackageListItem;

import com.redhat.rhn.manager.action.ActionManager;

import com.redhat.rhn.manager.ssm.SsmOperationManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

/**
 * Handles removing packages from servers in the SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmUpgradePackagesEvent
 */
public class SsmUpgradePackagesAction extends AbstractDatabaseAction {
    private static Logger log = Logger.getLogger(SsmUpgradePackagesAction.class);

    /** {@inheritDoc} */
    protected void doExecute(EventMessage msg) {
        log.debug("Executing package upgrades.");
        SsmUpgradePackagesEvent event = (SsmUpgradePackagesEvent) msg;

        DataResult result = event.getResult();
        User user = UserFactory.lookupById(event.getUserId());
        Date earliest = event.getEarliest();

        LocalizationService ls = LocalizationService.getInstance();
        long operationId = SsmOperationManager.createOperation(user,
            ls.getMessage("ssm.package.upgrade.operationname"), null);
        int numPackages = 0;

        // The package collection is a set to prevent duplciates when keeping a running
        // total of all packages selected
        Set<PackageListItem> allPackages = new HashSet<PackageListItem>();

        // Looking up all the server objects in Hibernate was *brutally* slow here:
        List<Long> allServerIds = new LinkedList<Long>();

        // Iterate the data, which is essentially each unique package/server combination
        // to upgrade. Note that this is only for servers that we have marked as having the
        // package installed.
        log.debug("Iterating data.");
        for (Iterator it = result.iterator(); it.hasNext();) {

            // Add action for each package found in the elaborator
            Map data = (Map) it.next();

            // Load the server
            Long sid = (Long)data.get("id");
            Server server = ServerFactory.lookupByIdAndOrg(sid, user.getOrg());

            // Get the packages out of the elaborator
            List elabList = (List) data.get("elaborator0");

            List<PackageListItem> items = new ArrayList<PackageListItem>(elabList.size());
            for (Iterator elabIt = elabList.iterator(); elabIt.hasNext();) {
                Map elabData = (Map) elabIt.next();
                String idCombo = (String) elabData.get("id_combo");
                PackageListItem item = PackageListItem.parse(idCombo);
                items.add(item);
            }

            // Convert to list of maps
            List<Map<String, Long>> packageListData = PackageListItem.toKeyMaps(items);

            // Create the action
            ActionManager.schedulePackageUpgrade(user, server, packageListData, earliest);
        }
        log.debug("Done.");
    }

}

