/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.ChannelVersion;
import com.redhat.rhn.domain.channel.ClonedChannel;
import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.channel.ProductName;
import com.redhat.rhn.domain.channel.ReleaseChannelMap;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.ssm.ChannelActionDAO;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.ChannelPerms;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.dto.ChildChannelDto;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.EssentialChannelDto;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.dto.SystemsPerChannelDto;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.ProxyChannelNotFoundException;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.taskomatic.TaskomaticApi;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.File;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ChannelManager
 * @version $Rev$
 */
public class ChannelManager extends BaseManager {

    private static Logger log = Logger.getLogger(ChannelManager.class);

    public static final String QRY_ROLE_MANAGE = "manage";
    public static final String QRY_ROLE_SUBSCRIBE = "subscribe";

    // Valid RHEL 4 EUS Channel Versions (from rhnReleaseChannelMap):
    public static final Set<String> RHEL4_EUS_VERSIONS;
    static {
        RHEL4_EUS_VERSIONS = new HashSet<String>();
        RHEL4_EUS_VERSIONS.add("4AS");
        RHEL4_EUS_VERSIONS.add("4ES");
    }


    // Product name (also sometimes referred to as OS) is unfortunately very
    // convoluted. For RHEL, in rhnDistChannelMap is appears as "Red Hat Linux", in
    // rhnReleaseChannelMap it is "RHEL AS", and in rhnProductName it's label is "rhel".
    // If this starts to shift we may need to stop relying on constants and find some
    // way to look these up...
    public static final String RHEL_PRODUCT_NAME = "rhel";

    /**
     * Key used to identify the rhn-tools channel.  Used in searches to find the channel
     */
    public static final String TOOLS_CHANNEL_PACKAGE_NAME =
        Config.get().getString("tools_channel.package_name", "rhncfg");


    /**
     * Key used to identify the rhel-arch-server-vt-5 channel.
     * Used in searches to find the channel
     */
    public static final String VIRT_CHANNEL_PACKAGE_NAME =
        Config.get().getString("virt_channel.package_name", "libvirt");

    /**
     * Package name of rhn-virtualization-host
     */
    public static final String RHN_VIRT_HOST_PACKAGE_NAME =
        Config.get().getString("tools_channel.virt_package_name",
                "rhn-virtualization-host");

    /**
     * OS name for the virt child channel.  rhnDistChannelMap.OS field.
     */
    public static final String VT_OS_PRODUCT =
        Config.get().getString("web.virt_product_os_name", "VT");


    private ChannelManager() {

    }

    /**
     * Refreshes the channel with the "newest" packages.  Newest isn't just
     * the latest versions, an errata could have obsoleted a package in which
     * case this would have removed said package from the channel.
     *
     * @param channel channel to be refreshed
     * @param label   the label
     */
    public static void refreshWithNewestPackages(Channel channel, String label) {
        refreshWithNewestPackages(channel.getId(), label);
    }

    /**
     * Refreshes the channel with the "newest" packages.  Newest isn't just
     * the latest versions, an errata could have obsoleted a package in which
     * case this would have removed said package from the channel.
     *
     * @param channelId identifies the channel to be refreshed
     * @param label     the label
     */
    public static void refreshWithNewestPackages(Long channelId, String label) {
        Channel chan = ChannelFactory.lookupById(channelId);
         ChannelFactory.refreshNewestPackageCache(channelId, label);
         if (chan != null) {
             ChannelManager.queueChannelChange(chan.getLabel(), label, label);
         }
    }

    /**
     * Clones the "newest" packages to the clone channel.
     * The reason is to speed up the process, becasue calling
     * rhn_channel.refresh_newest_package
     * takes two minutes for channel with 11000 packages
     *
     * @param fromChannelId original channel id
     * @param toChannel cloned channel
     * @param label label for taskomatic repo_regen request
     */
    public static void cloneNewestPackages(Long fromChannelId, Channel toChannel,
                                                                    String label) {
        ChannelFactory.cloneNewestPackageCache(fromChannelId, toChannel.getId());
        ChannelManager.queueChannelChange(
                toChannel.getLabel(), label, "clone channel");
    }

    /**
     * Returns a list of ChannelTreeNodes that have orgId null
     *      or has a parent with org_id null
     * @param user who we are requesting channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult<ChannelTreeNode> vendorChannelTree(User user,
                                                 ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "vendor_channel_tree");


        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());

        DataResult<ChannelTreeNode> dr =
                makeDataResult(params, params, lc, m, ChannelTreeNode.class);
        Collections.sort(dr);
        return dr;
    }


    /**
     * Returns a list of ChannelTreeNodes that have orgId null
     *      or has a prarent with org_id null
     * @param user who we are requesting Red Hat channels for
     * @param serverCount the number of systems registered to that channel for it to
     *      be popular
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult<ChannelTreeNode> popularChannelTree(User user,
            Long serverCount,
                                                 ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "popular_channel_tree");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        params.put("server_count", serverCount);

        DataResult<ChannelTreeNode> dr =
                makeDataResult(params, params, lc, m, ChannelTreeNode.class);
        Collections.sort(dr);
        return dr;
    }


    /**
     * Returns a list of ChannelTreeNodes that have orgId null
     *      or has a parent with org_id null
     * @param user who we are requesting Red Hat channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult<ChannelTreeNode> myChannelTree(User user,
                                                 ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "my_channel_tree");


        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());

        return makeDataResult(params, params, lc, m, ChannelTreeNode.class);
    }

    /**
     * Returns a list of ChannelTreeNodes containing all channels
     * the trusted org is consuming from a specific org
     * @param org Org that is sharing the channels
     * @param trustOrg org that is consuming the shared channels
     * @param user User of the sharing Org
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult<ChannelTreeNode> trustChannelConsume(Org org, Org trustOrg,
            User user,
                                            ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "trust_channel_consume");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", trustOrg.getId());
        params.put("user_id", user.getId());
        params.put("org_id2", org.getId());
        return makeDataResult(params, params, lc, m, ChannelTreeNode.class);
    }

    /**
     * Returns a list of ChannelTreeNodes containing all channels
     * the user can see
     * @param user who we are requesting channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult<ChannelTreeNode> allChannelTree(User user,
                                            ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "all_channel_tree");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());

        return makeDataResult(params, params, lc, m, ChannelTreeNode.class);
    }

    /**
     * Returns a list of channels owned by the user.
     *
     * @param user cannot be <code>null</code>
     * @return list of maps containing the channel data
     */
    public static DataResult<ChannelTreeNode> ownedChannelsTree(User user) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "owned_channels_tree");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());

        return makeDataResult(params, params, null, m, ChannelTreeNode.class);
    }

    /**
     * Returns a list of ChannelTreeNodes containing shared channels
     * the user can see
     * @param user who we are requesting channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult<ChannelTreeNode> sharedChannelTree(User user,
                                            ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "shared_channel_tree");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());

        return makeDataResult(params, params, lc, m, ChannelTreeNode.class);
    }

    /**
     * Returns a list of ChannelTreeNodes containing end-of-life
     * retired channels the user can see
     * @param user who we are requesting channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult<ChannelTreeNode> retiredChannelTree(User user,
                                                ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "retired_channel_tree");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());

        return makeDataResult(params, params, lc, m, ChannelTreeNode.class);
    }

    /**
     * Returns a list of channels and their parents who are in a particular
     * channel family/entitlement
     * @param user who we are requesting channels for
     * @param familyId Id of the family we want a tree for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's representing the channel family
     */
    public static DataResult<ChannelTreeNode> channelFamilyTree(User user,
                                               Long familyId,
                                               ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_family_tree");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());
        params.put("family_id", familyId);
        params.put("org_id", user.getOrg().getId());

        return makeDataResult(params, params, lc, m, ChannelTreeNode.class);
    }

    /**
     * Returns a dataresult containing the channels in an org.
     * @param orgId The org in question
     * @param pc page control for the user
     * @return Returns a data result containing ChannelOverview dtos
     */
    public static DataResult<ChannelOverview>
            channelsOwnedByOrg(Long orgId, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                                           "channels_owned_by_org");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", orgId);
        return makeDataResult(params, null, pc, m, ChannelOverview.class);
    }

    /**
     * Returns the package ids for packages relevant to a channel for a published errata
     * @param channelId The id for the channel in question
     * @param e the errata in question
     * @return Returns the ids for relevant packages
     */
    public static DataResult<Long> relevantPackages(Long channelId, Errata e) {
        SelectMode m;

        if (e.isPublished()) {
            m = ModeFactory.getMode("Channel_queries",
                                    "relevant_packages_for_channel_published");
        }
        else {
            m = ModeFactory.getMode("Channel_queries",
                                    "relevant_packages_for_channel_unpublished");
        }

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", channelId);
        params.put("eid", e.getId());
        return makeDataResult(params, null, null, m, Long.class);
    }

    /**
     * Returns a Channel object with the given id and user
     * @param cid The id for the channel you want
     * @param userIn The User looking for the channel
     * @return Returns the channel with the given id
     */
    public static Channel lookupByIdAndUser(Long cid, User userIn) {
        Channel channel = ChannelFactory.lookupByIdAndUser(cid, userIn);
        if (channel == null) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("User " + userIn.getId() +
                    " does not have access to channel " + cid +
                    " or the channel does not exist");
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.channel"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.channel"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.channel"));
            throw e;
        }
        return channel;
    }

    /**
     * Returns a Channel object with the given label and user
     * @param label The label for the channel you want
     * @param userIn The User looking for the channel
     * @return Returns the channel with the given id
     */
    public static Channel lookupByLabelAndUser(String label, User userIn) {
        Channel channel = ChannelFactory.lookupByLabelAndUser(label, userIn);
        if (channel == null) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("User " + userIn.getId() +
                    " does not have access to channel " + label +
                    " or the channel does not exist");
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.channel"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.channel"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.channel"));
            throw e;
        }
        return channel;
    }

    /**
     * returns a list of channel ids that the user can subscribe to
     * @param user User to check
     * @return List of all channel ids that are subscribable for this user
     */
    public static Set<Long> subscribableChannelIdsForUser(User user) {
        Set<Long> ret = new HashSet<Long>();

        //Setup items for the query
        SelectMode m = ModeFactory.getMode("Channel_queries", "user_subscribe_perms");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());

        //Execute the query
        DataResult<ChannelPerms> subscribable = m.execute(params);

        for (ChannelPerms perm : subscribable) {
            if (perm.isHasPerm()) {
                ret.add(perm.getId());
            }
        }

        return ret;
    }

    /**
     * channelsForUser returns a list containing the names of the channels
     * that this user has permissions to. If the user doesn't have permissions
     * to any channels, this method returns an empty list.
     * @param user The user in question
     * @return Returns the list of names of channels this user has permission to,
     * an empty list otherwise.
     */
    public static List<String> channelsForUser(User user) {
        //subscribableChannels is the list we'll be returning
        List<String> subscribableChannels = new ArrayList<String>();

        //Setup items for the query
        SelectMode m = ModeFactory.getMode("Channel_queries",
                                           "user_subscribe_perms");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());

        //Execute the query
        DataResult<ChannelPerms> subscribable = m.execute(params);

        /*
         * We now need to go through the subscribable DataResult and
         * add the names of the channels this user has permissions to
         * to the subscribableChannels list.
         */
        Iterator<ChannelPerms> i = subscribable.iterator();
        while (i.hasNext()) {
            ChannelPerms perms = i.next();
            //if the user has permissions for this channel
            if (perms.isHasPerm()) {
                //add the name to the list
                subscribableChannels.add(perms.getName());
            }
        }

        return subscribableChannels;
    }

    /**
     * Returns the list of Channel ids which the given orgid has access to.
     * @param orgid Org id
     * @param cid Base Channel id.
     * @return the list of Channel ids which the given orgid has access to.
     */
    public static List<Channel> userAccessibleChildChannels(Long orgid, Long cid) {
        return ChannelFactory.getUserAcessibleChannels(orgid, cid);
    }

    /**
     * Get the list of Channels with clonable Errata
     * @param org org we want to search against
     * @return List of com.redhat.rhn.domain.Channel objects
     */
    public static List<ClonedChannel> getChannelsWithClonableErrata(Org org) {
        return ChannelFactory.getChannelsWithClonableErrata(org);
    }

    /**
     * Get the list of Channels accessible by an org
     * @param orgid The id of the org
     * @return List of accessible channels
     */
    public static List<Channel> getChannelsAccessibleByOrg(Long orgid) {
        return ChannelFactory.getAccessibleChannelsByOrg(orgid);
    }

    /**
     * Returns list of proxy channel names for a given version
     * @param version proxy version
     * @param server Server
     * @return list of proxy channel names for a given version
     */
    public static Channel getProxyChannelByVersion(String version, Server server) {

        ChannelFamily proxyFamily = ChannelFamilyFactory
                                    .lookupByLabel(ChannelFamilyFactory
                                                   .PROXY_CHANNEL_FAMILY_LABEL,
                                                   null);

        if (proxyFamily == null ||
                    proxyFamily.getChannels() == null ||
                        proxyFamily.getChannels().isEmpty()) {
            if (!ConfigDefaults.get().isSpacewalk()) {
                throw new ProxyChannelNotFoundException();
            }
            return null;
        }

        /* We search for a proxy channel whose version equals the version of
         * proxy trying to activate and whose parent channel is our server's basechannel.
         * This will be the channel we attempt to subscribe the server to.
         */
        for (Channel proxyChan : proxyFamily.getChannels()) {
            if (proxyChan.getProduct() != null &&
                proxyChan.getProduct().getVersion().equals(version) &&
                proxyChan.getParentChannel().equals(server.getBaseChannel())) {
                return proxyChan;
            }
        }
        if (!ConfigDefaults.get().isSpacewalk()) {
            throw new ProxyChannelNotFoundException();
        }

        return null;
    }


    /**
     * Returns the list of all channels the user can see.
     * @param user User whose channels are sought.
     * @return the list of all channels the user can see as a DataResult
     *
     */
    public static List<Map<String, Object>> allChannelsTree(User user) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                                           "all_channels_tree");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());

        return m.execute(params);
    }

    /**
     * Returns list of ChannelArches
     * @return list of ChannelArches
     * @see com.redhat.rhn.domain.channel.ChannelArch
     */
    public static List<ChannelArch> getChannelArchitectures() {
        return ChannelFactory.getChannelArchitectures();
    }

    /**
     * Deletes a software channel
     * @param user User with access to delete the channel.
     * @param label Channel label
     * @throws InvalidChannelRoleException thrown if User does not have access
     * to delete channel.
     * @throws NoSuchChannelException thrown if no channel exists with the
     * given label
     */
    public static void deleteChannel(User user, String label)
        throws InvalidChannelRoleException, NoSuchChannelException {

        Channel toRemove = ChannelFactory.lookupByLabel(user.getOrg(), label);

        if (toRemove == null) {
            throw new NoSuchChannelException();
        }
        if (toRemove.getOrg() == null) {
            throw new PermissionException("api.channel.delete.redhat");
        }
        if (verifyChannelAdmin(user, toRemove.getId())) {
            if (!ChannelFactory.listAllChildrenForChannel(toRemove).isEmpty()) {
                throw new PermissionException("api.channel.delete.haschild");
            }
            if (toRemove.containsDistributions()) {
                ValidatorException.raiseException(
                        "message.channel.cannot-be-deleted.has-distros");

            }
            ChannelManager.unscheduleEventualRepoSync(toRemove, user);
            ChannelManager.queueChannelChange(label,
                    user.getLogin(), "java::deleteChannel");
            ChannelFactory.remove(toRemove);
        }
    }

    /**
     * Unschedule eventual repo sync schedule
     * @param channel relevant channel
     * @param user executive
     */
    public static void unscheduleEventualRepoSync(Channel channel, User user) {
        TaskomaticApi tapi = new TaskomaticApi();
        try {
            String cronExpr = tapi.getRepoSyncSchedule(channel, user);
            if (!StringUtils.isEmpty(cronExpr)) {
                log.info("Unscheduling repo sync schedule with " + cronExpr +
                        " for channel " + channel.getLabel());
                tapi.unscheduleRepoSync(channel, user);
            }
        }
        catch (Exception e) {
            log.warn("Failed to unschedule repo sync for channel " + channel.getLabel());
        }
    }

    /**
     * Verify that a user is a channel admin
     * @param user the user to verify
     * @param cid the channel id to verify
     * @return true if the user is an admin of this channel
     * @throws InvalidChannelRoleException if the user does not have perms
     */
    public static boolean verifyChannelAdmin(User user, Long cid)
        throws InvalidChannelRoleException {

        if (user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            return true;
        }

        return verifyChannelRole(user, cid, QRY_ROLE_MANAGE);
    }

    /**
     * Adds the subscribe role for the passed in user for the passed in channel.
     * @param user The user in question.
     * @param channel The channel in question.
     */
    public static void addSubscribeRole(User user, Channel channel) {
        if (verifyChannelSubscribe(user, channel.getId())) {
            return; //user already has subscribe perms to this channel
        }
        //Insert row into rhnChannelPermission
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                                               "grant_channel_permission");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("cid", channel.getId());
        params.put("role_label", QRY_ROLE_SUBSCRIBE);
        m.executeUpdate(params);
    }

    /**
     * Removes the subscribe role from the passed in user for the passed in channel.
     * @param user The user in question.
     * @param channel The channel in question.
     */
    public static void removeSubscribeRole(User user, Channel channel) {
        if (!verifyChannelSubscribe(user, channel.getId())) {
            return; //user doesn't have subscribe perms to begin with
        }
        //Delete row from rhnChannelPermission
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                                               "revoke_channel_permission");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("cid", channel.getId());
        params.put("role_label", QRY_ROLE_SUBSCRIBE);
        m.executeUpdate(params);
    }

    /**
     * Adds the mange role for the passed in user for the passed in channel.
     * @param user The user in question.
     * @param channel The channel in question.
     */
    public static void addManageRole(User user, Channel channel) {
        if (verifyChannelManage(user, channel.getId())) {
            return; //user already has subscribe perms to this channel
        }
        //Insert row into rhnChannelPermission
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                                               "grant_channel_permission");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("cid", channel.getId());
        params.put("role_label", QRY_ROLE_MANAGE);
        m.executeUpdate(params);
    }

    /**
     * Removes the manage role from the passed in user for the passed in channel.
     * @param user The user in question.
     * @param channel The channel in question.
     */
    public static void removeManageRole(User user, Channel channel) {
        if (!verifyChannelManage(user, channel.getId())) {
            return; //user doesn't have subscribe perms to begin with
        }
        //Delete row from rhnChannelPermission
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                                               "revoke_channel_permission");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("cid", channel.getId());
        params.put("role_label", QRY_ROLE_MANAGE);
        m.executeUpdate(params);
    }

    /**
     * Makes sure the passed in user has subscribe permissions to the channel with the
     * given id.
     * @param user The user in question
     * @param cid The id for the channel in question
     * @return Returns true if the user has permission, false otherwise
     */
    public static boolean verifyChannelSubscribe(User user, Long cid) {

        try {
            return verifyChannelRole(user, cid, QRY_ROLE_SUBSCRIBE);
        }
        catch (InvalidChannelRoleException e) {
            /*
             * We don't really care what the reason is for why this user doesn't have
             * access to this channel, so catch the exception, log it, and simply
             * return false.
             */
            StringBuilder msg = new StringBuilder("User: ");
            msg.append(user.getLogin());
            msg.append(" either does not have subscribe privileges to Channel: ");
            msg.append(cid);
            msg.append(" or ChannelManager.QRY_ROLE_SUBSCRIBE is defined wrong.");
            log.debug(msg.toString(), e);
            return false;
        }
    }

    /**
     * Makes sure the passed in user has manage permissions to the channel with the
     * given id.
     * @param user The user in question
     * @param cid The id for the channel in question
     * @return Returns true if the user has permission, false otherwise
     */
    public static boolean verifyChannelManage(User user, Long cid) {

        try {
            return verifyChannelRole(user, cid, QRY_ROLE_MANAGE);
        }
        catch (InvalidChannelRoleException e) {
            /*
             * We don't really care what the reason is for why this user doesn't have
             * access to this channel, so catch the exception, log it, and simply
             * return false.
             */
            StringBuilder msg = new StringBuilder("User: ");
            msg.append(user.getLogin());
            msg.append(" either does not have subscribe privileges to Channel: ");
            msg.append(cid);
            msg.append(" or ChannelManager.QRY_ROLE_MANAGE is defined wrong.");
            log.debug(msg.toString(), e);
            return false;
        }
    }

    private static boolean verifyChannelRole(User user, Long cid, String role)
        throws InvalidChannelRoleException {

        CallableMode m = ModeFactory.getCallableMode(
                "Channel_queries", "verify_channel_role");

        Map<String, Object> inParams = new HashMap<String, Object>();
        inParams.put("cid", cid);
        inParams.put("user_id", user.getId());
        inParams.put("role", role);

        Map<String, Integer> outParams = new HashMap<String, Integer>();
        outParams.put("result", new Integer(Types.VARCHAR));
        Map<String, Object> result = m.execute(inParams, outParams);

        String reason = (String) result.get("result");
        if (reason != null) {
            throw new InvalidChannelRoleException(reason);
        }
        return true;
    }

    /**
     * Returns true if the given channel is globally subscribable for the
     * given org.
     * @param user User
     * @param chanLabel label of Channel to validate
     * @return true if the given channel is globally subscribable for the
     */
    public static boolean isGloballySubscribable(User user, String chanLabel) {
        Channel c = lookupByLabelAndUser(chanLabel, user);
        return ChannelFactory.isGloballySubscribable(user.getOrg(), c);
    }

    /**
     * Returns the Channel whose label matches the given label.
     * @param org The org of the user looking up the channel
     * @param label Channel label sought.
     * @return the Channel whose label matches the given label.
     */
    public static Channel lookupByLabel(Org org, String label) {
        return ChannelFactory.lookupByLabel(org, label);
    }

    /**
     * Returns the latest packages in the channel. This call will return more details
     * about the channel than the API specific call
     * {@link #latestPackagesInChannel(com.redhat.rhn.domain.channel.Channel)}.
     *
     * @param channelId identifies the channel
     * @return list of packages in this channel
     */
    public static DataResult<PackageListItem> latestPackagesInChannel(Long channelId) {
        SelectMode m = ModeFactory.getMode(
                "Package_queries", "latest_packages_in_channel");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", channelId);

        return m.execute(params);
    }

    /**
     * Returns list of latest packages in channel
     * @param channel channel whose packages are sought
     * @return list of latest packages in channel
     */
    public static List<Map<String, Object>> latestPackagesInChannel(Channel channel) {
        SelectMode m = ModeFactory.getMode(
                "Package_queries", "latest_packages_in_channel_api");

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", channel.getId());

        return m.execute(params);
    }


    /**
     * List the errata applicable to a channel between start and end date
     * @param channel channel whose errata are sought
     * @param start start date
     * @param end end date
     * @param user the user doing the list
     * @param lastModified use query selecting by last_modified timestamp or not
     * @return the errata applicable to a channel
     */
    public static DataResult<ErrataOverview> listErrata(Channel channel, Date start,
            Date end, boolean lastModified, User user) {
        String mode = "in_channel";
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channel.getId());

        if (start != null) {
            params.put("start_date", new Timestamp(start.getTime()));
            mode = "in_channel_after";

            if (end != null) {
                params.put("end_date", new Timestamp(end.getTime()));
                mode = "in_channel_between";
            }

            if (lastModified) {
                mode += "_last_modified";
            }
        }
        SelectMode m = ModeFactory.getMode(
                "Errata_queries", mode);

        DataResult<ErrataOverview> dr = m.execute(params);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        dr.setElaborationParams(elabParams);
        return dr;
    }


    /**
     * List the errata applicable to a channel (used for repomd generation)
     * @param channelId channel whose errata are sought
     * @return the errata applicable to a channel
     */
    public static DataResult<ErrataOverview> listErrataSimple(Long channelId) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channelId);
        SelectMode m = ModeFactory.getMode("Errata_queries", "simple_in_channel");

        DataResult<ErrataOverview> dr = m.execute(params);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        dr.setElaborationParams(elabParams);
        return dr;
    }

    /**
     * List the errata applicable to a channel between start and end date
     * @deprecated Use appropriate listErrata
     * @param channel channel whose errata are sought
     * @param start start date
     * @param end end date
     * @return the errata applicable to a channel
     */
    @Deprecated
    public static DataResult<Map<String, Object>> listErrataForDates(Channel channel,
            String start, String end) {
        String mode = "relevant_to_channel_deprecated";
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channel.getId());

        if (!StringUtils.isEmpty(start)) {
            params.put("start_date_str", start);
            mode = "relevant_to_channel_after_deprecated";

            if (!StringUtils.isEmpty(end)) {
                params.put("end_date_str", end);
                mode = "relevant_to_channel_between_deprecated";
            }
        }

        SelectMode m = ModeFactory.getMode(
                "Errata_queries", mode);

        return m.execute(params);
    }

    /**
     * List the errata of a particular type that are applicable to a channel.
     * @param channel channel whose errata are sought
     * @param type type of errata
     * @return the errata applicable to a channel
     */
    public static DataResult<Map<String, Object>> listErrataByType(Channel channel,
            String type) {

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channel.getId());
        params.put("type", type);

        SelectMode m = ModeFactory.getMode(
                "Errata_queries", "relevant_to_channel_by_type");

        return m.execute(params);
    }

    /**
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @param startDate package start date
     * @param endDate package end date
     * @return list of packages in channel
     */
    public static List<PackageDto> listAllPackages(Channel channel, String startDate,
            String endDate) {
        String mode = "all_packages_in_channel";
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channel.getId());

        if (!StringUtils.isEmpty(startDate)) {
            params.put("start_date_str", startDate);
            mode = "all_packages_in_channel_after";
        }

        if (!StringUtils.isEmpty(endDate)) {
            params.put("end_date_str", endDate);
            mode = "all_packages_in_channel_between";
        }

        SelectMode m = ModeFactory.getMode("Package_queries", mode);

        return m.execute(params);
    }

    /**
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @return list of packages in channel
     */
    public static List<PackageDto> listAllPackages(Channel channel) {
        String mode = "all_packages_in_channel";
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", channel.getId());

        SelectMode m = ModeFactory.getMode("Package_queries", mode);

        return m.execute(params);
    }

    /**
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @param startDate package start date
     * @param endDate package end date
     * @return list of packages in channel
     */
    public static List<PackageDto> listAllPackages(Channel channel, Date startDate,
            Date endDate) {

        // convert the start and end dates to a string representation
        // that can be used in the db query...
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        String startDateStr = null;
        String endDateStr = null;

        if (startDate != null) {
            startDateStr = sdf.format(startDate);
        }
        if (endDate != null) {
            endDateStr = sdf.format(endDate);
        }

        return listAllPackages(channel, startDateStr, endDateStr);
    }

    /**
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @param startDate package start date
     * @param endDate package end date
     * @return list of packages in channel
     * @deprecated The only thing to use this is
     * ChannelSoftwareHandler.listAllPackagesByDate which is itself depricated
     */
    @Deprecated
    public static List<Map<String, Object>> listAllPackagesByDate(Channel channel,
            String startDate,
        String endDate) {

        String mode = "all_packages_in_channel_by_date";
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channel.getId());

        if (!StringUtils.isEmpty(startDate)) {
            params.put("start_date_str", startDate);
            mode = "all_packages_in_channel_after_by_date";
        }

        if (!StringUtils.isEmpty(endDate)) {
            params.put("end_date_str", endDate);
            mode = "all_packages_in_channel_between_by_date";
        }

        SelectMode m = ModeFactory.getMode(
                "Package_queries", mode);

        return m.execute(params);
    }

    /**
     * Get the id of latest packages equal in the passed in Channel and name
     *
     * @param channelId to lookup package against
     * @param packageName to check
     * @return List containing Maps of "CP.package_id, CP.name_id, CP.evr_id"
     */
    public static Long getLatestPackageEqual(Long channelId, String packageName) {
        List<Map<String, Object>> latestPkgs =
                listLatestPackagesEqual(channelId, packageName);
        if (latestPkgs != null && latestPkgs.size() > 0) {
            return (Long) latestPkgs.get(0).get("package_id");
        }
        return null;
    }

    /**
     * Get the id of latest packages located in the channel tree where channelId
     * is a parent
     *
     * @param channelId to lookup package against
     * @param packageName to check
     * @return package id of the newest package with a matching name
     */
    public static Long getLatestPackageEqualInTree(Long channelId,
            String packageName) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                "latest_package_equal_in_tree");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channelId);
        params.put("name", packageName);
        // Maps of "package_id, evr_id, arch_label"
        List<Map<String, Object>> results = m.execute(params);

        // See bug 1094364. If we wanted to really really fix this we would have
        // to add a channel-arch-to-default-package-arch mapping in the database
        // for every possible architecture. However that would still be somewhat
        // of a heuristic because we may want to install a non-default-arch package
        // at some point in the future. Much easier and almost just as good to
        // have a hueristic here that returns the package arch we probably want.
        if (results != null && results.size() > 0) {
            Map<String, Object> row = results.get(0);
            if (results.size() == 1) {
                return (Long) row.get("package_id");
            }
            // "default arches". If a channel contains multiple arches (eg.
            // "i386" and "x86_86") then these are probably the arches that we
            // want to install by default.
            List<String> defaultArches = new ArrayList<String>();
            defaultArches.add("x86_64");
            defaultArches.add("sparc64");
            defaultArches.add("s390x");
            defaultArches.add("armv7hnl");

            // more than one result. they are ordered based on EVR, so let's
            // examine the packages that have the same EVR as the first one and
            // see if we can find one that is of the default arch. If we run out
            // or go down to an older EVR, just return first result as a fallback.
            for (Map<String, Object> result : results) {
                if (!((Long) result.get("evr_id")).equals(row.get("evr_id"))) {
                    break;
                }
                if (defaultArches.contains(result.get("arch_label"))) {
                    return (Long) result.get("package_id");
                }
            }
            return (Long) row.get("package_id");
        }
        return null;
    }

    /**
     * List the latest packages equal in the passed in Channel and name
     *
     * @param channelId to lookup package against
     * @param packageName to check
     * @return List containing Maps of "CP.package_id, CP.name_id, CP.evr_id"
     */
    public static List<Map<String, Object>> listLatestPackagesEqual(Long channelId,
            String packageName) {
        if (log.isDebugEnabled()) {
            log.debug("listLatestPackagesEqual: " +
                    channelId + " pn: " + packageName);
        }
        SelectMode m = ModeFactory.getMode("Channel_queries",
            "latest_package_equal");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channelId);
        params.put("name", packageName);
        return m.execute(params);

    }

    /**
     * List the latest packages in a channel *like* the given package name.
     *
     * @param channelId to lookup package against
     * @param packageName to check
     * @return List containing Maps of "CP.package_id, CP.name_id, CP.evr_id"
     */
    public static List<Map<String, Object>> listLatestPackagesLike(Long channelId,
            String packageName) {
        if (log.isDebugEnabled()) {
            log.debug("listLatestPackagesLike() cid: " +
                    channelId + " packageName : " + packageName);
        }
        SelectMode m = ModeFactory.getMode("Channel_queries",
            "latest_package_like");
        StringBuilder pname = new StringBuilder();
        pname.append("%");
        pname.append(packageName);
        pname.append("%");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channelId);
        params.put("name", pname.toString());
        return m.execute(params);

    }

    /**
     * Finds the id of a child channel with the given parent channel id that contains
     * a package with the given name.  Will only find one child channel even if there are
     * many that qualify.
     * @param org Organization of the current user.
     * @param parent The id of the parent channel
     * @param packageName The exact name of the package sought for.
     * @return The id of a single child channel found or null if nothing found.
     */
    public static Long findChildChannelWithPackage(Org org, Long parent, String
            packageName) {

        List<Long> cids = findChildChannelsWithPackage(org, parent, packageName, true);
        if (cids.isEmpty()) {
            return null;
        }
        return cids.get(0);
    }

    /**
     * Finds the id of a child channel with the given parent channel id that contains
     * a package with the given name.  Returns all child channel unless expectOne is True
     * @param org Organization of the current user.
     * @param parent The id of the parent channel
     * @param packageName The exact name of the package sought for.
     * @param expectOne if true, throws exception, if more child channels are returned
     * @return List of child channel ids
     */
    public static List<Long> findChildChannelsWithPackage(Org org, Long parent, String
            packageName, boolean expectOne) {

        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_with_package");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("parent", parent);
        params.put("package", packageName);
        params.put("org_id", org.getId());

        DataResult dr = m.execute(params);
        List<Long> channelIds = new ArrayList<Long>();
        for (Iterator it = dr.iterator(); it.hasNext();) {
            channelIds.add((Long) ((Map) it.next()).get("id"));
        }
        if (expectOne && channelIds.size() > 1) {
            // Multiple channels have this package, highly unlikely we can guess which
            // one is the right one so we'll raise an exception and let the caller
            // decide what to do.
            throw new MultipleChannelsWithPackageException(channelIds);
        }

        return channelIds;
    }

    /**
     * Finds the ids of all child channels that contain
     * a package with the given name.  Will only all the child channels.
     * @param packageName The exact name of the package sought for.
     * @param org the org this is in
     * @return The list of ids
     */
    public static List<Long> findChildChannelsWithPackage(String packageName, Org org) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                        "child_channels_with_package");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("package", packageName);
        params.put("org_id", org.getId());
        //whittle down until we have the piece we want.
        DataResult<Map<String, Long>> dr = m.execute(params);
        List<Long> cids = new LinkedList<Long>();
        for (Map<String, Long> row : dr) {
            cids.add(row.get("id"));
        }
        return cids;
    }
    /**
     * Subscribe a Server to the first child channel of its base channel that contains
     * the packagename passed in.  Returns false if it can't be subscribed.
     *
     * @param user requesting the subscription
     * @param current System to be subbed
     * @param packageName to use to lookup the channel with.
     * @return Channel we subscribed to, null if not.
     */
    public static Channel subscribeToChildChannelWithPackageName(User user, Server current,
                String packageName) {

        log.debug("subscribeToChildChannelWithPackageName: " + current.getId() +
                " name: " + packageName);
        /*
         * First make sure that we have a base channel.
         * Second, make sure that the base channel has an RHN Tools child channel.
         * Third, try to subscribe to that child channel.
         */
        if (current.getBaseChannel() == null) {
            log.debug("base channel for server is null. returning null");
            return null;
        }

        // We know its the channel we want if it has the package in it:
        Long bcid = current.getBaseChannel().getId();
        log.debug("found basechannel: " + bcid);

        Long cid = null;

        try {
            cid = ChannelManager.findChildChannelWithPackage(user.getOrg(), bcid,
                    packageName);
        }
        catch (MultipleChannelsWithPackageException e) {
            // If multiple channels have the package we're looking for, see if the server
            // already has access to one of them before raising this exception.
            for (Long channelId : e.getChannelIds()) {
                Channel c = ChannelManager.lookupByIdAndUser(channelId, user);
                if (current.isSubscribed(c)) {
                    // found a channel already subscribed
                    cid = channelId;
                    break;
                }
            }
            if (cid == null) {
                // Didn't find one, re-throw the exception:
                throw e;
            }
        }

        if (cid == null) { // Didnt find it ..
            log.debug("didnt find a child channel with the package.");
            return null;
        }

        Channel channel = null;
        try {
            channel = ChannelManager.lookupByIdAndUser(cid, user);
        }
        catch (LookupException e) {
            log.warn("User " + user.getLogin() + " does not have access to channel " +
                    cid + ".");
        }

        if (!current.isSubscribed(channel)) {
            if (log.isDebugEnabled()) {
                log.debug("Subscribing server to channel: " + channel);
            }
            SystemManager.subscribeServerToChannel(user, current, channel);
        }
        return channel;
    }

    /**
     * Subscribe a Server to the first child channel of its base channel supplies OS level
     * functionality based on the "osProductName" passed in.  In DB terms it is looking
     * for a child channel that has an entry in rhnDistChannel map with an OS field
     * matching the osProductName.
     *
     * @param user requesting the subscription
     * @param current System to be subbed
     * @param osProductName to use to lookup the channel with.
     * @return Channel we subscribed to, null if not.
     */
    public static Channel subscribeToChildChannelByOSProduct(User user, Server current,
                String osProductName) {

        /*
         * First make sure that we have a base channel.
         * Second, make sure that the base channel has an RHN Tools child channel.
         * Third, try to subscribe to that child channel.
         */
        if (current.getBaseChannel() == null) {
            log.debug("base channel for server is null. returning null");
            return null;
        }

        Channel baseChannel = current.getBaseChannel();
        Channel foundChannel = null;

        Iterator<Channel> i =
                ChannelManager.userAccessibleChildChannels(
                user.getOrg().getId(), baseChannel.getId()).iterator();
        while (i.hasNext()) {
            Channel child = i.next();
            Set<DistChannelMap> distChannelMaps = child.getDistChannelMaps();
            log.debug("distChannelMaps null? " + (distChannelMaps == null));
            if (distChannelMaps != null) {
                Iterator<DistChannelMap> di = distChannelMaps.iterator();
                while (di.hasNext()) {
                    DistChannelMap dcm = di.next();
                    log.debug("got DistChannelMap: " + dcm);
                    if (dcm.getOs().equals(osProductName)) {
                        log.debug("found a channel to subscribe: " + dcm.getChannel());
                        foundChannel = dcm.getChannel();
                        break;
                    }
                }
            }
        }

        if (foundChannel != null) {
           log.debug("we found a channel, now lets see if we should sub");
           if (!current.isSubscribed(foundChannel)) {
                if (log.isDebugEnabled()) {
                    log.debug("subChildChannelByOSProduct " +
                            "Subscribing server to channel: " + foundChannel);
                }
                SystemManager.subscribeServerToChannel(user, current, foundChannel);
           }
        }
        log.debug("subscribeToChildChannelByOSProduct returning: " + foundChannel);
        return foundChannel;

    }

    /**
     * For the specified server, make a best-guess effort at what its base-channel
     * SHOULD be
     * @param usr User asking the question
     * @param s Server of interest
     * @return Channel that could serve as a base-channel for the Server
     */
    public static Channel guessServerBase(User usr, Server s) {
        Long guessedId = guessServerBase(usr, s.getId());

        Channel c = null;
        if (guessedId != null) {
            c = ChannelFactory.lookupByIdAndUser(guessedId, usr);
        }
        return c;
    }

    /**
     * For the specified server, make a best-guess effort at what its base-channel
     * SHOULD be
     * @param usr User asking the question
     * @param sid Server id of interest
     * @return Channel id
     */
    public static Long guessServerBase(User usr, Long sid) {
        // Figure out what this server's base OUGHT to be
        CallableMode sbm = ModeFactory.getCallableMode(
                "Channel_queries", "guess_server_base");
        Map<String, Object> inParams = new HashMap<String, Object>();
        inParams.put("server_id", sid);
        Map<String, Integer> outParams = new HashMap<String, Integer>();
        outParams.put("result", new Integer(Types.NUMERIC));
        Map<String, Object> result = sbm.execute(inParams, outParams);

        return (Long) result.get(("result"));
    }

    /**
     * Convert redhat-release release values to those that are stored in the
     * rhnReleaseChannelMap table.
     *
     * RHEL 4 release samples: 7.6, 8, 9
     * RHEL 5 release samples: 5.1.0.1, 5.2.0.2, 5.3.0.3
     *
     * RHEL 4 must be treated specially, if the release is X.Y, we only wish to look at
     * the X portion.
     *
     * For RHEL 5 and presumably all future releases, we only look at the W.X.Y portion of
     * W.X.Y.Z.
     *
     * @param rhelVersion RHEL version we're comparing release for. (5Server, 4AS, 4ES)
     * @param originalRelease Original package release.
     * @return Release version for rhnReleaseChannelMap.
     */
    public static String normalizeRhelReleaseForMapping(String rhelVersion,
            String originalRelease) {

        String [] tokens = originalRelease.split("\\.");

        if (RHEL4_EUS_VERSIONS.contains(rhelVersion)) {
            if (tokens.length <= 1) {
                return originalRelease;
            }
            return tokens[0];
        }

        if (tokens.length <= 3) {
            return originalRelease;
        }

        StringBuilder buf = new StringBuilder();
        buf.append(tokens[0]);
        buf.append(".");
        buf.append(tokens[1]);
        buf.append(".");
        buf.append(tokens[2]);
        return buf.toString();
    }

    /**
     * Search for the tools channel beneath the specified base channel.
     * Queries for package names that look like kickstart packages, and
     * assumes that if any are found in this channel is must be the
     * tools channel.
     * @param baseChannel Base channel to search for a tools channel beneath.
     * @param user User performing the search.
     * @return Tools channel if found, null otherwise.
     */
    public static Channel getToolsChannel(Channel baseChannel, User user) {
        if (log.isDebugEnabled()) {
            log.debug("getToolsChannel, baseChannel: " + baseChannel.getLabel());
        }

        Iterator<Channel> i =
                ChannelManager.userAccessibleChildChannels(
                user.getOrg().getId(), baseChannel.getId()).iterator();

        if (log.isDebugEnabled()) {
            log.debug("getToolsChannel, userAccessibleChildChannels: " + i.hasNext());
        }
        while (i.hasNext()) {
            Channel child = i.next();
            if (log.isDebugEnabled()) {
                log.debug("getToolsChannel, trying: " + child.getLabel());
            }
            // First search for legacy kickstart package names:
            List<Map<String, Object>> kspackages =
                    ChannelManager.
                listLatestPackagesLike(child.getId(),
                        KickstartData.LEGACY_KICKSTART_PACKAGE_NAME);
            if (kspackages.size() > 0) {
                return child;
            }

            // Search for rhn-kickstart package name:
            kspackages = ChannelManager.listLatestPackagesEqual(child.getId(),
                    ConfigDefaults.get().getKickstartPackageName());
            if (kspackages.size() > 0) {
                return child;
            }
        }
        return null;
    }

    /**
     * Examines each DistChannelMap associated with the given channel to build the
     * master set of all supported channel version constants.
     * @param channel Channel to return the versions for.
     * @return Set of all supported channel versions.
     */
    public static Set<ChannelVersion> getChannelVersions(Channel channel) {
        Set<ChannelVersion> returnSet = new HashSet<ChannelVersion>();
        Iterator<DistChannelMap> iter = channel.getDistChannelMaps().iterator();
        while (iter.hasNext()) {
            DistChannelMap dcm = iter.next();

            returnSet.add(ChannelVersion.getChannelVersionForDistChannelMap(dcm));
        }
        return returnSet;
    }

    /**
     * Returns all channels that are applicable to the systems currently selected in
     * the SSM.
     *
     * @param user logged in user
     * @param lc   controller for the UI list
     * @return description of all channels applicable to the systems
     */
    public static DataResult<ChannelTreeNode> getChannelsForSsm(User user, ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_tree_ssm_install");

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        params.put("set_label", RhnSetDecl.SYSTEMS.getLabel());
        DataResult dr = makeDataResult(params, params, lc, m);

        return dr;
    }

    /**
     * Returns the list of all child-channels in the user's System Set
     * @param user User whose channels are sought.
     * @return the list of all child-channels in that user's System Set
     */
    public static DataResult<ChildChannelDto> childrenAvailableToSet(User user) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "children_in_set");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());

        return m.execute(params);
    }

    /**
     * Returns the list of all base-channels represented in the System Set.
     * @param user User whose System Set is being considered
     * @return the list of all base-channels in that set.
     */
    public static DataResult<SystemsPerChannelDto> baseChannelsInSet(User user) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "base_channels_in_set");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("user_id", user.getId());

        return m.execute(params);
    }

    private static boolean isDefaultBaseChannel(Org org, Channel baseChan, String version) {
        if (baseChan == null) {
            return false;
        }

        Channel defaultBaseChan = getDefaultBaseChannel(org, version,
            baseChan.getChannelArch());
        if (defaultBaseChan == null) {
            return false;
        }
        return defaultBaseChan.getId().equals(baseChan.getId());
    }

    private static Channel getDefaultBaseChannel(Org org, String version, ChannelArch
            arch) {
        DistChannelMap dcm = ChannelManager.lookupDistChannelMapByPnReleaseArch(
                org, RHEL_PRODUCT_NAME, version, arch);
        if (dcm == null) {
            return null;
        }
        return dcm.getChannel();
    }


    /**
     * Given a system, find all the base channels available to the specified user
     * that the system may be re-subscribed to.
     *
     * If the system is currently subscribed to the default RHEL channel for their
     * version (i.e. main RHEL 4), then only the *newest* available EUS channel
     * will be included.
     *
     * If the system is already subscribed to a non-default channel (i.e. EUS or custom),
     * we look up the redhat-release package information on the system and use it's
     * version/release information to search for all *newer* EUS channels.
     *
     * Custom base channels for this organization will always be returned,
     * regardless of the RHEL version.
     *
     * @param usr requesting list
     * @param s Server to check against
     * @return List of Channel objects that match
     */
    public static List<EssentialChannelDto> listBaseChannelsForSystem(User usr,
            Server s) {

        List<EssentialChannelDto> channelDtos = new LinkedList<EssentialChannelDto>();
        PackageEvr releaseEvr = PackageManager.lookupReleasePackageEvrFor(s);
        if (releaseEvr != null) {
            String rhelVersion = releaseEvr.getVersion();

            List<EssentialChannelDto> baseEusChans = new LinkedList<EssentialChannelDto>();
            if (isDefaultBaseChannel(usr.getOrg(), s.getBaseChannel(), rhelVersion)) {
                EssentialChannelDto baseEus = lookupLatestEusChannelForRhelVersion(usr,
                        rhelVersion, s.getBaseChannel().getChannelArch().getId());
                if (baseEus != null) {
                    baseEusChans.add(baseEus);
                }
            }
            else {
                Channel currBase = s.getBaseChannel();
                if (currBase != null) {
                    ReleaseChannelMap rcm =
                            lookupDefaultReleaseChannelMapForChannel(currBase);
                    if (rcm != null) {
                        baseEusChans = listBaseEusChannelsByVersionReleaseAndServerArch(
                                usr, rhelVersion, releaseEvr.getRelease(),
                                s.getServerArch().getLabel());
                    }
                }
            }
            channelDtos.addAll(baseEusChans);
        }

        // Get all the possible base-channels owned by this Org
        channelDtos.addAll(listCustomBaseChannelsForServer(s));

        for (DistChannelMap dcm : ChannelFactory.listCompatibleDcmByServerInNullOrg(s)) {
            channelDtos.add(new EssentialChannelDto(dcm.getChannel()));
        }

        return channelDtos;
    }

    /**
     * Given a base-channel, find all the base channels available to the specified user
     * that a system with the specified channel may be re-subscribed to.
     *
     * @param u User of interest
     * @param inChan Base-channel of interest
     * @return List of channels that a system subscribed to "c" could be re-subscribed to
     */
    public static List<EssentialChannelDto> listCompatibleBaseChannelsForChannel(User u,
            Channel inChan) {

        List<EssentialChannelDto> retval = new ArrayList<EssentialChannelDto>();

        // Get all the custom-channels owned by this org and add them
        for (Channel c : ChannelFactory.listCustomBaseChannelsForSSM(u, inChan)) {
            retval.add(new EssentialChannelDto(c));
        }

        for (Channel c :
                    ChannelFactory.listCompatibleDcmForChannelSSMInNullOrg(u, inChan)) {
                retval.add(new EssentialChannelDto(c));
        }

        List<EssentialChannelDto> eusBaseChans = new LinkedList<EssentialChannelDto>();

        ReleaseChannelMap rcm = lookupDefaultReleaseChannelMapForChannel(inChan);
        if (rcm != null) {
                    eusBaseChans.addAll(listBaseEusChannelsByVersionReleaseAndChannelArch(
                            u, rcm.getVersion(), rcm.getRelease(),
                            inChan.getChannelArch().getId()));
        }
        else {
            for (DistChannelMap dcm : inChan.getDistChannelMaps()) {
                String rhelVersion = dcm.getRelease();
                if (isDefaultBaseChannel(u.getOrg(), inChan, rhelVersion)) {
                    EssentialChannelDto latestEus = lookupLatestEusChannelForRhelVersion(u,
                            rhelVersion, inChan.getChannelArch().getId());
                    if (latestEus != null) {
                        eusBaseChans.add(latestEus);
                    }
                }
            }
        }
        retval.addAll(eusBaseChans);

        for (EssentialChannelDto dto : retval) {
            if (dto.getId().longValue() == inChan.getId().longValue()) {
                retval.remove(dto); // normally not a good idea, but we do break
                break;
            }
        }

       return retval;
    }

    /**
     * Lookup the default release channel map for the given channel. Returns null if no
     * default is found.
     *
     * @param channel Channel to lookup mapping for
     * @return Default ReleaseChannelMap
     */
    public static ReleaseChannelMap lookupDefaultReleaseChannelMapForChannel(
            Channel channel) {
        return ChannelFactory.lookupDefaultReleaseChannelMapForChannel(channel);
    }

    /**
     * Lookup the dist channel map for the given os, release, and channel arch.
     * Returns null if none is found.
     * @param org organization
     * @param productName Product name.
     * @param release Version.
     * @param channelArch Channel arch.
     * @return DistChannelMap, null if none is found
     */
    public static DistChannelMap lookupDistChannelMapByPnReleaseArch(Org org,
            String productName, String release, ChannelArch channelArch) {
        return ChannelFactory.lookupDistChannelMapByPnReleaseArch(org, productName,
                release, channelArch);
    }

    /**
     * Lookup the EUS base channels suitable for the given version, release, and
     * server arch.
     *
     * NOTE: Release not actually used in the database query, must filter manually
     * in application code due to some very specific requirements on how it must
     * be compared. See normalizeRhelReleaseForMapping for more info.
     *
     * @param user User performing the query.
     * @param version RHEL version.
     * @param release RHEL version release.
     * @param serverArch RHEL server arch.
     * @return List of EssentialChannelDto's.
     */
    public static List<EssentialChannelDto>
        listBaseEusChannelsByVersionReleaseAndServerArch(User user,
            String version, String release, String serverArch) {

        log.debug("listBaseEusChannelsByVersionReleaseAndServerArch()");
        log.debug("   version = " + version);
        log.debug("   release = " + release);
        log.debug("   serverArch = " + serverArch);
        SelectMode m = ModeFactory.getMode("Channel_queries",
                    "base_eus_channels_by_version_release_server_arch");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("product_name_label", RHEL_PRODUCT_NAME);
        params.put("version", version);
        params.put("server_arch", serverArch);
        DataResult<EssentialChannelDto> dr =
                makeDataResult(params, new HashMap<String, Object>(), null, m,
                        EssentialChannelDto.class);

        List<EssentialChannelDto> result = new LinkedList<EssentialChannelDto>();
        EusReleaseComparator comparator = new EusReleaseComparator(version);
        for (EssentialChannelDto dto : dr) {
            log.debug(dto.getId());
            if (comparator.compare(dto.getRelease(), release) >= 0) {
                result.add(dto);
            }
        }

        return result;
    }

    /**
     * Lookup the EUS base channels suitable for the given version, release, and
     * channel arch.
     *
     * NOTE: Release not actually used in the database query, must filter manually
     * in application code due to some very specific requirements on how it must
     * be compared. See normalizeRhelReleaseForMapping for more info.
     *
     * @param user User performing the query.
     * @param version RHEL version.
     * @param release RHEL release.
     * @param channelArchId Channel arch.
     * @return List of EssentialChannelDto's.
     */
    public static List<EssentialChannelDto>
        listBaseEusChannelsByVersionReleaseAndChannelArch(User user,
            String version, String release, Long channelArchId) {

        log.debug("listBaseEusChannelsByVersionReleaseAndChannelArch()");
        SelectMode m = ModeFactory.getMode("Channel_queries",
                    "base_eus_channels_by_version_channel_arch");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        log.debug("   version = " + version);
        log.debug("   release = " + release);
        log.debug("   channelArch = " + channelArchId);
        params.put("product_name_label", RHEL_PRODUCT_NAME);
        params.put("version", version);
        params.put("channel_arch_id", channelArchId);
        DataResult<EssentialChannelDto> dr =
                makeDataResult(params, new HashMap<String, Object>(), null, m,
                        EssentialChannelDto.class);

        List<EssentialChannelDto> result = new LinkedList<EssentialChannelDto>();
        EusReleaseComparator comparator = new EusReleaseComparator(version);
        for (EssentialChannelDto dto : dr) {
            if (comparator.compare(dto.getRelease(), release) > 0) {
                result.add(dto);
            }
        }

        return result;
    }

    /**
     * Lookup the latest EUS base channel for the given version and server arch.
     *
     * Sorts based on the release column. null will be returned if none found.
     *
     * @param user User performing the query.
     * @param rhelVersion RHEL version.
     * @param channelArchId Channel arch id.
     * @return EssentialChannelDto, or null if no entry is found.
     */
    public static EssentialChannelDto lookupLatestEusChannelForRhelVersion(
            User user, String rhelVersion, Long channelArchId) {

        log.debug("listBaseEusChannelsByVersionAndChannelArch");
        SelectMode m = ModeFactory.getMode("Channel_queries",
                    "base_eus_channels_by_version_channel_arch");

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        log.debug("   version = " + rhelVersion);
        log.debug("   channelArch = " + channelArchId);
        params.put("product_name_label", RHEL_PRODUCT_NAME);
        params.put("version", rhelVersion);
        params.put("channel_arch_id", channelArchId);
        DataResult<EssentialChannelDto> dr =
                makeDataResult(params, new HashMap<String, Object>(), null, m,
                        EssentialChannelDto.class);
        if (dr.size() == 0) {
            return null;
        }
        Collections.sort(dr, new EusReleaseComparator(rhelVersion));
        return dr.get(dr.size() - 1);
    }

    /**
     * List base channels offered for the given server
     * @param server server
     * @return List of channels.
     */
    public static DataResult<EssentialChannelDto> listCustomBaseChannelsForServer(
            Server server) {
        SelectMode m =
            ModeFactory.getMode("Channel_queries", "custom_base_channels_for_server");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", server.getOrg().getId());
        params.put("server_arch_id", server.getServerArch().getId());
        return makeDataResult(params, new HashMap<String, Long>(), null, m,
                EssentialChannelDto.class);
    }

    /**
     * List base channels (including Red Hat channels) for a given org.
     * @param u User to list base channels for.
     * @return List of Channels
     */
    public static List<Channel> findAllBaseChannelsForOrg(User u) {
        return ChannelFactory.listAllBaseChannels(u);
    }

    /**
     * Given an old and a new base channel, return a map of old child channels to new
     * child channels with the same product name. If no match can be found the old
     * child channel is omitted from the map.
     *
     * @param oldBaseChannel the base channel to which we need to find the equivalent
     *      child channels
     * @param newBaseChannel the base channel which holds the a child channel with
     *      same product name
     * @param user user needed for authentication purposes
     * @return a map [childChannel1:childChannel2]
     */
    public static Map<Channel, Channel> findCompatibleChildren(Channel oldBaseChannel,
            Channel newBaseChannel, User user) {

        Map<Channel, Channel> compatibleChannels = new HashMap<Channel, Channel>();
        if (oldBaseChannel == null) {
            return compatibleChannels;
        }
        if (oldBaseChannel.equals(newBaseChannel)) {
            Map<Channel, Channel> result = new HashMap<Channel, Channel>();
            for (Channel channel : oldBaseChannel.getAccessibleChildrenFor(user)) {
                result.put(channel, channel);
            }
            return result;
        }

        Map <ProductName, Channel> prodChannels =
            new HashMap<ProductName, Channel>();
        Set<ProductName> nonUniqueProducts = new HashSet<ProductName>();
        List<Channel> newChildren = newBaseChannel.getAccessibleChildrenFor(user);
        for (Channel channel : newChildren) {
            if (channel.getProductName() != null) {
                if (prodChannels.get(channel.getProductName()) != null) {
                    nonUniqueProducts.add(channel.getProductName());
                }
                prodChannels.put(channel.getProductName(), channel);
            }
        }

        Map<Channel, List<Channel>> originalToClones = getOrignalToClonesMap(newChildren);

        for (Channel childOne : oldBaseChannel.getAccessibleChildrenFor(user)) {
            // if a new child was cloned from the same original as an old one,
            // return them as compatible
            List<Channel> candidates = originalToClones.get(getOriginalChannel(childOne));
            if (candidates != null && candidates.size() == 1) {
                compatibleChannels.put(childOne, candidates.get(0));
            }
            else {
                // if a new child refers to the same product name as an old one,
                // return them as compatible
                ProductName name = childOne.getProductName();
                if (prodChannels.containsKey(name) && !nonUniqueProducts.contains(name)) {
                    compatibleChannels.put(childOne, prodChannels.get(name));
                }
            }
        }

        return compatibleChannels;
    }

    /**
     * Returns a map in which values are channels specified by the argument and
     * keys are the corresponding original (ie. non-cloned) channels.
     * @param channels the channels to map
     * @return a map from originals to (possibly multiple) clones
     */
    private static Map<Channel, List<Channel>> getOrignalToClonesMap(
        List<Channel> channels) {
        Map<Channel, List<Channel>> result = new HashMap<Channel, List<Channel>>();
        for (Channel channel : channels) {
            Channel original = getOriginalChannel(channel);
            if (result.containsKey(original)) {
                result.get(original).add(channel);
            }
            else {
                List<Channel> entry = new LinkedList<Channel>();
                entry.add(channel);
                result.put(original, entry);
            }
        }
        return result;
    }

   /**
    * For a given {@link Channel}, determine the original {@link Channel}.
    *
    * @param channel channel
    * @return original channel
    */
   public static Channel getOriginalChannel(Channel channel) {
       while (channel.isCloned()) {
           channel = channel.getOriginal();
       }
       return channel;
    }

    /**
     * Finds non-custom errata for a target channel
     * @param targetChannel the channel to search for
     * @param packageAssoc  whether to filter packages on what packages are already
     *                      in the channel
     * @return List of errata
     */
    public static DataResult<ErrataOverview> findErrataForTarget(
            Channel targetChannel,  boolean packageAssoc) {
        String mode;
        if (packageAssoc) {
             mode = "for_target_package_assoc";
        }
        else {
             mode = "for_target";
        }

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("custom_cid", targetChannel.getId());

        SelectMode m = ModeFactory.getMode(
                "Errata_queries", mode);

        return m.execute(params);
    }


    /**
     * Finds errata associated with channels in the "channels_for_errata" rhnSet that
     *              apply to a custom channel
     * @param targetChannel the channel to search for
     * @param user the user doing the query
     * @param packageAssoc whether to filter packages on what packages are already
     *                      in the channel
     * @return List of Errata
     */
    public static DataResult<ErrataOverview> findErrataFromRhnSetForTarget(
            Channel targetChannel, boolean packageAssoc, User user) {

        String mode;
        if (packageAssoc) {
             mode =  "in_sources_for_target_package_assoc";
        }
        else {
             mode =  "in_sources_for_target";
        }

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("custom_cid", targetChannel.getId());
        params.put("user_id", user.getId());


        SelectMode m = ModeFactory.getMode(
                "Errata_queries", mode);

        return m.execute(params);
    }

    /**
     * find available errata from custom base channels and their child channels for a
     *          particular channel
     * @param targetChannel the channel to target
     * @param packageAssoc whether to filter packages on what packages are already
     *                      in the channel
     *
     * @return List of errata
     */
    public static DataResult<ErrataOverview> findCustomErrataForTarget(
            Channel targetChannel, boolean packageAssoc) {
        String mode;
        if (packageAssoc) {
             mode = "custom_for_target_package_assoc";
        }
        else {
             mode = "custom_for_target";
        }

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("custom_cid", targetChannel.getId());
        params.put("org_id", targetChannel.getOrg().getId());

        SelectMode m = ModeFactory.getMode(
                "Errata_queries", mode);

        return m.execute(params);
    }

    /**
     * Returns a list of compatible packages arches for the given ChannelArch
     * labels. It will NOT tell you which package arch goes with which channel
     * arch, for that you need to load the ChannelArch individually. This
     * methods purpose is for searching packages where we don't actually
     * care what package arch goes with what channel arch we only care what
     * package arch we should look for.
     * @param channelArchLabels List of ChannelArch labels.
     * @return list of compatible package arches.
     */
    public static List<String> listCompatiblePackageArches(String[] channelArchLabels) {
        if (channelArchLabels == null || (channelArchLabels.length < 1)) {
            return new ArrayList<String>();
        }

        SelectMode mode = ModeFactory.getMode(
                "Package_queries", "compatible_package_arches");
        List<Map<String, String>> dr = mode.execute(Arrays.asList(channelArchLabels));
        List<String> result = new ArrayList<String>();
        for (Map<String, String> m : dr) {
            result.add(m.get("label"));
        }
        return result;
    }

    /**
     * Returns a distinct list of ChannelArch labels for all synch'd and custom
     * channels in the satellite.
     * @return a distinct list of ChannelArch labels for all synch'd and custom
     * channels in the satellite.
     */
    public static List<String> getSyncdChannelArches() {
        return ChannelFactory.findChannelArchLabelsSyncdChannels();
    }

    /**
     *
     * @param channelLabel channel label
     * @param client client info
     * @param reason reason for queue
     */
    public static void queueChannelChange(String channelLabel, String client,
            String reason) {
        if ("".equals(client)) {
            client = null;
        }

        if ("".equals(reason)) {
            reason = null;
        }

        WriteMode m = ModeFactory.getWriteMode("Channel_queries", "request_repo_regen");
        Map<String, String> params = new HashMap<String, String>();
        params.put("label", channelLabel);
        params.put("client", client);
        params.put("reason", reason);
        m.executeUpdate(params);
    }

    /**
     * Remove packages from a channel very quickly
     * @param chan the channel
     * @param packageIds list of package ids
     * @param user the user doing the removing
     */
    public static void removePackages(Channel chan, List<Long> packageIds, User user) {

        if (!UserManager.verifyChannelAdmin(user, chan)) {
            StringBuilder msg = new StringBuilder("User: ");
            msg.append(user.getLogin());
            msg.append(" does not have channel admin access to channel: ");
            msg.append(chan.getLabel());

            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(msg.toString());
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.channel"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.channel"));
            throw pex;
        }

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", chan.getId());

        WriteMode m = ModeFactory.getWriteMode("Channel_queries", "remove_packages");
        m.executeUpdate(params, packageIds);

        HibernateFactory.getSession().refresh(chan);

    }

    /**
     * Adds packages to a channel
     * @param chan the channel
     * @param packageIds list of package ids
     * @param user the user adding packages
     */
    public static void addPackages(Channel chan, List<Long> packageIds, User user) {

        if (!UserManager.verifyChannelAdmin(user, chan)) {
            StringBuilder msg = new StringBuilder("User: ");
            msg.append(user.getLogin());
            msg.append(" does not have channel admin access to channel: ");
            msg.append(chan.getLabel());

            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(msg.toString());
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.channel"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.channel"));
            throw pex;
        }

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", chan.getId());

        WriteMode m = ModeFactory.getWriteMode("Channel_queries", "add_channel_packages");
        m.executeUpdate(params, packageIds);

        HibernateFactory.getSession().refresh(chan);
    }


    /**
     * Remove a set of erratas from a channel
     *      and remove associated packages
     * @param chan The channel to remove from
     * @param errataIds set of errata ids to remove
     * @param user the user doing the removing
     */
    public static void removeErrata(Channel chan, Set<Long> errataIds, User user) {
        if (!UserManager.verifyChannelAdmin(user, chan)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        List<Long> ids = new ArrayList<Long>();
        ids.addAll(errataIds);

        List<Long> pids = ChannelFactory.getChannelPackageWithErrata(chan, ids);

        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", chan.getId());

        WriteMode m = ModeFactory.getWriteMode("Channel_queries", "remove_errata");
        m.executeUpdate(params, ids);

        m = ModeFactory.getWriteMode("Channel_queries", "remove_errata_packages");
        m.executeUpdate(params, ids);

        ChannelManager.refreshWithNewestPackages(chan, "Remove errata");
        ErrataCacheManager.deleteCacheEntriesForChannelPackages(chan.getId(), pids);
        ErrataCacheManager.deleteCacheEntriesForChannelErrata(chan.getId(), ids);
        ChannelFactory.getSession().refresh(chan);
    }

    /**
     * List packages that are contained in an errata and in a channel
     * @param chan The channel
     * @param errata the Errata
     * @return A list of PackageDto that are in the channel and errata
     */
    public static List<PackageDto> listErrataPackages(Channel chan, Errata errata) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", chan.getId());
        params.put("eid", errata.getId());

        SelectMode mode = ModeFactory.getMode(
                "Channel_queries", "channel_errata_packages");
        return mode.execute(params);
    }

    /**
     * Returns an id of the original channel
     * @param channel The cloned channel
     * @return A original channel id
     */
    public static Long lookupOriginalId(Channel channel) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("cid", channel.getId());

        SelectMode mode = ModeFactory.getMode(
                "Channel_queries", "cloned_original_id");
        List<Map> list = mode.execute(params);
        if (!list.isEmpty()) {
            Map map = list.get(0);
            return (Long) map.get("id");
        }
        return null;
    }

    /**
     * List errata that is within a channel that needs to be resynced
     *  This is determined by the packages in the channel
     *
     * @param c the channel
     * @param user the user
     * @return list of errataOverview objects that need to be resynced
     */
    public static List<ErrataOverview> listErrataNeedingResync(Channel c, User user) {
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        if (c.isCloned()) {
            Map<String, Long> params = new HashMap<String, Long>();
            params.put("cid", c.getId());
            params.put("ocid", c.getOriginal().getId());
            SelectMode m = ModeFactory.getMode("Errata_queries",
                                        "list_errata_needing_sync");
            return m.execute(params);
        }
        return new ArrayList<ErrataOverview>();
    }

    /**
     * List ids of errata packages that need to be resynced
     * @param c the channel to look for packages in
     * @param user the user doing it
     * @return list of ids of packages
     */
    public static List<Long> listErrataPackageIdsForResync(Channel c, User user) {
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        List packageIds = new ArrayList<Long>();
        if (c.isCloned()) {
            Map<String, Long> params = new HashMap<String, Long>();
            params.put("cid", c.getId());
            params.put("ocid", c.getOriginal().getId());
            SelectMode m = ModeFactory.getMode("Errata_queries",
                    "list_packages_ids_needing_sync");
            DataResult result =  m.execute(params);
            for (Iterator iter = result.iterator(); iter.hasNext();) {
                Map row = (Map) iter.next();
                Long packageId = (Long) row.get("id");
                packageIds.add(packageId);
            }
        }
        return packageIds;
    }

    /**
     * List errata packages that need to be resynced
     * @param c the channel to look for packages in
     * @param user the user doing it
     * @return the list of PackageOverview objects
     */
    public static List<PackageOverview> listErrataPackagesForResync(Channel c, User user) {
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        if (c.isCloned()) {
            Map<String, Long> params = new HashMap<String, Long>();
            params.put("cid", c.getId());
            params.put("ocid", c.getOriginal().getId());
            SelectMode m = ModeFactory.getMode("Errata_queries",
                    "list_packages_needing_sync");
            return m.execute(params);
        }
        return new ArrayList<PackageOverview>();
    }

    /**
     * List errata that is within a channel that needs to be resynced
     *  This is determined by the packages in the channel
     *
     * @param c the channel
     * @param user the user
     * @return list of ids of errata that need to be resynced
     */
    public static List<Long> listErrataIdsNeedingResync(Channel c, User user) {
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        List errataIds = new ArrayList<Long>();
        if (c.isCloned()) {
            Map<String, Long> params = new HashMap<String, Long>();
            params.put("cid", c.getId());
            params.put("ocid", c.getOriginal().getId());
            SelectMode m = ModeFactory.getMode("Errata_queries",
                                        "list_errata_ids_needing_sync");

            DataResult result =  m.execute(params);
            for (Iterator iter = result.iterator(); iter.hasNext();) {
                Map row = (Map) iter.next();
                Long errataId = (Long) row.get("id");
                errataIds.add(errataId);
            }
        }
        return errataIds;
    }

    /**
     * List errata packages that need to be resynced
     * @param c the channel to look for packages in
     * @param user the user doing it
     * @param setLabel the set of errata to base the package off of
     * @return the list of PackageOverview objects
     */
    public static List<PackageOverview> listErrataPackagesForResync(Channel c, User user,
            String setLabel) {
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        if (c.isCloned()) {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("cid", c.getId());
            params.put("set_label", setLabel);
            params.put("ocid", c.getOriginal().getId());
            SelectMode m = ModeFactory.getMode("Errata_queries",
                    "list_packages_needing_sync_from_set");
            return m.execute(params);
        }
        return new ArrayList<PackageOverview>();
    }

    /**
     * Check the status of the cache repo data
     * @param channel the channel to look for status
     * @return repodata status
     */
    public static boolean isChannelLabelInProgress(String channel) {
        SelectMode selector = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_REPOMD_DETAILS_QUERY);
        Map<Object, Object> params = new HashMap<Object, Object>();
        params.put("channel_label", channel);
        return (selector.execute(params).size() > 0);
    }

    /**
     * get the last build date on repodata per channel
     * @param channel the channel to look for repodata build date
     * @return last repo build date
     */
    public static String getRepoLastBuild(Channel channel) {
        String  pathPrefix = Config.get().getString(ConfigDefaults.REPOMD_PATH_PREFIX,
        "rhn/repodata");
        String mountPoint = Config.get().getString(ConfigDefaults.REPOMD_CACHE_MOUNT_POINT,
                "/pub");
        File theFile = new File(mountPoint + File.separator + pathPrefix +
                File.separator + channel.getLabel() + File.separator +
                "repomd.xml");
        if (!theFile.exists()) {
            // No repo file, dont bother computing build date
            return null;
        }
        Date fileModifiedDateIn = new Date(theFile.lastModified());
        // the file Modified date should be getting set when the file
        // is moved into the correct location.
        log.info("File Modified Date:" + fileModifiedDateIn);
        return LocalizationService.getInstance().formatCustomDate(fileModifiedDateIn);
    }


    /**
     * get the latest log file for spacewalk-repo-sync
     * @param c channel
     * @return the string of the filename (fully qualified)
     */
    public static List<String> getLatestSyncLogFiles(Channel c) {

        String logPath = Config.get().getString(ConfigDefaults.SPACEWALK_REPOSYNC_LOG_PATH,
                "/var/log/rhn/reposync/");

        File dir = new File(logPath);
        List<String> possibleList = new ArrayList<String>();
        String[] dirList = dir.list();
        if (dirList != null) {
            for (String file : dirList) {
                if (file.startsWith(c.getLabel() + ".log") && !file.endsWith(".gz")) {
                    possibleList.add(logPath + file);
                }
            }
            Collections.sort(possibleList);
        }
        return possibleList;
    }




    /**
     * Takes a list of child channels and a set label and returns a Map
     *    with system ids as the key and a set ChannelActionDAO's
     *     as the value
     * @param setLabel the set label of System ids
     * @param subChans the list of channels to subscribe
     * @param unsubChans the list of channels to unsubscribe
     * @param user the user doing the work
     * @return The aformentioned map
     */
    public static Map<Long, ChannelActionDAO> filterChildSubscriptions(
            String setLabel, List<Channel> subChans, List<Channel> unsubChans, User user) {
        Map<Long, ChannelActionDAO> toRet = new  HashMap<Long, ChannelActionDAO>();

        List<Long> subCids = new ArrayList<Long>();
        for (Channel c : subChans) {
            subCids.add(c.getId());
        }
        List<Long> unsubCids = new ArrayList<Long>();
        for (Channel c : unsubChans) {
            unsubCids.add(c.getId());
        }

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("uid", user.getId());
        params.put("set_label", setLabel);

        SelectMode m = null;
        List<Map<String, Object>> subDr = new ArrayList<Map<String, Object>>();
        List<Map<String, Object>> unsubDr = new ArrayList<Map<String, Object>>();
        if (!subChans.isEmpty()) {
            m = ModeFactory.getMode("Channel_queries",
                    "ssm_systems_for_child_subscription");
            subDr =  m.execute(params, subCids);
        }
        if (!unsubChans.isEmpty()) {
            m = ModeFactory.getMode("Channel_queries",
                        "ssm_systems_for_child_unsubscription");
            unsubDr = m.execute(params, unsubCids);
        }


        for (Map<String, Object> row : subDr) {
            Long id = (Long) row.get("id");
            ChannelActionDAO sys = toRet.get(id);
            if (sys == null) {
                sys = new ChannelActionDAO();
                sys.setId(id);
                sys.setName((String) row.get("name"));
                toRet.put(id, sys);
            }
            sys.addSubscribeChannelId((Long) row.get("channel_id"));
            sys.addSubscribeName((String) row.get("channel_name"));
        }

        for (Map<String, Object> row : unsubDr) {
            Long id = (Long) row.get("id");
            ChannelActionDAO sys = toRet.get(id);
            if (sys == null) {
                sys = new ChannelActionDAO();
                sys.setId(id);
                sys.setName((String) row.get("name"));
                toRet.put(id, sys);
            }
            sys.addUnsubscribeChannelId((Long) row.get("channel_id"));
            sys.addUnsubcribeName((String) row.get("channel_name"));
        }

        return toRet;
    }

    /**
     * returns channel manager ids within the given org for a given channel
     * @param org given organization
     * @param channel channel
     * @return list of channel manager ids
     */
    public static List<Long> listChannelManagerIdsForChannel(Org org, Channel channel) {
        return ChannelFactory.listManagerIdsForChannel(org, channel.getId());
    }

    /**
     * returns channel subscriber ids within the given org for a given channel
     * @param org given organization
     * @param channel channel
     * @return list of channel subscriber ids
     */
    public static List<Long> listChannelSubscriberIdsForChannel(Org org, Channel channel) {
        return ChannelFactory.listSubscriberIdsForChannel(org, channel.getId());
    }

    /**
     * @param csid content source (repository) ID
     * @param pc pageControl
     * @return List of channels associated to a content source (repository)
     */
    public static DataResult channelsForContentSource(Long csid, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                "channels_for_content_source");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("csid", csid);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * @param parentArchLabel The channel arch label of the parent channel
     * @return List of {'name': channel_arch_name, 'label': channel_arch_label}
     *   for compatible child channel arches.
     */
    public static List<Map<String, String>> compatibleChildChannelArches(
            String parentArchLabel) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                "compatible_child_channel_arches");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("pa_label", parentArchLabel);
        return m.execute(params);
    }

    /**
     * Clone the original channel packages from one channel to another
     * @param fromCid The original channel's id
     * @param toCid The cloned channel's id
     * @return 1 if successfull
     */
    public static int cloneOriginalChannelPackages(Long fromCid, Long toCid) {
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                "clone_original_channel_packages");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("from", fromCid);
        params.put("to", toCid);
        return m.executeUpdate(params);
    }

    /**
     * Clone all channel packages from one channel to another
     * @param fromCid The original channel's id
     * @param toCid The cloned channel's id
     * @return 1 if successfull
     */
    public static int cloneChannelPackages(Long fromCid, Long toCid) {
        WriteMode m = ModeFactory.getWriteMode("Channel_queries", "clone_channel_packages");
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("from", fromCid);
        params.put("to", toCid);
        return m.executeUpdate(params);
    }

    /**
     * Return the channel id of the "most likely" parent if we're cloning this
     * channel. "Most likely" is determined by:
     *   1) See if the org owns a clone of the original channel's parent
     *     1.a) if multiple choose most recently modified
     *   2) Else return the original channel's parent id
     * Returns null if original is not a child channel
     * @param original Original channel that we are cloning
     * @param org Org to look for clones in
     * @return channel id of most likely parent
     */
    public static Long likelyParentId(Channel original, Org org) {
        if (original.isBaseChannel()) {
            return null;
        }
        SelectMode m = ModeFactory.getMode("Channel_queries", "likely_parent");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", original.getId());
        params.put("org_id", org.getId());
        List<Map<String, Object>> result = m.execute(params);

        if (result.size() != 0) {
            return (Long) result.get(0).get("id");
        }

        return original.getParentChannel().getId();
    }
}
