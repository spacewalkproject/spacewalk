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
import java.util.List;
import java.util.Map;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.action.ActionManager;

/**
 * Handles removing packages from servers in the SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmUpgradePackagesEvent
 */
public class SsmUpgradePackagesAction extends SsmPackagesAction {

    protected String getOperationName() {
        return "ssm.package.upgrade.operationname";
    }

    protected List<Long> getAffectedServers(SsmPackageEvent event, User u) {
        SsmUpgradePackagesEvent supe = (SsmUpgradePackagesEvent) event;
        List<Long> sids = new ArrayList<Long>();
        sids.addAll(supe.getSysPackageSet().keySet());
       return sids;
    }

    protected List<Action> doSchedule(SsmPackageEvent event,
                                      User user,
                                      List<Long> sids,
                                      Date earliest) {

        SsmUpgradePackagesEvent supe = (SsmUpgradePackagesEvent) event;
        Map<Long, List<Map<String, Long>>> packageListItems = supe.getSysPackageSet();

        return ActionManager.schedulePackageUpgrades(user, packageListItems, earliest);

    }

}
