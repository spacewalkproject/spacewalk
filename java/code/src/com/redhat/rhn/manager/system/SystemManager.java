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

import com.redhat.rhn.common.client.ClientCertificate;
import com.redhat.rhn.common.client.InvalidCertificateException;
import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.CachedStatement;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorWarning;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.CPU;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.domain.server.ProxyInfo;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerLock;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;
import com.redhat.rhn.domain.server.VirtualInstanceState;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.CustomDataKeyOverview;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.HardwareDeviceDto;
import com.redhat.rhn.frontend.dto.NetworkDto;
import com.redhat.rhn.frontend.dto.OrgProxyServer;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.dto.kickstart.KickstartSessionDto;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.xmlrpc.InvalidProxyVersionException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchSystemException;
import com.redhat.rhn.frontend.xmlrpc.NotActivatedSatelliteException;
import com.redhat.rhn.frontend.xmlrpc.ProxySystemIsSatelliteException;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.MultipleChannelsWithPackageException;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.sql.Types;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * SystemManager
 * @version $Rev$
 */
public class SystemManager extends BaseManager {
    
    private static Logger log = Logger.getLogger(SystemManager.class);
    
    public static final String CAP_PACKAGES_RUNTXN = "packages.runTransaction";
    public static final String CAP_PACKAGES_ROLLBACK = "packages.rollBack";
    public static final String CAP_REBOOT = "reboot.reboot";
    public static final String CAP_CONFIGFILES_UPLOAD = "configfiles.upload";
    public static final String CAP_CONFIGFILES_DIFF = "configfiles.diff";
    public static final String CAP_CONFIGFILES_MTIME_UPLOAD =
        "configfiles.mtime_upload";
    public static final String CAP_CONFIGFILES_DEPLOY = "configfiles.deploy";
    public static final String CAP_KICKSTART_INITIATE = "kickstart.initiate";
    public static final String CAP_SCRIPT_RUN = "script.run";
    public static final String CAP_PACKAGES_VERIFYALL = "packages.verifyAll";
    public static final String CAP_RHNAPPLET_USE_SAT =
        "rhn_applet.use_satellite";
    public static final String CAP_PACKAGES_VERIFY = "packages.verify";
    public static final String CAP_CONFIGFILES_BASE64_ENC =
        "configfiles.base64_enc";
    public static final String CAP_OSAD_RHNCHECK = "osad.rhn_check";
    public static final String CAP_OSAD_PING = "osad.ping";
    
    public static final String[] INFO_PATTERNS = {
        "Registered by username = '(\\w+)' using rhn_register client",
        "rhn_register by username = '(\\w+)'",
        "Registered by (\\w+) using rhn_register client"};

    public static final String NO_SLOT_KEY = "system.entitle.noslots";

    private SystemManager() {
    }
    
    /**
     * Takes a snapshot for a server by calling the snapshot_server stored proc.
     * @param server The server to snapshot
     * @param reason The reason for the snapshotting.
     */
    public static void snapshotServer(Server server, String reason) {

        if (!Config.get().getBoolean(ConfigDefaults.TAKE_SNAPSHOTS)) {
            return;
        }

        // If the server is null or doesn't have the snapshotting feature, don't bother.
        if (server == null || !serverHasFeature(server.getId(), "ftr_snapshotting")) {
            return;
        }
        
        CallableMode m = ModeFactory.getCallableMode("System_queries", "snapshot_server");
        Map in = new HashMap();
        in.put("server_id", server.getId());
        in.put("reason", reason);
        m.execute(in, new HashMap());
    }
    
    /**
     * Gets the list of channels that this server could subscribe to given it's base 
     * channel.
     * @param sid The id of the server in question
     * @param uid The id of the user asking
     * @param cid The id of the base channel for the server
     * @return Returns a list of subscribable (child) channels for this server.
     */
    public static DataResult subscribableChannels(Long sid, Long uid, Long cid) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                                           "subscribable_channels", Map.class);
        Map params = new HashMap();
        params.put("server_id", sid);
        params.put("user_id", uid);
        params.put("base_channel_id", cid);
        
        return m.execute(params);
    }
    
    /**
     * Gets the list of channel ids that this server could subscribe to
     * according to it's base channel.
     * @param sid The id of the server in question
     * @param uid The id of the user asking
     * @param cid The id of the base channel for the server
     * @return Returns a list of subscribable (child) channel ids for this server.
     */
    public static Set subscribableChannelIds(Long sid, Long uid, Long cid) {
        Iterator subscribableChannelIter = subscribableChannels(sid, uid, cid).iterator();

        Set subscribableChannelIdSet = new HashSet();
        while (subscribableChannelIter.hasNext()) {
            Map row = (Map) subscribableChannelIter.next();
            subscribableChannelIdSet.add(row.get("id"));
        }
        return subscribableChannelIdSet;
    }

    /**
     * Gets the latest upgradable packages for a system
     * @param sid The id for the system we want packages for
     * @return Returns a list of the latest upgradable packages for a system
     */
    public static DataResult latestUpgradablePackages(Long sid) {
        SelectMode m = ModeFactory.getMode("Package_queries",
                                           "system_upgradable_package_list_no_errata_info",
                                           Map.class);
        Map params = new HashMap();
        params.put("sid", sid);
        return m.execute(params);
    }
    
    /**
     * Gets the latest installable packages for a system
     * @param sid The id for the system we want packages for
     * @return Returns a list of latest installable packages for a system.
     */
    public static DataResult latestInstallablePackages(Long sid) {
        SelectMode m = ModeFactory.getMode("Package_queries",
                                           "system_latest_all_available_packages",
                                           Map.class);
        Map params = new HashMap();
        params.put("sid", sid);
        return m.execute(params);
    }
    
    /**
     * Gets the installed packages on a system
     * @param sid The system in question
     * @return Returns a list of packages for a system
     */
    public static DataResult installedPackages(Long sid) {
        SelectMode m = ModeFactory.getMode("System_queries", "system_installed_packages", 
                                           Map.class);
        Map params = new HashMap();
        params.put("sid", sid);
        return m.execute(params);
    }
    
    /**
     * Deletes a server
     * @param user The user doing the deleting.
     * @param sid The id of the system to be deleted
     */
    public static void deleteServer(User user, Long sid) {
        /*
         * Looking up the server here rather than being passed in a Server object, allows
         * us to call lookupByIdAndUser which will ensure the user has access to this 
         * server.
         */
        Server server = lookupByIdAndUser(sid, user);
        if (server.isVirtualGuest()) {
            VirtualInstance virtInstance = server.getVirtualInstance();
            virtInstance.deleteGuestSystem();
        }
        else {
            if (server.getGuests() != null) {
                // Remove guest associations to the host system we're now deleting:
                for (Iterator it = server.getGuests().iterator(); it.hasNext();) {
                    VirtualInstance vi = (VirtualInstance)it.next();
                    server.removeGuest(vi);
                }
            }
            ServerFactory.delete(server);
        }
    }
    
    /**
     * Adds a server to a server group
     * @param server The server to add
     * @param serverGroup The group to add the server to
     */
    public static void addServerToServerGroup(Server server, ServerGroup serverGroup) {
        ServerFactory.addServerToGroup(server, serverGroup);
        snapshotServer(server, "Group membership alteration");
    }
    
    /**
     * Removes a server from a group
     * @param server The server to remove
     * @param serverGroup The group to remove the server from
     */
    public static void removeServerFromServerGroup(Server server, ServerGroup serverGroup) {
        ServerFactory.removeServerFromGroup(server, serverGroup);
        snapshotServer(server, "Group membership alteration");
    }
    
    /**
     * Returns a list of available server groups for a given server
     * @param server The server in question 
     * @param user The user requesting the information
     * @return Returns a list of system groups available for this server/user
     */
    public static DataResult availableSystemGroups(Server server, User user) {
        SelectMode m = ModeFactory.getMode("SystemGroup_queries", "visible_to_system", 
                                           Map.class);
        Map params = new HashMap();
        params.put("sid", server.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        return m.execute(params);
    }
    
    /**
     * Returns list of all systems visible to user.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult systemList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "visible_to_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of all systems visible to user.
     *    This is meant to be fast and only gets the id, name, and last checkin
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult systemListShort(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "xmlrpc_visible_to_user", 
                SystemOverview.class);
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns list of all systems that are  visible to user 
     * but not in the given server group.
     * @param user Currently logged in user.
     * @param sg a ServerGroup 
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult <SystemOverview> systemsNotInGroup(User user,
                                                    ServerGroup sg, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "target_systems_for_group");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sgid", sg.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }    
    
    /**
     * Returns a list of all systems visible to user with pending errata.
     * @param user Current logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews
     */
    public static DataResult mostCriticalSystems(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "most_critical_systems");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns list of all systems visible to user.
     * @param user Currently logged in user.
     * @param feature The String label of the feature we want to get a list of systems for.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult systemsWithFeature(User user, String feature, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "systems_with_feature");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("feature", feature);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of out of date systems visible to user.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult outOfDateList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "out_of_date");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of unentitled systems visible to user.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult unentitledList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "unentitled");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of ungrouped systems visible to user.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult ungroupedList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "ungrouped");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of inactive systems visible to user, sorted by name.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult inactiveList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "inactive");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        params.put("checkin_threshold", new Integer(Config.get().getInt(ConfigDefaults
                .SYSTEM_CHECKIN_THRESHOLD)));
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of inactive systems visible to user, sorted by name.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @param inactiveDays number of days the systems should have been inactive for
     * @return list of SystemOverviews.
     */
    public static DataResult inactiveList(User user, PageControl pc, int inactiveDays) {
        SelectMode m = ModeFactory.getMode("System_queries", "inactive");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        params.put("checkin_threshold", inactiveDays);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    
    /**
     * Returns a list of systems recently registered by the user
     * @param user Currently logged in user.
     * @param pc PageControl
     * @param threshold maximum amount of days ago the system, 0 returns all systems
     * was registered for it to appear in the list
     * @return list of SystemOverviews
     */
    public static DataResult registeredList(User user, 
                                            PageControl pc, 
                                            int threshold) {
        SelectMode m;
        Map params = new HashMap();
        
        if (threshold == 0) {
            m = ModeFactory.getMode("System_queries", 
            "all_systems_by_registration");
        }
        else {
            m = ModeFactory.getMode("System_queries", 
            "recently_registered");
            params.put("threshold", new Integer(threshold));
        }
        
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        
        Iterator i = dr.iterator();
        
        while (i.hasNext()) {
            SystemOverview so = (SystemOverview) i.next();
            
            if (so.getInfo() != null) {
                for (int j = 0; j < INFO_PATTERNS.length; ++j) {
                    Pattern pattern = Pattern.compile(INFO_PATTERNS[j]);
                    Matcher matcher = pattern.matcher(so.getInfo());
                    
                    if (matcher.matches()) {
                        so.setNameOfUserWhoRegisteredSystem(matcher.group(1));
                    }
                }
            }
        }
        
        return dr;
    }
    
    /**
     * Returns list of inactive systems visible to user, sorted by the systems' last
     * checkin time instead of by name.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult inactiveListSortbyCheckinTime(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", 
                                            "inactive_order_by_checkin_time");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        params.put("checkin_threshold", new Integer(Config.get().getInt(ConfigDefaults
                .SYSTEM_CHECKIN_THRESHOLD)));
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of proxy systems visible to user.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult proxyList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "proxy_servers");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of virtual host systems visible to user.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult virtualSystemsList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "virtual_servers");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns list of virtual guest systems running 'under' the given system.
     * @param user Currently logged in user.
     * @param sid The id of the system we are looking at
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult virtualGuestsForHostList(User user, Long sid, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "virtual_guests_for_host");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of virtual systems in the given set
     * @param user Currently logged in user.
     * @param setLabel The label of the set of virtual systems
     *        (rhnSet.elem = rhnVirtualInstance.id)
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult virtualSystemsInSet(User user,
                                                 String setLabel,
                                                 PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "virtual_systems_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", setLabel);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of system groups visible to user.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemGroupOverviews.
     */
    public static DataResult groupList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("SystemGroup_queries", "visible_to_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        elabParams.put("org_id", user.getOrg().getId());
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns list of systems in the specified group.
     * @param sgid System Group Id
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult<SystemOverview> systemsInGroup(Long sgid,
                                                            PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "systems_in_group");
        Map params = new HashMap();
        params.put("sgid", sgid);
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns the number of actions associated with a system
     * @param sid The system's id
     * @return number of actions
     */
    public static int countActions(Long sid) {
        SelectMode m = ModeFactory.getMode("System_queries", "actions_count");
        Map params = new HashMap();
        params.put("server_id", sid);
        DataResult dr = makeDataResult(params, params, null, m);
        return ((Long)((HashMap)dr.get(0)).get("count")).intValue();
    }
    
    /**
     * Returns the number of package actions associated with a system
     * @param sid The system's id
     * @return number of package actions
     */
    public static int countPackageActions(Long sid) {
        SelectMode m = ModeFactory.getMode("System_queries", "package_actions_count");
        Map params = new HashMap();
        params.put("server_id", sid);
        DataResult dr = makeDataResult(params, params, null, m);
        return ((Long)((HashMap)dr.get(0)).get("count")).intValue();
    }
    
    /**
     * Returns a list of unscheduled relevent errata for a system
     * @param user The user
     * @param sid The system's id
     * @param pc PageControl
     * @return a list of ErrataOverviews
     */
    public static DataResult<Errata> unscheduledErrata(User user, Long sid, 
            PageControl pc) {
        SelectMode m = ModeFactory.getMode("Errata_queries", 
                                           "unscheduled_relevant_to_system");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns whether a system has unscheduled relevant errata
     * @param user The user
     * @param sid The system's id
     * @return boolean of if system has unscheduled errata
     */
    public static boolean hasUnscheduledErrata(User user, Long sid) {
        SelectMode m = ModeFactory.getMode("Errata_queries", 
                                           "unscheduled_relevant_to_system");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        DataResult dr = m.execute(params);
        return !dr.isEmpty();
    }
    
    /**
     * Returns Kickstart sessions associated with a server
     * @param user The logged in user
     * @param sid The server id
     * @return a list of KickStartSessions
     */
    public static DataResult lookupKickstartSession(User user, Long sid) {
        SelectMode m = ModeFactory.getMode("System_queries", "lookup_kickstart");
        
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("sid", sid);
        
        return makeDataResult(params, params, null, m);
    }
    
    /**
     * Returns whether or not a server is kickstarting
     * @param user The logged in user
     * @param sid The server id
     * @return boolean of if a server is kickstarting
     */
    public static boolean isKickstarting(User user, Long sid) {
        Iterator i = lookupKickstartSession(user, sid).iterator();
        while (i.hasNext()) {
            KickstartSessionDto next = (KickstartSessionDto)i.next();
            if (!(next.getState().equals("complete") ||
                   next.getState().equals("failed"))) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Returns whether or not this org has unused entitlements.
     * @param org The organization
     * @return boolean for the presence of unused entitlements
     */
    public static boolean unusedEntitlements(Org org) {
        SelectMode m = ModeFactory.getMode("SystemGroup_queries", "unused_entitlements");
        
        Map params = new HashMap();
        params.put("org_id", org.getId());
        
        DataResult dr = makeDataResult(params, params, null, m);
        return ((Long)((HashMap)dr.get(0)).get("available")).intValue() > 0;
    }
    
    /**
     * Returns a list of errata relevant to a system
     * @param user The user
     * @param sid System Id
     * @return a list of ErrataOverviews
     */
    public static DataResult<ErrataOverview> relevantErrata(User user, Long sid) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "relevant_to_system");
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        
        Map elabParams = new HashMap();
        elabParams.put("sid", sid);
        elabParams.put("user_id", user.getId());
        
        return makeDataResultNoPagination(params, elabParams, m);
    }
    
    /**
     * Returns a list of errata relevant to a system
     * @param user The user
     * @param sid System Id
     * @param types of errata types (strings) to include
     * @return a list of ErrataOverviews
     */
    public static DataResult<ErrataOverview> relevantErrata(User user,
                                               Long sid, List<String> types) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "relevant_to_system_by_types");

        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);

        Map elabParams = new HashMap();
        elabParams.put("sid", sid);
        elabParams.put("user_id", user.getId());

        DataResult<ErrataOverview> dr =  m.execute(params, types);
        dr.setElaborationParams(elabParams);
        return dr;
    }


    /**
     * Returns a list of errata relevant to a system by type
     * @param user The user
     * @param sid System Id
     * @param type Type
     * @return a list of ErrataOverviews
     */
    public static DataResult<ErrataOverview> relevantErrataByType(User user, Long sid,
            String type) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "relevant_to_system_by_type");
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        params.put("type", type);
        
        Map elabParams = new HashMap();
        elabParams.put("sid", sid);
        elabParams.put("user_id", user.getId());
        
        return makeDataResultNoPagination(params, elabParams, m);
    }

    /**
     * Returns a list of errata relevant to a system, sorted by priority. Security errata
     * come first, then bug fix errata, and finally enhancement errata
     * @param user The user
     * @param sid System Id
     * @param pc PageControl
     * @return a list of ErrataOverviews
     */
    public static DataResult relevantErrataSortedByPriority(User user, 
                                                            Long sid, 
                                                            PageControl pc) {
        SelectMode m = ModeFactory.getMode("Errata_queries", 
                                           "relevant_to_system_sorted_by_priority");
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        
        Map elabParams = new HashMap();
        elabParams.put("sid", sid);
        elabParams.put("user_id", user.getId());
        
        return makeDataResult(params, elabParams, pc, m);
    }
    
    /**
     * Returns a count of the number of critical errata that are present on the system.
     * 
     * @param user user making the request
     * @param sid  identifies the server
     * @return number of critical errata on the system
     */
    public static int countCriticalErrataForSystem(User user, Long sid) {
        SelectMode m = ModeFactory.getMode("Errata_queries",
            "count_critical_errata_for_system");
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        
        DataResult dr = makeDataResult(params, null, null, m);
        return ((Long)((HashMap)dr.get(0)).get("count")).intValue();
    }

    /**
     * Returns a count of the number of non-critical errata that are present on the system.
     * 
     * @param user user making the request
     * @param sid  identifies the server
     * @return number of non-critical errata on the system
     */
    public static int countNoncriticalErrataForSystem(User user, Long sid) {
        SelectMode m = ModeFactory.getMode("Errata_queries",
            "count_noncritical_errata_for_system");
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", sid);
        
        DataResult dr = makeDataResult(params, null, null, m);
        return ((Long)((HashMap)dr.get(0)).get("count")).intValue();
    }
    
    /**
     * Returns a list of errata in a specified set
     * @param user The user
     * @param label The label for the errata set
     * @param pc PageControl
     * @return a list of ErrataOverviews
     */
    public static DataResult errataInSet(User user, String label, 
                                                 PageControl pc) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "in_set");
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", label);
        
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        
        DataResult dr =  m.execute(params);
        dr.setElaborationParams(elabParams);
        return dr;
    }
    
    /**
     * Looks up a server by its Id
     * @param sid The server's id
     * @param userIn who wants to lookup the Server
     * @return a server object associated with the given Id
     */
    public static Server lookupByIdAndUser(Long sid, User userIn) {
        Server server = ServerFactory.lookupByIdAndOrg(sid, 
                userIn.getOrg());
        
        if (!isAvailableToUser(userIn, sid)) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find server " + sid +
                    " for user " + userIn.getId());
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.system"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.system"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.system"));
            throw e;
        }
        else {
            return server;
        }
    }
    
    /**
     * Returns a List of hydrated server objects from server ids. 
     * @param serverIds the list of server ids to hyrdrate
     * @param userIn the user who wants to lookup the server
     * @return a List of hydrated server objects.
     */
    public static List<Server> hydrateServerFromIds(Collection<Long> serverIds,
                                                                User userIn) {
        List <Server> servers = new ArrayList(serverIds.size());
        for (Long id : serverIds) {
            servers.add(lookupByIdAndUser(id, userIn));
        }
        return servers;
    }
    
    /**
     * Looks up a server by its Id
     * @param sid The server's id
     * @param org who wants to lookup the Server
     * @return a server object associated with the given Id
     */
    public static Server lookupByIdAndOrg(Long sid, Org org) {
        Server server = ServerFactory.lookupByIdAndOrg(sid, org);
        return server;
    }
   
    /**
     * Looks up a Server by it's client certificate.
     * @param cert ClientCertificate of the server.
     * @return the Server which matches the client certificate.
     * @throws InvalidCertificateException thrown if certificate is invalid.
     */
    public static Server lookupByCert(ClientCertificate cert)
        throws InvalidCertificateException {
        
        return ServerFactory.lookupByCert(cert);
    }
    
    /**
     * Returns the list of activation keys used when the system was
     * registered.
     * @param serverIn the server to query for
     * @return list of ActivationKeyDto containing the token id and name
     */
    public static DataResult getActivationKeys(Server serverIn) {

        SelectMode m = ModeFactory.getMode("General_queries",
        "activation_keys_for_server");
        Map params = new HashMap();
        params.put("server_id", serverIn.getId());
        return makeDataResult(params, Collections.EMPTY_MAP, null, m);
    }

    /**
     * Returns list of inactive systems visible to user, sorted by name.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return list of SystemOverviews.
     */
    public static DataResult getSystemEntitlements(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "system_entitlement_list");
        Map params = new HashMap();
        params.put("user_id", user.getId());        
        return makeDataResult(params, Collections.EMPTY_MAP, pc, m);
    }    
    
    
    
    /**
     * Returns the entitlements for the given server id.
     * @param sid Server id
     * @return entitlements - ArrayList of entitlements
     */
    public static ArrayList getServerEntitlements(Long sid) {
        ArrayList entitlements = new ArrayList();
        
        SelectMode m = ModeFactory.getMode("General_queries", "system_entitlements");
        
        Map params = new HashMap();
        params.put("sid", sid);
        
        DataResult dr = makeDataResult(params, null, null, m);
        
        if (dr.isEmpty()) {
            return null;
        }
        
        Iterator iter = dr.iterator();
        while (iter.hasNext()) {
            Map map = (Map) iter.next();
            String ent = (String) map.get("label");
            entitlements.add(EntitlementManager.getByName(ent));
        }

        return entitlements;
    }

    /**
     * Used to test if the server has a specific entitlement.
     * We should almost always check for features with serverHasFeature instead.
     * @param sid Server id
     * @param ent Entitlement to look for
     * @return true if the server has the specified entitlement
     */
    public static boolean hasEntitlement(Long sid, Entitlement ent) {
        List entitlements = getServerEntitlements(sid);
        
        return entitlements != null && entitlements.contains(ent);
    }

    /**
     * Returns the features for the given server id.
     * @param sid Server id
     * @return features - ArrayList of features (Strings)
     */
    public static ArrayList getServerFeatures(Long sid) {
        ArrayList features = new ArrayList();
        
        SelectMode m = ModeFactory.getMode("General_queries", "system_features");
        
        Map params = new HashMap();
        params.put("sid", sid);
        
        DataResult dr = makeDataResult(params, null, null, m);
        
        Iterator iter = dr.iterator();
        while (iter.hasNext()) {
            Map map = (Map) iter.next();
            String feat = (String) map.get("label");
            features.add(feat);
        }

        return features;
    }

    /**
     * Used to test if the server has a specific feature.
     * We should almost always check for features with serverHasFeature instead.
     * @param sid Server id
     * @param feat Feature to look for
     * @return true if the server has the specified feature
     */
    public static boolean serverHasFeature(Long sid, String feat) {
        SelectMode m = ModeFactory.getMode("General_queries", "system_has_feature");
        
        Map params = new HashMap();
        params.put("sid", sid);
        params.put("feature", feat);
        
        DataResult dr = makeDataResult(params, null, null, m);
        return !dr.isEmpty();
    }
    
    /**
     * Return <code>true</code> the given server has virtualization entitlements, 
     * <code>false</code> otherwise.

     * @param sid Server ID to lookup.
     * @param org Org id of user performing this query.
     * @return <code>true</code> if the server has virtualization entitlements,
     *      <code>false</code> otherwise.
     */
    public static boolean serverHasVirtuaizationEntitlement(Long sid, Org org) {
        Server s = SystemManager.lookupByIdAndOrg(sid, org);
        return s.hasVirtualizationEntitlement();
    }
    
    /**
     * Returns true if server has capability.
     * @param sid Server id
     * @param capability capability
     * @return true if server has capability
     */
    public static boolean clientCapable(Long sid, String capability) {
        SelectMode m = ModeFactory.getMode("System_queries", "lookup_capability");
        
        Map params = new HashMap();
        params.put("sid", sid);
        params.put("name", capability);
        
        DataResult dr = makeDataResult(params, params, null, m);
        return !dr.isEmpty();
    }
    
    /**
     * Returns a list of Servers which are compatible with the given server.
     * @param user User owner
     * @param server Server whose profiles we want.
     * @return  a list of Servers which are compatible with the given server.
     */
    public static List compatibleWithServer(User user, Server server) {
        return ServerFactory.compatibleWithServer(user, server);
    }

    /**      
     * Subscribes the given server to the given channel.     
     * @param user Current user      
     * @param server Server to be subscribed     
     * @param channel Channel to subscribe to.
     * @return the modified server if there were
     *           any changes modifications made 
     *           to the Server during the call.
     *           Make sure the caller uses the 
     *           returned server.   
     */      
    public static Server subscribeServerToChannel(User user, 
                                            Server server, Channel channel) {     
        return subscribeServerToChannel(user, server, channel, false);      
    }    
    
    /**
     * Subscribes the given server to the given channel.
     * @param user Current user
     * @param server Server to be subscribed
     * @param channel Channel to subscribe to.
     * @param flush flushes the hibernate session. 
     * @return the modified server if there were
     *           any changes modifications made 
     *           to the Server during the call.
     *           Make sure the caller uses the 
     *           returned server. 
     */
    public static Server subscribeServerToChannel(User user,
                                                    Server server, 
                                                    Channel channel,
                                                    boolean flush) {
        
        // do not allow non-satellite or non-proxy servers to 
        // be subscribed to satellite or proxy channels respectively.
        if (channel.isSatellite()) {
            if (!server.isSatellite()) {
                return server;
            }
        }
        else if (channel.isProxy()) {
            if (!server.isProxy()) {
                return server;
            }
        }
        
        if (user != null && !ChannelManager.verifyChannelSubscribe(user, channel.getId())) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User does not have" +
                    " permission to subscribe this server to this channel.");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.subscribechannel"));
            pex.setLocalizedSummary(
                    ls.getMessage("permission.jsp.summary.subscribechannel"));
            throw pex;
        }
        
        if (!verifyArchCompatibility(server, channel)) {
            throw new IncompatibleArchException(
                    server.getServerArch(), channel.getChannelArch());
        }
        
        log.debug("calling subscribe_server_to_channel");
        CallableMode m = ModeFactory.getCallableMode("Channel_queries",
                "subscribe_server_to_channel");
        
        Map in = new HashMap();
        in.put("server_id", server.getId());
        if (user != null) {
            in.put("user_id", user.getId());
        }
        else {
            in.put("user_id", null);
        }
        in.put("channel_id", channel.getId());
        
        m.execute(in, new HashMap());
        
        /*
         * This is f-ing hokey, but we need to be sure to refresh the 
         * server object since    
         * we modified it outside of hibernate :-/      
         * This will update the server.channels set.
         */        
        log.debug("returning with a flush? " + flush);
        if (flush) {
            return (Server) HibernateFactory.reload(server);    
        }
        else {
            HibernateFactory.getSession().refresh(server);
            return server;
        }
    }
    
    /**
     * Returns true if the given server has a compatible architecture with the
     * given channel architecture. False if the server or channel is null or
     * they are not compatible.
     * @param server Server architecture to be verified.
     * @param channel Channel to check
     * @return true if compatible; false if null or not compatible.
     */
    public static boolean verifyArchCompatibility(Server server, Channel channel) {
        if (server == null || channel == null) {
            return false;
        }
        return channel.getChannelArch().isCompatible(server.getServerArch());
    }
    
    /**
     * Unsubscribe given server from the given channel.
     * @param user The user performing the operation
     * @param server The server to be unsubscribed
     * @param channel The channel to unsubscribe from
     */
    public static void unsubscribeServerFromChannel(User user, Server server, 
                                                    Channel channel) {
        unsubscribeServerFromChannel(user, server, channel, false);
    }
    
    /**
     * Unsubscribe given server from the given channel.
     * @param user The user performing the operation
     * @param sid The id of the server to be unsubscribed
     * @param cid The id of the channel from which the server will be unsubscribed
     */
    public static void unsubscribeServerFromChannel(User user, Long sid, 
            Long cid) {
        if (ChannelManager.verifyChannelSubscribe(user, cid)) {
            CallableMode m = ModeFactory.getCallableMode("Channel_queries",
                    "unsubscribe_server_from_channel");
            Map in = new HashMap();
            in.put("server_id", sid);
            in.put("channel_id", cid);
            
            m.execute(in, new HashMap());
        }
    }

    /**
     * Unsubscribe given server from the given channel.
     * @param user The user performing the operation
     * @param server The server to be unsubscribed
     * @param channel The channel to unsubscribe from
     * @param flush flushes the hibernate session. Make sure you 
     *              reload the server & channel after  method call
     *              if you set this to true..
     */
    public static void unsubscribeServerFromChannel(User user, Server server, 
                                                    Channel channel, boolean flush) {
        if (!isAvailableToUser(user, server.getId())) {
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException("User does not have" +
                    " permission to unsubscribe this server from this channel.");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.subscribechannel"));
            pex.setLocalizedSummary(
                    ls.getMessage("permission.jsp.summary.subscribechannel"));
            throw pex;
        }
        
        unsubscribeServerFromChannel(server, channel, flush);
    }
    
    /**
     * Unsubscribe given server from the given channel. If you use this method, 
     * YOU BETTER KNOW WHAT YOU'RE DOING!!! (Use the version that takes a user as well if
     * you're unsure. better safe than sorry).
     * @param server server to be unsubscribed
     * @param channel the channel to unsubscribe from
     * @return the modified server if there were
     *           any changes modifications made 
     *           to the Server during the call.
     *           Make sure the caller uses the 
     *           returned server.   
     */ 
    public static Server unsubscribeServerFromChannel(Server server, 
                                                    Channel channel) {
        return unsubscribeServerFromChannel(server, channel, false);
    }

    /**
     * Unsubscribe given server from the given channel. If you use this method, 
     * YOU BETTER KNOW WHAT YOU'RE DOING!!! (Use the version that takes a user as well if
     * you're unsure. better safe than sorry).
     * @param server server to be unsubscribed
     * @param channel the channel to unsubscribe from
     * @param flush flushes the hibernate session. Make sure you 
     *              reload the server & channel after  method call
     *              if you set this to true.. 
     * @return the modified server if there were
     *           any changes modifications made 
     *           to the Server during the call.
     *           Make sure the caller uses the 
     *           returned server.   
     */
    public static Server unsubscribeServerFromChannel(Server server, 
                                                    Channel channel, 
                                                        boolean flush) {
        if (channel == null) {
            //nothing to do ;)
            return server;
        }
        
        CallableMode m = ModeFactory.getCallableMode("Channel_queries",
                "unsubscribe_server_from_channel");
        Map in = new HashMap();
        in.put("server_id", server.getId());
        in.put("channel_id", channel.getId());        
        m.execute(in, new HashMap());

            /*
             * This is f-ing hokey, but we need to be sure to refresh the 
             * server object since we modified it outside of hibernate :-/
             * This will update the server.channels set.
             */
            if (flush) {
                return (Server)HibernateFactory.reload(server);
            }
            else {
                HibernateFactory.getSession().refresh(server);
                return server;
            }

    }
    
    /**
     * Deactivates the given proxy.
     * Make sure you either reload  the server after this call,,
     * or use the returned Server object
     * @param server ProxyServer to be deactivated.
     * @return deproxified server.
     */
    public static Server deactivateProxy(Server server) {
        Long sid = server.getId();

        Map params = new HashMap();
        params.put("server_id", sid);

        executeWriteMode("Monitoring_queries",
                "delete_probe_states_from_server", params);
        executeWriteMode("Monitoring_queries",
                "delete_deployed_probes_from_server", params);
        executeWriteMode("Monitoring_queries",
                "delete_probes_from_server", params);
        executeWriteMode("Monitoring_queries",
                "delete_sat_cluster_for_server", params);
        
        // At this point we have the deletes happening
        // in write mode. So our server which is a hibernate
        // object is NOT in sync and so we have to refresh 
        // for it to work....
        HibernateFactory.getSession().refresh(server);
        ServerFactory.deproxify(server);

        Set channels = server.getChannels();
        for (Iterator itr = channels.iterator(); itr.hasNext();) {
            Channel c = (Channel)itr.next();
            ChannelFamily cf = c.getChannelFamily();
            if (cf.getLabel().equals("rhn-proxy")) {
                SystemManager.unsubscribeServerFromChannel(server, c);
            }
        }

        return server;
    }
    
    private static int executeWriteMode(String catalog, String mode, Map params) {
        WriteMode m = ModeFactory.getWriteMode(catalog, mode);
        return m.executeUpdate(params);
    }
    
    /**
     * Creates the client certificate (systemid) file for the given Server.
     * @param server Server whose client certificate is sought.
     * @return the client certificate (systemid) file for the given Server.
     * @throws InstantiationException thrown if error occurs creating the
     * client certificate.
     */
    public static ClientCertificate createClientCertificate(Server server)
        throws InstantiationException {
        
        ClientCertificate cert = new ClientCertificate();
        // add members to this cert
        User user = UserManager.findResponsibleUser(server.getOrg(), RoleFactory.ORG_ADMIN);
        cert.addMember("username", user.getLogin());
        cert.addMember("os_release", server.getRelease());
        cert.addMember("operating_system", server.getOs());
        cert.addMember("architecture",  server.getServerArch().getLabel());
        cert.addMember("system_id", "ID-" + server.getId().toString());
        cert.addMember("type", "REAL");
        String[] fields = {"system_id", "os_release", "operating_system",
                "architecture", "username", "type"};
        cert.addMember("fields", fields);
        
        try {
            //Could throw InvalidCertificateException in any fields are invalid
            cert.addMember("checksum", cert.genSignature(server.getSecret()));
        }
        catch (InvalidCertificateException e) {
            throw new InstantiationException("Couldn't generate signature");
        }
        
        return cert;
    }

    /**
     * Store the server back to the db
     * @param serverIn The server to save
     */
    public static void storeServer(Server serverIn) {
        ServerFactory.save(serverIn);
    }
    
    /**
     * Activates the given proxy for the given version.
     * @param server proxy server to activate.
     * @param version Proxy version.
     * @throws ProxySystemIsSatelliteException thrown if system is a satellite.
     * @throws InvalidProxyVersionException thrown if version is invalid.
     */
    public static void activateProxy(Server server, String version)
       throws ProxySystemIsSatelliteException, InvalidProxyVersionException {

        if (server.isSatellite()) {
            throw new ProxySystemIsSatelliteException();
        }

        ProxyInfo info = new ProxyInfo();
        info.setServer(server);
        info.setVersion(null, version, "1");
        server.setProxyInfo(info);
        if (Config.get().getBoolean(ConfigDefaults.WEB_SUBSCRIBE_PROXY_CHANNEL)) {
            Channel proxyChannel = ChannelManager.getProxyChannelByVersion(
                    version, server);
            if (proxyChannel != null) {
                subscribeServerToChannel(null, server, proxyChannel);    
            }
        }
    }

    /**
     * Deactivate a current satellite
     * @param server the current satellite to be deactivated
     * @throws NotActivatedSatelliteException <code>server</code> is not a satellite
     * @throws NoSuchSystemException thrown if the server is null.
     */
    public static void deactivateSatellite(Server server) 
        throws NotActivatedSatelliteException, NoSuchSystemException {
        if (server == null) {
            throw new NoSuchSystemException();
        }
        
        if (!server.isSatellite()) {
            throw new NotActivatedSatelliteException();
        }

        Map params = new HashMap();
        params.put("sid", server.getId());
        executeWriteMode("System_queries", "delete_satellite_info", params);
        executeWriteMode("System_queries", "delete_satellite_channel_family", params);
        
        Set channels = server.getChannels();
        for (Iterator itr = channels.iterator(); itr.hasNext();) {
            Channel c = (Channel)itr.next();
            ChannelFamily cf = c.getChannelFamily();
            if (cf.getLabel().equals("rhn-satellite")) {
                SystemManager.unsubscribeServerFromChannel(server, c);
            }
        }
    }
    
    /**
     * Entitles the given server to the given Entitlement.
     * @param server Server to be entitled.
     * @param ent Level of Entitlement.
     * @return ValidatorResult of errors and warnings.
     */
    public static ValidatorResult entitleServer(Server server, Entitlement ent) {
        log.debug("Entitling: " + ent.getLabel());
        
        return entitleServer(server.getOrg(), server.getId(), ent);
    }
    
    /**
     * Entitles the given server to the given Entitlement.
     * @param orgIn Org who wants to entitle the server. 
     * @param sid server id to be entitled.
     * @param ent Level of Entitlement.
     * @return ValidatorResult of errors and warnings.
     */
    public static ValidatorResult entitleServer(Org orgIn, Long sid,
                                                Entitlement ent) {
        Server server = ServerFactory.lookupByIdAndOrg(sid, orgIn);
        ValidatorResult result = new ValidatorResult();
        
        if (hasEntitlement(sid, ent)) {
            log.debug("server already entitled.");
            result.addError(new ValidatorError("system.entitle.alreadyentitled",
                    ent.getHumanReadableLabel()));
            return result;
        }
        if (ent instanceof VirtualizationEntitlement) {
            if (server.isVirtualGuest()) {
                result.addError(new ValidatorError("system.entitle.guestcantvirt"));
                return result;
            }
            //we now check if we need to swap the server's entitlement 
            // with the entitlement you are passing in.
            // if server has virt and we want convert it to virt_platform
            // or server has virt_platform and we want convert it to virt
            // are the 2 instances where we want to swap the old virt
            // with the new... 
            if ((EntitlementManager.VIRTUALIZATION.equals(ent) &&
                   hasEntitlement(sid, EntitlementManager.VIRTUALIZATION_PLATFORM))) {
                log.debug("removing VIRT_PLATFORM");
                removeServerEntitlement(sid, EntitlementManager.VIRTUALIZATION_PLATFORM, 
                        false);
            }
            else if ((EntitlementManager.VIRTUALIZATION_PLATFORM.equals(ent) &&
                        hasEntitlement(sid, EntitlementManager.VIRTUALIZATION))) {
                log.debug("removing VIRT");
                removeServerEntitlement(sid, EntitlementManager.VIRTUALIZATION, 
                        false);
            }
            else {
                log.debug("setting up system for virt.");
                ValidatorResult virtSetupResults = setupSystemForVirtualization(orgIn, sid);
                result.append(virtSetupResults);
                if (virtSetupResults.getErrors().size() > 0) {
                    log.debug("error trying to setup virt ent: " +
                            virtSetupResults.getMessage());
                    return result;
                }
            }
        }

        boolean checkCounts = true;
        if (server.isVirtualGuest()) {
            Server host = server.getVirtualInstance().getHostSystem(); 
            if (host != null) {
                log.debug("host isnt null, checking entitlements.");
                if ((host.hasEntitlement(EntitlementManager.VIRTUALIZATION) || 
                        host.hasEntitlement(EntitlementManager.VIRTUALIZATION_PLATFORM)) &&
                        host.hasEntitlement(ent)) {
                    log.debug("host has virt and the ent passed in. FREE entitlement");
                    checkCounts = false;
                }
                else {
                    if (log.isDebugEnabled()) {
                        log.debug("host doesnt have virt or : " + ent.getLabel());
                    }
                }
            }
        } 
        if (checkCounts) {
            Long availableEntitlements =
                EntitlementManager.getAvailableEntitlements(ent, orgIn); 
            log.debug("avail: " + availableEntitlements);
            if (availableEntitlements != null && 
                    availableEntitlements.longValue() < 1) {
                log.debug("Not enough slots.  returning error");
                result.addError(new ValidatorError(NO_SLOT_KEY,
                            ent.getHumanReadableLabel()));
                return result;
            }        
        }
        
        Map in = new HashMap();
        in.put("sid", sid);
        in.put("entitlement", ent.getLabel());

        CallableMode m = ModeFactory.getCallableMode(
                "System_queries", "entitle_server");

        m.execute(in, new HashMap());
        log.debug("done.  returning null");
        return result;
    }
    
    // Need to do some extra logic here
    // 1) Subscribe system to rhel-i386-server-vt-5 channel
    // 2) Subscribe system to rhn-tools-rhel-i386-server-5
    // 3) Schedule package install of rhn-virtualization-host
    // Return a map with errors and warnings:
    //      warnings -> list of ValidationWarnings
    //      errors -> list of ValidationErrors
    private static ValidatorResult setupSystemForVirtualization(Org orgIn, Long sid) {

        Server server = ServerFactory.lookupById(sid);
        User user = UserFactory.findRandomOrgAdmin(orgIn);
        ValidatorResult result = new ValidatorResult();

        // If this is a Satellite, subscribe to the virt channel if possible:
        if (!ConfigDefaults.get().isSpacewalk()) {
            subscribeToVirtChannel(server, user, result);
        }

        // Before we start looking to subscribe to a 'tools' channel for
        // rhn-virtualization-host, check if the server already has a package by this
        // name installed and leave it be if so.
        InstalledPackage rhnVirtHost = PackageFactory.lookupByNameAndServer(
                ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME, server);
        if (rhnVirtHost != null) {
            // System already has the package, we can stop here.
            log.debug("System already has " +
                    ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME + " installed.");
            return result;
        }
        else {
            scheduleVirtualizationHostPackageInstall(server, user, result);
        }

        return result;
    }

    /**
     * Schedule installation of rhn-virtualization-host package.
     *
     * Implies that we locate a child channel with this package and automatically
     * subscribe the system to it if possible. If multiple child channels have the package
     * and the server is not already subscribed to one, we report the discrepancy and
     * instruct the user to deal with this manually.
     *
     * @param server Server to schedule install for.
     * @param user User performing the operation.
     * @param result Validation result we'll be returning for the UI to render.
     */
    private static void scheduleVirtualizationHostPackageInstall(Server server,
            User user, ValidatorResult result) {
        // Now subscribe to a child channel with rhn-virtualization-host (RHN Tools in the
        // case of Satellite) and schedule it for installation, or warn if we cannot find
        // a child with the package:
        Channel toolsChannel = null;
        try {
            toolsChannel = ChannelManager.subscribeToChildChannelWithPackageName(
                    user, server, ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME);

            // If this is a Satellite and no RHN Tools channel is available
            // report the error, but continue:
            if (!ConfigDefaults.get().isSpacewalk() && toolsChannel == null) {
                log.warn("no tools channel found");
                result.addWarning(new ValidatorWarning("system.entitle.notoolschannel"));
            }
            // If Spacewalk and no channel has the rhn-virtualization-host package,
            // warn but allow the operation to proceed.
            else if (toolsChannel == null) {
                result.addWarning(new ValidatorWarning("system.entitle.novirtpackage",
                            ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME));
            }
            else {
                List packageResults = ChannelManager.listLatestPackagesEqual(
                        toolsChannel.getId(), ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME);
                if (packageResults.size() > 0) {
                    Map row = (Map) packageResults.get(0);
                    Long nameId = (Long) row.get("name_id");
                    Long evrId = (Long) row.get("evr_id");
                    Long archId = (Long) row.get("package_arch_id");
                    ActionManager.schedulePackageInstall(
                            user, server, nameId, evrId, archId);
                }
                else {
                    result.addWarning(new ValidatorWarning("system.entitle.novirtpackage",
                                        ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME));
                }
            }
        }
        catch (MultipleChannelsWithPackageException e) {
            log.warn("Found multiple child channels with package: " +
                    ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME);
            result.addWarning(new ValidatorWarning(
                        "system.entitle.multiplechannelswithpackagepleaseinstall",
                        ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME));
        }
    }

    /**
     * Subscribe the system to the Red Hat Virtualization channel if necessary.
     *
     * This method should only ever be called in Satellite.
     *
     * @param server Server to schedule install for.
     * @param user User performing the operation.
     * @param result Validation result we'll be returning for the UI to render.
     */
    private static void subscribeToVirtChannel(Server server, User user,
            ValidatorResult result) {
        Channel virtChannel = ChannelManager.subscribeToChildChannelByOSProduct(
                user, server, ChannelManager.VT_OS_PRODUCT);
        log.debug("virtChannel search by OS product found: " + virtChannel);
        // Otherwise, try just searching by package name: (libvirt in this case)
        if (virtChannel == null) {
            log.debug("Couldnt find a virt channel by OS/Product mappings, " +
                    "trying package");
            try {
                virtChannel = ChannelManager.subscribeToChildChannelWithPackageName(
                        user, server, ChannelManager.VIRT_CHANNEL_PACKAGE_NAME);

                // If we couldn't find a virt channel, warn the user but continue:
                if (virtChannel == null) {
                    log.warn("no virt channel");
                    result.addWarning(new ValidatorWarning(
                            "system.entitle.novirtchannel"));
                }
            }
            catch (MultipleChannelsWithPackageException e) {
                log.warn("Found multiple child channels with package: " +
                        ChannelManager.VIRT_CHANNEL_PACKAGE_NAME);
                result.addWarning(new ValidatorWarning(
                            "system.entitle.multiplechannelswithpackage",
                            ChannelManager.VIRT_CHANNEL_PACKAGE_NAME));
            }
        }
    }
    
    /**
     * Removes all the entitlements related to a server.. 
     * @param sid server id to be unentitled.
     */
    public static void removeAllServerEntitlements(Long sid) {
        Map in = new HashMap();
        in.put("sid", sid);
        CallableMode m = ModeFactory.getCallableMode(
                "System_queries", "unentitle_server");
        m.execute(in, new HashMap());
    }    


    /**
     * Removes a specific level of entitlement from the given Server.
     * @param sid server id to be unentitled.
     * @param ent Level of Entitlement.
     */
    public static void removeServerEntitlement(Long sid, 
                                        Entitlement ent) {
        removeServerEntitlement(sid, ent, true);
    }
    
    /**
     * Removes a specific level of entitlement from the given Server.
     * @param sid server id to be unentitled.
     * @param ent Level of Entitlement.
     * @param repoll used mainly to repoll virtual entitlements post removal
     *               irrelevant if virtual entitlements are not found..   
     */
    public static void removeServerEntitlement(Long sid, 
                                        Entitlement ent, 
                                        boolean repoll) {
        
        if (!hasEntitlement(sid, ent)) {
            if (log.isDebugEnabled()) {
                log.debug("server doesnt have entitlement: " + ent);
            }
            return;
        }

        Map in = new HashMap();
        in.put("sid", sid);
        in.put("entitlement", ent.getLabel());
        if (repoll) {
            in.put("repoll", new Integer(1));
        }
        else {
            in.put("repoll", new Integer(0));
        }
        CallableMode m = ModeFactory.getCallableMode(
                "System_queries", "remove_server_entitlement");
        m.execute(in, new HashMap());
    }
    
    
    /**
     * Tests whether or not a given server can be entitled with a specific entitlement
     * @param server The server in question
     * @param ent The entitlement to test
     * @return Returns true or false depending on whether or not the server can be 
     * entitled to the passed in entitlement.
     */
    public static boolean canEntitleServer(Server server, Entitlement ent) {
        return canEntitleServer(server.getId(), ent);
    }

    /**
     * Tests whether or not a given server can be entitled with a specific entitlement
     * @param serverId The Id of the server in question
     * @param ent The entitlement to test
     * @return Returns true or false depending on whether or not the server can be 
     * entitled to the passed in entitlement.
     */
    public static boolean canEntitleServer(Long serverId, Entitlement ent) {
        if (log.isDebugEnabled()) {
            log.debug("canEntitleServer.serverId: " + serverId + " ent: " + 
                    ent.getHumanReadableLabel());
        }
        Map in = new HashMap();
        in.put("sid", serverId);
        in.put("entitlement", ent.getLabel());
        
        Map out = new HashMap();
        out.put("retval", new Integer(Types.NUMERIC));
        
        CallableMode m = ModeFactory.getCallableMode("System_queries", 
                                                     "can_entitle_server");
        Map result = m.execute(in, out);
        boolean retval = BooleanUtils.
            toBoolean(((Long) result.get("retval")).intValue()); 
        log.debug("canEntitleServer.returning: " + retval);
        return retval;
    }    
    
    /**
     * Returns a DataResult containing the systems subscribed to a particular channel.
     *      but returns a DataResult of SystemOverview objects instead of maps
     * @param channel The channel in question
     * @param user The user making the call
     * @return Returns a DataResult of maps containing the ids and names of systems
     * subscribed to a channel.
     */
    public static DataResult systemsSubscribedToChannelDto(Channel channel, User user) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("cid", channel.getId());
        params.put("org_id", user.getOrg().getId());
        SelectMode m = ModeFactory.getMode("System_queries",
                           "systems_subscribed_to_channel", SystemOverview.class);
        return m.execute(params);
    }

    /**
     * Returns the number of systems subscribed to the given channel.
     * 
     * @param channelId identifies the channel
     * @param user      user making the request
     * @return number of systems subscribed to the channel
     */
    public static int countSystemsSubscribedToChannel(Long channelId, User user) {
        Map<String, Long> params = new HashMap<String, Long>(2);
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("cid", channelId);
        
        SelectMode m = ModeFactory.getMode("System_queries",
            "count_systems_subscribed_to_channel");
        DataResult dr = makeDataResult(params, params, null, m);
        
        Map result = (Map) dr.get(0);
        Long count = (Long) result.get("count");
        return count.intValue();
    }
    
    /**
     * Returns a DataResult containing the systems subscribed to a particular channel.
     * @param channel The channel in question
     * @param user The user making the call
     * @return Returns a DataResult of maps containing the ids and names of systems 
     * subscribed to a channel.
     */
    public static DataResult systemsSubscribedToChannel(Channel channel, User user) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("cid", channel.getId());
        params.put("org_id", user.getOrg().getId());
        
        SelectMode m = ModeFactory.getMode("System_queries",
                           "systems_subscribed_to_channel", Map.class);
        return m.execute(params);
    }

    /**
     * Return the list of systems subscribed to the given channel in the current set.
     * Each entry in the result will be of type EssentialServerDto as per the query.
     *
     * @param cid Channel
     * @param user User requesting the list
     * @param setLabel Set label
     * @return List of systems
     */
    public static DataResult systemsSubscribedToChannelInSet(
            Long cid, User user, String setLabel) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("cid", cid);
        params.put("org_id", user.getOrg().getId());
        params.put("set_label", setLabel);
        
        SelectMode m = ModeFactory.getMode(
                "System_queries", "systems_subscribed_to_channel_in_set");
        return m.execute(params);
    }
    
    /**
     * Returns a DataResult containing maps representing the channels a particular system
     * is subscribed to.
     * @param server The server in question.
     * @return Returns a DataResult of maps representing the channels a particular system
     * is subscribed to.
     */
    public static DataResult channelsForServer(Server server) {
        Map params = new HashMap();
        params.put("sid", server.getId());
        SelectMode m = ModeFactory.getMode("Channel_queries", "system_channels", Map.class);
        return m.execute(params);
    }
    
    /**
     * Returns a DataResult of SystemSearchResults which are based on the user's search 
     * criteria
     * @param user user performing the search
     * @param searchString string to search on
     * @param viewMode what field to search
     * @param invertResults whether the results should be inverted
     * @param whereToSearch whether to search through all user visible systems or the 
     *        systems selected in the SSM
     * @param pc PageControl
     * @return DataResult of SystemSearchResults based on user's search criteria
     */
    public static DataResult systemSearch(User user, 
                                          String searchString, 
                                          String viewMode, 
                                          Boolean invertResults, 
                                          String whereToSearch,
                                          PageControl pc) {
        Map queryParams = new HashMap();
        queryParams.put("user_id", user.getId());
        queryParams.put("search_string", StringUtils.trimToEmpty(searchString));
        SelectMode mode = ModeFactory.getMode("system_search", viewMode);
        CachedStatement query = mode.getQuery();
        
        /* The reason we change the queries in the Java code is to save us from having 
         * a mode for every single combination of inversion, base search query, and 
         * set of systems to search.
         */
        
        if (invertResults != null && invertResults.booleanValue()) {
            query.setQuery("SELECT  USP.server_id AS ID FROM  rhnUserServerPerms USP " +
                           "WHERE USP.user_id = :user_id MINUS(" +
                           query.getOrigQuery() + ")");
        }
        
        if (whereToSearch.equals("system_list")) {
            query.setQuery(query.getOrigQuery() + " INTERSECT SELECT element FROM rhnSet " +
                           "WHERE label = 'system_list' AND user_id = :user_id");
        }
        
        /* We use the ListControl makeDataResult as this allows us to use elaborated queries
         * without all the overhead of paging. We need elaboration for the selectable field
         * to be retrieved from all the queries correctly
         */
        DataResult dr;
        if (pc != null) {
            dr =  makeDataResult(queryParams, queryParams, pc, mode);
        }
        else {
            dr =  makeDataResult(queryParams, queryParams, (ListControl) null, mode);
            // only elaborate when passing in null, and make sure
            // we pass in the query params so that subsequent
            // elaborators have access to the original params.
            dr.elaborate(queryParams);
        }
        
        return dr;
    }
    
    /**
     * Unlocks a server if the user has permissions on the server
     * @param user User who is attempting to unlock the server
     * @param server Server that is attempting to be unlocked
     */
    public static void unlockServer(User user, Server server) {
        if (!isAvailableToUser(user, server.getId())) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException(
                    "Could not find server " + server.getId() +
                    " for user " + user.getId());
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.system"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.system"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.system"));
            throw e;
        }
        else {
            HibernateFactory.getSession().delete(server.getLock());
            server.setLock(null);
        }
    }
    
    /**
     * Locks a server if the user has permissions on the server
     * @param locker User who is attempting to lock the server
     * @param server Server that is attempting to be locked
     * @param reason String representing the reason the server was locked
     */
    public static void lockServer(User locker, Server server, String reason) {
        if (!isAvailableToUser(locker, server.getId())) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException(
                    "Could not find server " + server.getId() +
                    " for user " + locker.getId());
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.system"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.system"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.system"));
            throw e;
        }
        else {
            ServerLock sl = new ServerLock(locker,
                                           server, 
                                           reason);

            server.setLock(sl);
        }
    }
    
    /**
     * Check to see if an attempt to subscribe the passed in server to the
     * passed in channel will succeed.  Checks available slots, if the channel is
     * 'free' and the Server is virtual.
     * 
     * @param orgIn of caller
     * @param serverIn to check
     * @param channelIn to check
     * @return boolean if it will succeed.
     */
    public static boolean canServerSubscribeToChannel(Org orgIn, Server serverIn, 
            Channel channelIn) {
        
        if (serverIn.isSubscribed(channelIn)) {
            log.debug("already subscribed.  return true");
            return true;
        }
        
        // If channel is free for this guest, dont check avail subs
        if (ChannelManager.isChannelFreeForSubscription(serverIn, channelIn)) {
            log.debug("its a free channel for this server, returning true");
            return true;
        }
        
        // Otherwise check available subs
        Long availableSubscriptions = 
            ChannelManager.getAvailableEntitlements(orgIn, channelIn);
        
        if (availableSubscriptions != null && 
                (availableSubscriptions.longValue() < 1)) {
            log.debug("avail subscriptions is to small : " + availableSubscriptions);
            return false;
        }
        log.debug("canServerSubscribeToChannel true!");
        return true;
    }
    
    /**
     * Checks if the user has permissions to see the Server
     * @param user User being checked
     * @param sid ID of the Server being checked
     * @return true if the user can see the server, false otherwise
     */
    public static boolean isAvailableToUser(User user, Long sid) {
        SelectMode m = ModeFactory.getMode("System_queries", "is_available_to_user");
        Map params = new HashMap();
        params.put("uid", user.getId());
        params.put("sid", sid);
        return m.execute(params).size() >= 1;
    }
    
    /**
     * Return systems in the current set without a base channel.
     * @param user User requesting the query.
     * @return List of systems.
     */
    public static DataResult systemsWithoutBaseChannelsInSet(User user) {
        SelectMode m = ModeFactory.getMode("System_queries",
                "systems_in_set_with_no_base_channel");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        return m.execute(params);
    }


    /**
     * Validates that the proposed number of virtual CPUs is valid for the
     * given virtual instance.
     *
     * @param guestId ID of a virtual instance.
     * @param proposedVcpuSetting Requested number of virtual CPUs for the guest.
     * @return ValidatorResult containing both error and warning messages.
     */
    public static ValidatorResult validateVcpuSetting(Long guestId, 
            int proposedVcpuSetting) {
        ValidatorResult result = new ValidatorResult();

        VirtualInstanceFactory viFactory = VirtualInstanceFactory.getInstance();
        VirtualInstance guest = viFactory.lookupById(guestId);
        Server host = guest.getHostSystem();

        // Technically the limit is 32 for 32-bit architectures and 64 for 64-bit,
        // but the kernel is currently set to only accept 32 in either case. This may
        // need to change down the road.
        if (proposedVcpuSetting > 32) {
            result.addError(new ValidatorError(
                "systems.details.virt.vcpu.limit.msg", 
                new Object [] {"32", guest.getName()}));
        }

        // Warn the user if the proposed vCPUs exceeds the physical CPUs on the
        // host:
        CPU hostCpu = host.getCpu();
        if (hostCpu != null && hostCpu.getNrCPU() != null) {
            if (proposedVcpuSetting > hostCpu.getNrCPU().intValue()) {
                result.addWarning(new ValidatorWarning(
                    "systems.details.virt.vcpu.exceeds.host.cpus",
                    new Object [] {host.getCpu().getNrCPU(), guest.getName()}));
            }
        }

        // Warn the user if the proposed vCPUs is an increase for this guest.
        // If the new value exceeds the setting the guest was started with, a
        // reboot will be required for the setting to take effect.
        VirtualInstanceState running = VirtualInstanceFactory.getInstance().
            getRunningState();
        if (guest.getState() != null && 
                guest.getState().getId().equals(running.getId())) {
            Integer currentGuestCpus = guest.getNumberOfCPUs();
            if (currentGuestCpus != null && proposedVcpuSetting > 
                    currentGuestCpus.intValue()) {
                result.addWarning(new ValidatorWarning(
                    "systems.details.virt.vcpu.increase.warning",
                    new Object [] {new Integer(proposedVcpuSetting), guest.getName()}));
            }
        }
        
        return result;
    }

    /**
     * Validates the amount requested amount of memory can be allocated to each
     * of the guest systems in the list. Assumes all guests are on the same host.
     *
     * @param guestIds List of longs representing IDs of virtual instances.
     * @param proposedMemory Requested amount of memory for each guest. (in Mb)
     * @return ValidatorResult containing both error and warning messages.
     */
    public static ValidatorResult validateGuestMemorySetting(List guestIds, 
            int proposedMemory) {
        ValidatorResult result = new ValidatorResult();
        VirtualInstanceFactory viFactory = VirtualInstanceFactory.getInstance();
        
        if (guestIds.isEmpty()) {
            return result;
        }

        // Grab the host from the first guest in the list:  
        Long firstGuestId = (Long)guestIds.get(0);
        Server host = ((VirtualInstance)viFactory.lookupById(firstGuestId)).
                                                                getHostSystem(); 

        int proposedMemoryKb = proposedMemory * 1024;
        long netMemoryDifferenceKb = 0;
        long guestMemoryUsageKb = 0; // accumulate mem allocation of all running guests
        VirtualInstanceState running = VirtualInstanceFactory.getInstance().
            getRunningState();

        log.debug("Adding guest memory:");
        List warnings = new LinkedList();
        for (Iterator it = host.getGuests().iterator(); it.hasNext();) {
            VirtualInstance guest = (VirtualInstance)it.next();
            
            // if the guest we're examining isn't running, don't count it's memory
            // when determining if the host has enough free:
            if (guest.getState() != null && 
                    guest.getState().getId().equals(running.getId())) {
                
                if (guest.getTotalMemory() != null) {
                    guestMemoryUsageKb += guest.getTotalMemory().longValue();
                    log.debug("   " + guest.getName() + " = " + 
                            (guest.getTotalMemory().longValue() / 1024) + "MB");
    
                    if (guestIds.contains(guest.getId())) {
                        long guestMemoryDelta = proposedMemoryKb - 
                                            guest.getTotalMemory().longValue();
                        netMemoryDifferenceKb += guestMemoryDelta;
                        
                        // Warn the user that a change to max memory will require a reboot
                        // for the settings to take effect:
                        warnings.add(new ValidatorWarning(
                            "systems.details.virt.memory.warning",
                            new Object [] {guest.getName()}));
                    }
                }
                else {
                    // Not much we can do for calculations if we don't have reliable data,
                    // continue on to other guests:
                    log.warn("No total memory set for guest: " + guest.getName());
                }
            }
        }
        
        // Warn the user to verify the system has enough free memory:
        // NOTE: Once upon a time we tried to do this automagically but the
        // code was removed due to uncertainty in terms of rebooting guests
        // if increasing past the allocation they were booted with, missing
        // hardware refreshes for the host, etc.
        warnings.add(new ValidatorWarning("systems.details.virt.memory.check.host"));
        
        if (!warnings.isEmpty()) {
            for (Iterator itr = warnings.iterator(); itr.hasNext();) {
                result.addWarning((ValidatorWarning)itr.next());
            }
        }

        return result;
    }
    
    /**
     * gets the monitoring status for a particular system
     * @param user the user to check for
     * @param sid the system id to check for
     * @return DataResult with the monitoring string
     */
    public static DataResult getMonitoringStatus(User user, Long sid) {
        SelectMode m = ModeFactory.getMode("System_queries", "monitoring_status");
        Map params = new HashMap();
        params.put("uid", user.getId());
        params.put("sid", sid);
        return m.execute(params);
    }
    
    /**
     * Return the system names and IDs that are selected in the SSM for the given user,
     * which also have been subscribed to the given channel.
     * 
     * @param user User.
     * @param channelId Channel ID.
     * @return List of maps containing the system name and ID.
     */
    public static List<Map> getSsmSystemsSubscribedToChannel(User user, Long channelId) {
        SelectMode m = ModeFactory.getMode("System_queries", 
                "systems_in_set_with_channel");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("channel_id", channelId);
        return m.execute(params);
    }
    
    /**
     * lists  systems with the given installed NVR
     * @param user the user doing the search
     * @param name the name of the package
     * @param version package version
     * @param release package release
     * @return  list of systemOverview objects
     */
    public static List<SystemOverview> listSystemsWithPackage(User user, 
            String name, String version, String release) {
        SelectMode m = ModeFactory.getMode("System_queries", 
        "systems_with_package_nvr");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("version", version);
        params.put("release", release);
        params.put("name", name);
        DataResult toReturn = m.execute(params);
        toReturn.elaborate();
        return toReturn;
    }
    
    /**
     * lists  systems with the given installed package id
     * @param user the user doing the search
     * @param id the id of the package
     * @return  list of systemOverview objects
     */
    public static List<SystemOverview> listSystemsWithPackage(User user, Long id) {
        SelectMode m = ModeFactory.getMode("System_queries", 
        "systems_with_package");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("pid", id);
        DataResult toReturn = m.execute(params);
        //toReturn.elaborate();
        return toReturn;
    }

    /**
     * lists systems with the given needed/upgrade package id
     * @param user the user doing the search
     * @param id the id of the package
     * @return  list of systemOverview objects
     */
    public static List<SystemOverview> listSystemsWithNeededPackage(User user, Long id) {
        SelectMode m = ModeFactory.getMode("System_queries", 
        "systems_with_needed_package");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("pid", id);
        DataResult toReturn = m.execute(params);
        //toReturn.elaborate();
        return toReturn;
    }
    
    /**
     * List all virtual hosts for a user
     * @param user the user in question 
     * @return list of SystemOverview objects
     */
    public static List<SystemOverview> listVirtualHosts(User user) {
        SelectMode m = ModeFactory.getMode("System_queries", 
        "virtual_hosts_for_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        DataResult toReturn = m.execute(params);
        toReturn.elaborate();
        return toReturn;
    }
    
    /**
     * List systems subscribed to a particular channel
     * @param user the user checking
     * @param cid the channel id
     * @return list of systems
     */
    public static List<SystemOverview> subscribedToChannel(User user, Long cid) {
        SelectMode m = ModeFactory.getMode("System_queries", 
        "systems_subscribed_to_channel");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("cid", cid);
        DataResult toReturn = m.execute(params);        
        toReturn.elaborate();
        return toReturn;
    }

    /**
     * Returns the number of systems subscribed to the channel that are <strong>not</strong>
     * in the given org.
     * 
     * @param orgId identifies the filter org
     * @param cid   identifies the channel
     * @return count of systems
     */
    public static int countSubscribedToChannelWithoutOrg(Long orgId, Long cid) {
        SelectMode m = ModeFactory.getMode("System_queries", 
        "count_systems_subscribed_to_channel_not_in_org");
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("cid", cid);
        
        DataResult dr = m.execute(params);
        Map result = (Map) dr.get(0);
        Long count = (Long) result.get("count");
        
        return count.intValue();
    }
    
    /**
     * List of servers subscribed to shared channels via org trust.
     * @param orgA The first org in the trust.
     * @param orgB The second org in the trust.
     * @return (system.id, system.org_id, system.name)
     */
    public static DataResult subscribedInOrgTrust(long orgA, long orgB) {
        SelectMode m =
            ModeFactory.getMode("System_queries",
                    "systems_subscribed_by_orgtrust");
        Map params = new HashMap();
        params.put("orgA", orgA);
        params.put("orgB", orgB);
        return m.execute(params);
    }
    
    /**
     * List of distinct servers subscribed to shared channels via org trust.
     * @param orgA The first org in the trust.
     * @param orgB The second org in the trust.
     * @return (system.id)
     */
    public static DataResult sidsInOrgTrust(long orgA, long orgB) {
        SelectMode m =
            ModeFactory.getMode("System_queries",
                    "sids_subscribed_by_orgtrust");
        Map params = new HashMap();
        params.put("orgA", orgA);
        params.put("orgB", orgB);
        return m.execute(params);
    }

    /**
     * gets the number of systems subscribed to a channel
     * @param user the user checking
     * @param cid the channel id
     * @return list of systems
     */
    public static Long subscribedToChannelSize(User user, Long cid) {
        SelectMode m = ModeFactory.getMode("System_queries", 
        "systems_subscribed_to_channel_size");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("cid", cid);
        DataResult toReturn = m.execute(params);
        return (Long) ((HashMap)toReturn.get(0)).get("count");
        
    }    
    
    /**
     * List all virtual hosts for a user
     * @param user the user in question
     * @return list of SystemOverview objects
     */
    public static DataResult<CustomDataKeyOverview> listDataKeys(User user) {
        SelectMode m = ModeFactory.getMode("System_queries",
        "custom_vals", CustomDataKeyOverview.class);
        Map params = new HashMap();
        params.put("uid", user.getId());
        params.put("org_id", user.getOrg().getId());
        DataResult toReturn = m.execute(params);
        return toReturn;
    }
    /**
     * Looks up a hardware device by the hardware device id
     * @param hwId the hardware device id
     * @return the HardwareDeviceDto 
     */
    public static HardwareDeviceDto getHardwareDeviceById(Long hwId) {
        HardwareDeviceDto hwDto = null;
        SelectMode m = ModeFactory.getMode("System_queries", "hardware_device_by_id");
        Map params = new HashMap();
        params.put("hw_id", hwId);
        DataResult<HardwareDeviceDto> dr = m.execute(params);
        if (dr != null) {
            hwDto = dr.get(0);
        }
        return hwDto;
    }

    /**
     * Returns a mapping of servers in the SSM to the user-selected packages to remove
     * that actually exist on those servers.
     *
     * @param user            identifies the user making the request
     * @param packageSetLabel identifies the RhnSet used to store the packages selected
     *                        by the user (this is needed for the query). This must be
     *                        established by the caller prior to calling this method
     * @param shortened       whether or not to include the full elaborator, or a shortened 
     *                        one that is much much faster, but doesn't provide a displayed
     *                        string for the package (only the id combo)
     * @return description of server information as well as a list of relevant packages
     */
    public static DataResult ssmSystemPackagesToRemove(User user,
                                                       String packageSetLabel, 
                                                       boolean shortened) {       
        SelectMode m; 
        if (shortened) {
            m = ModeFactory.getMode("System_queries",
                "system_set_remove_or_verify_packages_conf_short");
        }
        else {
            m = ModeFactory.getMode("System_queries",
            "system_set_remove_or_verify_packages_conf");           
        }

        Map<String, Object> params = new HashMap<String, Object>(3);
        params.put("user_id", user.getId());
        params.put("set_label", RhnSetDecl.SYSTEMS.getLabel());
        params.put("package_set_label", packageSetLabel);

        DataResult result = makeDataResult(params, params, null, m);
        return result;
    }

    /**
     * Returns a mapping of servers in the SSM to the user-selected packages to verify
     * that actually exist on those servers.
     *
     * @param user            identifies the user making the request
     * @param packageSetLabel identifies the RhnSet used to store the packages selected
     *                        by the user (this is needed for the query). This must be
     *                        established by the caller prior to calling this method
     * @return description of server information as well as a list of relevant packages
     */
    public static DataResult ssmSystemPackagesToVerify(User user,
                                                       String packageSetLabel) {
        // The query for this operation is the same as remove, so simply chain to
        // that method; this method is to make the verify code not look like it 
        // erronuously calls a remove query.
        return ssmSystemPackagesToRemove(user, packageSetLabel, false);
    }    
    
    /**
     * Returns a mapping of servers in the SSM to user-selected packages to upgrade
     * that actually exist on those servers
     * 
     * @param user            identifies the user making the request
     * @param packageSetLabel identifies the RhnSet used to store the packages selected
     *                        by the user (this is needed for the query). This must be
     *                        established by the caller prior to calling this method
     * @return description of server information as well as a list of all relevant packages
     */
    public static DataResult ssmSystemPackagesToUpgrade(User user,
                                                        String packageSetLabel) {
        
        SelectMode m =
            ModeFactory.getMode("System_queries", "ssm_package_upgrades_conf");
        
        Map<String, Object> params = new HashMap<String, Object>(3);
        params.put("user_id", user.getId());
        params.put("set_label", RhnSetDecl.SYSTEMS.getLabel());
        params.put("package_set_label", packageSetLabel);
        
        DataResult result = makeDataResult(params, params, null, m);
        return result;
    }

    /**
     * Deletes the indicates note, assuming the user has the proper permissions to the
     * server.
     * 
     * @param user     user making the request
     * @param serverId identifies server the note resides on
     * @param noteId   identifies the note being deleted   
     */
    public static void deleteNote(User user, Long serverId, Long noteId) {
        Server server = lookupByIdAndUser(serverId, user);
        
        Session session = HibernateFactory.getSession();
        Note doomed = (Note) session.get(Note.class, noteId);
        
        boolean deletedOnServer = server.getNotes().remove(doomed);
        if (deletedOnServer) {
            session.delete(doomed);
        }
    }

    /**
     * Deletes all notes on the given server, assuming the user has the proper permissions
     * to the server. 
     * 
     * @param user     user making the request
     * @param serverId identifies the server on which to delete its notes
     */
    public static void deleteNotes(User user, Long serverId) {
        Server server = lookupByIdAndUser(serverId, user);
        
        Session session = HibernateFactory.getSession();
        for (Object doomed : server.getNotes()) {
            session.delete(doomed);
        }

        server.getNotes().clear();
    }

    /**
     * Is the package with nameId, archId, and evrId available in the
     *  provided server's subscribed channels
     * @param server the server
     * @param nameId the name id
     * @param archId the arch id
     * @param evrId the evr id
     * @return true if available, false otherwise
     */
    public static boolean hasPackageAvailable(Server server, Long nameId,
                                            Long archId, Long evrId) {
        Map params = new HashMap();
        params.put("server_id", server.getId());
        params.put("eid", evrId);
        params.put("nid", nameId);

        String mode = "has_package_available";
        if (archId == null) {
            mode = "has_package_available_no_arch";
        }
        else {
            params.put("aid", archId);
        }
        SelectMode m =
            ModeFactory.getMode("System_queries", mode);
        DataResult toReturn = m.execute(params);
        return toReturn.size() > 0;
    }

    /**
     * Gets the list of proxies that the given system connects
     * through in order to reach the server.
     * @param sid The id of the server in question
     * @return Returns a list of ServerPath objects.
     */
    public static DataResult getConnectionPath(Long sid) {
        SelectMode m = ModeFactory.getMode("System_queries", "proxy_path_for_server");
        Map params = new HashMap();
        params.put("sid", sid);
        return m.execute(params);
    }

    /**
     * List all of the installed packages with the given name
     * @param packageName the package name
     * @param server the server
     * @return list of maps with name_id, evr_id and arch_id
     */
    public static List<Map<String, Long>> listInstalledPackage(
                                    String packageName, Server server) {
        SelectMode m = ModeFactory.getMode("System_queries",
                "list_installed_packages_for_name");
        Map params = new HashMap();
        params.put("sid", server.getId());
        params.put("name", packageName);
        return m.execute(params);
    }

    /**
     * returns a List proxies available in the given org
     * @param org needed for org information
     * @return list of proxies for org
     */
    public static DataResult<OrgProxyServer> listProxies(Org org) {
        DataResult retval = null;
        SelectMode mode = ModeFactory.getMode("System_queries",
                "org_proxy_servers");
        Map params = new HashMap();
        params.put("org_id", org.getId());
        retval = mode.execute(params);
        return retval;
    }

    /**
     * list systems that can be subscribed to a particular child channel
     * @param user the user
     * @param chan the child channle
     * @return list of SystemOverview objects
     */
    public static List<SystemOverview> listTargetSystemForChannel(User user, Channel chan) {
        DataResult retval = null;
        SelectMode mode = ModeFactory.getMode("System_queries",
                "target_systems_for_channel");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("cid", chan.getId());
        params.put("org_id", user.getOrg().getId());
        retval = mode.execute(params);
        retval.setElaborationParams(Collections.EMPTY_MAP);
        return retval;
    }

    /**
     * Get a list of SystemOverview objects for the systems in an rhnset
     * @param user the user doing the lookup
     * @param setLabel the label of the set
     * @return List of SystemOverview objects
     */
    public static List<SystemOverview> inSet(User user, String setLabel) {
        DataResult retval = null;
        SelectMode mode = ModeFactory.getMode("System_queries",
                "in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set_label", setLabel);
        retval = mode.execute(params);
        retval.setElaborationParams(Collections.EMPTY_MAP);
        return retval;
    }
    
    private static List listDuplicates(User user, String query, List ignored) {
        SelectMode ipMode = ModeFactory.getMode("System_queries",
        query);
    
        Map params = new HashMap();
        params.put("uid", user.getId());
        DataResult<NetworkDto> nets;
        if (ignored.isEmpty()) {
            nets = ipMode.execute(params);
        }
        else {
            nets = ipMode.execute(params, ignored);
        }
         
        
        List<DuplicateSystemGrouping> nodes = new ArrayList<DuplicateSystemGrouping>();
        for (NetworkDto net : nets) {
            boolean found = false;
            for (DuplicateSystemGrouping node : nodes) {
                if (node.addIfMatch(net)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                nodes.add(new DuplicateSystemGrouping(net));
            }
        }
        return nodes;
    }
    
    /**
     * List duplicate systems by ip address
     * @param user the user doing the search
     * @return List of DuplicateSystemGrouping objects
     */
    public static List listDuplicatesByIP(User user) {
        List ignoreIps = new ArrayList();
        ignoreIps.add("127.0.0.1");
        ignoreIps.add("127.0.0.01");
        ignoreIps.add("0");
        return listDuplicates(user, "duplicate_system_ids_ip", ignoreIps);
    }
    
    /**
     * List duplicate systems by mac address
     * @param user the user doing the search
     * @return List of DuplicateSystemGrouping objects
     */
    public static List listDuplicatesByMac(User user) {
        List ignoreMacs = new ArrayList();
        ignoreMacs.add("00:00:00:00:00:00");
        ignoreMacs.add("fe:ff:ff:ff:ff:ff");
        return listDuplicates(user, "duplicate_system_ids_mac", ignoreMacs);
    }
    
    /**
     * List duplicate systems by hostname
     * @param user the user doing the search
     * @return List of DuplicateSystemBucket objects
     */
    public static List listDuplicatesByHostname(User user) {
        return listDuplicates(user, "duplicate_system_ids_hostname", 
                Collections.EMPTY_LIST);
    }
    
    
}
