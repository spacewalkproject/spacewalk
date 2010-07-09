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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ServerGroupManager
 * @version $Rev$
 */
public class ServerGroupManager {

    private static final ServerGroupManager MANAGER = new ServerGroupManager();

    /**
     * Singleton Instance to get manager object
     * @return an instance of the manager
     */
    public static ServerGroupManager getInstance() {
        return MANAGER;
    }
    /**
     * Private constructor.
     */
    private ServerGroupManager() {
    }

    /**
     * Lookup a ServerGroup by ID and organization.
     * @param id Server group id
     * @param user logged in user needed for authentication
     * @return Server group requested
     */
    public ManagedServerGroup lookup(Long id, User user) {
        ManagedServerGroup sg = ServerGroupFactory.
                                lookupByIdAndOrg(id, user.getOrg());
        if (sg == null) {
            validateAccessCredentials(user, sg, id.toString());
        }
        else {
            validateAccessCredentials(user, sg, sg.getName());
        }

        return sg;
    }

    /**
     * Lookup a ServerGroup by ID and organization.
     * @param name Server group name
     * @param user logged in user needed for authentication
     * @return Server group requested
     */
    public ManagedServerGroup lookup(String name, User user) {
        ManagedServerGroup sg = ServerGroupFactory.
                                lookupByNameAndOrg(name, user.getOrg());
        validateAccessCredentials(user, sg, name);
        return sg;
    }

    /**
     * Returns an EntitlementServerGroup for a given entitlement type
     * @param ent the entitlement type desired
     * @param user logged in user needed for authentication -
     *                           needs to be ORG Admin
     * @return the Server group requested.
     */
    public EntitlementServerGroup lookupEntitled(Entitlement ent, User user) {
        validateOrgAdminCredentials(user);
        EntitlementServerGroup sg = ServerGroupFactory.
                                lookupEntitled(ent, user.getOrg());

        return sg;
    }

    /**
     * Returns an EntitlementServerGroup for a given server group type
     * @param typeIn the servergroup type desired
     * @param user logged in user needed for authentication -
     *                           needs to be ORG Admin
     * @return the Server group requested.
     */
    public EntitlementServerGroup lookupEntitled(ServerGroupType typeIn,
                                                                User user) {
        validateOrgAdminCredentials(user);
        EntitlementServerGroup sg = ServerGroupFactory.
                                lookupEntitled(user.getOrg(), typeIn);

        return sg;
    }

    /**
     * Returns true if the the given user can
     * administer server groups..
     * This should be the baseline for us to load activation keys.
     * @param user the user to check on
     * @param group the server group object to authenticate.
     * @return true if a key can be administered. False otherwise.
     */
    public boolean canAccess(User user, ServerGroup group) {
        if (user == null || group == null) {
            return false;
        }
        if (!user.getOrg().equals(group.getOrg())) {
            return false;
        }
        SelectMode m = ModeFactory.getMode("SystemGroup_queries", "is_visible");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sgid", group.getId());
        List result = m.execute(params);
        return result.size() > 0;
    }

    /**
     * validates that the given user can access
     * the given ServerGroup object. Raises a permission exception
     * if the combination is invalid..
     * @param user the user to authenticate
     * @param group the servergroup to authenticate
     * @param groupIdentifier id or group name to use when reporting exception
     * (group could be null)
     */
    public void validateAccessCredentials(User user,
                                    ServerGroup group, String groupIdentifier) {
        if (group == null || (group.isManaged() && !canAccess(user, group))) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e =
                new LookupException("Unable to locate or access server group: " +
                    groupIdentifier);
            e.setLocalizedTitle(ls.getMessage("lookup.servergroup.title"));
            e.setLocalizedReason1(ls.getMessage("lookup.servergroup.reason1"));
            e.setLocalizedReason2(ls.getMessage("lookup.servergroup.reason2"));
            throw e;
        }
    }

    /**
     * validates that the given user can administer
     * a server group.  Raises a permission exception if administering
     *  is Not possible
     * @param user the user to authenticate
     */
    public void validateAdminCredentials(User user) {
        if (!user.hasRole(RoleFactory.SYSTEM_GROUP_ADMIN)) {
            String msg = "The desired operation cannot be performed since the user" +
                            "[" + user + "] does not have the system group admin role";
            throw new PermissionException(msg);
        }
    }


    /**
     * validates that the given user can administer
     * or lookup an entitled server group.
     *  Raises a permission exception if administering
     *  is Not possible
     * @param user the user to authenticate
     */
    public void validateOrgAdminCredentials(User user) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            String msg = "The desired operation cannot be performed since the user" +
                            "[" + user + "] does not have the Org Admin role";
            throw new PermissionException(msg);
        }
    }
    /**
     * Removes an ServerGroup.
     * @param user user object needed for authentication
     * @param group the group to remove
     */
    public void remove(User user, ManagedServerGroup group) {
        validateAccessCredentials(user, group, group.getName());
        validateAdminCredentials(user);
        removeServers(group, listServers(group), user);
        dissociateAdmins(group, group.getAssociatedAdminsFor(user), user);
        ServerGroupFactory.remove(group);
    }

    /**
     * Create a new Server group
     * @param user user needed for authentication
     * @param name the name of the server group
     * @param description the description of the server group
     * @return the created server group.
     */
    public ManagedServerGroup create(User user, String name, String description) {
        validateAdminCredentials(user);
        ManagedServerGroup sg = ServerGroupFactory.create(name, description,
                                                                user.getOrg());
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            sg.getAssociatedAdminsFor(user).add(user);
            ServerGroupFactory.save(sg);
            UserFactory.save(user);
        }
        return sg;
    }

    /**
     * Associates/Disocciates a list of admins to a server group
     * by using User's login name.. This method had to be added
     * to give access to a list of users to a
     * server group admin. By default one needs Org Admin role
     * to access/acquire user objects other than the loggedInUser.
     * However according to the UI, Server Group Admin
     * needs to be able to assign Users to Groups.
     *  (even if he cannot access the User's details)
     * However our ServerGroup instances need full blown user objects
     *  to get mapped correctly.. Due to which this method was added.
     * @param group the Servergroup to associate/dissociate users
     * @param adminLogins the login names of the users to associate/dissociate
     * @param associate true if we want to associate false otherwise.
     * @param loggedInUser the logged in user.
     */

    public void associateOrDissociateAdminsByLoginName(ManagedServerGroup group,
                                Collection adminLogins,
                                boolean associate,
                                User loggedInUser) {
        validateAccessCredentials(loggedInUser, group, group.getName());
        validateAdminCredentials(loggedInUser);
        List admins = new LinkedList();
        for (Iterator itr = adminLogins.iterator(); itr.hasNext();) {
            String login = (String) itr.next();
            User admin = UserFactory.lookupByLogin(login);
            if (admin == null || !loggedInUser.getOrg().equals(admin.getOrg())) {
                LocalizationService ls = LocalizationService.getInstance();
                LookupException e = new LookupException("Could not find user " + login);
                e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.user"));
                e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.user"));
                e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.user"));
                throw e;
            }
            admins.add(admin);
        }
        if (associate) {
            associateAdmins(group, admins, loggedInUser);
        }
        else {
            dissociateAdmins(group, admins, loggedInUser);
        }
    }
    /**
     * Associates a bunch of administrators to a server group
     * @param sg the server group to process
     * @param admins a collection of users to add as administrators
     * @param loggedInUser the loggedInUser needed for credentials
     */
    public void associateAdmins(ManagedServerGroup sg, Collection admins,
                                                        User loggedInUser) {
        validateAccessCredentials(loggedInUser, sg, sg.getName());
        validateAdminCredentials(loggedInUser);
        Set adminSet = sg.getAssociatedAdminsFor(loggedInUser);
        processAdminList(sg, admins, loggedInUser);
        adminSet.addAll(admins);
        ServerGroupFactory.save(sg);
        UserFactory factory = UserFactory.getInstance();
        for (Iterator itr = admins.iterator(); itr.hasNext();) {
            User u = (User) itr.next();
            factory.syncServerGroupPerms(u);
        }
    }

    /**
     * Disssociates a bunch of administrators from a server group
     * @param sg the server group to process
     * @param admins a collection of administrators to deassociate
     * @param loggedInUser the loggedInUser needed for credentials
     */
    public void dissociateAdmins(ManagedServerGroup sg, Collection admins,
                                                    User loggedInUser) {
        validateAccessCredentials(loggedInUser, sg, sg.getName());
        validateAdminCredentials(loggedInUser);

        Set adminSet = sg.getAssociatedAdminsFor(loggedInUser);
        processAdminList(sg, admins, loggedInUser);
        admins.remove(loggedInUser); //can't disassociate thyself.
        adminSet.removeAll(admins);
        ServerGroupFactory.save(sg);
        for (Iterator itr = admins.iterator(); itr.hasNext();) {
            User u = (User) itr.next();
            UserFactory.save(u);
        }
    }
    /**
     * @param sg the server group to process
     * @param admins a collection of users to authenticate
     * @param loggedInUser the loggedInUser needed for credentials
     */
    private void processAdminList(ServerGroup sg, Collection admins,
            User loggedInUser) {
        for (Iterator itr = admins.iterator(); itr.hasNext();) {
            User user = (User) itr.next();
            if (!user.getOrg().equals(loggedInUser.getOrg())) {
                String msg = "Invalid Administrator.[" + user + "]." +
                                "Unable to add the given administrator to" +
                            " the servergroup [" + sg + "] because the org of" +
                            " the user does NOT belong to the org of the server group";
                throw new PermissionException(msg);
            }
            if (user.hasRole(RoleFactory.ORG_ADMIN)) {
                //we are not in the business of
                //adding or removing org admins..
                itr.remove();
            }
        }
    }

    /**
     * Associates a bunch of servers to a server group
     * @param sg the server group to process
     * @param servers a collection of servers to add.
     * @param loggedInUser the loggedInUser needed for credentials
     */
    public void addServers(ServerGroup sg, Collection servers, User loggedInUser) {
        validateAccessCredentials(loggedInUser, sg, sg.getName());
        validateAdminCredentials(loggedInUser);
        for (Iterator itr = servers.iterator(); itr.hasNext();) {
            Server s = (Server) itr.next();
            SystemManager.addServerToServerGroup(s, sg);
        }
    }

    /**
     * Dissociates a bunch of servers from a server group
     * @param sg the server group to process
     * @param servers a collection of servers to dissociate
     * @param loggedInUser the loggedInUser needed for credentials
     */
    public void removeServers(ServerGroup sg, Collection servers,
                                                        User loggedInUser) {
        validateAccessCredentials(loggedInUser, sg, sg.getName());
        validateAdminCredentials(loggedInUser);
        removeServers(sg, servers);
    }

    /**
     * Dissociates a bunch of servers from a server group.
     * **WARNING** This method does not validate the user's access or
     * admin credentials; therefore, it should be used with caution.
     * @param sg the server group to process
     * @param servers a collection of servers to dissociate
     */
    public void removeServers(ServerGroup sg, Collection servers) {
        for (Iterator itr = servers.iterator(); itr.hasNext();) {
            Server s = (Server) itr.next();
            SystemManager.removeServerFromServerGroup(s, sg);
        }
    }

    /**
     * Returns the admins of a given servergroup. This list includes
     * ORG ADMINS + Associated Admins.. so this is different from
     * sg.getAssociatedAdmins()
     * @param sg the server group that you want the admin list for.
     * @param loggedInUser the loggedInUser needed for credentials
     * @return list of User objects that can administer the server group
     */
    public List listAdministrators(ManagedServerGroup sg, User loggedInUser) {
        validateAccessCredentials(loggedInUser, sg, sg.getName());
        validateAdminCredentials(loggedInUser);
        return ServerGroupFactory.listAdministrators(sg);
    }


    /**
     * Returns a list of servergroups that have NO administrators
     * associated to it.
     * Note this requires ORG_ADMIN access so that the
     * administrator can access ALL servergroups.
     * @param user ORG_ADMIN user.
     * @return a list of server groups
     */
    public List listNoAdminGroups(User user) {
        if (!user.hasRole(RoleFactory.ORG_ADMIN)) {
            String msg = "The desired operation cannot be performed since the user" +
                            "[" + user + "] does not have the org  admin role";
            throw new PermissionException(msg);
        }
        return ServerGroupFactory.listNoAdminGroups(user.getOrg());
    }

    /**
     * Returns the servers of a given servergroup
     * @param sg the server group to find the servers of
     * @return list of Server objects that are a part of the given server group.
     */
    public List<Server> listServers(ServerGroup sg) {
        return ServerGroupFactory.listServers(sg);
    }

    /**
     * List all servers that have checked in within a X days
     * @param sg the sever group
     * @param threshold the number of days a system needs to have checked in by
     * @return list of system ids
     */
    public List<Long> listActiveServers(ServerGroup sg, Long threshold) {
        return ServerGroupFactory.listActiveServerIds(sg, threshold);
    }

    /**
     * List all servers that have not checked in in X days
     * @param sg the sever group
     * @param threshold the number of days a system needs to have not checked in by
     * @return list of system ids
     */
    public List<Long> listInactiveServers(ServerGroup sg, Long threshold) {
        return ServerGroupFactory.listInactiveServerIds(sg, threshold);
    }
}
