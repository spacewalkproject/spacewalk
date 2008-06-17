/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.manager.org;

import java.util.LinkedList;
import java.util.List;

import com.redhat.rhn.common.security.PermissionException;

import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;

import com.redhat.rhn.domain.role.RoleFactory;

import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.VirtualInstance;

import com.redhat.rhn.domain.user.User;

import com.redhat.rhn.frontend.dto.monitoring.ServerProbeDto;

import com.redhat.rhn.manager.BaseManager;

import com.redhat.rhn.manager.monitoring.MonitoringManager;

import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;


/**
 * MigrationManager
 *
 * Handles the migration of systems from one organization to another.
 *
 * @version $Rev$
 */
public class MigrationManager extends BaseManager {

    /**
     * Remove a server's relationships with it's current org.
     *
     * Used to clean the servers assocations in the database in preparation for migration
     * before the server profile is moved to the migration queue.
     * 
     * @param user Org admin performing the migration.
     * @param server Server to be migrated.
     */
    public static void removeOrgRelationships(User user, Server server) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            throw new PermissionException(RoleFactory.ORG_ADMIN);
        }

        // Perform operations that have to be done outside Hibernate first:
        SystemManager.removeAllServerEntitlements(server.getId());
        
        // Remove from all system groups:
        ServerGroupManager manager = ServerGroupManager.getInstance();
        for (ManagedServerGroup group : server.getManagedGroups()) {
            List<Server> tempList = new LinkedList<Server>();
            tempList.add(server);
            manager.removeServers(group, tempList, user);
        }

        // Sever relationships with guests:
        for (VirtualInstance guest : server.getGuests()) {
            server.removeGuest(guest);
        }

        // Remove monitoring probe suites:
        MonitoringManager monMgr = MonitoringManager.getInstance();
        for (ServerProbeDto dto : monMgr.probesForSystem(user, server, null)) {
            if (dto.getIsSuiteProbe()) {
                ProbeSuite suite = monMgr.lookupProbeSuite(dto.getProbeSuiteId(),
                        user);
                monMgr.removeServerFromSuite(suite, server, user);
            }
            else {
                /*
                Probe probe = monMgr.lookupProbe(user, dto.getId());
                monMgr.deleteProbe(probe, user);
                */
            }
        }

        // Give all the new org admins rights to manage the server:
        /*
        for (User u : newOrgAdmins) {
            u.addServer(server);
            UserFactory.save(u);
        }
        */

        // Remove rights from the old org admins:
//        List<User> oldOrgAdmins = UserFactory.getInstance().findAllOrgAdmins(oldOrg);
        /*
        for (User u : oldOrgAdmins) {
            u.removeServer(server);
            UserFactory.save(u);
        }
        */
    }
}
