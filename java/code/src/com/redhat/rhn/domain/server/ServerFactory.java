/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.client.ClientCertificate;
import com.redhat.rhn.common.client.InvalidCertificateException;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageEvrFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.HistoryEvent;
import com.redhat.rhn.frontend.dto.SoftwareCrashDto;
import com.redhat.rhn.frontend.xmlrpc.ChannelSubscriptionException;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.UpdateBaseChannelCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;

import java.sql.Types;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * ServerFactory - the singleton class used to fetch and store
 * com.redhat.rhn.domain.server.Server objects from the database.
 * @version $Rev$
 */
public class ServerFactory extends HibernateFactory {

    private static ServerFactory singleton = new ServerFactory();
    private static Logger log = Logger.getLogger(ServerFactory.class);

    private ServerFactory() {
        super();
    }

    /**
     * Looks up the CustomDataValue given CustomDataKey and Server objects.
     * @param key The Key for the value you would like to lookup
     * @param server The Server in question
     * @return Returns the CustomDataValue object if found, null if not.
     */
    protected static CustomDataValue getCustomDataValue(CustomDataKey key,
            Server server) {
        // Make sure we didn't recieve any nulls
        if (key == null || server == null) {
            return null;
        }

        Session session = HibernateFactory.getSession();
        return (CustomDataValue) session.getNamedQuery(
                "CustomDataValue.findByServerAndKey").setEntity("server",
                        server).setEntity("key", key)
                        // Retrieve from cache if there
                        .setCacheable(true).uniqueResult();
    }

    /**
     * Remove the custom data values associated with a server.
     * @param server The server
     */
    public static void removeCustomDataValues(Server server) {
        for (Object value : server.getCustomDataValues()) {
            singleton.removeObject(value);
        }
        server.getCustomDataValues().clear();
    }

    /**
     * Remove the custom data value associated with the custom data key
     * provided for the given server.
     * @param server The server
     * @param key The custom data key
     */
    public static void removeCustomDataValue(Server server, CustomDataKey key) {
        CustomDataValue value = server.getCustomDataValue(key);
        server.getCustomDataValues().remove(value);
        if (value != null) {
            singleton.removeObject(value);
        }
    }

    /**
     * Lookup all CustomDataValues associated with the CustomDataKey.
     * @param key The Key for the values you would like to lookup
     * @return List of custom data values.
     */
    public static List<CustomDataValue> lookupCustomDataValues(CustomDataKey key) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("key", key);
        return singleton.listObjectsByNamedQuery(
                "CustomDataValue.findByKey", params);
    }

    /**
     * Lookup all the systems with the specified CustomDataKey.
     * @param userId The User ID of the user doing the query
     * @param cikid The ID of the Key for the values you would like to lookup
     * @return List of systems
     */
    public static List lookupServersWithCustomKey(Long userId, Long cikid) {
        SelectMode m = ModeFactory.getMode("System_queries",
                "users_systems_with_value_for_key");
        Map inParams = new HashMap();

        inParams.put("user_id", userId);
        inParams.put("cikid", cikid);

        return m.execute(inParams);
    }

    /**
     * Lookup all storage Devices associated with the server.
     * @param s The server for the values you would like to lookup
     * @return List of devices
     */
    public static List<Device> lookupStorageDevicesByServer(Server s) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("server", s);
        return singleton.listObjectsByNamedQuery(
                "Device.findStorageByServer", params);
    }

    /**
     * Get the Logger for the derived class so log messages show up on the
     * correct class
     */
    @Override
    protected Logger getLogger() {
        return log;
    }

    /**
     * Create a new Server from scratch
     * @return the Server created
     */
    public static Server createServer() {
        return new Server();
    }

    /**
     * Adds a Server to a group.
     * @param serverIn The server to add
     * @param serverGroupIn The group to add the server to
     */
    public static void addServerToGroup(Server serverIn,
            ServerGroup serverGroupIn) {
        Long sid = serverIn.getId();
        Long sgid = serverGroupIn.getId();

        CallableMode m = ModeFactory.getCallableMode("System_queries",
                "insert_into_servergroup_maybe");
        Map inParams = new HashMap();
        Map outParams = new HashMap();

        inParams.put("server_id", sid);
        inParams.put("server_group_id", sgid);
        // Outparam
        outParams.put("retval", new Integer(Types.NUMERIC));

        m.execute(inParams, outParams);
    }

    /**
     * Removes a Server from a group
     * @param sid The server id to remove
     * @param sgid The group id to remove the server from
     */
    public static void removeServerFromGroup(Long sid, Long sgid) {
        CallableMode m = ModeFactory.getCallableMode("System_queries",
                "delete_from_servergroup");
        Map inParams = new HashMap();
        Map outParams = new HashMap();

        inParams.put("server_id", sid);
        inParams.put("server_group_id", sgid);
        // Outparam
        // outParams.put("retval", new Integer(Types.NUMERIC));

        m.execute(inParams, outParams);
    }

    /**
     * Lookup a Server with the ClientCertificate.
     * @param clientcert ClientCertificate for the server wanted.
     * @return the Server found if certificate is valid, null otherwise.
     * @throws InvalidCertificateException thrown if certificate is invalid.
     */
    public static Server lookupByCert(ClientCertificate clientcert)
            throws InvalidCertificateException {

        String idstr = clientcert.getValueByName(ClientCertificate.SYSTEM_ID);
        String[] parts = StringUtils.split(idstr, '-');
        if (parts != null && parts.length > 0) {
            Long sid = new Long(parts[1]);
            Server s = ServerFactory.lookupById(sid);
            if (s != null) {
                clientcert.validate(s.getSecret());
                return s;
            }
        }

        return null;
    }

    /**
     * Lookup a Server by their id
     * @param id the id to search for
     * @param orgIn Org who owns the server
     * @return the Server found (null if not or not member if orgIn)
     */
    public static Server lookupByIdAndOrg(Long id, Org orgIn) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("sid", id);
        params.put("orgId", orgIn.getId());
        return (Server) singleton.lookupObjectByNamedQuery(
                "Server.findByIdandOrgId", params);
    }

    /**
     * Looks up server objects from the given list of server IDs.
     *
     * If more than 1000 servers are present in the list we'll split it into
     * chunks as this can cause problems on Oracle.
     *
     * @param serverIds List of server IDs.
     * @param user who wants to lookup the Server
     * @return list of server objects
     */
    public static List<Server> lookupByIdsAndUser(List<Long> serverIds, User user) {
        Session session = HibernateFactory.getSession();
        Query query = session.getNamedQuery("Server.findByIdsAndOrgId")
                .setParameter("orgId", user.getOrg().getId());
        if (serverIds.size() < 1000) {
            query.setParameterList("serverIds", serverIds);
            return query.list();
        }

        List<Server> results = new LinkedList<Server>();
        List<Long> blockOfIds = new LinkedList<Long>();
        for (Long sid : serverIds) {
            blockOfIds.add(sid);
            if (blockOfIds.size() == 999) {
                query.setParameterList("serverIds", blockOfIds);
                results.addAll(query.list());
                blockOfIds = new LinkedList<Long>();
            }
        }
        // Deal with the remainder:
        if (blockOfIds.size() > 0) {
            query.setParameterList("serverIds", blockOfIds);
            results.addAll(query.list());
        }
        return results;
    }

    /**
     * Lookup a Server by their id
     * @param id the id to search for
     * @return the Server found
     */
    public static Server lookupById(Long id) {
        return (Server) HibernateFactory.getSession().get(Server.class, id);
    }

    /**
     * Lookup Servers by their ids
     * @param ids the ids to search for
     * @return the Servers found
     */
    public static List<Server> lookupByIds(List<Long> ids) {
        Session session = HibernateFactory.getSession();
        Query query = session.getNamedQuery("Server.findByIds");
        List<Server> results = new LinkedList<Server>();

        if (ids.size() == 0) {
            return results;
        }

        if (ids.size() < 1000) {
            query.setParameterList("serverIds", ids);
            return query.list();
        }

        List<Long> blockOfIds = new LinkedList<Long>();
        for (Long sid : ids) {
            blockOfIds.add(sid);
            if (blockOfIds.size() == 999) {
                query.setParameterList("serverIds", blockOfIds);
                results.addAll(query.list());
                blockOfIds = new LinkedList<Long>();
            }
        }
        // Deal with the remainder:
        if (blockOfIds.size() > 0) {
            query.setParameterList("serverIds", blockOfIds);
            results.addAll(query.list());
        }
        return results;
    }

    /**
     * Lookup a ServerGroupType by its label
     * @param label The label to search for
     * @return The ServerGroupType
     */
    public static ServerGroupType lookupServerGroupTypeByLabel(String label) {
        ServerGroupType retval = (ServerGroupType) HibernateFactory
                .getSession().getNamedQuery("ServerGroupType.findByLabel")
                .setString("label", label)
                // Retrieve from cache if there
                .setCacheable(true).uniqueResult();
        return retval;

    }

    /**
     * Insert or Update a Server.
     * @param serverIn Server to be stored in database.
     */
    public static void save(Server serverIn) {
        if (serverIn.isSatellite()) {
            SatelliteServer ss = (SatelliteServer) serverIn;
            PackageEvrFactory.lookupOrCreatePackageEvr(ss.getVersion());
        }

        singleton.saveObject(serverIn);
        updateServerPerms(serverIn);
    }

    /**
     * Save a custom data key
     * @param keyIn the key to save
     */
    public static void saveCustomKey(CustomDataKey keyIn) {
        singleton.saveObject(keyIn);
    }

    /**
     * Remove a custom data key. This will also remove all systems'
     * values for the key.
     * @param keyIn the key to remove
     */
    public static void removeCustomKey(CustomDataKey keyIn) {

        // If the CustomKey is being removed, any system that has a
        // "Custom Info" value associated with it must have that
        // value removed...
        List<CustomDataValue> values = lookupCustomDataValues(keyIn);
        for (Iterator itr = values.iterator(); itr.hasNext();) {
            CustomDataValue value = (CustomDataValue) itr.next();
            singleton.removeObject(value);
        }

        singleton.removeObject(keyIn);
    }

    /**
     * Remove proxy info object associated to the server.
     * @param server the server to deProxify
     */
    public static void deproxify(Server server) {
        if (server.getProxyInfo() != null) {
            ProxyInfo info = server.getProxyInfo();
            singleton.removeObject(info);
            server.setProxyInfo(null);
        }
    }

    /**
     * Deletes a server
     *
     * @param server The server to delete
     */
    public static void delete(Server server) {
        HibernateFactory.getSession().evict(server);
        CallableMode m = ModeFactory.getCallableMode("System_queries",
                "delete_server");
        Map in = new HashMap();
        in.put("server_id", server.getId());
        m.execute(in, new HashMap());
        HibernateFactory.getSession().evict(server);
    }

    private static void updateServerPerms(Server server) {
        CallableMode m = ModeFactory.getCallableMode("System_queries",
                "update_perms_for_server");
        Map inParams = new HashMap();
        inParams.put("sid", server.getId());
        m.execute(inParams, new HashMap());
    }

    /**
     * Lookup a ServerArch by its label
     * @param label The label to search for
     * @return The ServerArch
     */
    public static ServerArch lookupServerArchByLabel(String label) {
        Session session = HibernateFactory.getSession();
        return (ServerArch) session.getNamedQuery("ServerArch.findByLabel")
                .setString("label", label)
                // Retrieve from cache if there
                .setCacheable(true).uniqueResult();
    }

    /**
     * Lookup a CPUArch by its name
     * @param name The name to search for
     * @return The CPUArch
     */
    public static CPUArch lookupCPUArchByName(String name) {
        Session session = HibernateFactory.getSession();
        return (CPUArch) session.getNamedQuery("CPUArch.findByName")
                .setString("name", name)
                // Retrieve from cache if there
                .setCacheable(true).uniqueResult();
    }

    /**
     * Returns a list of Servers which are compatible with the given server.
     * @param user User owner
     * @param server Server whose profiles we want.
     * @return a list of Servers which are compatible with the given server.
     */
    public static List<Map<String, Object>> compatibleWithServer(User user, Server server) {
        SelectMode m = ModeFactory.getMode("System_queries",
                "compatible_with_server");

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("sid", server.getId());
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        return m.execute(params);
    }

    /**
     * Returns the admins of a given server This includes
     * @param server the server to find the admins of
     * @return list of User objects that can administer the system
     */
    public static List<User> listAdministrators(Server server) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("sid", server.getId());
        params.put("org_id", server.getOrg().getId());
        return singleton.listObjectsByNamedQuery("Server.lookupAdministrators",
                params);
    }

    /**
     * gets a server's history sorted by creation time. This includes items from
     * the rhnServerHistory and rhnAction* tables
     * @param server the server who's history you want
     * @return A list of ServerHistoryEvents
     */
    public static List<HistoryEvent> getServerHistory(Server server) {

        SelectMode m = ModeFactory.getMode("Action_queries",
                "system_events_history");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("sid", server.getId());

        return m.execute(params);
    }

    /**
     * List all proxies for a given org
     * @param user the user, who's accessible proxies will be returned.
     * @return a list of Proxy Server objects
     */
    public static List<Server> lookupProxiesByOrg(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("userId", user.getId());
        params.put("orgId", user.getOrg().getId());
        List<Number> ids = singleton.listObjectsByNamedQuery(
                "Server.listProxies", params);
        List<Server> servers = new ArrayList(ids.size());
        for (Number id : ids) {
            servers.add(lookupById(id.longValue()));
        }
        return servers;
    }

    /**
     * Clear out all subscriptions for a particular server
     * @param user User doing the un-subscription
     * @param server Server that is unsubscribing
     * @return new Server object showing all the new channel info.
     */
    public static Server unsubscribeFromAllChannels(User user, Server server) {
        UpdateBaseChannelCommand command = new UpdateBaseChannelCommand(user,
                server, new Long(-1));
        ValidatorError error = command.store();
        if (error != null) {
            throw new ChannelSubscriptionException(error.getKey());
        }
        return (Server) HibernateFactory.reload(server);
    }

    /**
     * Returns a list of Server objects currently selected in the System Set
     * Manager. This list will <strong>not</strong> contain servers that are
     * proxies.
     *
     * @param user User requesting.
     * @return List of servers.
     */
    public static List<Server> listSystemsInSsm(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("userId", user.getId());
        params.put("label", RhnSetDecl.SYSTEMS.getLabel());
        List<Server> servers = singleton.listObjectsByNamedQuery(
                "Server.findInSet", params);
        return servers;
    }

    /**
     * Returns a global multi org spanning list of
     * servers that are config enabled.
     * Basically used by taskomatic.
     * @return a list of config enabled systems
     */
    public static List<Server> listConfigEnabledSystems() {
        return singleton.listObjectsByNamedQuery(
                "Server.listConfigEnabledSystems", Collections.EMPTY_MAP);
    }

    /**
     * Returns a global multi org spanning list of
     * servers that are config-diff enabled.
     * Basically used by taskomatic.
     * @return a list of config-diff enabled systems
     */
    public static List<Server> listConfigDiffEnabledSystems() {
        return singleton.listObjectsByNamedQuery(
                "Server.listConfigDiffEnabledSystems", Collections.EMPTY_MAP);
    }

    /**
     * List snapshots associated with a server.
     *
     * A user may optionally provide a start and end date to narrow the snapshots that
     * will be listed.  For example,
     * - If user provides startDate only, all snapshots created either on or after the
     *   date provided will be returned
     * - If user provides startDate and endDate, all snapshots created on or between the
     *   dates provided will be returned
     * - If the user doesn't provide a startDate and endDate, all snapshots associated with
     *   the server will be returned.
     *
     * @param org the org doing the request. Required.
     * @param server the server to check for. Required.
     * @param startDate the start date.  Optional, unless endDate is provided.
     * @param endDate the end date. Optional.
     * @return list of ServerSnapshot objects
     */
    public static List<ServerSnapshot> listSnapshots(Org org, Server server,
            Date startDate, Date endDate) {

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org", org);
        params.put("server", server);

        List<ServerSnapshot> snaps = null;

        if ((startDate != null) && (endDate != null)) {
            params.put("start_date", startDate);
            params.put("end_date", endDate);
            snaps = singleton.listObjectsByNamedQuery(
                    "ServerSnapshot.findBetweenDates", params);
        }
        else if (startDate != null) {
            params.put("start_date", startDate);
            snaps = singleton.listObjectsByNamedQuery(
                    "ServerSnapshot.findAfterDate", params);
        }
        else {
            snaps = singleton.listObjectsByNamedQuery(
                    "ServerSnapshot.findForServer", params);
        }
        return snaps;
    }

    /**
     * Looks up a server snapshot by it's id
     * @param id the snap id
     * @return the server snapshot
     */
    public static ServerSnapshot lookupSnapshotById(Integer id) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("snapId", new Long(id));
        return (ServerSnapshot) singleton.lookupObjectByNamedQuery(
                "ServerSnapshot.findById", params);
    }

    /**
     * Looks up a latest snapshot for a sever
     * @param server server
     * @return the server snapshot
     */
    public static ServerSnapshot lookupLatestForServer(Server server) {
        Map params = new HashMap();
        params.put("sid", server);
        return (ServerSnapshot) singleton.lookupObjectByNamedQuery(
                "ServerSnapshot.findLatestForServer", params);
    }

    /**
     * Save a server snapshot
     * @param snapshotIn snapshot to save
     */
    public static void saveSnapshot(ServerSnapshot snapshotIn) {
        singleton.saveObject(snapshotIn);
    }

    /**
     * Delete a snapshot
     * @param snap the snapshot to delete
     */
    public static void deleteSnapshot(ServerSnapshot snap) {
        ServerFactory.getSession().delete(snap);
    }

    /**
     * Delete snapshots across servers in the org.
     *
     * A user may optionally provide a start and end date to narrow the snapshots that
     * will be removed.  For example,
     * - If user provides startDate only, all snapshots created either on or after the
     *   date provided will be removed
     * - If user provides startDate and endDate, all snapshots created on or between the
     *   dates provided will be removed
     * - If the user doesn't provide a startDate and endDate, all snapshots associated with
     *   the server will be removed.
     *
     * @param org the org doing the request. Required.
     * @param startDate the start date.  Optional, unless endDate is provided.
     * @param endDate the end date. Optional.
     */
    public static void deleteSnapshots(Org org, Date startDate, Date endDate) {

        if ((startDate != null) && (endDate != null)) {
            HibernateFactory.getSession()
            .getNamedQuery("ServerSnapshot.deleteBetweenDates")
            .setParameter("org", org)
            .setParameter("start_date", startDate)
            .setParameter("end_date", endDate)
            .executeUpdate();
        }
        else if (startDate != null) {
            HibernateFactory.getSession()
            .getNamedQuery("ServerSnapshot.deleteAfterDate")
            .setParameter("org", org)
            .setParameter("start_date", startDate)
            .executeUpdate();
        }
        else {
            HibernateFactory.getSession()
            .getNamedQuery("ServerSnapshot.delete")
            .setParameter("org", org)
            .executeUpdate();
        }
    }

    /**
     * Delete snapshots associated with a server.
     *
     * A user may optionally provide a start and end date to narrow the snapshots that
     * will be removed.  For example,
     * - If user provides startDate only, all snapshots created either on or after the
     *   date provided will be removed
     * - If user provides startDate and endDate, all snapshots created on or between the
     *   dates provided will be removed
     * - If the user doesn't provide a startDate and endDate, all snapshots associated with
     *   the server will be removed.
     *
     * @param org the org doing the request. Required.
     * @param server the server to check for. Required.
     * @param startDate the start date.  Optional, unless endDate is provided.
     * @param endDate the end date. Optional.
     */
    public static void deleteSnapshots(Org org, Server server,
            Date startDate, Date endDate) {

        if ((startDate != null) && (endDate != null)) {
            HibernateFactory.getSession()
            .getNamedQuery("ServerSnapshot.deleteForServerBetweenDates")
            .setParameter("org", org)
            .setParameter("server", server)
            .setParameter("start_date", startDate)
            .setParameter("end_date", endDate)
            .executeUpdate();
        }
        else if (startDate != null) {
            HibernateFactory.getSession()
            .getNamedQuery("ServerSnapshot.deleteForServerAfterDate")
            .setParameter("org", org)
            .setParameter("server", server)
            .setParameter("start_date", startDate)
            .executeUpdate();
        }
        else {
            HibernateFactory.getSession()
            .getNamedQuery("ServerSnapshot.deleteForServer")
            .setParameter("org", org)
            .setParameter("server", server)
            .executeUpdate();
        }
    }

    /**
     * get tags for a given snapshot
     * @param snap the snapshot to get tags for
     * @return list of tags
     */
    public static List<SnapshotTag> getSnapshotTags(ServerSnapshot snap) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("snap", snap);
        List<SnapshotTag> snaps = singleton.listObjectsByNamedQuery(
                "ServerSnapshot.findTags", params);
        return snaps;
    }

    /**
     * Filter out a list of systemIds with ones that are linux systems
     *  (i.e. not solaris systems)
     * @param systemIds list of system ids
     * @return list of system ids that are linux systems
     */
    public static List<Long> listLinuxSystems(Collection<Long> systemIds) {
        return singleton.listObjectsByNamedQuery("Server.listRedHatSystems",
                new HashMap(), systemIds, "sids");
    }

    /**
     * Adds tag to the snapshot
     * @param snpId snapshot id
     * @param orgId org id
     * @param tagName name of the tag
     */
    public static void addTagToSnapshot(Long snpId, Long orgId, String tagName) {
        CallableMode m = ModeFactory.getCallableMode("System_queries",
                "add_tag_to_snapshot");
        Map inParams = new HashMap();
        inParams.put("snapshot_id", snpId);
        inParams.put("org_id", orgId);
        inParams.put("tag_name", tagName);
        m.execute(inParams, new HashMap());
    }

    /**
     * Adds tag to snapshot for systems in set
     * @param tagName Name of the tag
     * @param setLabel set to find systems in
     * @param user User making the request
     */
    public static void bulkAddTagToSnapshot(String tagName, String setLabel, User user) {
        CallableMode m = ModeFactory.getCallableMode("System_queries",
                "bulk_add_tag_to_snapshot");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("set_label", setLabel);
        params.put("org_id", user.getOrg().getId());
        params.put("tag_name", tagName);
        params.put("user_id", user.getId());
        m.execute(params, new HashMap<String, Integer>());
    }

    /**
     * Removes tag from system snapshot
     * @param serverId server id
     * @param tag snapshot tag
     */
    public static void removeTagFromSnapshot(Long serverId, SnapshotTag tag) {
        CallableMode m = ModeFactory.getCallableMode("System_queries",
                "remove_tag_from_snapshot");
        Map inParams = new HashMap();
        inParams.put("server_id", serverId);
        inParams.put("tag_id", tag.getId());
        m.execute(inParams, new HashMap());
    }

    /**
     * Looks up snapshot tag by tag name
     * @param tagName name of the tag
     * @return snapshot tag
     */
    public static SnapshotTag lookupSnapshotTagbyName(String tagName) {
        SnapshotTag retval = (SnapshotTag) HibernateFactory
                .getSession().getNamedQuery("SnapshotTag.lookupByTagName")
                .setString("tag_name", tagName)
                // Do not use setCacheable(true), as tag deletion will
                // usually end up making this query's output out of date
                .uniqueResult();
        return retval;
    }

    /**
     * @param tagId snapshot tag ID
     * @return snapshot Tag
     */
    public static SnapshotTag lookupSnapshotTagbyId(Long tagId) {
        SnapshotTag retval = (SnapshotTag) HibernateFactory
                .getSession().getNamedQuery("SnapshotTag.lookupById")
                .setLong("id", tagId)
                // Do not use setCacheable(true), as tag deletion will
                // usually end up making this query's output out of date
                .uniqueResult();
        return retval;
    }

    /**
     * Lists software crashes for a server
     * @param server of interest
     * @return crash list
     */
    public static List<SoftwareCrashDto> listServerSoftwareCrashes(Server server) {
        SelectMode m = ModeFactory.getMode("System_queries",
                "list_server_software_crashes");
        Map<String, Object> params = new HashMap<String, Object>();
        // params.put("org_id", user.getOrg().getId());
        params.put("server_id", server.getId());
        return m.execute(params);
    }
}
