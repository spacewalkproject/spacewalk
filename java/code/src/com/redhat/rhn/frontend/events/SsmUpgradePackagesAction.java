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
package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

import org.apache.log4j.Logger;

import java.util.Date;
import java.util.List;
import java.util.Map;

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

        /* The following isn't 100% accurate. All systems in the SSM are associated
           with the operation, however only systems on which the package already exists
           (since this is an upgrade) will actually have events scheduled.

           The problem is that the list of servers to which the package upgrades apply
           is never stored in an RhnSet, which is used to make the impact of this call
           minimal. The correct list is showed to the user before selecting confirm,
           so the only potential issue is in viewing the SSM task log after the user
           has confirmed the operation. Again, the events themselves are correctly
           scheduled on only the systems to which they apply.

           For now, this small potential for logging inaccuracy is acceptable given the
           proxmity of this fix to the Satellite 5.3 release (as opposed to omitting
           the server association to the task entirely).

           jdobies, Aug 12, 2009
         */


        long operationId = SsmOperationManager.createOperation(user,
                "ssm.package.upgrade.operationname", RhnSetDecl.SYSTEMS.getLabel());

        // Explicitly call handle transactions here so the operation creation above
        // is persisted before the potentially long running logic below
        handleTransactions(true);

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

        Date earliest = event.getEarliest();
        Map<Long, List<Map<String, Long>>> packageListItems = event.getSysPackageSet();

        ActionManager.schedulePackageUpgrades(user, packageListItems, earliest);

        if (log.isDebugEnabled()) {
            log.debug("Time to schedule all actions: " +
                (System.currentTimeMillis() - actionStart));
        }
    }

}

