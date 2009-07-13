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

import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.apache.log4j.Logger;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

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
        User user = UserFactory.lookupById(event.getUserId()); 

        LocalizationService ls = LocalizationService.getInstance();
        long operationId = SsmOperationManager.createOperation(user,
            ls.getMessage("ssm.package.upgrade.operationname"), null);

        // Explicitly call handle transactions here so the operation creation above
        // is persisted before the potentially long running logic below
        handleTransactions();

        try {
            scheduleUpgrades(user, event);
        }
        catch (Exception e) {
            log.error("Error while scheduling package upgrades for event: " + event, e);
        }
        finally {
            SsmOperationManager.completeOperation(user, operationId);
        }

        log.debug("Done.");
    }

    private void scheduleUpgrades(User user, SsmUpgradePackagesEvent event) {

        long actionStart = System.currentTimeMillis();

        DataResult result = event.getResult();
        Date earliest = event.getEarliest();
        List<Map<String, Long>> packageListItems = event.getPackageListItems();

        // Migrate server data result into a single list for lookup
        List<Long> serverIds = new ArrayList<Long>(result.size());
        for (Iterator it = result.iterator(); it.hasNext();) {
            Map data = (Map) it.next();
            Long serverId = (Long) data.get("id");
            serverIds.add(serverId);
        }

        List<Server> serverList = ServerFactory.lookupByIdsAndUser(serverIds, user);
        ActionManager.schedulePackageUpgrades(user, serverList, packageListItems, earliest);

        if (log.isDebugEnabled()) {
            log.debug("Time to schedule all actions: " +
                (System.currentTimeMillis() - actionStart));
        }
    }

}

