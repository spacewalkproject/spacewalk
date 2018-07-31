/**
 * Copyright (c) 2009--2017 Red Hat, Inc.
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
package com.redhat.rhn.domain.channel;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

/**
 * ChannelFactory
 * @version $Rev$
 */
public class ChannelFactory extends HibernateFactory {

    private static ChannelFactory singleton = new ChannelFactory();
    private static Logger log = Logger.getLogger(ChannelFactory.class);
    private ChannelFactory() {
        super();
    }

    /**
     * Get the Logger for the derived class so log messages
     * show up on the correct class
     */
    @Override
    protected Logger getLogger() {
        return log;
    }

    /**
     * Lookup a Channel by its id
     * @param id the id to search for
     * @return the Channel found
     */
    public static Channel lookupById(Long id) {
        Session session = HibernateFactory.getSession();
        return (Channel) session.get(Channel.class, id);
    }

    /**
     * Lookup a Channel by id and User
     * @param id the id to search for
     * @param userIn User who is doing the looking
     * @return the Server found (null if not or not member if userIn)
     */
    public static Channel lookupByIdAndUser(Long id, User userIn) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", id);
        params.put("userId", userIn.getId());
        return (Channel) singleton.lookupObjectByNamedQuery(
                                       "Channel.findByIdAndUserId", params);
    }

    /**
     * Lookup a Channel by label and User
     * @param label the label to search for
     * @param userIn User who is doing the looking
     * @return the Server found (null if not or not member if userIn)
     */
    public static Channel lookupByLabelAndUser(String label, User userIn) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", label);
        params.put("userId", userIn.getId());
        return (Channel) singleton.lookupObjectByNamedQuery(
                                       "Channel.findByLabelAndUserId", params);
    }

    /**
     * Lookup a content source type by label
     * @param label the label to lookup
     * @return the ContentSourceType
     */
    public static ContentSourceType lookupContentSourceType(String label) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", label);
        return (ContentSourceType) singleton.lookupObjectByNamedQuery(
                "ContentSourceType.findByLabel", params);
    }

    /**
     * List all available content source types
     * @return list of ContentSourceType
     */
    public static List<ContentSourceType> listContentSourceTypes() {
        return singleton.listObjectsByNamedQuery("ContentSourceType.listAllTypes",
                Collections.EMPTY_MAP);
    }

    /**
     * Lookup a content source by org
     * @param org the org to lookup
     * @return the ContentSource(s)
     */
    public static List<ContentSource> lookupContentSources(Org org) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org", org);
        return singleton.listObjectsByNamedQuery(
                "ContentSource.findByOrg", params);
    }

    /**
     * Lookup a content source by org/channel
     * @param org the org to lookup
     * @param c the channel
     * @return the ContentSource(s)
     */
    public static List<ContentSource> lookupContentSources(Org org, Channel c) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org", org);
        params.put("channel", c);
        return singleton.listObjectsByNamedQuery(
                "ContentSource.findByOrgandChannel", params);
    }

    /**
     * Lookup a content source by org and label
     * @param org the org to lookup
     * @param label repo label
     * @return the ContentSource(s)
     */
    public static ContentSource lookupContentSourceByOrgAndLabel(Org org,
            String label) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org", org);
        params.put("label", label);
        return (ContentSource) singleton.lookupObjectByNamedQuery(
                "ContentSource.findByOrgAndLabel", params);
    }

    /**
     * Lookup a content source by org and repo
     * @param org the org to lookup
     * @param repoType repo type
     * @param repoUrl repo url
     * @return the ContentSource(s)
     */
    public static List<ContentSource> lookupContentSourceByOrgAndRepo(Org org,
            ContentSourceType repoType, String repoUrl) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org", org);
        params.put("type_id", repoType.getId());
        params.put("url", repoUrl);
        return singleton.listObjectsByNamedQuery(
                "ContentSource.findByOrgAndRepo", params);
    }

    /**
     * lookup content source by id and org
     * @param id id of content source
     * @param orgIn org to check
     * @return content source
     */
    public static ContentSource lookupContentSource(Long id, Org orgIn) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("id", id);
        params.put("org", orgIn);
        return (ContentSource) singleton.lookupObjectByNamedQuery(
                "ContentSource.findByIdandOrg", params);
    }


    /**
     * Lookup a content source's filters by id
     * @param id source id
     * @return the ContentSourceFilters
     */
    public static List<ContentSourceFilter> lookupContentSourceFiltersById(Long id) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("source_id", id);
        return singleton.listObjectsByNamedQuery(
                "ContentSourceFilter.findBySourceId", params);
    }

    /**
     * Retrieve a list of channel ids associated with the labels provided
     * @param labelsIn the labels to search for
     * @return list of channel ids
     */
    public static List getChannelIds(List<String> labelsIn) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("labels", labelsIn);
        List<Long> list = singleton.listObjectsByNamedQuery(
                "Channel.findChannelIdsByLabels", params);
        if (list != null) {
            return list;
        }
        return new ArrayList<Long>();
    }

    /**
     * Insert or Update a Channel.
     * @param c Channel to be stored in database.
     */
    public static void save(Channel c) {
        c.setLastModified(new Date());
        singleton.saveObject(c);
    }

    /**
     * Insert or Update a content source.
     * @param c content source to be stored in database.
     */
    public static void save(ContentSource c) {
        singleton.saveObject(c);
    }

    /**
     * Insert or Update a DistChannelMap.
     * @param dcm DistChannelMap to be stored in database.
     */
    public static void save(DistChannelMap dcm) {
        singleton.saveObject(dcm);
    }

    /**
     * Insert or Update a content source filter.
     * @param f content source filter to be stored in database.
     */
    public static void save(ContentSourceFilter f) {
        singleton.saveObject(f);
    }

    /**
     * Remove a Channel from the DB
     * @param c Action to be removed from database.
     */
    public static void remove(Channel c) {
        // When we change delete_channel to return the number of rows
        // affected, we can delete all of the CallableMode code below
        // and simply use singleton.removeObject(c); Until then I'm
        // using DataSource.  I must say that working with existing
        // schema, while a reality in most software projects, SUCKS!

        CallableMode m = ModeFactory.getCallableMode(
                "Channel_queries", "delete_channel");
        Map<String, Object> inParams = new HashMap<String, Object>();
        inParams.put("cid", c.getId());

        m.execute(inParams, new HashMap<String, Integer>());
    }

    /**
     * Remove a DistChannelMap from the DB
     * @param dcm Action to be removed from database.
     */
    public static void remove(DistChannelMap dcm) {
        singleton.removeObject(dcm);
    }

    /**
     * Remove a Content Source from the DB
     * @param src to be removed from database
     */
    public static void remove(ContentSource src) {
        singleton.removeObject(src);
    }

    /**
     * Remove a ContentSourceFilter from the DB
     * @param filter to be removed from database
     */
    public static void remove(ContentSourceFilter filter) {
        singleton.removeObject(filter);
    }

    /**
     * Returns the base channel for the given server id.
     * @param sid Server id whose base channel we want.
     * @return Base Channel for the given server id.
     */
    public static Channel getBaseChannel(Long sid) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("sid", sid);
        return (Channel) singleton.lookupObjectByNamedQuery(
                "Channel.findBaseChannel", params);
    }

    /**
     * Returns a list of Channels which have clonable errata.
     * @param org Org.
     * @return List of com.redhat.rhn.domain.Channel objects which have
     * clonable errata.
     */
    public static List<ClonedChannel> getChannelsWithClonableErrata(Org org) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org", org);
        return singleton.listObjectsByNamedQuery(
                "Channel.channelsWithClonableErrata", params, false);
    }

    /**
     * Returns the list of Channel ids which the given orgid has access to.
     * @param orgid Org id
     * @param cid Base Channel id.
     * @return the list of Channel ids which the given orgid has access to.
     */
    public static List<Channel> getUserAcessibleChannels(Long orgid, Long cid) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", orgid);
        params.put("cid", cid);
        return singleton.listObjectsByNamedQuery(
                "Channel.accessibleChildChannelIds", params);
    }

    /**
     * Returns the accessible child channels associated to a base channel.
     * @param baseChannel the base channel who's child channels are needed
     * @param user the user requesting the info.. (has to be globally subscribed etc.)
     * @return the accessible child channels..
     */
    public static List<Channel> getAccessibleChildChannels(Channel baseChannel,
                                                                    User user) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("userId", user.getId());
        params.put("cid", baseChannel.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.accessibleChildChannels", params);
    }

    /**
     * Returns the list of Channels accessible by an org
     * Channels are accessible if they are owned by an org or public.
     * @param orgid The id for the org
     * @return A list of Channel Objects.
     */
    public static List<Channel> getAccessibleChannelsByOrg(Long orgid) {
        Map<String, Long> params = new HashMap<String, Long>();
        params.put("org_id", orgid);
        return singleton.listObjectsByNamedQuery("Org.accessibleChannels", params);
    }

    /**
     * Returns list of channel architectures
     * @return list of channel architectures
     */
    public static List<ChannelArch> getChannelArchitectures() {
        Session session = getSession();
        Criteria criteria = session.createCriteria(ChannelArch.class);
        return criteria.list();
    }

    /**
     * returns a ChannelArch by label
     * @param label ChannelArch label
     * @return a ChannelArch by label
     */
    public static ChannelArch findArchByLabel(String label) {
        Session session = getSession();
        Criteria criteria = session.createCriteria(ChannelArch.class);
        criteria.add(Restrictions.eq("label", label));
        return (ChannelArch) criteria.uniqueResult();
    }

    /**
     * Returns the Channel whose label matches the given label.
     * @param org The org of the user looking up the channel
     * @param label Channel label sought.
     * @return the Channel whose label matches the given label.
     */
    public static Channel lookupByLabel(Org org, String label) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", label);
        params.put("orgId", org.getId());
        return (Channel) singleton.lookupObjectByNamedQuery("Channel.findByLabelAndOrgId",
                params);
    }

    /**
     * Returns the Channel whose label matches the given label.
     * This was added to allow taskomatic to lookup channels by label,
     * and should NOT be used from the webui.
     * @param label Channel label sought.
     * @return the Channel whose label matches the given label.
     */
    public static Channel lookupByLabel(String label) {
        Session session = getSession();
        Criteria c = session.createCriteria(Channel.class);
        c.add(Restrictions.eq("label", label));
        return (Channel) c.uniqueResult();
    }



    /**
     * Returns true if the given channel is globally subscribable for the
     * given org.
     * @param org Org
     * @param c Channel to validate.
     * @return true if the given channel is globally subscribable for the
     */
    public static boolean isGloballySubscribable(Org org, Channel c) {
        SelectMode mode = ModeFactory.getMode(
                "Channel_queries", "is_not_globally_subscribable");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        params.put("cid", c.getId());
        params.put("label", "not_globally_subscribable");

        DataResult dr = mode.execute(params);
        // if the query returns something that means that this channel
        // is NOT globally subscribable by the org.  Which means the DataResult
        // will have a value in it.  If the channel IS globally subscribable
        // the DataResult will be empty (true);
        return dr.isEmpty();
    }

    /**
     * Set the globally subscribable attribute for a given channel
     * @param org The org containing the channel
     * @param channel The channel in question
     * @param value True to make the channel globally subscribable, false to make it not
     * globally subscribable.
     */
    public static void setGloballySubscribable(Org org, Channel channel, boolean value) {
        //we need to check here, otherwise if we try to remove and it's already removed
        //  the db throws a violation
        if (value == channel.isGloballySubscribable(org)) {
            return;
        }

        /*
         *  this is some bass-ackwards logic...
         *  if value == true, remove the 'not_globally_subscribable' setting
         *  if value == false, add the 'not_globally_subscribable' setting
         */
        if (value) {
            removeOrgChannelSetting(org, channel, "not_globally_subscribable");
        }
        else {
            addOrgChannelSetting(org, channel, "not_globally_subscribable");
        }
    }

    /**
     * Remove an org-channel setting
     * @param org The org in question
     * @param channel The channel in question
     * @param label the label of the setting to remove
     */
    private static void removeOrgChannelSetting(Org org, Channel channel, String label) {
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                                      "remove_org_channel_setting");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        params.put("cid", channel.getId());
        params.put("label", label);
        m.executeUpdate(params);
    }

    /**
     * Adds an org-channel setting
     * @param org The org in question
     * @param channel The channel in question
     * @param label the label of the setting to add
     */
    private static void addOrgChannelSetting(Org org, Channel channel, String label) {
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                                      "add_org_channel_setting");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        params.put("cid", channel.getId());
        params.put("label", label);
        m.executeUpdate(params);
    }

    /**
     *
     * @param cid Channel package is being added to
     * @param pid Package id from rhnPackage
     */
    public static void addChannelPackage(Long cid, Long pid) {
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
        "add_channel_package");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", cid);
        params.put("pid", pid);
        m.executeUpdate(params);
    }

    /**
     * Creates an empty Channel
     * @return empty Channel
     */
    public static Channel createChannel() {
        return new Channel();
    }

    /**
     * Creates an empty Repo
     * @return empty Repo
     */
    public static ContentSource createRepo() {
        return new ContentSource();
    }

    /**
     * Creates empty SSL set for repository
     * @return empty SSL set
     */
    public static SslContentSource createRepoSslSet() {
        return new SslContentSource();
    }

    /**
     * Utility to call {@link #refreshNewestPackageCache(Long, String)} given a channel.
     *
     * @param c     channel to be refreshed
     * @param label the label
     */
    public static void refreshNewestPackageCache(Channel c, String label) {
        refreshNewestPackageCache(c.getId(), label);
    }

    /**
     * Refreshes the channel with the "newest" packages.  Newest isn't just
     * the latest versions, an errata could have obsoleted a package in which
     * case this would have removed said package from the channel.
     *
     * @param channelId identifies the channel to be refreshed
     * @param label     the label
     */
    public static void refreshNewestPackageCache(Long channelId, String label) {
        CallableMode m = ModeFactory.getCallableMode("Channel_queries",
            "refresh_newest_package");
        Map<String, Object> inParams = new HashMap<String, Object>();
        inParams.put("cid", channelId);
        inParams.put("label", label);

        m.execute(inParams, new HashMap<String, Integer>());
    }

    /**
     * Clones the "newest" channel packages according to clone.
     *
     * @param fromChannelId original channel id
     * @param toChannelId cloned channle id
     */
    public static void cloneNewestPackageCache(Long fromChannelId, Long toChannelId) {
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
            "clone_newest_package");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("from_cid", fromChannelId);
        params.put("to_cid", toChannelId);
        m.executeUpdate(params);
    }

    /**
     * Returns true if the given label is in use.
     * @param label Label
     * @return true if the given label is in use.
     */
    public static boolean doesChannelLabelExist(String label) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", label);
        Object o = singleton.lookupObjectByNamedQuery(
                "Channel.verifyLabel", params, false);
        return (o != null);
    }

    /**
     * Returns true if the given name is in use.
     * @param name name
     * @return true if the given name is in use.
     */
    public static boolean doesChannelNameExist(String name) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("name", name);
        Object o = singleton.lookupObjectByNamedQuery(
                "Channel.verifyName", params, false);
        return (o != null);
    }

    /**
     * Return a list of kickstartable tree channels, i.e. channels that can
     * be used for creating kickstartable trees (distributions).
     * @param org org
     * @return list of channels
     */
    public static List<Channel> getKickstartableTreeChannels(Org org) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.kickstartableTreeChannels", params, false);
    }

    /**
     * Return a list of channels that are kickstartable to the Org passed in,
     * i.e. channels that can be used for creating kickstart profiles.
     * @param org org
     * @return list of channels
     */
    public static List<Channel> getKickstartableChannels(Org org) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.kickstartableChannels", params, false);
    }

    /**
     * Get a list of base channels that have an org associated
     * @param user the logged in user
     * @return List of Channels
     */
    public static List<Channel> listCustomBaseChannels(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findCustomBaseChannels", params);
    }

    /**
     * Find yum supported checksum types
     * @return List of ChecksumTypes instances
     */
    public static List<ChecksumType> listYumSupportedChecksums() {
        return singleton.listObjectsByNamedQuery(
                "ChecksumType.loadAllForYum", Collections.EMPTY_MAP);
    }

    /**
     * Find checksumtype by label
     * @param checksum checksum label
     * @return ChecksumType instance for given label
     */
    public static ChecksumType findChecksumTypeByLabel(String checksum) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", checksum);
        return (ChecksumType)
            singleton.lookupObjectByNamedQuery("ChecksumType.findByLabel", params);
    }

    /**
     * Get a list of packages ids that are in a channel
     *  and in a list of errata.  (The errata do not
     *  necessarily have to be associate with the channel)
     * @param chan the channel
     * @param eids the errata ids
     * @return list of package ids
     */
    public static List<Long>
            getChannelPackageWithErrata(Channel chan, Collection<Long> eids) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", chan.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.packageInChannelAndErrata", params, eids, "eids");

    }

    /**
     * Lookup a ChannelArch based on its name
     * @param name arch name
     * @return ChannelArch if found, otherwise null
     */
    public static ChannelArch lookupArchByName(String name) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("name", name);
        return (ChannelArch)
            singleton.lookupObjectByNamedQuery("ChannelArch.findByName", params);
    }

    /**
     * Lookup a ChannelArch based on its label
     * @param label arch label
     * @return ChannelArch if found, otherwise null
     */
    public static ChannelArch lookupArchByLabel(String label) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", label);
        return (ChannelArch)
            singleton.lookupObjectByNamedQuery("ChannelArch.findByLabel", params);
    }

    /**
     * Get package ids for a channel
     * @param cid the channel id
     * @return List of package ids
     */
    public static List<Long> getPackageIds(Long cid) {
        if (cid == null) {
            return new ArrayList<Long>();
        }
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", cid);
        return singleton.listObjectsByNamedQuery("Channel.getPackageIdList", params);
    }

    /**
     * Looksup the number of Packages in a channel
     * @param channel the Channel who's package count you are interested in.
     * @return number of packages in this channel.
     */
    public static int getPackageCount(Channel channel) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channel.getId());
        return (Integer)singleton.lookupObjectByNamedQuery
                                ("Channel.getPackageCount", params);
    }

    /**
     * Get the errata count for a channel
     * @param channel the channel
     * @return the errata count as an int
     */
    public static int getErrataCount(Channel channel) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", channel.getId());
        return (Integer)singleton.lookupObjectByNamedQuery
                                ("Channel.getErrataCount", params);
    }

    /**
     * Find the original packages that were part of a channel.  This list
     *      includes only those packages that have not had errata released for them.
     * @param channel the channel to clone from
     * @return List of packages
     */
    public static List<Long> findOriginalPackages(Channel channel) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("from_cid", channel.getId());
        return singleton.listObjectsByNamedQuery(
                    "Channel.lookupOriginalPackages", params);
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

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("channel", channel);
        List<ReleaseChannelMap> list = singleton.listObjectsByNamedQuery(
                "ReleaseChannelMap.findDefaultForChannel", params);
        if (list.isEmpty()) {
            return null;
        }
        Collections.sort(list);
        return list.get(0);
    }

    /**
     * List all defined dist channel maps
     *
     * Returns empty array if none is found.
     *
     * @return DistChannelMap[], empty if none is found
     */
    public static List<DistChannelMap> listAllDistChannelMaps() {

        return singleton.listObjectsByNamedQuery("DistChannelMap.listAll", null);
    }

    /**
     * Lists all dist channel maps for an user organization
     * @param org organization
     * @return list of dist channel maps
     */
    public static List<DistChannelMap> listAllDistChannelMapsByOrg(Org org) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        return singleton.listObjectsByNamedQuery("DistChannelMap.listAllByOrg", params);
    }

    /**
     * Lookup the dist channel map by id
     *
     * @param id dist channel map id
     * @return DistChannelMap, null if none is found
     */
    public static DistChannelMap lookupDistChannelMapById(Long id) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("id", id);
        return (DistChannelMap)singleton.lookupObjectByNamedQuery(
                "DistChannelMap.lookupById", params);
    }

    /**
     * Lookup the dist channel map for the given product name, release, and channel arch.
     * Returns null if none is found.
     * @param org organization
     * @param productName Product name.
     * @param release Version.
     * @param channelArch Channel arch.
     * @return DistChannelMap, null if none is found
     */
    public static DistChannelMap lookupDistChannelMapByPnReleaseArch(
            Org org, String productName, String release, ChannelArch channelArch) {

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("for_org_id", org.getId());
        params.put("product_name", productName);
        params.put("release", release);
        params.put("channel_arch_id", channelArch.getId());
        return (DistChannelMap)singleton.lookupObjectByNamedQuery(
                "DistChannelMap.findByProductNameReleaseAndChannelArch", params);
    }

    /**
     * Lookup the dist channel map for the given organization according to
     * release and channel arch.
     * Returns null if none is found.
     *
     * @param org organization
     * @param release release
     * @param channelArch Channel arch.
     * @return DistChannelMap, null if none is found
     */
    public static DistChannelMap lookupDistChannelMapByOrgReleaseArch(Org org,
            String release, ChannelArch channelArch) {

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        params.put("release", release);
        params.put("channel_arch_id", channelArch.getId());
        return (DistChannelMap)singleton.lookupObjectByNamedQuery(
                "DistChannelMap.findByOrgReleaseArch", params);
    }

    /**
     * Lists compatible dist channel mappings for a server available within an organization
     * Returns empty list if none is found.
     * @param server server
     * @return list of dist channel mappings, empty list if none is found
     */
    public static List<DistChannelMap> listCompatibleDcmByServerInNullOrg(Server server) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("release", server.getRelease());
        params.put("server_arch_id", server.getServerArch().getId());
        return singleton.listObjectsByNamedQuery(
                "DistChannelMap.findCompatibleByServerInNullOrg", params);
    }

    /**
     * Lists *common* compatible channels for all SSM systems subscribed to a common base
     * Returns empty list if none is found.
     * @param user user
     * @param channel channel
     * @return list of compatible channels, empty list if none is found
     */
    public static List<Channel> listCompatibleDcmForChannelSSMInNullOrg(User user,
            Channel channel) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("channel_id", channel.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findCompatibleForChannelSSMInNullOrg", params);
    }

    /**
     * Lists *common* compatible channels for all SSM systems subscribed to a common base
     * Returns empty list if none is found.
     * @param user user
     * @return list of compatible channels, empty list if none is found
     */
    public static List<Channel> listCompatibleBasesForSSMNoBaseInNullOrg(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findCompatibleSSMNoBaseInNullOrg", params);
    }

    /**
     * Lists *common* custom compatible channels
     * for all SSM systems subscribed to a common base
     * @param user user
     * @param channel channel
     * @return List of channels.
     */
    public static List<Channel> listCustomBaseChannelsForSSM(User user, Channel channel) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("channel_id", channel.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findCompatCustomBaseChsSSM", params);
    }

    /**
     * Lists *common* custom compatible channels
     * for all SSM systems without base channel
     * @param user user
     * @return List of channels.
     */
    public static List<Channel> listCustomBaseChannelsForSSMNoBase(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findCompatCustomBaseChsSSMNoBase", params);
    }

    /**
     * Lookup dist channel mappings for the given channel.
     * Returns empty list if none is found.
     *
     * @param c Channel to lookup mapping for
     * @return list of dist channel mappings, empty list if none is found
     */
    public static List<DistChannelMap> listDistChannelMaps(Channel c) {

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("channel", c);
        return singleton.listObjectsByNamedQuery(
                "DistChannelMap.findByChannel", params);
    }

    /**
     * Get a list of channels with no org that are not a child
     * @return List of Channels
     */
    public static List<Channel> listRedHatBaseChannels() {
        Map<String, Object> params = new HashMap<String, Object>();
        return singleton.listObjectsByNamedQuery("Channel.findRedHatBaseChannels", params);
    }


    /**
     * List all accessible Red Hat base channels for a given user
     * @param user logged in user
     * @return list of Red Hat base channels
     */
    public static List<Channel> listRedHatBaseChannels(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("userId", user.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findRedHatBaseChannelsByUserId", params);
    }

    /**
     * Lookup the original channel of a cloned channel
     * @param chan the channel to find the original of
     * @return The channel that was cloned, null if none
     */
    public static Channel lookupOriginalChannel(Channel chan) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("clone", chan);
        return (Channel)singleton.lookupObjectByNamedQuery(
                "Channel.lookupOriginal", params);
    }

    /**
     * Lookup a product name by label.
     *
     * @param label Product name label to search for.
     * @return Product name if found, null otherwise.
     */
    public static ProductName lookupProductNameByLabel(String label) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("label", label);
        return (ProductName)singleton.lookupObjectByNamedQuery(
                "ProductName.findByLabel", params);
    }

    /**
     * Returns a distinct list of ChannelArch labels for all synch'd and custom
     * channels in the satellite.
     * @return a distinct list of ChannelArch labels for all synch'd and custom
     * channels in the satellite.
     */
    public static List<String> findChannelArchLabelsSyncdChannels() {
        return singleton.listObjectsByNamedQuery(
                "Channel.findChannelArchLabelsSyncdChannels", null);
    }

    /**
     * List all accessible base channels for an org
     * @param user logged in user.
     * @return list of custom channels
     */
    public static List<Channel> listSubscribableBaseChannels(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findSubscribableBaseChannels", params);
    }

    /**
     * List all accessible base channels for an org
     * @param user logged in user.
     * @return list of custom channels
     */
    public static List<Channel> listAllBaseChannels(User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", user.getOrg().getId());
        params.put("user_id", user.getId());
        return singleton.listObjectsByNamedQuery(
                "Channel.findAllBaseChannels", params);
    }

    /**
     * List all accessible base channels for the entire satellite
     * @return list of base channels
     */
    public static List<Channel> listAllBaseChannels() {
        Map<String, Object> params = new HashMap<String, Object>();
        return singleton.listObjectsByNamedQuery(
                "Channel.findAllBaseChannelsOnSatellite", params);
    }


    /**
     * List all child channels of the given parent regardless of the user
     * @param parent the parent channel
     * @return list of children of the parent
     */
    public static List<Channel> listAllChildrenForChannel(Channel parent) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("parent", parent);
        return singleton.listObjectsByNamedQuery(
                "Channel.listAllChildren", params);
    }

    /**
     * Lookup a Package based on the channel and package file name
     * @param channel to look in
     * @param fileName to look up
     * @return Package if found
     */
    public static Package lookupPackageByFilename(Channel channel,
            String fileName) {

        List<Package> pkgs = HibernateFactory.getSession()
          .getNamedQuery("Channel.packageByFileName")
          .setString("pathlike", "%/" + fileName)
          .setLong("channel_id", channel.getId().longValue())
          .list();
        if (pkgs.isEmpty()) {
            return null;
        }
        return pkgs.get(0);
    }

    /**
     * Method to check if the channel contains any kickstart distributions
     * associated to it.
     * @param ch the channel to check distros on
     * @return true of the channels contains any distros
     */
    public static boolean containsDistributions(Channel ch) {
        Criteria criteria = getSession().createCriteria(KickstartableTree.class);
        criteria.setProjection(Projections.rowCount());
        criteria.add(Restrictions.eq("channel", ch));
        return ((Number)criteria.uniqueResult()).intValue() > 0;
    }

    /**
     * Clear a content source's filters
     * @param id source id
     */
    public static void clearContentSourceFilters(Long id) {
        List<ContentSourceFilter> filters = lookupContentSourceFiltersById(id);

        for (ContentSourceFilter filter : filters) {
            remove(filter);
        }

        // flush so that if we're creating new filters we don't get constraint
        // violations for rhn_csf_sid_so_uq
        HibernateFactory.getSession().flush();
    }

    /**
     * returns channel manager id for given channel
     * @param org given organization
     * @param channelId channel id
     * @return list of channel managers
     */
    public static List<Long> listManagerIdsForChannel(Org org, Long channelId) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                "managers_for_channel_in_org");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        params.put("channel_id", channelId);
        DataResult<Map<String, Long>> dr = m.execute(params);
        List<Long> ids = new ArrayList<Long>();
        for (Map<String, Long> row : dr) {
            ids.add(row.get("id"));
        }
        return ids;
    }

    /**
     * returns channel subscriber id for given channel
     * @param org given organization
     * @param channelId channel id
     * @return list of channel subscribers
     */
    public static List<Long> listSubscriberIdsForChannel(Org org, Long channelId) {
        SelectMode m = ModeFactory.getMode("Channel_queries",
                "subscribers_for_channel_in_org");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", org.getId());
        params.put("channel_id", channelId);
        DataResult<Map<String, Long>> dr = m.execute(params);
        List<Long> ids = new ArrayList<Long>();
        for (Map<String, Long> row : dr) {
            ids.add(row.get("id"));
        }
        return ids;
    }

    /**
     * Locks the given Channel for update on a database level
     * @param c Channel to lock
     */
    public static void lock(Channel c) {
        singleton.lockObject(Channel.class, c.getId());
    }

    /**
     * Adds errata to channel mapping. Does nothing else
     * @param eids List of eids to add mappings for
     * @param cid channel id we're cloning into
     */
    public static void addClonedErrataToChannel(Set<Long> eids, Long cid) {
        WriteMode m = ModeFactory.getWriteMode("Channel_queries",
                "add_cloned_erratum_to_channel");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", cid);
        for (Long eid : eids) {
            params.put("eid", eid);
            m.executeUpdate(params);
        }
    }
}
