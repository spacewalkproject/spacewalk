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
package com.redhat.rhn.manager.org;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.org.SystemMigration;
import com.redhat.rhn.domain.org.SystemMigrationFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerHistoryEvent;
import com.redhat.rhn.domain.server.ServerSnapshot;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.monitoring.ServerProbeDto;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

/**
 * MigrationManager
 *
 * Handles the migration of systems from one organization to another.
 *
 * @version $Rev$
 */
public class MigrationManager extends BaseManager {

    /**
     * Migrate a set of servers to the organization specified
     * @param user Org admin that is performing the migration
     * @param toOrg The destination org
     * @param servers List of servers to be migrated
     * @return the list of server ids successfully migrated.
     */
    public static List<Long> migrateServers(User user, Org toOrg, List<Server> servers) {
        
        List<Long> serversMigrated = new ArrayList<Long>();
        
        for (Server server : servers) {
        
            Org fromOrg = server.getOrg();
            
            // Update the server to ignore entitlement checking... This is needed to ensure
            // that things such as configuration files are moved with the system, even if
            // the system currently has provisioning entitlements removed.
            server.setIgnoreEntitlementsForMigration(Boolean.TRUE);

            MigrationManager.removeOrgRelationships(user, server);
            MigrationManager.updateAdminRelationships(fromOrg, toOrg, server);
            MigrationManager.moveServerToOrg(toOrg, server);
            serversMigrated.add(server.getId());
            OrgFactory.save(toOrg);
            OrgFactory.save(fromOrg);
            ServerFactory.save(server);
            
            if (user.getOrg().equals(toOrg)) {
                server.setCreator(user);
            }
            else {
                server.setCreator(UserFactory.getInstance().findRandomOrgAdmin(toOrg));
            }
            
            
            // update server history to record the migration.
            ServerHistoryEvent event = new ServerHistoryEvent();
            event.setCreated(new Date());
            event.setServer(server);
            event.setSummary("System migration");
            String details = "From organization: " + fromOrg.getName();
            details += ", To organization: " + toOrg.getName();
            event.setDetails(details);
            server.getHistory().add(event);

            SystemMigration migration = SystemMigrationFactory.createSystemMigration();
            migration.setToOrg(toOrg);
            migration.setFromOrg(fromOrg);
            migration.setServer(server);
            migration.setMigrated(new Date());
            SystemMigrationFactory.save(migration);
        }
        return serversMigrated;
    }

    /**
     * Remove a server's relationships with it's current org.
     *
     * Used to clean the servers associations in the database in preparation for migration
     * before the server profile is moved to the migration queue.
     * 
     * @param user Org admin performing the migration.
     * @param server Server to be migrated.
     */
    public static void removeOrgRelationships(User user, Server server) {
        
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            throw new PermissionException(RoleFactory.ORG_ADMIN);
        }

        // Remove from all system groups:
        ServerGroupManager manager = ServerGroupManager.getInstance();
        for (ManagedServerGroup group : server.getManagedGroups()) {
            List<Server> tempList = new LinkedList<Server>();
            tempList.add(server);
            manager.removeServers(group, tempList);
        }

        // Remove custom data values (aka System->CustomInfo)
        ServerFactory.removeCustomDataValues(server);

        // Server relationships with guests:
        for (VirtualInstance guest : server.getGuests()) {
            server.removeGuest(guest);
        }

        // Remove existing channels
        server.getChannels().clear();
        
        // Remove existing config channels
        if (server.getConfigChannelCount() > 0) {
            server.getConfigChannels().clear();
        }
        
        // If the server has a reactivation key, remove it... It will not be valid once the
        // server is in the new org.
        Token token = TokenFactory.lookupByServer(server);
        if (token != null) {
            TokenFactory.removeToken(token);
        }

        // Remove the errata and package cache
        ErrataCacheManager.deleteNeededErrataCache(server.getId());
        ErrataCacheManager.deleteNeededPackageCache(server.getId());
        
        // Remove snapshots
        List<ServerSnapshot> snapshots = ServerFactory.listSnapshots(
                server.getOrg(), server, null, null);
        for (ServerSnapshot snapshot : snapshots) {
            ServerFactory.deleteSnapshot(snapshot);
        }
        
        // Remove monitoring probe suites:
        MonitoringManager monMgr = MonitoringManager.getInstance();
        for (ServerProbeDto dto : monMgr.probesForSystem(user, server, null)) {
            if (dto.getIsSuiteProbe()) {
                ProbeSuite suite = MonitoringFactory.lookupProbeSuiteByIdAndOrg(
                        dto.getProbeSuiteId(), server.getOrg());
                monMgr.removeServerFromSuite(suite, server, user);
            }
            else {
                Probe probe = MonitoringFactory.lookupProbeByIdAndOrg(
                        dto.getId(), server.getOrg()); 
                MonitoringFactory.deleteProbe(probe);
            }
        }
        
        SystemManager.removeAllServerEntitlements(server.getId());
    }
    
    /**
     * Update the org admin to server relationships in the originating and destination
     * orgs.
     *
     * @param fromOrg originating org where the server currently exists
     * @param toOrg destination org where the server will be migrated to
     * @param server Server to be migrated.
     */
    public static void updateAdminRelationships(Org fromOrg, Org toOrg, Server server) {
        // TODO: In some scenarios this appears to be somewhat slow, for an org with
        // around a thousand org admins and a dozen or so servers, this can take about a
        // minute to run. Probably a much more efficient way to do this. (i.e. delete
        // from rhnUserServerPerms where server_id = blah. Add a huge number of servers to
        // the mix and it could take quite some time.
        for (User admin : fromOrg.getActiveOrgAdmins()) {
            admin.removeServer(server);
            UserFactory.save(admin);
        }
        
        // add the server to all org admins in the destination org
        for (User admin : toOrg.getActiveOrgAdmins()) {
            admin.addServer(server);
            UserFactory.save(admin);
        }
    }
    
    /**
     * Move the server to the destination org.
     *
     * @param toOrg destination org where the server will be migrated to
     * @param server Server to be migrated.
     */
    public static void moveServerToOrg(Org toOrg, Server server) {
        
        // if the server has any "Locally-Managed" config files associated with it, then
        // a config channel was created for them... that channel needs to be moved to
        // the new org...
        if (server.getLocalOverrideNoCreate() != null) {
            server.getLocalOverrideNoCreate().setOrg(toOrg);
        }

        // if the server has any "Local Sandbox" config files associated with it, then
        // a config channel was created for them... that channel needs to be moved to
        // the new org...
        if (server.getSandboxOverrideNoCreate() != null) {
            server.getSandboxOverrideNoCreate().setOrg(toOrg);
        }

        // Move the server
        server.setOrg(toOrg);
    }
}
