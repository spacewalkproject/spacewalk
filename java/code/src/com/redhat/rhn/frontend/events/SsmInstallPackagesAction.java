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
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.dto.EssentialServerDto;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * Schedules package installations on systems in the SSM.
 */
public class SsmInstallPackagesAction extends SsmPackagesAction {

    protected String getOperationName() {
        return "ssm.package.install.operationname";
    }

    protected List<Long> getAffectedServers(SsmPackageEvent event, User u) {
        SsmInstallPackagesEvent sipe = (SsmInstallPackagesEvent) event;
        Long channelId = sipe.getChannelId();

        List<EssentialServerDto> servers = SystemManager.systemsSubscribedToChannelInSet(
                        channelId, u, SetLabels.SYSTEM_LIST);

        // Create one action for all servers to which the packages are installed
        List<Long> serverIds = new LinkedList<Long>();
        for (EssentialServerDto dto : servers) {
            serverIds.add(dto.getId());
        }
        return serverIds;
    }

    protected List<Action> doSchedule(SsmPackageEvent event, User user, List<Long> sids,
                    Date earliest, ActionChain actionChain) {
        SsmInstallPackagesEvent sipe = (SsmInstallPackagesEvent) event;

        Set<String> data = sipe.getPackages();
        // Convert the package list to domain objects
        List<PackageListItem> pkgListItems = new ArrayList<PackageListItem>(data.size());
        for (String key : data) {
            pkgListItems.add(PackageListItem.parse(key));
        }

        // Convert to list of maps
        List<Map<String, Long>> packageListData = PackageListItem
                        .toKeyMaps(pkgListItems);

        return ActionChainManager.schedulePackageInstall(user, sids, packageListData,
            earliest, actionChain);
    }

}
