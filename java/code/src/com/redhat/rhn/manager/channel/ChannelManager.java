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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.ChannelVersion;
import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.channel.ProductName;
import com.redhat.rhn.domain.channel.ReleaseChannelMap;
import com.redhat.rhn.domain.common.CommonConstants;
import com.redhat.rhn.domain.common.VirtSubscriptionLevel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.ChannelPerms;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.EssentialChannelDto;
import com.redhat.rhn.frontend.dto.MultiOrgEntitlementsDto;
import com.redhat.rhn.frontend.dto.OrgChannelFamily;
import com.redhat.rhn.frontend.dto.OrgSoftwareEntitlementDto;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.ProxyChannelNotFoundException;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.sql.Types;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
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
     * @param channel Channel to be refreshed.
     * @param label the label.
     */
    public static void refreshWithNewestPackages(Channel channel, String label) {
        ChannelFactory.refreshNewestPackageCache(channel, label);
    }
    
    /**
     * Retrieves a list of base channels the given user can subscribe the given server to.
     * @param user The user in question
     * @param server The server in question
     * @return Returns a list of base channels the user can subscribe the server to.
     */
    public static DataResult userSubscribableBaseChannelsForSystem(User user, 
                                 Server server) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                           "subscribable_base_channels_for_system", Map.class);
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("server_id", server.getId());
        DataResult dr = m.execute(params);
        /*
         * This sucks, but verifying channel access for a user is a stored proc so we have
         * to loop through each of the org's base channels and make sure we can show them
         * to this user.
         */
        List toRemove = new ArrayList();
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            Map map = (Map) itr.next();
            //Verify channel access for the user
            Long id = (Long) map.get("id");
            if (!verifyChannelSubscribe(user, id)) {
                toRemove.add(map);
            }
        }
        
        dr.removeAll(toRemove);
        return dr;
    }
    
    /**
     * Returns a list channel entitlements
     * @param orgId The users org ID
     * @param pc The PageControl
     * @return channel entitlements
     */
    public static DataResult<ChannelOverview> entitlements(Long orgId, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_entitlements");
        
        Map params = new HashMap();
        params.put("org_id", orgId);
        return makeDataResult(params, params, pc, m);
    }
    
    /**
     * Given an org it returns all the channel family subscription information
     * pertaining to that org.
     * @param org the org whose subscriptsion you are interested
     * @return channel family subscriptions/entitlement information.
     */
    public static List <OrgChannelFamily> listChannelFamilySubscriptionsFor(Org org) {
        List <OrgChannelFamily> ret = new LinkedList<OrgChannelFamily>();
        List<ChannelOverview> orgEntitlements = ChannelManager.entitlements(org.getId(), 
                null);

        List <ChannelOverview> satEntitlements = ChannelManager.entitlements(
                OrgFactory.getSatelliteOrg().getId(), null);        
        
        // Reformat it into a map for easy lookup
        Map <Long, ChannelOverview> orgMap = new HashMap();
        for (ChannelOverview orgEnt : orgEntitlements) {
            orgMap.put(orgEnt.getId(), orgEnt);            
        }
        
        for (ChannelOverview sato : satEntitlements) {
            ChannelOverview orgo =  orgMap.get(sato.getId());
            OrgChannelFamily ocf = new OrgChannelFamily();
            ocf.setSatelliteCurrentMembers(sato.getCurrentMembers());
            ocf.setSatelliteMaxMembers(sato.getMaxMembers());
            ocf.setId(sato.getId());
            ocf.setName(sato.getName());
            ocf.setLabel(sato.getLabel());
            if (orgo == null) {
                ocf.setCurrentMembers(new Long(0));
                ocf.setMaxMembers(new Long(0));
            }
            else {
                ocf.setCurrentMembers(orgo.getCurrentMembers());
                ocf.setMaxMembers(orgo.getMaxMembers());
            }
            if (ocf.getSatelliteMaxMembers() != null) {
              ret.add(ocf);
            }
        }        
        return ret;
    }
    
    
    
    /**
     * Returns a list channel entitlements for all orgs.
     * @param pc The PageControl
     * @return channel entitlements
     */
    public static DataResult<ChannelOverview> entitlementsForAllOrgs(PageControl pc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                "channel_entitlements_for_all_orgs");
        
        Map params = new HashMap();
        return makeDataResult(params, params, pc, m);
    }
    
    /**
     * Returns a list channel entitlements for all orgs.
     * @return channel entitlements for multiorgs
     */
    public static DataList<MultiOrgEntitlementsDto> entitlementsForAllMOrgs() {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                "channel_entitlements_for_all_m_orgs");        
        return DataList.getDataList(m, Collections.EMPTY_MAP,
                Collections.EMPTY_MAP);
    }
    
    /**
     * Return a ChannelOverview for all orgs using the given channel family.
     * @param entitlementId Channel family ID.
     * @return List of ChannelOverview objects.
     */
    public static List<ChannelOverview> getEntitlementForAllOrgs(
            Long entitlementId) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                "channel_entitlement_for_all_orgs");
        
        Map params = new HashMap();
        params.put("entitlement_id", entitlementId);
        return makeDataResult(params, params, null, m);
    }
    
    /**
     * Given a channel family, this method  returns
     *  entitlement information on a per org basis.
     * @param cf the channel family
     * @param user the user needed for access privilege
     * @return the lists the entitlement information  for the given channel family
     *          for all orgs.
     */
    public static List<OrgSoftwareEntitlementDto> 
                    listEntitlementsForAllOrgs(ChannelFamily cf, User user) {
        List <OrgSoftwareEntitlementDto> ret = 
                            new LinkedList<OrgSoftwareEntitlementDto>();
        
        List<ChannelOverview> entitlementUsage = ChannelManager.getEntitlementForAllOrgs(
                cf.getId());
        
        // Create a mapping of org ID's to the channel overview returned, we'll need this
        // when iterating the list of all orgs shortly:
        Map<Long, ChannelOverview> orgEntitlementUsage = 
            new HashMap<Long, ChannelOverview>();
        for (ChannelOverview o : entitlementUsage) {
            orgEntitlementUsage.put(o.getOrgId(), o);
        }        
        Org satelliteOrg = OrgFactory.getSatelliteOrg();
        ChannelOverview satelliteOrgOverview = ChannelManager.getEntitlement(
                                            satelliteOrg.getId(),
                                            cf.getId());
        if (satelliteOrgOverview == null) {
            throw new RuntimeException("Satellite org does not" +
                                "appear to have been allocated entitlement:" +
                                cf.getId());
        }
        
        List<Org> allOrgs = OrgManager.allOrgs(user);
        for (Org org : allOrgs) {
            if (orgEntitlementUsage.containsKey(org.getId())) {
                ChannelOverview co = orgEntitlementUsage.get(org.getId());
                if (co.getMaxMembers() == 0) {                    
                    continue;
                }
                Long maxPossibleAllocation = null;
                if (co.getMaxMembers() != null && 
                        satelliteOrgOverview.getFreeMembers() != null) {
                        maxPossibleAllocation = co.getMaxMembers() + 
                            satelliteOrgOverview.getFreeMembers();
                }                
                OrgSoftwareEntitlementDto seDto = new OrgSoftwareEntitlementDto(org, 
                  co.getCurrentMembers(), co.getMaxMembers(), maxPossibleAllocation);
                ret.add(seDto);
            }
        }
        
        return ret;
    }
    
    /**
     * Returns a specifically requested entitlement
     * @param orgId The user's org ID
     * @param entitlementId the id of the entitlement
     * @return the Channel Entitlement
     */
    public static ChannelOverview getEntitlement(Long orgId, Long entitlementId) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_entitlement");
        
        Map params = new HashMap();
        params.put("org_id", orgId);
        params.put("entitlement_id", entitlementId);
        DataResult dr = m.execute(params);
        
        if (dr != null && !dr.isEmpty()) {
            return (ChannelOverview) dr.get(0);
        }
        else {
            return null;
        }
    }
        
    /**
     * Returns a list of ChannelTreeNodes that have orgId null 
     *      or has a prarent with org_id null
     * @param user who we are requesting Red Hat channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult redHatChannelTree(User user, 
                                                 ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "redhat_channel_tree");
        
        
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
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
    public static DataResult popularChannelTree(User user, Long serverCount,
                                                 ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "popular_channel_tree");
        
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        params.put("server_count", serverCount);
        
        DataResult dr = makeDataResult(params, params, lc, m);
        Collections.sort(dr);
        return dr;
    }        
    
    
    /**
     * Returns a list of ChannelTreeNodes that have orgId null 
     *      or has a prarent with org_id null
     * @param user who we are requesting Red Hat channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult myChannelTree(User user, 
                                                 ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "my_channel_tree");
        
        
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        Collections.sort(dr);
        return dr;
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
    public static DataResult trustChannelConsume(Org org, Org trustOrg, User user, 
                                            ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "trust_channel_consume");
        
        Map params = new HashMap();        
        params.put("org_id", org.getId());
        params.put("user_id", user.getId());
        params.put("org_id2", trustOrg.getId());        
        DataResult dr = makeDataResult(params, params, lc, m);
        return dr;
    }
    
    /**
     * Returns a list of ChannelTreeNodes containing all channels
     * the trusted org is consuming from a specific org
     * @param org Org that is consuming from the trusted org shared channels
     * @param trustOrg org that is sharing the channels
     * @param user User of trust org that is sharing the channels 
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult trustChannelProvide(Org org, Org trustOrg, User user, 
                                            ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "trust_channel_consume");
        
        Map params = new HashMap();        
        params.put("org_id", trustOrg.getId());
        params.put("user_id", user.getId());
        params.put("org_id2", org.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        return dr;
    }
    
    
    /**
     * Returns a list of ChannelTreeNodes containing all channels
     * the user can see
     * @param user who we are requesting channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult allChannelTree(User user, 
                                            ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "all_channel_tree");
        
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        return dr;
    }
    
    /**
     * Returns a list of ChannelTreeNodes containing shared channels
     * the user can see
     * @param user who we are requesting channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult sharedChannelTree(User user, 
                                            ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "shared_channel_tree");
        
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        return dr;
    }
    
    /**
     * Returns a list of ChannelTreeNodes containing end-of-life
     * retired channels the user can see
     * @param user who we are requesting channels for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's
     */
    public static DataResult retiredChannelTree(User user, 
                                                ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "retired_channel_tree");
        
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        return dr;
    }
    
    /**
     * Returns a list of channels and their parents who are in a particular
     * channel family/entitlement
     * @param user who we are requesting channels for
     * @param familyId Id of the family we want a tree for
     * @param lc ListControl to use
     * @return list of ChannelTreeNode's representing the channel family
     */
    public static DataResult channelFamilyTree(User user, 
                                               Long familyId, 
                                               ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_family_tree");
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("family_id", familyId);
        params.put("org_id", user.getOrg().getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        return dr;
    }
    
    /**
     * Returns a list of packages whose ids match those from the given list.
     * @param pids The ids of the package list.
     * @param archLabels Channel arch labels.
     * @return list of packages
     */
    public static List<PackageOverview> packageSearch(List pids, List archLabels) {
        return PackageFactory.packageSearch(pids, archLabels);
    }
    
    /**
     * Returns a dataresult containing the channels in an org.
     * @param orgId The org in question
     * @param pc page control for the user
     * @return Returns a data result containing ChannelOverview dtos
     */
    public static DataResult channelsOwnedByOrg(Long orgId, PageControl pc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                                           "channels_owned_by_org");
        Map params = new HashMap();
        params.put("org_id", orgId);
        return makeDataResult(params, null, pc, m);
    }
    
    /**
     * Returns the package ids for packages relevant to a channel for a published errata
     * @param channelId The id for the channel in question
     * @param e the errata in question
     * @return Returns the ids for relevant packages
     */
    public static DataResult relevantPackages(Long channelId, Errata e) {
        SelectMode m;
        
        if (e.isPublished()) {
            m = ModeFactory.getMode("Channel_queries", 
                                    "relevant_packages_for_channel_published"); 
        }
        else {
            m = ModeFactory.getMode("Channel_queries", 
                                    "relevant_packages_for_channel_unpublished");
        }

        Map params = new HashMap();
        params.put("cid", channelId);
        params.put("eid", e.getId());
        return makeDataResult(params, null, null, m);
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
     * channelsForUser returns a list containing the names of the channels
     * that this user has permissions to. If the user doesn't have permissions
     * to any channels, this method returns an empty list.
     * @param user The user in question
     * @return Returns the list of names of channels this user has permission to,
     * an empty list otherwise.
     */
    public static List channelsForUser(User user) {
        //subscribableChannels is the list we'll be returning
        List subscribableChannels = new ArrayList();

        //Setup items for the query
        SelectMode m = ModeFactory.getMode("Channel_queries",
                                           "user_subscribe_perms");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        
        //Execute the query
        DataResult subscribable = m.execute(params);

        /*
         * We now need to go through the subscribable DataResult and
         * add the names of the channels this user has permissions to
         * to the subscribableChannels list.
         */
        Iterator i = subscribable.iterator();
        while (i.hasNext()) {
            ChannelPerms perms = (ChannelPerms) i.next();
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
    public static List userAccessibleChildChannels(Long orgid, Long cid) {
        return ChannelFactory.getUserAcessibleChannels(orgid, cid);
    }
    
    /**
     * Get the list of Channels with clonable Errata
     * @param org org we want to search against
     * @return List of com.redhat.rhn.domain.Channel objects
     */
    public static List getChannelsWithClonableErrata(Org org) {
        return ChannelFactory.getChannelsWithClonableErrata(org);
    }
    
    /**
     * Get the list of Channels accessible by an org
     * @param orgid The id of the org
     * @return List of accessible channels
     */
    public static List getChannelsAccessibleByOrg(Long orgid) {
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
            if (!Config.get().isSpacewalk()) {
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
        if (!Config.get().isSpacewalk()) {
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
    public static List<DataResult> allChannelsTree(User user) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                                           "all_channels_tree");
        Map params = new HashMap();
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
            throw new PermissionException(
                    LocalizationService.getInstance().getMessage(
                            "api.channel.delete.redhat"));
        }
        if (verifyChannelAdmin(user, toRemove.getId())) {
            if (!ChannelFactory.listAllChildrenForChannel(toRemove).isEmpty()) {
                throw new PermissionException(
                        LocalizationService.getInstance().getMessage(
                                "api.channel.delete.haschild"));              
            }
            ChannelManager.queueChannelChange(label, 
                    "java::deleteChannel", user.getLogin());  
            ChannelFactory.remove(toRemove);            
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
        
        if (user.hasRole(RoleFactory.RHN_SUPERUSER) || 
                user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
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
        Map params = new HashMap();
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
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("cid", channel.getId());
        params.put("role_label", QRY_ROLE_SUBSCRIBE);
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

        if (user.hasRole(RoleFactory.RHN_SUPERUSER)) {
            return true;
        }
        
        try {
            return verifyChannelRole(user, cid, QRY_ROLE_SUBSCRIBE);
        }
        catch (InvalidChannelRoleException e) {
            /*
             * We don't really care what the reason is for why this user doesn't have 
             * access to this channel, so catch the exception, log it, and simply
             * return false.
             */
            StringBuffer msg = new StringBuffer("User: ");
            msg.append(user.getLogin());
            msg.append(" either does not have subscribe privileges to Channel: ");
            msg.append(cid);
            msg.append(" or ChannelManager.QRY_ROLE_SUBSCRIBE is defined wrong.");
            log.debug(msg.toString(), e);
            return false;
        }
    }
    
    /**
     * Check to see if the channel passed in is subscribable by the Server passed in for
     * *free* without costing an entitlement.  Criteria:
     * 
     *  1) if server is a virtual guest
     *  2) the host of the guest has the Virtualization or VirtualizationPlatform 
     *     entitlement
     *  3) the host's system entitlement has to match the type of the Channel's 
     *     ChannelFamily's VirtSubLevel type.
     *  
     * @param serverIn to check against the channelIn
     * @param channelIn channelIn to check against the server
     * @return boolean if its free or not
     */
    public static boolean isChannelFreeForSubscription(Server serverIn, Channel channelIn) {
        
        if (log.isDebugEnabled()) {
            log.debug("isChannelFreeForSubscription.start: " + channelIn.getLabel());
        }
        
        if (!serverIn.isVirtualGuest()) {
            log.debug("server is not a guest, returning false");
            return false;
        }
        Server host = serverIn.getVirtualInstance().getHostSystem();
        Set levels = channelIn.getChannelFamily().getVirtSubscriptionLevels();
        if (levels == null || levels.size() == 0) {
            log.debug("Channel has no virtsublevel. returning false");
            return false;
        }
        if (log.isDebugEnabled()) {
            log.debug("levels   : " + levels);
            if (host != null) {
                log.debug("host.ents: " + host.getEntitlements());
            }
        }
        // No host for this guest, false!
        if (host == null) {
            log.debug("host is null, returning false");
            return false;
        }
        if (host.hasEntitlement(EntitlementManager.VIRTUALIZATION)) {
            log.debug("host has virt");
            Iterator i = levels.iterator();
            while (i.hasNext()) {
                VirtSubscriptionLevel level = (VirtSubscriptionLevel) i.next();
                if (level.equals(CommonConstants.getVirtSubscriptionLevelFree())) {
                    log.debug("Channel has virt and host has virt, returning true");
                    return true;
                }
            }
        }
        if (host.hasEntitlement(EntitlementManager.VIRTUALIZATION_PLATFORM)) {
            log.debug("host has virt-plat");
            Iterator i = levels.iterator();
            while (i.hasNext()) {
                VirtSubscriptionLevel level = (VirtSubscriptionLevel) i.next();
                if (level.equals(
                        CommonConstants.getVirtSubscriptionLevelPlatformFree())) {
                    log.debug("Channel has virt-plat and host virt-plat, returning true");
                    return true;
                }
            }
        }
        
        log.debug("No criteria match.  returning false");
        return false;
    }
    
    private static boolean verifyChannelRole(User user, Long cid, String role)
        throws InvalidChannelRoleException {
        
        CallableMode m = ModeFactory.getCallableMode(
                "Channel_queries", "verify_channel_role");
        
        Map inParams = new HashMap();
        inParams.put("cid", cid);
        inParams.put("user_id", user.getId());
        inParams.put("role", role);
        
        Map outParams = new HashMap();
        outParams.put("result", new Integer(Types.NUMERIC));
        outParams.put("reason", new Integer(Types.VARCHAR));
        Map result = m.execute(inParams, outParams);
        
        boolean accessible = BooleanUtils.toBoolean(
                ((Long) result.get("result")).intValue());
        if (!accessible) {
            String reason = (String) result.get("reason");
            throw new InvalidChannelRoleException(reason);
        }
        return accessible;
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
     * Returns available entitlements for the org and the given channel.
     * @param org Org
     * @param c Channel
     * @return available entitlements for the org and the given channel.
     */
    public static Long getAvailableEntitlements(Org org, Channel c) {
        ChannelEntitlementCounter counter = 
            (ChannelEntitlementCounter) MethodUtil.getClassFromConfig(
                    ChannelEntitlementCounter.class.getName());
         
        Long retval = counter.getAvailableEntitlements(org, c);
        log.debug("getAvailableEntitlements: " + c.getLabel() + " got: " + retval);        
        
        return retval;
    }

    /**
     * Returns the latest packages in the channel. This call will return more details
     * about the channel than the API specific call
     * {@link #latestPackagesInChannel(com.redhat.rhn.domain.channel.Channel)}.
     *
     * @param channelId identifies the channel
     * @return list of packages in this channel
     */
    public static DataResult latestPackagesInChannel(Long channelId) {
        SelectMode m = ModeFactory.getMode(
                "Package_queries", "latest_packages_in_channel");

        Map params = new HashMap();
        params.put("cid", channelId);

        return m.execute(params);
    }
    
    /**
     * Returns list of latest packages in channel
     * @param channel channel whose packages are sought
     * @return list of latest packages in channel
     */
    public static List latestPackagesInChannel(Channel channel) {
        SelectMode m = ModeFactory.getMode(
                "Package_queries", "latest_packages_in_channel_api");
        
        Map params = new HashMap();
        params.put("cid", channel.getId());
        
        return m.execute(params);
    }
    
    
    /**
     * List the errata applicable to a channel, uses an ErrataOverview Object
     * @param channel channel whose errata are sought
     * @return the errata applicable to a channel
     */
    public static List listErrata(Channel channel) {
                return listErrata(channel, null, null);
    }
    
            


    /**
     * List the errata applicable to a channel after given start date.
     * @param channel channel whose errata are sought
     * @param start start date
     * @return the errata applicable to a channel
     */
    public static DataResult listErrata(Channel channel, String start) {
        return listErrata(channel, start, null);
    }
    
    /**
     * List the errata applicable to a channel between start and end date
     * @param channel channel whose errata are sought
     * @param start start date
     * @param end end date
     * @return the errata applicable to a channel
     */
    public static DataResult listErrata(Channel channel, String start, String end) {
        String mode = "relevant_to_channel";
        Map params = new HashMap();
        params.put("cid", channel.getId());
        
        if (!StringUtils.isEmpty(start)) {
            params.put("start_date_str", start);
            mode = "relevant_to_channel_after";
        }
        
        if (!StringUtils.isEmpty(end)) {
            params.put("end_date_str", end);
            mode = "relevant_to_channel_between";
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
    public static DataResult listErrataByType(Channel channel, String type) {

        Map params = new HashMap();
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
     * @return list of packages in channel
     */
    public static List listAllPackages(Channel channel, String startDate) {
        return listAllPackages(channel, startDate, null);
    }
    
    /**
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @param startDate package start date
     * @param endDate package end date
     * @return list of packages in channel
     */
    public static List listAllPackages(Channel channel, String startDate,
            String endDate) {
        String mode = "all_packages_in_channel";
        Map params = new HashMap();
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
    public static List listAllPackages(Channel channel) {
        return listAllPackages(channel, null, null);
    }
    
    /**
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @param startDate package start date
     * @return list of packages in channel
     */
    public static List listAllPackagesByDate(Channel channel,
            String startDate) {
        return listAllPackagesByDate(channel, startDate, null);
    }
    
    /**
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @param startDate package start date
     * @param endDate package end date
     * @return list of packages in channel
     */
    public static List listAllPackagesByDate(Channel channel, String startDate,
        String endDate) {

        String mode = "all_packages_in_channel_by_date";
        Map params = new HashMap();
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
     * Returns list of packages in channel
     * @param channel channel whose packages are sought
     * @return list of packages in channel
     */
    public static List listAllPackagesByDate(Channel channel) {
        return listAllPackagesByDate(channel, null, null);
    }
    

    /**
     * Get the id of latest packages equal in the passed in Channel and name
     * 
     * @param channelId to lookup package against
     * @param packageName to check
     * @return List containing Maps of "CP.package_id, CP.name_id, CP.evr_id"
     */    
    public static Long getLatestPackageEqual(Long channelId, String packageName) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
            "latest_package_equal");       
        Map params = new HashMap();
        params.put("cid", channelId);
        params.put("name", packageName);
        List results = m.execute(params);
        if (results != null && results.size() > 0) {
            Map row = (Map) results.get(0);
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
    public static List listLatestPackagesEqual(Long channelId, String packageName) {
        if (log.isDebugEnabled()) {
            log.debug("listLatestPackagesEqual: " + 
                    channelId + " pn: " + packageName);
        }
        SelectMode m = ModeFactory.getMode("Channel_queries", 
            "latest_package_equal");       
        Map params = new HashMap();
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
    public static List listLatestPackagesLike(Long channelId, String packageName) {
        if (log.isDebugEnabled()) {
            log.debug("listLatestPackagesLike() cid: " + 
                    channelId + " packageName : " + packageName);
        }
        SelectMode m = ModeFactory.getMode("Channel_queries", 
            "latest_package_like");
        StringBuffer pname = new StringBuffer();
        pname.append("%");
        pname.append(packageName);
        pname.append("%");
        Map params = new HashMap();
        params.put("cid", channelId);
        params.put("name", pname.toString());
        return m.execute(params);
        
    }
    
    /**
     * Finds the id of a child channel with the given parent channel id that contains
     * a package with the given name.  Will only find one child channel even if there are
     * many that qualify.
     * @param parent The id of the parent channel
     * @param packageName The exact name of the package sought for.
     * @return The id of a single child channel found or null if nothing found. 
     */
    public static Long findChildChannelWithPackage(Long parent, String packageName) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_with_package");
        Map params = new HashMap();
        params.put("parent", parent);
        params.put("package", packageName);
        
        //whittle down until we have the piece we want.
        DataResult dr = m.execute(params);
        if (dr.size() == 0) {
            return null;
        }
        Map dm = (Map)dr.get(0);
        return (Long) dm.get("id");
    }

    
    /**
     * Finds the id of a child channel that contains
     * a package with the given name.  Will only all the child channels.
     * @param packageName The exact name of the package sought for.
     * @return The list of ids 
     */
    public static List<Long> findChildChannelsWithPackage(String packageName) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channels_with_package");
        Map params = new HashMap();
        params.put("package", packageName);
        
        //whittle down until we have the piece we want.
        DataResult<Map<String, Long>> dr  = m.execute(params);
        List <Long> cids = new LinkedList<Long>();
        for (Map <String, Long> row : dr) {
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
        
        //we know its the channel we want if it has the rhncfg package in it.
        Long bcid = current.getBaseChannel().getId();
        log.debug("found basechannel: " + bcid);
        Long cid = ChannelManager.findChildChannelWithPackage(bcid, 
                packageName);
        if (cid == null) { // Didnt find it ..
            log.debug("didnt find a child channel with the package.");
            return null;
        }
        Channel channel = ChannelManager.lookupByIdAndUser(cid, user);
        boolean canSubscribe = false;
        
        // check to make sure we *can* sub to this channel
        if (channel != null) {
            canSubscribe = SystemManager.canServerSubscribeToChannel(user.getOrg(), 
                    current, channel);
        }
        if (!canSubscribe) {
            return null;
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
        
        Iterator i = ChannelManager.userAccessibleChildChannels(
                user.getOrg().getId(), baseChannel.getId()).iterator();
        while (i.hasNext()) {
            Channel child = (Channel) i.next();
            Set distChannelMaps = child.getDistChannelMaps();
            log.debug("distChannelMaps null? " + (distChannelMaps == null));
            if (distChannelMaps != null) {
                Iterator di = distChannelMaps.iterator();
                while (di.hasNext()) {
                    DistChannelMap dcm = (DistChannelMap) di.next();
                    log.debug("got DistChannelMap: " + dcm);
                    if (dcm.getOs().equals(osProductName)) {
                        log.debug("found a possible channel: " + dcm.getChannel());
                        foundChannel = dcm.getChannel();
                        if (SystemManager.canServerSubscribeToChannel(user.getOrg(), 
                                current, dcm.getChannel())) {
                            log.debug("we can subscribe.  lets set foundChannel");
                            foundChannel = dcm.getChannel();
                            break;
                        }
                        else {
                            log.debug("no subscriptions available.");
                        }
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
        // Figure out what this server's base OUGHT to be
        CallableMode sbm = ModeFactory.getCallableMode(
                "Channel_queries", "guess_server_base");
        Map inParams = new HashMap();
        inParams.put("server_id", s.getId());
        Map outParams = new HashMap();
        outParams.put("result", new Integer(Types.NUMERIC));
        Map result = sbm.execute(inParams, outParams);
        
        Long guessedId = (Long) result.get(("result"));
        
        Channel c = null;
        if (guessedId != null) {
            c = ChannelManager.lookupByIdAndUser(guessedId, usr);
        }
        return c;
    }
    
    /**
     * Convert redhat-release release values to those that are stored in the
     * rhnReleaseChannelMap table.
     *
     * @param originalRelease Original package evr release.
     * @return Release version for rhnReleaseChannelMap.
     */
    public static String normalizeRhelReleaseForMapping(String originalRelease) {
        String [] tokens = originalRelease.split("\\.");
        if (tokens.length <= 3) {
            return originalRelease;
        }
        
        StringBuffer buf = new StringBuffer();
        buf.append(tokens[0]);
        buf.append(".");
        buf.append(tokens[1]);
        buf.append(".");
        buf.append(tokens[2]);
        return buf.toString();
    }
    
    /**
     * Return the list of ALL ISO channels 
     * @param u Currently-logged-in user
     * @param lc ListControl (if there is one)
     * @return DataResult of ChannelTreeNodes
     */
    public static DataResult allDownloadsTree(User u, ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                "channels_with_downloads_tree_full");
        Map params = new HashMap();
        params.put("user_id", u.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        if (dr.size() == 0) {
            return null;
        }
        else {
            return dr;
        }
    }
    /**
     * Return the list of ISO channels with SUPPORTED distributions
     * @param u Currently-logged-in user
     * @param lc ListControl (if there is one)
     * @return DataResult of ChannelTreeNodes
     */
    public static DataResult supportedDownloadsTree(User u, ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                "channels_with_downloads_tree_supported");
        Map params = new HashMap();
        params.put("user_id", u.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        if (dr.size() == 0) {
            return null;
        }
        else {
            return dr;
        }
    }
    /**
     * Return the list of ISO channels for RETIRED distributions
     * @param u Currently-logged-in user
     * @param lc ListControl (if there is one)
     * @return DataResult of ChannelTreeNodes
     */
    public static DataResult retiredDownloadsTree(User u, ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                "channels_with_downloads_tree_retired");
        Map params = new HashMap();
        params.put("user_id", u.getId());
        
        DataResult dr = makeDataResult(params, params, lc, m);
        if (dr.size() == 0) {
            return null;
        }
        else {
            return dr;
        }
    }

    /**
     * Return a list of categories available for download
     * @param u User making the request
     * @param channelLabel channel to download from
     * @param downloadType download-type to look for (typically "iso")
     * @param lc associated list-control (if any)
     * @param forSatellite true if we want satellite-related categories
     * @return DataResult<ISOCategory>
     */
    public static DataResult listDownloadCategories(
            User u, 
            String channelLabel, String downloadType, ListControl lc,
            boolean forSatellite) {
        SelectMode m = null;
        
        if (forSatellite) {
            m = ModeFactory.getMode("Channel_queries", 
                    "satellite_channel_download_categories_by_type");
        }
        else {
            m = ModeFactory.getMode("Channel_queries", 
            "channel_download_categories_by_type");
        }
            
        Map params = new HashMap();
        params.put("org_id", u.getOrg().getId());
        params.put("channel_label", channelLabel);
        params.put("download_type", downloadType);
        DataResult dr = makeDataResult(params, params, lc, m);
        if (dr.size() == 0) {
            return null;
        }
        else {
            return dr;
        }
    }
    
    /**
     * Return a list of all downlaods available for download from the specified channel
     * @param u User making the request
     * @param channelLabel label of channel of interest
     * @param downloadType type of download requested (typically "iso")
     * @param lc associated list-control
     * @param forSatellite true if we want satellite-related downloads
     * @return DataResult<ISOImage>
     */
    public static DataResult listDownloadImages(
            User u,
            String channelLabel, String downloadType, ListControl lc,
            boolean forSatellite) {
        SelectMode m = null;
        
        if (forSatellite) {
            m = ModeFactory.getMode("Channel_queries", 
                    "satellite_channel_downloads_by_type");
        }
        else {
            m = ModeFactory.getMode("Channel_queries", 
            "channel_downloads_by_type");
        }
            
        Map params = new HashMap();
        params.put("org_id", u.getOrg().getId());
        params.put("channel_label", channelLabel);
        params.put("download_type", downloadType);
        DataResult dr = makeDataResult(params, params, lc, m);
        if (dr.size() == 0) {
            return null;
        }
        else {
            return dr;
        }
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
        Iterator i = ChannelManager.userAccessibleChildChannels(
                user.getOrg().getId(), baseChannel.getId()).iterator();
        while (i.hasNext()) {
            Channel child = (Channel) i.next();
            // First search for legacy kickstart package names:
            List kspackages = ChannelManager.
                listLatestPackagesLike(child.getId(), 
                        KickstartData.LEGACY_KICKSTART_PACKAGE_NAME);
            if (kspackages.size() > 0) {
                return child;
            }
            
            // Search for rhn-kickstart package name:
            kspackages = ChannelManager.listLatestPackagesEqual(child.getId(), 
                    Config.get().getKickstartPackageName());
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
    public static Set getChannelVersions(Channel channel) {
        Set returnSet = new HashSet();
        Iterator iter = channel.getDistChannelMaps().iterator();
        while (iter.hasNext()) {
            DistChannelMap dcm = (DistChannelMap)iter.next();
            
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
    public static DataResult getChannelsForSsm(User user, ListControl lc) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "channel_tree_ssm_install");

        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        DataResult dr = makeDataResult(params, params, lc, m);

        return dr;
    }

    /**
     * Save the Channel and update the rhnChannelNewestPackageCache
     * 
     * @param c to save
     * @param user doing the saving.
     */
    public static void saveAndUpdateErrataAndPackageCache(Channel c, User user) {
        ChannelFactory.save(c);
        c = (Channel) HibernateFactory.reload(c);
        
        refreshWithNewestPackages(c, user.getLogin());
        Set cacheUpdate = new HashSet();
        cacheUpdate.add(c);
        ErrataCacheManager.updateErrataCacheForChannelsAsync(cacheUpdate, user.getOrg());
    }

    /**
     * Returns the list of all child-channels in the user's System Set
     * @param user User whose channels are sought.
     * @return the list of all child-channels in that user's System Set
     */
    public static DataResult childrenAvailableToSet(User user) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "children_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());

        return m.execute(params);
    }
    
    /**
     * Returns the list of all base-channels represented in the System Set.
     * @param user User whose System Set is being considered
     * @return the list of all base-channels in that set.
     */
    public static DataResult baseChannelsInSet(User user) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "base_channels_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());

        return m.execute(params);
    }
    
    private static boolean isDefaultBaseChannel(Channel baseChan, String version) {
        if (baseChan == null) {
            return false;
        }
        
        log.debug("isDefaultBaseChannel()");
        log.debug("   version = " + version);
        Channel defaultBaseChan = getDefaultBaseChannel(version, 
            baseChan.getChannelArch());
        if (defaultBaseChan == null) {
            return false;
        }
        return defaultBaseChan.getId().equals(baseChan.getId());
    }

    private static Channel getDefaultBaseChannel(String version, ChannelArch
            arch) {
        DistChannelMap dcm = ChannelManager.lookupDistChannelMap(RHEL_PRODUCT_NAME, 
                version, arch);
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
        log.debug("listBaseChannelsForSystem()");
        
        List<EssentialChannelDto> channelDtos = new LinkedList<EssentialChannelDto>();
        
        if (s.getReleasePackage() != null && s.getReleasePackage().getEvr() != null) {
            String rhelVersion = s.getReleasePackage().getEvr().getVersion();
            String rhelRelease = s.getReleasePackage().getEvr().getRelease();
            String serverArch = s.getServerArch().getLabel();
            
            // If the system has the default base channel, that channel will not have
            // compatability entries in rhnReleaseChannelMap. Assume that this is a base
            // RHEL channel and that only the most recent (i.e. default) EUS channel
            // in rhnReleaseChannelMap is a suitable replacement.
            List<EssentialChannelDto> baseEusChans = new LinkedList<EssentialChannelDto>();
            if (isDefaultBaseChannel(s.getBaseChannel(), rhelVersion)) {
                log.debug("System has default base channel, including most recent EUS " + 
                        "channel.");
                EssentialChannelDto baseEus = lookupLatestEusChannelForRhelVersion(usr, 
                        rhelVersion, s.getBaseChannel().getChannelArch().getId());
                if (baseEus != null) {
                    baseEusChans.add(baseEus);
                }
            }
            else {
                log.debug("System does not have default base channel.");
                log.debug("Looking up all available EUS channels.");
                baseEusChans = listBaseEusChannelsByVersionReleaseAndServerArch(usr, 
                    rhelVersion, rhelRelease, serverArch);
            }
            channelDtos.addAll(baseEusChans);

            log.debug("Base EUS channels:");
            for (EssentialChannelDto dto : baseEusChans) {
                log.debug("      " + dto.getLabel());
            }
        }
        
        // Get all the possible base-channels owned by this Org (IE, custom)
        // and add the server's current base-channel to it:
        channelDtos.addAll(listBaseChannelsForOrg(usr.getOrg()));
        Channel guessedBase = ChannelManager.guessServerBase(usr, s);
        if (guessedBase != null) {
            if (log.isDebugEnabled()) {
                log.debug("guessedBase = " + guessedBase.getLabel());    
            }

            EssentialChannelDto guessed = new EssentialChannelDto();
            guessed.setId(guessedBase.getId());
            guessed.setName(guessedBase.getName());
            channelDtos.add(0, guessed);
        }
        
        // For each channel, ensure user-access and arch-compat with this server:
        List<EssentialChannelDto> retval = new LinkedList<EssentialChannelDto>();
        for (EssentialChannelDto ecd : channelDtos) {
            Channel channel = null;
            try {
                channel = lookupByIdAndUser(new Long(ecd.getId().longValue()), usr);
            } 
            catch (LookupException le) {
                log.info("User doesnt have access to channel: " + ecd.getId());
            }
            if (channel != null && 
                    channel.getChannelArch().isCompatible(s.getServerArch())) {
                if (!retval.contains(channel)) {
                    retval.add(ecd);
                }
            }
        }
        
        if (log.isDebugEnabled()) {
            log.debug("retval.size() = " + retval.size());
        }
        return retval;
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
        
        log.debug("ChannelManager.listCompatibleBaseChannelsForChannel");
        log.debug("channel = " + inChan.getLabel());
        List<EssentialChannelDto> retval = new ArrayList();

        // Get all the custom-channels owned by this org and add them
        DataResult dr = listBaseChannelsForOrg(u.getOrg());
        List<EssentialChannelDto> channels = new DataList(dr);
        
        // Find all of the obvious matches
        for (EssentialChannelDto ecd : channels) {
            Channel c = ChannelManager.lookupByIdAndUser(ecd.getId().longValue(), u);
            log.debug("   " + c.getName());
            if (c != null && 
                (c.getOrg() != null || 
                inChan.getChannelArch().equals(c.getChannelArch())) &&
                !retval.contains(ecd)) {
                retval.add(ecd);
            }
        }
        
        List<EssentialChannelDto> eusBaseChans = new LinkedList<EssentialChannelDto>();
        
        DistChannelMap dcm = ChannelFactory.lookupDistChannelMap(inChan);
        ReleaseChannelMap rcm = lookupDefaultReleaseChannelMapForChannel(inChan);
        if (dcm != null) {
            log.debug("Found dist channel map");
            String version = dcm.getRelease(); // bad naming in rhnDistChannelMap
            
            // If the inChan is the default base channel, that channel will not have
            // compatibility entries in rhnReleaseChannelMap, and we are to assume
            // that ALL entries in that table for the product/version/channel arch
            // are valid replacement base channels:
            if (isDefaultBaseChannel(inChan, version)) {
                EssentialChannelDto latestEus = lookupLatestEusChannelForRhelVersion(u, 
                        version, inChan.getChannelArch().getId());
                if (latestEus != null) {
                    log.debug("inChan is default channel, including latest EUS channel: " + 
                            latestEus.getLabel());
                    eusBaseChans.add(latestEus);
                }
                else {
                    log.warn("Unable to lookup the latest EUS channel!");
                }
            }
            
        }
        else if (rcm != null) {
            log.debug("Found release channel map");
            log.debug("System not subscribed to default base channel");
            String version = rcm.getVersion();
            String release = rcm.getRelease();
            ChannelArch channelArch = inChan.getChannelArch();
            
            // TODO: is this null check needed or just to get through tests?
            if (version != null) {
                // First make sure to add the default base channel, EUS systems should
                // always be able to upgrade to the mainline RHEL release for their 
                // version:
                Channel defaultBaseChan = getDefaultBaseChannel(version, channelArch);
                log.debug("Adding default base channel: " + defaultBaseChan.getLabel());
                retval.add(channelToEssentialChannelDto(defaultBaseChan, false));

                eusBaseChans = listBaseEusChannelsByVersionReleaseAndChannelArch(
                        u, version, release, channelArch.getId());
            }
        }
        else {
            log.debug("Unable to find dist or release channel map.");
        }
        
        log.debug("found " + eusBaseChans.size() + " EUS channels");
        retval.addAll(eusBaseChans);

        // Final check to remove the current channel if it's found in the list, we
        // already have a "No Change" option in the list:
        log.debug("Removing existing channel from list:");
        for (EssentialChannelDto dto : retval) {
            log.debug("   " + dto);
            log.debug("   " + dto.getLabel());
            if (dto.getId().longValue() == inChan.getId().longValue()) {
                log.debug("Removing current channel: " + dto.getLabel());
                retval.remove(dto); // normally not a good idea, but we do break
                break; 
            }
        }

       return retval;
    }

    private static EssentialChannelDto channelToEssentialChannelDto(Channel channel, 
            boolean isCustom) {
        EssentialChannelDto dto = new EssentialChannelDto();
        dto.setId(channel.getId());
        dto.setName(channel.getName());
        dto.setLabel(channel.getLabel());
        dto.setIsCustom(isCustom);
        return dto;
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
     * 
     * @param os Product name.
     * @param release Version.
     * @param channelArch Channel arch.
     * @return DistChannelMap, null if none is found
     */
    public static DistChannelMap lookupDistChannelMap(String os, String release, 
            ChannelArch channelArch) {
        return ChannelFactory.lookupDistChannelMap(os, release, 
                channelArch);
    }
    
    /**
     * Lookup the EUS base channels suitable for the given version, release, and 
     * server arch.
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
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                    "base_eus_channels_by_version_release_server_arch");
        release = normalizeRhelReleaseForMapping(release);
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        log.debug("   version = " + version);
        log.debug("   release = " + release);
        log.debug("   serverArch = " + serverArch);
        params.put("product_name_label", RHEL_PRODUCT_NAME);
        params.put("version", version);
        params.put("release", release);
        params.put("server_arch", serverArch);
        DataResult dr  = makeDataResult(params, new HashMap(), null, m);
        return dr;
    }
    
    /**
     * Lookup the EUS base channels suitable for the given version, release, and 
     * channel arch.
     * 
     * @param user User performing the query.
     * @param version RHEL version.
     * @param release RHEL version release.
     * @param channelArchId Channel arch.
     * @return List of EssentialChannelDto's.
     */
    public static List<EssentialChannelDto> 
        listBaseEusChannelsByVersionReleaseAndChannelArch(User user, 
            String version, String release, Long channelArchId) {
        
        log.debug("listBaseEusChannelsByVersionReleaseAndChannelArch()");
        SelectMode m = ModeFactory.getMode("Channel_queries", 
                    "base_eus_channels_by_version_release_channel_arch");
        release = normalizeRhelReleaseForMapping(release);
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        log.debug("   version = " + version);
        log.debug("   release = " + release);
        log.debug("   channelArch = " + channelArchId);
        params.put("product_name_label", RHEL_PRODUCT_NAME);
        params.put("version", version);
        params.put("release", release);
        params.put("channel_arch_id", channelArchId);
        DataResult dr  = makeDataResult(params, new HashMap(), null, m);
        return dr;
    }
    
    /**
     * Lookup the latest EUS base channel for the given version and server arch. Uses the
     * is_default column of rhnReleaseChannelMap to locate the latest release. If no
     * entry exists, null will be returned.
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
        
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        log.debug("   version = " + rhelVersion);
        log.debug("   channelArch = " + channelArchId);
        params.put("product_name_label", RHEL_PRODUCT_NAME);
        params.put("version", rhelVersion);
        params.put("channel_arch_id", channelArchId);
        DataResult dr  = makeDataResult(params, new HashMap(), null, m);
        if (dr.size() == 0) {
            return null;
        }
        else if (dr.size() > 1) {
            throw new LookupException(
                    "Found multiple default EUS channels for RHEL version.");
        }
        return (EssentialChannelDto)dr.get(0);
    }
    
    /**
     * List base channels for the given org.
     * @param o Org to list channels for.
     * @return List of channels.
     */
    public static DataResult listBaseChannelsForOrg(Org o) {
        SelectMode m = 
            ModeFactory.getMode("Channel_queries", "base_channels_for_org");
        Map params = new HashMap();
        params.put("org_id", o.getId());
        DataResult dr  = makeDataResult(params, new HashMap(), null, m);
        return dr;
    }
    
    /**
     * List base channels (including Red Hat channels) for a given org.
     * @param o Org to list base channels for.
     * @return List of Channels
     */
    public static List<Channel> findAllBaseChannelsForOrg(Org o) {
        return ChannelFactory.listAllBaseChannels(o);
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
        
        Map <ProductName, Channel> prodChannels = 
            new HashMap<ProductName, Channel>();
        
        for (Channel channel : newBaseChannel.getAccessibleChildrenFor(user)) {
            if (channel.getProductName() != null) {
                prodChannels.put(channel.getProductName(), channel);
            }
        }

        for (Channel childOne : oldBaseChannel.getAccessibleChildrenFor(user)) {
            ProductName name = childOne.getProductName();
            if (prodChannels.containsKey(name)) {
                compatibleChannels.put(childOne, prodChannels.get(name));
            }
        }
            
        return compatibleChannels;
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

        Map params = new HashMap();
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

        Map params = new HashMap();
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

        Map params = new HashMap();
        params.put("custom_cid", targetChannel.getId());

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
            return Collections.EMPTY_LIST;
        }

        SelectMode mode = ModeFactory.getMode(
                "Package_queries", "compatible_package_arches");
        DataResult dr = mode.execute(Arrays.asList(channelArchLabels));
        List<String> result = new ArrayList<String>();
        for (Object o : dr) {
            Map m = (Map) o;
            result.add((String) m.get("label"));
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
        if (client == null) {
            client = "";
        }
        
        if (reason == null) {
            reason = "";
        }
        
        WriteMode m = ModeFactory.getWriteMode("Channel_queries", "request_repo_regen");
        Map params = new HashMap();
        params.put("label", channelLabel);
        params.put("client", client);
        params.put("reason", reason);
        m.executeUpdate(params);
    }

}
