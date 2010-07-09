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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.common.hibernate.DuplicateObjectException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 *
 * ServerGroupFactory
 * @version $Rev$
 */
public class ServerGroupFactory extends HibernateFactory {

    public static final String NULL_DESCRIPTION = "none";
    private static final ServerGroupFactory SINGLETON = new ServerGroupFactory();
    private static Logger log = Logger.getLogger(ServerGroupFactory.class);

    protected Logger getLogger() {
        return log;
    }

    /**
     * Returns the ServerGroups that the user can administer.
     * @param user User whose ServerGroups are sought.
     * @return the ServerGroups that the user can administer.
     */
    public static List listAdministeredServerGroups(User user) {
        Map params = new HashMap();
        params.put("uid", user.getId());
        return SINGLETON.listObjectsByNamedQuery(
                "ServerGroup.lookupAdministeredServerGroups", params);
    }

    /**
     * Insert or update a ServerGroup
     * @param group the ServerGroup to save
     */
    public static void save(ServerGroup group) {
        SINGLETON.saveObject(group);
    }

    /**
     * Lookup a ServerGroup by ID and organization.
     * @param id Server group id
     * @param org Organization
     * @return Server group requested
     */
    public static ManagedServerGroup lookupByIdAndOrg(Long id, Org org) {
        Session session = HibernateFactory.getSession();
        return (ManagedServerGroup)session.getNamedQuery(
                                            "ServerGroup.lookupByIdAndOrg")
            .setParameter("id", id).setParameter("org", org)
            .uniqueResult();
    }

    /**
     * Lookup a ServerGroup by Name and organization.
     * @param name Server group name
     * @param org Organization
     * @return Server group requested
     */

    public static ManagedServerGroup lookupByNameAndOrg(String name, Org org) {
        Session session = HibernateFactory.getSession();
        return (ManagedServerGroup)session.getNamedQuery(
                                            "ServerGroup.lookupByNameAndOrg")
            .setParameter("name", name).setParameter("org", org)
            .uniqueResult();
    }
    /**
     * Returns an EntitlementServerGroup for the given org
     * and servergroup type.
     * @param org the org to look at
     * @param typeIn the server group type to look at
     * @return the Server group requested.
     */
    public static EntitlementServerGroup lookupEntitled(Org org,
                                                    ServerGroupType typeIn) {
        if (typeIn == null) {
            String msg = "Invalid argument Null value  passed in for typeIn argument." +
                            " This method only looks up Entitled servergroups.";
            throw new IllegalArgumentException(msg);
        }
        Session session = HibernateFactory.getSession();
        EntitlementServerGroup existingGroup = (EntitlementServerGroup)
                session.getNamedQuery("ServerGroup.lookupByTypeAndOrg")
                                        .setParameter("groupType", typeIn)
                                        .setParameter("org", org)
                                        .uniqueResult();
        return existingGroup;
    }

    /**
     * Retrieves a specific group from the server groups for this org
     * @param ent The entitlement of the desired servergroup
     * @param org The org in which the server group belongs
     * @return Returns the server group if found, null otherwise
     */
    public static EntitlementServerGroup lookupEntitled(Entitlement ent,
                                                            Org org) {
        Map qryParams = new HashMap();
        qryParams.put("label", ent.getLabel());
        qryParams.put("org", org);
        return (EntitlementServerGroup) SINGLETON.lookupObjectByNamedQuery(
                "ServerGroup.lookupByTypeLabelAndOrg",
                qryParams);
    }

    /**
     * Remove an server group
     * @param group to remove
     */
    public static void remove(ServerGroup group) {
        if (group != null) {
            SINGLETON.removeObject(group);
        }
    }

    /**
     * Creates a new ServerGroup object and
     * persists it to the database before returning it
     * @param name name of the server group (cant be null)
     * @param description description of servergroup (non-null)
     * @param org the org of the server group
     * @return the created server group.
     */
    public static ManagedServerGroup create(String name,
                                String description,
                                Org org) {
        if (StringUtils.isBlank(name)) {
            String msg = "ServerGroup create exception. " +
                           "Null value provided for the non null field -> 'name'.";
            throw new IllegalArgumentException(msg);
        }

        if (StringUtils.isBlank(description)) {
            description = NULL_DESCRIPTION;
        }


        if (org == null) {
            String msg = "ServerGroup create exception. " +
                    "Null value provided for the non null field -> 'org'.";
            throw new IllegalArgumentException(msg);
        }

        if (lookupByNameAndOrg(name, org) == null) {
            ManagedServerGroup sg = new ManagedServerGroup();
            sg.setName(name);
            sg.setDescription(description);
            sg.setOrg(org);
            save(sg);
            return sg;
        }
        String msg = "Duplicate server group requested to be created.." +
                                "Server Group with name -[" + name + "] and" +
                                " org - [" + org.getName() + "] already exists";

        throw new DuplicateObjectException(msg);
    }

    /**
     * Returns a list of ServerGroups that have NO administrators
     * @param org org of the current user.
     * @return the list of servergroups without any admins.
     */
    public static List listNoAdminGroups(Org org) {
        Map params = new HashMap();
        params.put("org_id", org.getId());
        return SINGLETON.listObjectsByNamedQuery(
                "ServerGroup.lookupGroupsWithNoAssocAdmins", params);
    }

    /**
     * Returns the admins of a given serverGroup.
     * @param sg the serverGroup to find the admins of
     * @return list of User objects that can administer the server group
     */
    public static List listAdministrators(ServerGroup sg) {
        Map params = new HashMap();
        params.put("sgid", sg.getId());
        params.put("org_id", sg.getOrg().getId());
        return SINGLETON.listObjectsByNamedQuery(
                "ServerGroup.lookupAdministrators", params);
    }

    /**
     * Returns the servers of a given serverGroup.
     * @param sg the serverGroup to find the servers of
     * @return list of Server objects that are part of
     *                      the server group
     */
    public static List listServers(ServerGroup sg) {
        Map params = new HashMap();
        params.put("sgid", sg.getId());
        params.put("org_id", sg.getOrg().getId());
        List ids = SINGLETON.listObjectsByNamedQuery(
                "ServerGroup.lookupServerIds", params);
        List servers = new ArrayList(ids.size());
        for (Iterator itr = ids.iterator(); itr.hasNext();) {
            Number id = (Number) itr.next();
            servers.add(ServerFactory.lookupById(new Long(id.longValue())));
        }
        return servers;
    }

    /**
     * Returns the value listed by current members column
     * on the rhnServerGroup table.. This was made as a query
     * instead of mapping because this column is only updated
     * by the stored procedures dealing with entitlements..
     * @param sg the server group to get the current members of
     * @return the value of the the currentmemebers column.
     */
    public static Long getCurrentMembers(ServerGroup sg) {
        Map params = new HashMap();
        params.put("sgid", sg.getId());
        Object obj  = SINGLETON.lookupObjectByNamedQuery(
                "ServerGroup.lookupCurrentMembersValue", params);
        Number members = (Number) obj;
        if (members == null) {
           return new Long(0);
        }
        return new Long(members.longValue());
    }

    /**
     * Returns the list of Entitlement ServerGroups  associated to a server.
     * @param s the server to find the server groups of
     * @return list of EntitlementServerGroup objects that are associated to
     *                      the server.
     */
    public static List<EntitlementServerGroup> listEntitlementGroups(Server s) {
        return (List<EntitlementServerGroup>)
                    listServerGroups(s, "ServerGroup.lookupEntitlementGroupsByServer");
    }

    /**
     * Returns the list of Managed ServerGroups  associated to a server.
     * @param s the server to find the server groups of
     * @return list of ManagedServerGroup objects that are associated to
     *                      the server.
     */
    public static List<ManagedServerGroup> listManagedGroups(Server s) {
        return (List<ManagedServerGroup>)listServerGroups(s,
                "ServerGroup.lookupManagedGroupsByServer");
    }

    private static List listServerGroups(Server s, String queryName) {
        Map params = new HashMap();
        params.put("id", s.getId());
        return  SINGLETON.listObjectsByNamedQuery(queryName, params);
    }

    /**
     * Returns the list of Entitlement ServerGroups  associated to a server.
     * @param org the Org to find the server groups of
     * @return list of EntitlementServerGroup objects that are associated to
     *                      the org.
     */
    public static List<EntitlementServerGroup> listEntitlementGroups(Org org) {
        return (List<EntitlementServerGroup>)listServerGroups(org,
                            "ServerGroup.lookupEntitlementGroupsByOrg");
    }

    /**
     * Returns the list of Managed ServerGroups  associated to a server.
     * @param org the org to find the server groups of
     * @return list of ManagedServerGroup objects that are associated to
     *                      the org.
     */
    public static List<ManagedServerGroup> listManagedGroups(Org org) {
        return (List<ManagedServerGroup>)listServerGroups(org,
                                "ServerGroup.lookupManagedGroupsByOrg");
    }

    private static List<? extends ServerGroup> listServerGroups(Org org, String queryName) {
        Map params = new HashMap();
        params.put("org", org);
        return  SINGLETON.listObjectsByNamedQuery(queryName, params);
    }

    /**
     * Returns a list of active server Ids associated to this servergroup
     * Here active implies that the system has checked in after
     * sysdate - threshold
     * @param sg the server group to check systems on
     * @param threshold the threshold to check on
     * @return the server ids
     */
    public static List <Long> listActiveServerIds(ServerGroup sg, Long threshold) {
        return listServerIds(sg, threshold, "ServerGroup.lookupActiveServerIds");
    }

    /**
     * Returns a list of Inactive server Ids associated to this servergroup
     * Here inactive implies that the system has checked in before
     * sysdate - threshold
     * @param sg the server group to check systems on
     * @param threshold the threshold to check on
     * @return the server ids
     */
    public static List <Long> listInactiveServerIds(ServerGroup sg, Long threshold) {
        return listServerIds(sg, threshold, "ServerGroup.lookupInactiveServerIds");    }

    private static List <Long> listServerIds(ServerGroup sg, Long threshold, String query) {
        Map params = new HashMap();
        params.put("sgid", sg.getId());
        params.put("threshold", threshold);
        return  SINGLETON.listObjectsByNamedQuery(query, params);
    }
}
