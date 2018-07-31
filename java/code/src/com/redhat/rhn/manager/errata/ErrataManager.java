/**
 * Copyright (c) 2009--2018 Red Hat, Inc.
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
/*
 * Copyright (c) 2010 SUSE LLC
 */
package com.redhat.rhn.manager.errata;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.action.errata.ErrataAction;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.ErrataFile;
import com.redhat.rhn.domain.errata.Severity;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.channel.manage.PublishErrataHelper;
import com.redhat.rhn.frontend.dto.CVE;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.OwnedErrata;
import com.redhat.rhn.frontend.dto.PackageDto;
import com.redhat.rhn.frontend.dto.PackageOverview;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.events.CloneErrataEvent;
import com.redhat.rhn.frontend.events.NewCloneErrataEvent;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.xmlrpc.InvalidErrataException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import redstone.xmlrpc.XmlRpcClient;
import redstone.xmlrpc.XmlRpcFault;

/**
 * ErrataManager is the singleton class used to provide business operations
 * on Errata, where those operations interact with other top tier business
 * objects.  Operations that require changes to the Errata.
 * @version $Rev$
 */
public class ErrataManager extends BaseManager {

    private static Logger log = Logger.getLogger(ErrataManager.class);
    public static final String DATE_FORMAT_PARSE_STRING = "yyyy-MM-dd";
    public static final long MAX_ADVISORY_RELEASE = 9999;

    private ErrataManager() {
    }

    /**
     * Converts a list of ErrataFile instances into java.io.File instances
     * If a corresponding java.io.File instance is not found for a given
     * ErrataFile instance then it is skipped and not added to the returned list.
     * @param errataFiles list of files to resolve
     * @return list of corresponding java.io.File instances
     */
    public static List resolveOvalFiles(List errataFiles) {
        if (errataFiles == null || errataFiles.size() == 0) {
            return null;
        }
        List retval = new LinkedList();
        for (Iterator iter = errataFiles.iterator(); iter.hasNext();) {
            String directory = Config.get().getString("web.mount_point");
            ErrataFile ef = (ErrataFile) iter.next();
            if (directory == null) {
                return null;
            }
            if (!directory.endsWith("/")) {
                directory += "/";
            }
            directory += "rhn/errata/oval/";
            String fileName = ef.getFileName();
            if (!fileName.toLowerCase().startsWith(directory)) {
                fileName = directory + fileName;
            }
            File f = new File(fileName);
            if (f.exists()) {
                retval.add(f);
            }
        }
        return retval;
    }

    /**
     * Tries to locate errata based on either the errataum's id or the
     * CVE/CAN identifier string.
     * @param identifier erratum id or CVE/CAN id string
     * @param org User organization
     * @return list of erratas found
     */
    public static List lookupErrataByIdentifier(String identifier, Org org) {
        return ErrataFactory.lookupByIdentifier(identifier, org);
    }

    /**
     * Takes an unpublished errata and returns a published errata into the
     * channels we pass in. NOTE:  This method does NOT update the errata cache for
     * the channels.  That is done when packages are pushed as part of the errata
     * publication process (which is not done here)
     *
     * @param unpublished The errata to publish
     * @param channelIds The Long channelIds we want to publish this Errata to.
     * @param user who is publishing errata
     * @return Returns a published errata.
     */
    public static Errata publish(Errata unpublished, Collection channelIds, User user) {
        //pass on to the factory
        Errata retval = ErrataFactory.publish(unpublished);
        log.debug("publish - errata published");

        retval = addChannelsToErrata(retval, channelIds, user);
        log.debug("publish - updateErrataCacheForChannelsAsync called");

        // update the search server
        updateSearchIndex();
        return retval;
    }

    /**
     * Takes an unpublished errata and returns a published errata
     *
     * @param unpublished The errata to publish
     * @return Returns a published errata.
     */
    public static Errata publish(Errata unpublished) {
        //pass on to the factory
        Errata retval = ErrataFactory.publish(unpublished);
        log.debug("publish - errata published");

        // update the search server
        updateSearchIndex();
        return retval;
    }

    /**
     * Add the channels in the channelIds set to the passed in errata.
     *
     * @param errata to add channels to
     * @param channelIds to add
     * @param user who is adding channels to errata
     * @return Errata that is reloaded from the DB.
     */
    public static Errata addChannelsToErrata(Errata errata,
            Collection<Long> channelIds, User user) {
        log.debug("addChannelsToErrata");
        Iterator itr = channelIds.iterator();

        while (itr.hasNext()) {
            Long channelId = (Long) itr.next();
            Channel channel = ChannelManager.lookupByIdAndUser(channelId, user);
            if (channel != null) {
                errata.addChannel(channel);
                errata.addChannelNotification(channel, new Date());
            }
        }

        //if we're publishing the errata but not pushing packages
        //  We need to add cache entries for ones that are already in the channel
        //  and associated to the errata
        List<Long> list = new ArrayList<Long>();
        list.addAll(channelIds);
        ErrataCacheManager.insertCacheForChannelErrata(list, errata);


        //Save the errata
        log.debug("addChannelsToErrata - storing errata");
        storeErrata(errata);

        errata = (Errata) HibernateFactory.reload(errata);
        log.debug("addChannelsToErrata - errata reloaded from DB");
        return errata;
    }

    /**
     * Creates a new (Unpublished) Errata object.
     * @return Returns a fresh errata
     */
    public static Errata createNewErrata() {
        return ErrataFactory.createUnpublishedErrata();
    }

    /**
     * Creates a new Unpublished Bug with the id and summary given.
     * @param id The id for the new bug.
     * @param summary The summary for the new bug.
     * @param url The url for the new bug.
     * @return Returns a Bug object.
     */
    public static Bug createNewUnpublishedBug(Long id, String summary, String url) {
        return ErrataFactory.createUnpublishedBug(id, summary, url);
    }

    /**
     * Creates a new PublishedBug with the id and summary given.
     * @param id The id for the new bug
     * @param summary The summary for the new bug
     * @param url The url for the new bug.
     * @return Returns a Bug object
     */
    public static Bug createNewPublishedBug(Long id, String summary, String url) {
        return ErrataFactory.createPublishedBug(id, summary, url);
    }

    /**
     * Returns all of the errata.
     * @param user Currently logged in user.
     * @return all of the errata.
     */
    public static DataResult allErrata(User user) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "all_errata");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", user.getOrg().getId());
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * Returns all of the errata of specified advisory type.
     * @param user Currently logged in user.
     * @param type advisory type
     * @return all errata of specified advisory type
     */
    public static DataResult allErrataByType(User user, String type) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "all_errata_by_type");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", user.getOrg().getId());
        params.put("type", type);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * Returns all of the security errata
     * @param user Currently logged in user.
     * @return all security errata
     */
    public static DataResult allSecurityErrata(User user) {
        SelectMode m = ModeFactory.getMode("Errata_queries",
                "all_errata_by_type_with_cves");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", user.getOrg().getId());
        params.put("type", ErrataFactory.ERRATA_TYPE_SECURITY);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * Returns all of the errata in a channel
     * @param cid the channel id
     * @return all of the errata in the channel.
     */
    public static DataResult errataInChannel(Long cid) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "channel_errata_for_list");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", cid);
        return m.execute(params);
    }


    /**
     * Returns a list of ErrataOverview whose errata contains the packages
     * with the given pids.
     * @param pids list of package ids whose errata are sought.
     * @return a list of ErrataOverview whose errata contains the packages
     * with the given pids.
     */
    public static List<ErrataOverview> searchByPackageIds(List pids) {
        return ErrataFactory.searchByPackageIds(pids);
    }

    /**
     * Returns a list of ErrataOverview whose errata contains the packages
     * with the given pids.
     * @param pids list of package ids whose errata are sought.
     * @param org Organization to match results with
     * @return a list of ErrataOverview whose errata contains the packages
     * with the given pids.
     */
    public static List<ErrataOverview> searchByPackageIdsWithOrg(List pids, Org org) {
        return ErrataFactory.searchByPackageIdsWithOrg(pids, org);
    }

    /**
     * Returns a list of ErrataOverview matching the given errata ids.
     * @param eids Errata ids sought.
     * @param org Organization to match results with
     * @return a list of ErrataOverview matching the given errata ids.
     */
    public static List<ErrataOverview> search(List eids, Org org) {
        return ErrataFactory.search(eids, org);
    }

    /** Returns errata relevant to given server group.
     * @param serverGroup Server group.
     * @return Relevant errata for server group.
     */
    public static DataResult relevantErrata(ManagedServerGroup serverGroup) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "relevant_to_server_group");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("sgid", serverGroup.getId());
        return makeDataResultNoPagination(params, null, m);
    }

    /**
     * Returns the relevant errata to the system set (used in SSM).
     *
     * @param user Currently logged in user.
     * @param types List of errata types to include
     * @return relevant errata.
     */
    public static DataResult relevantErrataToSystemSet(User user, List<String> types) {
        SelectMode m = ModeFactory.getMode("Errata_queries",
                                           "relevant_to_system_set");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        DataResult dr = m.execute(params, types);
        dr.setElaborationParams(elabParams);
        return dr;
    }

    /**
     * Returns the relevant errata.
     * @param user Currently logged in user.
     * @return relevant errata.
     */
    public static DataResult relevantErrata(User user) {
        SelectMode m = ModeFactory.getMode("Errata_queries",
                                           "relevant_errata");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * Returns the relevant errata.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @param typeIn String type of errata.  See ErrataFactory.ERRATA_TYPE_*
     * @return relevant errata.
     */
    public static DataResult relevantErrataByType(User user,
            PageControl pc, String typeIn) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "relevant_errata_by_type");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("type", typeIn);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns the relevant security errata.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return relevant errata.
     */
    public static DataResult relevantSecurityErrata(User user,
            PageControl pc) {
        SelectMode m = ModeFactory.getMode("Errata_queries",
                "relevant_errata_by_type_with_cves");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("type", ErrataFactory.ERRATA_TYPE_SECURITY);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns all of the unpublished errata.
     * @param user Currently logged in user.
     * @return all of the errata.
     */
    public static DataResult unpublishedOwnedErrata(User user) {
        return unpublishedOwnedErrata(user, null);
    }

    /**
     * Returns all of the unpublished errata.
     * @param user Currently logged in user.
     * @param clazz The class you would like the return values represented as
     * @return all of the errata.
     */
    public static DataResult unpublishedOwnedErrata(User user, Class clazz) {
        return ownedErrata(user, "unpublished_owned_errata", clazz);
    }

    /**
     * Returns all of the unpublished errata in the given set.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @param label Set label
     * @return all of the errata.
     */
    public static DataResult unpublishedInSet(User user, PageControl pc, String label) {
        return errataInSet(user, pc, "unpublished_in_set", label);
    }

    /**
     * Returns all of the published errata.
     * @param user Currently logged in user.
     * @return all of the errata.
     */
    public static DataResult publishedOwnedErrata(User user) {
        return ownedErrata(user, "published_owned_errata");
    }

    /**
     * Returns all of the published errata.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @param label Set label
     * @return all of the errata.
     */
    public static DataResult publishedInSet(User user, PageControl pc, String label) {
        return errataInSet(user, pc, "published_in_set", label);
    }

    /**
     * Returns all errata selected for cloning.
     * @param user Currently logged in user.
     * @param pc PageControl
     * @return errata selected for cloning
     */
    public static DataResult selectedForCloning(User user, PageControl pc) {
        return errataInSet(user, pc, "in_set", "clone_errata_list");
    }

    /**
     * Return a list of errata overview objects contained in a set
     * @param user the user doing the lookup
     * @param setLabel the set
     * @return the set of ErrataOverview
     */
    public static DataResult<ErrataOverview> errataInSet(User user, String setLabel) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "in_set_details");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("set_label", setLabel);
        DataResult dr = m.execute(params);
        params.remove("set_label");
        dr.setElaborationParams(params);
        return dr;
    }

    /**
     * Helper method to get the unpublished/published errata
     * @param user Currently logged in user
     * @param mode Tells which mode (published/unpublished) we need to run
     * @return all of the errata
     */
    private static DataResult ownedErrata(User user, String mode) {
        return ownedErrata(user, mode, null);
    }

    /**
     * Helper method to get the unpublished/published errata
     * @param user Currently logged in user
     * @param mode Tells which mode (published/unpublished) we need to run
     * @param clazz The class you would like the return values represented as
     * @return all of the errata
     */
    private static DataResult ownedErrata(User user, String mode, Class clazz) {
        SelectMode m;
        if (clazz == null) {
            m = ModeFactory.getMode("Errata_queries", mode);
        }
        else {
            m = ModeFactory.getMode("Errata_queries", mode, clazz);
        }
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", user.getOrg().getId());
        return makeDataResult(params, new HashMap(), null, m);
    }

    /**
     * Helper method to get the unpublished/published errata in the set
     * @param user Currently logged in user
     * @param pc PageControl
     * @param mode Tells which mode (published/unpublished) we need to run
     * @param label Set label
     * @return all of the errata
     */
    private static DataResult errataInSet(User user, PageControl pc, String mode,
            String label) {
        SelectMode m = ModeFactory.getMode("Errata_queries", mode);
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("set_label", label);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }


    /**
     * Delete published errata in the set named as label
     * @param user User performing the operation
     * @param label name of the set that contains the id's of the errata to be deleted
     */
    public static void deletePublishedErrata(User user, String label) {
        DataResult dr = publishedInSet(user, null, label);
        deleteErrata(user, dr);
    }

    /**
     * Delete unpublished errata in the set named as label
     * @param user User performing the operation
     * @param label name of the set that contains the id's of the errata to be deleted
     */
    public static void deleteUnpublishedErrata(User user, String label) {
        DataResult dr = unpublishedInSet(user, null, label);
        deleteErrata(user, dr);
    }

    /**
     * Delete multiple errata
     * @param user the user deleting
     * @param The list of errata ids
     */
    private static void deleteErrata(User user, List<OwnedErrata> erratas) {


        RhnSet bulk = RhnSetDecl.ERRATA_TO_DELETE_BULK.get(user);
        bulk.clear();

        for (OwnedErrata oe : erratas) {
            bulk.add(oe.getId());
        }
        RhnSetManager.store(bulk);

        List eList = new ArrayList();
        eList.addAll(bulk.getElementValues());
        List<ChannelOverview> cList = listChannelForErrataFromSet(bulk);


        List<WriteMode> modes = new LinkedList<WriteMode>();
        modes.add(ModeFactory.getWriteMode("Errata_queries",
                "deleteChannelErrataPackagesBulk"));
        modes.add(ModeFactory.getWriteMode("Errata_queries", "deleteErrataFileBulk"));
        modes.add(ModeFactory.getWriteMode("Errata_queries", "deleteErrataPackageBulk"));
        modes.add(ModeFactory.getWriteMode("Errata_queries", "deleteErrataTmpBulk"));
        modes.add(ModeFactory.getWriteMode("Errata_queries",
                "deleteServerErrataPackageCacheBulk"));
        modes.add(ModeFactory.getWriteMode("Errata_queries", "deleteErrataBulk"));


        Map errataParams = new HashMap();
        Map errataOrgParams = new HashMap();
        errataOrgParams.put("org_id", user.getOrg().getId());

        errataParams.put("uid", user.getId());
        errataOrgParams.put("uid", user.getId());
        errataParams.put("set", bulk.getLabel());
        errataOrgParams.put("set", bulk.getLabel());

        for (WriteMode mode : modes) {
            if (mode.getArity() == 2) {
                mode.executeUpdate(errataParams);
            }
            else {
                mode.executeUpdate(errataOrgParams);
            }
        }

        bulk.clear();
        RhnSetManager.store(bulk);

        for (ChannelOverview chan : cList) {
            ChannelManager.refreshWithNewestPackages(chan.getId(),
                    "channel_errata_remove");
        }

    }

    /**
     * Deletes a single erratum
     * @param user doing the deleting
     * @param errata The erratum for deletion
     */
    public static void deleteErratum(User user, Errata errata) {
        List<OwnedErrata> eids = new ArrayList<OwnedErrata>();
        OwnedErrata oErrata = new OwnedErrata();
        oErrata.setId(errata.getId());
        oErrata.setAdvisory(errata.getAdvisory());
        eids.add(oErrata);
        deleteErrata(user, eids);
    }

    /**
     * Get a list of channel ids, and labels that a list of errata belongs to.
     * @param set the set of errata ids to retrieve channels for
     * @return list of Channel OVerview Objects
     */
    protected static List<ChannelOverview> listChannelForErrataFromSet(RhnSet set) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "errata_channel_id_label");
        Map map = new HashMap();
        map.put("label", set.getLabel());
        map.put("uid", set.getUserId());
        return m.execute(map);
    }

    /**
     * Returns the errata with given id
     * @param eid errata id
     * @param user The user performing the lookup
     * @return Errata the requested errata
     */
    public static Errata lookupErrata(Long eid, User user) {
        Errata returnedErrata = null;
        if (eid == null) {
            return null;
        }

        returnedErrata = ErrataFactory.lookupById(eid);

        SelectMode m = ModeFactory.getMode("Errata_queries", "available_to_org");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", user.getOrg().getId());
        params.put("eid", eid);

        // If we didn't find an errata, throw a lookup exception
        if (returnedErrata == null) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find errata: " + eid);
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.errata"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.errata"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.errata"));
            throw e;
        }

        // If the errata is available to the users org, return the errata
        if (!m.execute(params).isEmpty()) {
            return returnedErrata;
        }

        // If this is a non-accessible RH errata or the errata belongs to another org,
        // throw a lookup exception
        if (returnedErrata.getOrg() == null ||
                (returnedErrata.getOrg().getId() != user.getOrg().getId() &&
                !user.getOrg().getTrustedOrgs().contains(returnedErrata.getOrg()))) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e = new LookupException("Could not find errata: " + eid);
            e.setLocalizedTitle(ls.getMessage("lookup.jsp.title.errata"));
            e.setLocalizedReason1(ls.getMessage("lookup.jsp.reason1.errata"));
            e.setLocalizedReason2(ls.getMessage("lookup.jsp.reason2.errata"));
            throw e;
        }

        // The errata belongs to the users org
        return returnedErrata;
    }

    /**
     * Returns the errata with the given advisory name
     * @param advisoryName The advisory name of the errata you're looking for
     * @param org User organization
     * @return Returns the requested Errata
     */
    public static Errata lookupByAdvisory(String advisoryName, Org org) {
        return ErrataFactory.lookupByAdvisory(advisoryName, org);
    }

    /**
     * Looks up errata by CVE string
     * @param cve errata's CVE string
     * @return Errata if found, otherwise null
     */
    public static List lookupByCVE(String cve) {
        return ErrataFactory.lookupByCVE(cve);
    }

    /**
     * Lookup all Errata by Advisory Type
     * @param advisoryType the advisory type to use to query the set of Errata
     * @return List of Errata found
     */
    public static List lookupErrataByType(String advisoryType) {
        return ErrataFactory.lookupErratasByAdvisoryType(advisoryType);
    }

    /**
     * Looks up published errata by errata id
     * @param id errata id
     * @return Errata if found, otherwise null
     */
    public static Errata lookupPublishedErrata(Long id) {
        return ErrataFactory.lookupPublishedErrataById(id);
    }

    /**
     * Returns the systems affected by a given errata
     * @param user The current user
     * @param eid The errata id
     * @param pc PageControl
     * @return systems affected by current errata
     */
    public static DataResult<SystemOverview> systemsAffected(User user, Long eid,
            PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries", "affected_by_errata");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        params.put("user_id", user.getId());
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("eid", eid);
        return makeDataResult(params, elabParams, pc, m, SystemOverview.class);
    }

    /**
     * Returns the systems affected by a given errata
     *
     * @param user Logged-in user.
     * @param serverGroup Server group.
     * @param erratum Errata ID.
     * @param pc PageControl
     * @return systems Affected by current errata, that are in serverGroup.
     */
    public static DataResult<SystemOverview> systemsAffected(User user,
            ManagedServerGroup serverGroup, Errata erratum, PageControl pc) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", erratum.getId());
        params.put("user_id", user.getId());
        params.put("sgid", serverGroup.getId());
        return makeDataResult(params, Collections.EMPTY_MAP, pc,
            ModeFactory.getMode("Errata_queries", "in_group_and_affected_by_errata"));
    }

    /**
     * Returns the systems affected by a given errata
     *
     * @param user Logged-in user.
     * @param eid Errata ID.
     * @param pc PageControl
     * @return systems Affected by current errata, that are in the set of SSM.
     */
    public static DataResult<SystemOverview> systemsAffectedInSet(User user, Long eid,
            PageControl pc) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        params.put("user_id", user.getId());
        return makeDataResult(params, Collections.EMPTY_MAP, pc,
                ModeFactory.getMode("Errata_queries", "in_set_and_affected_by_errata"));
    }

    /**
     * Returns the system id and system names of the systems affected by a given errata
     * @param user The logged in user
     * @param eid The id of the errata in question
     * @return Returns the system id and system names of the systems affected by a
     * given errata
     */
    public static DataResult systemsAffectedXmlRpc(User user, Long eid) {
        SelectMode m = ModeFactory.getMode("System_queries",
                "affected_by_errata_no_selectable",
                Map.class);
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        params.put("user_id", user.getId());
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("eid", eid);
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * Returns the systems in the current set that are affected by an errata
     * @param user The current user
     * @param label The name of the set
     * @param eid Errata id
     * @param pc PageControl
     * @return DataResult of systems
     */
    public static DataResult relevantSystemsInSet(User user, String label,
            Long eid, PageControl pc) {
        SelectMode m = ModeFactory.getMode("System_queries",
                "in_set_and_affected_by_errata");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        params.put("user_id", user.getId());
        params.put("set_label", label);
        if (pc != null) {
            return makeDataResult(params, params, pc, m);
        }
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        return dr;
    }

    /**
     * Returns a list of available channels affected by an errata
     * @param user The user (to determine available channels)
     * @param eid The errata id
     * @return channels affected
     */
    public static DataResult affectedChannels(User user, Long eid) {
        SelectMode m = ModeFactory.getMode("Channel_queries", "affected_by_errata");

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        params.put("org_id", user.getOrg().getId());
        return m.execute(params);
    }

    /**
     * Returns a list of bugs fixed by an errata
     * @param eid The errata id
     * @return bugs fixed
     */
    public static DataResult bugsFixed(Long eid) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "bugs_fixed_by_errata");

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        return m.execute(params);
    }

    /**
     * Returns a list of CVEs for an errata
     * @param eid The errata id
     * @return common vulnerabilities and exposures
     */
    public static DataResult errataCVEs(Long eid) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "cves_for_errata");

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        return m.execute(params);
    }

    /**
     * Returns a list of keywords for an errata
     * @param eid The errata id
     * @return keywords
     */
    public static DataResult keywords(Long eid) {
        SelectMode m = ModeFactory.getMode("Errata_queries", "keywords");

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        return m.execute(params);
    }

    /**
     * Returns a list of advisory types available for an errata
     * @return advisory types
     */
    public static List<String> advisoryTypes() {
        List<String> advTypes = new ArrayList<String>();
        LocalizationService ls = LocalizationService.getInstance();
        advTypes.add(ls.getMessage("errata.create.bugfixadvisory",
                LocalizationService.DEFAULT_LOCALE));
        advTypes.add(ls.getMessage("errata.create.productenhancementadvisory",
                LocalizationService.DEFAULT_LOCALE));
        advTypes.add(ls.getMessage("errata.create.securityadvisory",
                LocalizationService.DEFAULT_LOCALE));
        return advTypes;
    }



    /**
     * Returns a list of l10n-ed advisory types available for an errata
     * @return l10n-ed advisory type labels
     */
    public static List<String> advisoryTypeLabels() {
        List<String> advTypeLabels = new ArrayList<String>();
        LocalizationService ls = LocalizationService.getInstance();
        advTypeLabels.add(ls.getMessage("errata.create.bugfixadvisory"));
        advTypeLabels.add(ls.getMessage("errata.create.productenhancementadvisory"));
        advTypeLabels.add(ls.getMessage("errata.create.securityadvisory"));
        return advTypeLabels;
    }

    /**
     * Returns a list of l10n-ed advisory severity types available for an errata
     * @return l10n-ed advisory severity labels
     */
    public static List<String> advisorySeverityLabels() {
        List<String> advSeverityLabels = new ArrayList<String>();
        LocalizationService ls = LocalizationService.getInstance();
        advSeverityLabels.add(ls.getMessage(Severity.CRITICAL_LABEL));
        advSeverityLabels.add(ls.getMessage(Severity.IMPORTANT_LABEL));
        advSeverityLabels.add(ls.getMessage(Severity.MODERATE_LABEL));
        advSeverityLabels.add(ls.getMessage(Severity.LOW_LABEL));
        advSeverityLabels.add(ls.getMessage(Severity.UNSPECIFIED_LABEL));
        return advSeverityLabels;
    }

    /**
     * Returns untranslated severity labels
     * @return Untranslated advisory severity labels
     */
    public static Map<String, String> advisorySeverityUntranslatedLabels() {
        Map<String, String> labelMap = new HashMap<String, String>();
        LocalizationService ls = LocalizationService.getInstance();
        labelMap.put(Severity.CRITICAL_LABEL, ls.getMessage(Severity.CRITICAL_LABEL));
        labelMap.put(Severity.IMPORTANT_LABEL, ls.getMessage(Severity.IMPORTANT_LABEL));
        labelMap.put(Severity.MODERATE_LABEL, ls.getMessage(Severity.MODERATE_LABEL));
        labelMap.put(Severity.LOW_LABEL, ls.getMessage(Severity.LOW_LABEL));
        labelMap.put(Severity.UNSPECIFIED_LABEL, ls.getMessage(Severity.UNSPECIFIED_LABEL));
        return labelMap;
    }

    /**
     * Returns a list of advisory severity ranks available for an errata
     * @return advisory severity ranks
     */
    public static List<Integer> advisorySeverityRanks() {
        List<Integer> advSeverityRankss = new ArrayList<Integer>();
        // get ranks for all of 4 severities we define, plus 'unspecified' for null value
        advSeverityRankss.add(Severity.getById(0).getRank());
        advSeverityRankss.add(Severity.getById(1).getRank());
        advSeverityRankss.add(Severity.getById(2).getRank());
        advSeverityRankss.add(Severity.getById(3).getRank());
        advSeverityRankss.add(Severity.UNSPECIFIED_RANK); // dummy rank for 'unspecified'
        return advSeverityRankss;
    }

    /**
     * Stores an errata to the db
     * @param errataIn The errata to store.
     */
    public static void storeErrata(Errata errataIn) {
        ErrataFactory.save(errataIn);
    }

    /**
     * Sees if there is an errata with the same advisory name as the errata with eid
     * @param eid The id of the errata you're checking
     * @param name The advisory name you're checking
     * @param org User organization
     * @return Returns true if no other errata exists with the same advisoryName, false
     * otherwise.
     */
    public static boolean advisoryNameIsUnique(Long eid, String name, Org org) {
        Errata e = lookupByAdvisory(name, org);
        //If we can't find an errata, then the advisoryName is unique
        if (e == null) {
            return true;
        }
        //If the errata we found is the same as the one we are checking for,
        //then we don't care. return false.
        return e.getId().equals(eid);
    }

    /**
     * Get List of all cloneable errata for an org
     * @param orgid org we want to lookup against
     * @param showCloned whether we should show errata that have already been cloned
     * @return List of cloneableErrata
     */
    public static DataResult clonableErrata(Long orgid,
            boolean showCloned) {
        SelectMode m;

        if (showCloned) {
            m = ModeFactory.getMode("Errata_queries",
                    "clonable_errata_list_all");
        }
        else {
            m = ModeFactory.getMode("Errata_queries",
                    "clonable_errata_list_uncloned");
        }


        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", orgid);
        return makeDataResult(params, params, null, m);
    }

    /**
     * Get List of cloneable Errata for an org, from a particular channel
     * @param orgid org we want to lookup against
     * @param cid channelid
     * @param showCloned whether we should show errata that have already been cloned
     * @return List of cloneableErrata
     */
    public static DataResult clonableErrataForChannel(Long orgid,
            Long cid,
            boolean showCloned) {
        SelectMode m;

        if (showCloned) {
            m = ModeFactory.getMode("Errata_queries",
                    "clonable_errata_for_channel_all");
        }
        else {
            m = ModeFactory.getMode("Errata_queries",
                    "clonable_errata_for_channel_uncloned");
        }

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("channel_id", cid);
        params.put("org_id", orgid);
        return makeDataResult(params, params, null, m);
    }



    /**
     * Get a list of channels applicable to the erratum
     * @param eid The id of the erratum
     * @param orgid The id for the org we want to lookup against
     * @param pc The page control for the user
     * @param clazz The class you would like the return values represented as
     * @return List of applicable channels for the erratum (that the org has access to)
     */
    public static DataResult applicableChannels(Long eid, Long orgid,
            PageControl pc, Class clazz) {
        SelectMode m;
        if (clazz == null) {
            m = ModeFactory.getMode("Channel_queries", "org_errata_channels");
        }
        else {
            m = ModeFactory.getMode("Channel_queries", "org_errata_channels", clazz);
        }

        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", orgid);
        params.put("eid", eid);
        return makeDataResult(params, params, pc, m);
    }

    /**
     * Create a clone of the errata
     * @param user user performing the cloning
     * @param e errata to be cloned
     * @return clone of the errata
     */
    public static Errata createClone(User user, Errata e) {
        return ErrataFactory.createClone(user.getOrg(), e);
    }

    /**
     * Lookup all the clones of a particular errata
     *      looks up unpublished first, and then if none of those
     *      exist, it looks up published ones
     * @param user User that is performing the cloning operation
     * @param original Original errata that the clones are clones of
     * @return list of clones of the errata
     */
    public static List lookupByOriginal(User user, Errata original) {
        return ErrataFactory.lookupByOriginal(user.getOrg(), original);
    }

    /**
     * Lookup all the clones of a particular errata
     * @param user User that is performing the cloning operation
     * @param original Original errata that the clones are clones of
     * @return list of clones of the errata
     */
    public static List lookupPublishedByOriginal(User user, Errata original) {
        return ErrataFactory.lookupPublishedByOriginal(user.getOrg(), original);
    }

    /**
     * Lists errata present in both channels
     * @param user user
     * @param channelFrom channel1
     * @param channelTo channel2
     * @return list of errata
     */
    public static List listSamePublishedInChannels(User user,
            Channel channelFrom, Channel channelTo) {
        return ErrataFactory.listSamePublishedInChannels(user.getOrg(),
                channelFrom, channelTo);
    }

    /**
     * Lists errata from channelFrom, that are cloned from the same original
     * as errata in channelTo
     * @param user user
     * @param channelFrom channel1
     * @param channelTo channel2
     * @return list of errata
     */
    public static List listPublishedBrothersInChannels(User user,
            Channel channelFrom, Channel channelTo) {
        return ErrataFactory.listPublishedBrothersInChannels(user.getOrg(),
                channelFrom, channelTo);
    }

    /**
     * Lists errata from channelFrom, that have clones in channelTo
     * @param user user
     * @param channelFrom channel1
     * @param channelTo channel2
     * @return list of errata
     */
    public static List listPublishedClonesInChannels(User user,
            Channel channelFrom, Channel channelTo) {
        return ErrataFactory.listPublishedClonesInChannels(user.getOrg(),
                channelFrom, channelTo);
    }

    /**
     * Lookup packages that are associated with errata in the RhnSet "errata_list"
     * @param srcChan the source channel to find the package associations with
     * @param destChan if srcChan is not available, we will match package associations
     *      based on packages in the destChan
     * @param user the user doing the query
     * @param set the set label
     * @return List of packages
     */
    public static DataResult<PackageOverview> lookupPacksFromErrataSet(
            Channel srcChan, Channel destChan, User user, String set) {
        String mode;
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("uid", user.getId());
        params.put("set", set);

        if (srcChan != null) {
            mode = "find_packages_for_errata_set_with_assoc";
            params.put("src_cid", srcChan.getId());
            params.put("dest_cid", destChan.getId());
        }
        else {
            mode = "find_packages_for_errata_set_no_chan";
            params.put("dest_cid", destChan.getId());
        }
        SelectMode m = ModeFactory.getMode(
                "Errata_queries", mode);

        return m.execute(params);
    }


    /**
     * Lookup errata that are in the set and relevant to selected systems (in SSM)
     * @param user the user to search the set for
     * @param setLabel the set label
     * @return list of Errata Overview Objects
     */
    public static DataResult<ErrataOverview> lookupSelectedErrataInSystemSet(
            User user, String setLabel) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", user.getId());
        params.put("set_label", setLabel);
        Map<String, Object> elabParams = new HashMap<String, Object>();
        elabParams.put("user_id", user.getId());
        SelectMode m = ModeFactory.getMode(
                "Errata_queries", "in_set_relevant_to_system_set");
        return  makeDataResult(params, elabParams, null, m);

    }

    /**
     * Finds the packages contained in an errata that apply to a channel
     * @param customChan the channel to look in
     * @param errata the errata to look for packs with
     * @param user the user doing the request.
     * @return collection of PackageOverview objects
     */
    public static DataResult<PackageOverview> lookupPacksFromErrataForChannel(
            Channel customChan, Errata errata, User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        //params.put("uid", user.getId());
        params.put("eid" , errata.getId());
        params.put("org_id" , user.getOrg().getId());
        params.put("custom_cid", customChan.getId());
        SelectMode m = ModeFactory.getMode(
                "Errata_queries",  "find_packages_for_errata_and_channel");
        return m.execute(params);

    }

    /**
     * Finds the packages contained in an errata that apply to a channel
     * @param channelId the channel to look in
     * @param errataId the errata to look for packs with
     * @return collection of PackageDto objects
     */
    public static DataResult<PackageDto> lookupPacksFromErrataForChannel(Long channelId,
            Long errataId) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", errataId);
        params.put("cid", channelId);
        SelectMode m = ModeFactory.getMode("Errata_queries",
                "find_packages_for_errata_and_channel_simple");
        return m.execute(params);
    }

    /**
     * Finds the bugs associated with an erratum
     * @param erratumId the erratum to look for
     * @return collection of Bug (dto) objects
     */
    public static DataResult<com.redhat.rhn.frontend.dto.Bug> lookupBugsForErratum(
            Long erratumId) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", erratumId);
        SelectMode m = ModeFactory.getMode("Errata_queries", "find_bugs_for_erratum");
        return m.execute(params);
    }

    /**
     * Finds the cves associated with an erratum
     * @param erratumId the erratum to look for
     * @return collection of cves (String)
     */
    public static DataResult<CVE> lookupCvesForErratum(Long erratumId) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", erratumId);
        SelectMode m = ModeFactory.getMode("Errata_queries", "find_cves_for_erratum");
        return m.execute(params);
    }

    /**
     * Finds the keywords associated with an erratum
     * @param erratumId the erratum to look for
     * @return collection of keywords (String)
     */
    public static List<String> lookupKeywordsForErratum(Long erratumId) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", erratumId);
        SelectMode m = ModeFactory.getMode("Errata_queries", "find_keywords_for_erratum");
        List<Map<String, String>> results = m.execute(params);
        List<String> ret = new ArrayList<String>();
        for (Map<String, String> row : results) {
            ret.add(row.get("keyword"));
        }
        return ret;
    }

    /**
     * Lists the packages contained in an errata associated to a channel
     * @param customChan the channel to look in
     * @param errata the errata to look for packs with
     * @param user the user doing the request.
     * @return collection of PackageOverview objects
     */
    public static DataResult<PackageOverview> listErrataChannelPacks(
            Channel customChan, Errata errata, User user) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid" , errata.getId());
        params.put("org_id" , user.getOrg().getId());
        params.put("custom_cid", customChan.getId());
        SelectMode m = ModeFactory.getMode(
                "Errata_queries",  "find_errata_channel_packages");
        return m.execute(params);

    }

    /**
     * Finds the errata ids issued between start and end dates.
     * @param start String start date
     * @param end String end date
     * @return errata ids issued between {@literal start -> end}
     */
    public static List<Long> listErrataIdsIssuedBetween(String start, String end) {
        String mode = "issued_between";
        Map<String, Object> params = new HashMap<String, Object>();
        if (!StringUtils.isEmpty(start)) {
            params.put("start_date_str", start);
        }
        if (!StringUtils.isEmpty(end)) {
            params.put("end_date_str", end);
        }
        SelectMode m = ModeFactory.getMode("Errata_queries", mode);
        DataResult result =  m.execute(params);
        List ids = new ArrayList<Long>();
        for (Iterator iter = result.iterator(); iter.hasNext();) {
            Map row = (Map) iter.next();
            Long rawId = (Long) row.get("id");
            ids.add(rawId);
        }
        return ids;

    }



    /**
     * remove an erratum for a channel and updates the errata cache accordingly
     * @param errata the errata to remove
     * @param chan the channel to remove the erratum from
     * @param user the user doing the removing
     */
    public static void removeErratumFromChannel(Errata errata, Channel chan, User user) {

        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        //Since we don't remove the packages, we need to insert those entries
        //       in case they aren't already there.
        // So we are inserting   (systemID, packageId) entries, because we're
        //      going to delete the (systemId, packageId, errataId) entries
        List<Long> pids = ErrataFactory.listErrataChannelPackages(
                chan.getId(), errata.getId());
        ErrataCacheManager.insertCacheForChannelPackages(chan.getId(), null, pids);


        //Remove the errata from the channel
        chan.getErratas().remove(errata);
        List<Long> eList = new ArrayList<Long>();
        eList.add(errata.getId());
        //First delete the cache entries
        ErrataCacheManager.deleteCacheEntriesForChannelErrata(chan.getId(), eList);
        // Then we need to see if the errata is in any other channels within the
        // channel tree.

        List<Channel> cList = new ArrayList<Channel>();
        if (chan.isBaseChannel()) {
            cList.addAll(ChannelFactory.listAllChildrenForChannel(chan));
        }
        else {
            //add parent
            Channel parent = chan.getParentChannel();
            cList.add(parent); //add parent
            //add sibbling and self
            cList.addAll(ChannelFactory.listAllChildrenForChannel(parent));
            cList.remove(chan); //remove self

        }
        for (Channel tmpChan : cList) {
            if (tmpChan.getErratas().contains(errata)) {
                List<Long> tmpCidList = new ArrayList<Long>();
                tmpCidList.add(tmpChan.getId());
                ErrataCacheManager.insertCacheForChannelErrataAsync(tmpCidList, errata);
            }
        }

    }


    /**
     * Publish errata to a channel asynchronously (cloning as necessary),
     *   does not do any package push
     * @param chan the channel
     * @param errataIds list of errata ids
     * @param user the user doing the push
     */
    public static void publishErrataToChannelAsync(Channel chan,
            Collection<Long> errataIds, User user) {
        Logger.getLogger(ErrataManager.class).debug("Publishing");
        CloneErrataEvent eve = new CloneErrataEvent(chan, errataIds, user);
        MessageQueue.publish(eve);
    }

    /**
     * Clone errata to a channel
     * @param chan the channel
     * @param errata list of errata ids
     * @param user the user doing the push
     * @param inheritPackages inherit packages from the original bug (instaed of the
     * clone in the case of a clone of a clone)
     * @return an array of Errata that have been published
     */
    public static Object[] cloneErrataApi(Channel chan, Collection<Errata> errata,
            User user, boolean inheritPackages) {
        return cloneErrataApi(chan, errata, user, inheritPackages, true);
    }

    /**
     * Clone errata to a channel
     * @param chan the channel
     * @param errata list of errata ids
     * @param user the user doing the push
     * @param inheritPackages inherit packages from the original bug (instaed of the
     * clone in the case of a clone of a clone)
     * @param performPostActions true (default) if you want to refresh newest package
     * cache and schedule repomd regeneration. False only if you're going to do those
     * things yourself.
     * @return an array of Errata that have been published
     */
    public static Object[] cloneErrataApi(Channel chan, Collection<Errata> errata,
            User user, boolean inheritPackages, boolean performPostActions) {
        List<Errata> errataToPublish = new ArrayList<Errata>();
        // For each errata look up existing clones, or manually clone it
        for (Errata toClone : errata) {
            if (toClone.isCloned()) {
                errataToPublish.add(toClone);
            }
            else {
                List<Errata> clones = ErrataManager.lookupPublishedByOriginal(
                        user, toClone);
                if (clones.isEmpty()) {
                    errataToPublish.add(PublishErrataHelper.cloneErrataFast(
                            toClone, user.getOrg()));
                }
                else {
                    errataToPublish.add(clones.get(0));
                }
            }
        }

        List<Errata> published = ErrataFactory.publishToChannel(errataToPublish, chan,
                user, inheritPackages, performPostActions);
        for (Errata e : published) {
            ErrataFactory.save(e);
        }
        return published.toArray();
    }

    /**
     * Clone errata as necessary and link cloned errata with new channel.
     * Warning: this does not clone packages or schedule channel repomd regeneration.
     * You must do that yourself!
     * @param fromCid id of old channel
     * @param toCid id of channel to clone into
     * @param user the requesting user
     */
    public static void cloneChannelErrata(Long fromCid, Long toCid, User user) {
        List<ErrataOverview> toClone = ErrataFactory
                .relevantToOneChannelButNotAnother(fromCid, toCid);
        cloneChannelErrata(toClone, toCid, user);
    }

    /**
     * Clone errata as necessary and link cloned errata with new channel.
     * Warning: this does not clone packages or schedule channel repomd regeneration.
     * You must do that yourself!
     * @param toClone List of ErrataOverview to clone
     * @param toCid Channel id to clone them into
     * @param user the requesting user
     * @return list of errata ids that were published into channel
     */
    public static Set<Long> cloneChannelErrata(List<ErrataOverview> toClone, Long toCid,
            User user) {
        List<OwnedErrata> owned = ErrataFactory
                .listPublishedOwnedUnmodifiedClonedErrata(user.getOrg().getId());
        Set<Long> eids = new HashSet<Long>();

        // add published, cloned, owned errata to mapping. we want the oldest owned
        // clone to reuse. listPublishedOwnedUnmodifiedClonedErrata orders by created,
        // so we just add the first one we come across to the mapping and skip others
        Map<Long, OwnedErrata> eidToClone = new HashMap<Long, OwnedErrata>();
        for (OwnedErrata erratum : owned) {
            if (!eidToClone.containsKey(erratum.getFromErrataId())) {
                eidToClone.put(erratum.getFromErrataId(), erratum);
            }
            // add self id mapping too in case we are cloning the clone
            if (!eidToClone.containsKey(erratum.getId())) {
                eidToClone.put(erratum.getId(), erratum);
            }
        }

        for (ErrataOverview erratum : toClone) {
            if (!eidToClone.containsKey(erratum.getId())) {
                // no published owned clones yet, lets make our own
                // hibernate was too slow, had to rewrite in mode queries
                Long cloneId = PublishErrataHelper.cloneErrataFaster(erratum.getId(), user
                        .getOrg());
                eids.add(cloneId);

            }
            else {
                // we have one already, reuse it
                eids.add(eidToClone.get(erratum.getId()).getId());
            }
        }

        ChannelFactory.addClonedErrataToChannel(eids, toCid);

        // for things like errata email and auto errata updates
        for (Long eid : eids) {
            ErrataManager.addErrataChannelNotifications(eid, toCid);
        }
        return eids;
    }

    /**
     * Clone errata to a channel asynchronously
     * @param chan the channel
     * @param errata list of errata ids
     * @param user the user doing the push
     * @param inheritPackages inherit packages from the original bug (instead of the
     * clone in the case of a clone of a clone)
     */
    public static void cloneErrataApiAsync(Channel chan, List<Long> errata,
            User user, boolean inheritPackages) {
        Logger.getLogger(ErrataManager.class).debug("Cloning");
        ChannelFactory.lock(chan);
        for (long eid : errata) {
            NewCloneErrataEvent neve = new NewCloneErrataEvent(chan, eid, user,
                    inheritPackages);
            neve.register();
            MessageQueue.publish(neve);
        }
    }

    /**
     * Check if the channel has pending asynchronous errata clone jobs
     * @param channel channel to check
     * @return true if there are pending jobs, false otherwise
     */
    public static boolean channelHasPendingAsyncCloneJobs(Channel channel) {
        return AsyncErrataCloneCounter.getInstance().channelHasPendingJobs(
                channel.getId());
    }

    /**
     * Send errata notifications for a particular errata and channel
     * @param e the errata to send notifications about
     * @param chan the channel with which to decide which systems
     *       and users to send errata for
     * @param date  the date
     */
    public static void addErrataNotification(Errata e, Channel chan, Date date) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("cid", chan.getId());
        params.put("eid", e.getId());
        java.sql.Date newDate = new java.sql.Date(date.getTime());
        params.put("datetime", newDate);
        WriteMode m = ModeFactory.getWriteMode(
                "Errata_queries",  "insert_errata_notification");
        m.executeUpdate(params);
    }

    /**
     * Delete all errata notifications for an errata
     * @param e the errata to clear notifications for
     */
    public static void clearErrataNotifications(Errata e) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", e.getId());
        WriteMode m = ModeFactory.getWriteMode(
                "Errata_queries",  "clear_errata_notification");
        m.executeUpdate(params);
    }

    /**
     * delete any present and then enqueue a channel notification for the
     * given channel and erratum. This will trigger the taskomatic ErrataQueue
     * task to take a look, ensuring things like auto-errata-updates.
     * @param eid the errata to enqueue
     * @param cid affected channel
     */
    public static void addErrataChannelNotifications(Long eid, Long cid) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", eid);
        params.put("cid", cid);
        WriteMode m = ModeFactory.getWriteMode("Errata_queries",
                "clear_errata_channel_notification");
        m.executeUpdate(params);
        java.sql.Date newDate = new java.sql.Date(new java.util.Date().getTime());
        params.put("datetime", newDate);
        m = ModeFactory.getWriteMode("Errata_queries", "insert_errata_notification");
        m.executeUpdate(params);
    }

    /**
     * Delete all errata notifications for an errata in specified channel
     * @param e the errata to clear notifications for
     * @param c affected channel
     */
    public static void clearErrataChannelNotifications(Errata e, Channel c) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", e.getId());
        params.put("cid", c.getId());
        WriteMode m = ModeFactory.getWriteMode(
                "Errata_queries",  "clear_errata_channel_notification");
        m.executeUpdate(params);
    }

    /**
     * List queued errata notifications
     * @param e the errata
     * @return list of maps
     */
    public static List listErrataNotifications(Errata e) {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("eid", e.getId());
        SelectMode m = ModeFactory.getMode("Errata_queries", "list_errata_notification");
        return m.execute(params);
    }

    /**
     * update the errata search index.
     * @return true if index was updated, false otherwise.
     */
    private static boolean updateSearchIndex() {
        boolean flag = false;

        try {
            XmlRpcClient client = new XmlRpcClient(
                    ConfigDefaults.get().getSearchServerUrl(), true);
            List args = new ArrayList();
            args.add("errata");
            Boolean rc = (Boolean)client.invoke("admin.updateIndex", args);
            flag =  rc.booleanValue();
        }
        catch (XmlRpcFault e) {
            // right now updateIndex doesn't throw any faults.
            log.error("Errata index not updated. Search server unavailable." +
                    "ErrorCode = " + e.getErrorCode(), e);
            e.printStackTrace();
        }
        catch (Exception e) {
            // if the search server is down, folks will know when they
            // attempt to search. If this call failed the errata in
            // question won't be searchable immediately, but will get picked
            // up the next time the search server runs the job (after being
            // restarted.
            log.error("Errata index not updated. Search server unavailable.", e);
        }

        return flag;
    }

    /**
     * Apply errata updates to a system list at a specified time.
     * @param loggedInUser The logged in user
     * @param systemIds list of system IDs
     * @param errataIds List of errata IDs to apply (as Integers)
     * @param earliestOccurrence Earliest occurrence of the errata update
     * @return list of action ids
     */
    public static List<Long> applyErrataHelper(User loggedInUser, List<Long> systemIds,
            List<Integer> errataIds, Date earliestOccurrence) {

        if (systemIds.isEmpty()) {
            throw new InvalidParameterException("No systems specified.");
        }
        if (errataIds.isEmpty()) {
            throw new InvalidParameterException("No errata to apply.");
        }

        // at this point all errata is applicable to all systems, so let's apply
        return applyErrata(loggedInUser, errataIds, earliestOccurrence,
                null, systemIds, false);
    }

    /**
     * Apply a list of errata to a list of servers.
     * @param user user
     * @param errataIds errata ids
     * @param earliest schedule time
     * @param serverIds server ids
     * @return list of action ids
     */
    public static List<Long> applyErrata(User user, List errataIds, Date earliest,
        List<Long> serverIds) {
        return applyErrata(user, errataIds, earliest, null, serverIds);
    }

    /**
     * Apply a list of errata to a list of servers, with an optional Action
     * Chain.
     * Note that not all erratas are applied to all systems. Systems get
     * only the erratas relevant for them.
     * @param user user
     * @param errataIds errata ids
     * @param earliest schedule time
     * @param actionChain the action chain to add the action to or null
     * @param serverIds server ids
     * @return list of action ids
     */
    public static List<Long> applyErrata(User user, List errataIds, Date earliest,
                                         ActionChain actionChain, List<Long> serverIds) {
        return  applyErrata(user, errataIds, earliest, actionChain, serverIds, true);
    }

    /**
     * Apply a list of errata to a list of servers, with an optional Action
     * Chain.
     * Note that not all erratas are applied to all systems. Systems get
     * only the erratas relevant for them.
     *
     * @param user user
     * @param errataIds errata ids
     * @param earliest schedule time
     * @param actionChain the action chain to add the action to or null
     * @param serverIds server ids
     * @param onlyRelevant If true not all erratas are applied to all systems.
     *        Systems get only the erratas relevant for them.
     *        If false, InvalidErrataException is thrown if an errata does not apply
     *        to a system.
     * @return list of action ids
     */
    private static List<Long> applyErrata(User user, List errataIds, Date earliest,
        ActionChain actionChain, List<Long> serverIds, boolean onlyRelevant) {

        // not all errata applies to all systems, so we will filter them
        Map<Long, List<Server>> serversForErrata = new HashMap<Long, List<Server>>();

        // Prepare empty list of systems for each errata
        for (Object errataIdObject : errataIds) {
            // HACK: ugly conversion needed because in some cases errataIds contains
            // Integers, in other cases Longs
            Long errataId = ((Number) errataIdObject).longValue();
            List<Server> serverList = new ArrayList<Server>();
            serversForErrata.put(errataId, serverList);
        }

        // Filter only relevant errata for servers
        for (Long serverId : serverIds) {
            List<Errata> relevantErrata =
                    SystemManager.unscheduledErrata(user, serverId, null);
            Set<Long> relevantErrataIds = new HashSet<Long>();
            for (Errata e : relevantErrata) {
                relevantErrataIds.add(e.getId());
            }

            Server server = SystemManager.lookupByIdAndOrg(serverId, user.getOrg());

            for (Long errataId : serversForErrata.keySet()) {
                if (relevantErrataIds.contains(errataId)) {
                    List<Server> serverList = serversForErrata.get(errataId);
                    serverList.add(server);
                }
                else {
                    if (!onlyRelevant) {
                        throw new InvalidErrataException();
                    }
                }
            }
        }

        // Divide stack updates from regular errata
        List<Errata> stackUpdates = new ArrayList<Errata>();
        List<Errata> errata = new ArrayList<Errata>();
        for (Long errataId : serversForErrata.keySet()) {
            Errata erratum = ErrataManager.lookupErrata(errataId, user);
            if (erratum.hasKeyword("restart_suggested")) {
                stackUpdates.add(erratum);
            }
            else {
                errata.add(erratum);
            }
        }

        // Schedule updates to the software update stack first
        List<Long> actionIds = new ArrayList<Long>();
        for (Errata stackUpdate : stackUpdates) {
            List<ErrataAction> errataActions = createErrataActions(user, stackUpdate,
                    earliest, actionChain, serversForErrata.get(stackUpdate.getId()));
            for (ErrataAction errataAction : errataActions) {
                Object[] args = new Object[] {errataAction.getErrata().size()};
                errataAction.setName(LocalizationService.getInstance().getMessage(
                        "errata.swstack", args));
                Action action = ActionManager.storeAction(errataAction);
                actionIds.add(action.getId());
            }
        }

        // Schedule remaining errata actions
        for (Errata e : errata) {
            List<ErrataAction> errataActions = createErrataActions(user, e, earliest,
                    actionChain, serversForErrata.get(e.getId()));
            for (ErrataAction errataAction : errataActions) {
                Action action = ActionManager.storeAction(errataAction);
                actionIds.add(action.getId());
            }
        }

        return actionIds;
    }

    /**
     * Creates errata actions for the specified servers.
     * @param user the user
     * @param erratum the erratum
     * @param earliest the earliest
     * @param actionChain the action chain to add the actions to or null
     * @param servers the servers
     * @return the list
     */
    private static List<ErrataAction> createErrataActions(User user, Errata erratum,
        Date earliest, ActionChain actionChain, List<Server> servers) {

        List<ErrataAction> result = new LinkedList<ErrataAction>();
        if (actionChain == null) {
            ErrataAction errataAction = (ErrataAction) ActionManager.createErrataAction(
                user, erratum);
            if (earliest != null) {
                errataAction.setEarliestAction(earliest);
            }
            for (Server server : servers) {
                ActionManager.addServerToAction(server, errataAction);
            }
            result.add(errataAction);
        }
        else {
            int sortOrder = ActionChainFactory.getNextSortOrderValue(actionChain);
            for (Server server : servers) {
                ErrataAction errataAction = (ErrataAction) ActionManager.createErrataAction(
                    user, erratum);
                if (earliest != null) {
                    errataAction.setEarliestAction(earliest);
                }
                ActionChainFactory.queueActionChainEntry(errataAction, actionChain,
                    server, sortOrder);

                result.add(errataAction);
            }
        }
        return result;
    }
}
