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
package com.redhat.rhn.manager.errata.cache;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ErrataCacheFactory
 * @version $Rev$
 */
public class ErrataCacheManager extends HibernateFactory {

    private static ErrataCacheManager singleton = new ErrataCacheManager();
    private static Logger log = Logger.getLogger(ErrataCacheManager.class);

    private ErrataCacheManager() {
        super();
    }

    /**
     * {@inheritDoc}
     */
    protected Logger getLogger() {
        return log;
    }

    /**
     * Returns the server count that are in the queue for the given org.
     * @param org Org whose server count is sought.
     * @return the server count that are in the queue for the given org.
     */
    public static int countServersInQueue(Org org) {
        Map params = new HashMap();
        params.put("org_id", org.getId());
        DataResult dr = executeSelectMode("ErrataCache_queries",
                "count_servers_in_errata_cache_queue", params);
        if (dr.isEmpty()) {
            return 0;
        }
        else {
            Map record = (Map) dr.get(0);
            Long cnt = (Long) record.get("num_items");
            return (cnt != null) ? cnt.intValue() : 0;
        }
    }

    /**
     * Deletes all the ErrataCache items for the given org.
     * @param org Org whose errata cache queue should be emptied.
     * @return number of rows affected.
     */
    public static int deleteErrataCacheQueue(Org org) {
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "delete_errata_cache_queue");
        Map params = new HashMap();
        params.put("org_id", org.getId());
        return m.executeUpdate(params);
    }

    /**
     * Returns all Server ids for the given org.
     * @param org Org
     * @return all Server ids for the given org.
     */
    public static DataResult allServerIdsForOrg(Org org) {
        Map params = new HashMap();
        params.put("org_id", org.getId());
        return executeSelectMode("ErrataCache_queries",
                "all_serverids_for_org", params);
    }

    /**
     * Returns packages needing updates for the given server id.
     * @param sid Server Id.
     * @return packages needing updates for the given server id.
     */
    public static DataResult packagesNeedingUpdates(Long sid) {
        Map params = new HashMap();
        params.put("server_id", sid);
        return executeSelectMode("ErrataCache_queries",
                "packages_needing_updates", params);
    }

    /**
     * Returns the new packages for the server id.
     * @param sid Server Id.
     * @return the new packages for the server id.
     */
    public static DataResult newPackages(Long sid) {
        Map params = new HashMap();
        params.put("server_id", sid);
        return executeSelectMode("ErrataCache_queries", "new_packages", params);
    }

    /**
     * Inserts record into NeededPackage cache table
     * @param sid Server Id
     * @param errataId Errata Id
     * @param packageId Package Id
     * @return number of rows affected.
     */
    public static int insertNeededPackageCache(Long sid, Long errataId,
            Long packageId) {
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "insert_needed_package_cache");
        Map params = new HashMap();
        params.put("server_id", sid);
        if (errataId == null) {
            params.put("errata_id", "");
        }
        else {
            params.put("errata_id", errataId);
        }
        params.put("package_id", packageId);
        return m.executeUpdate(params);
    }

    /**
     * Deletes record from NeededPackage cache table.
     * @param sid Server Id
     * @param errataId Errata Id
     * @param packageId Package Id
     * @return number of rows affected.
     */
    public static int deleteNeededPackageCache(Long sid, Long errataId,
            Long packageId) {
        if (errataId != null) {
            WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                    "delete_needed_package_cache");
            Map params = new HashMap();
            params.put("server_id", sid);
            params.put("errata_id", errataId);
            params.put("package_id", packageId);
            return m.executeUpdate(params);
        }
        else {
            WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                    "delete_needed_package_cache_null_errata");
            Map params = new HashMap();
            params.put("server_id", sid);
            params.put("package_id", packageId);
            return m.executeUpdate(params);
        }
    }

    /**
     * Inserts all records from ServerNeeded cache for the server provided.
     * @param sid Server Id
     * @return number of rows affected.
     */
    public static int deleteServerNeededCache(Long sid) {
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "delete_needed_cache_all");
        Map params = new HashMap();
        params.put("server_id", sid);
        return m.executeUpdate(params);
    }

    /**
     * Delete all records from Server Needed cache for the server provided.
     * @param sid Server Id
     * @return number of rows affected.
     */
    public static int insertServerNeededCache(Long sid) {
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "insert_needed_cache_all");
        Map params = new HashMap();
        params.put("server_id", sid);
        return m.executeUpdate(params);
    }    
    
    /**
     * Inserts record into NeededErrata cache table
     * @param sid Server Id
     * @param eid Errata Id
     * @param pid Package Id
     * @return number of rows affected.
     */
    public static int insertNeededErrataCache(Long sid, Long eid, Long pid) {
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "insert_needed_errata_cache");
        Map params = new HashMap();
        params.put("server_id", sid);
        params.put("errata_id", eid);
        params.put("package_id", pid);
        return m.executeUpdate(params);
    }

    /**
     * Deletes record from NeededErrata cache table. If the Errata Id is null,
     * all errata cache for the server will be deleted.
     * @param sid Server Id
     * @param eid Errata Id
     * @return number of rows affected.
     */
    public static int deleteNeededErrataCache(Long sid, Long eid) {
        if (eid != null) {
            WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                    "delete_needed_errata_cache");
            Map params = new HashMap();
            params.put("server_id", sid);
            params.put("errata_id", eid);
            return m.executeUpdate(params);
        }
        else {
            WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                    "delete_needed_errata_cache_null_errata");
            Map params = new HashMap();
            params.put("server_id", sid);
            return m.executeUpdate(params);
        }
    }

    /**
     * Delete all records from NeededErrata cache for the server provided.
     * errata cache for the server will be deleted.
     * @param sid Server Id
     * @return number of rows affected.
     */
    public static int deleteNeededErrataCache(Long sid) {
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "delete_needed_errata_cache_all");
        Map params = new HashMap();
        params.put("server_id", sid);
        return m.executeUpdate(params);
    }

    /**
     * Asynchronusly updates the errata caches for the channels passed in.
     * Deletes the entire cache for All servers in the channel VERY INEFFICIENT
     * @param channelIdsToUpdate - channel IDs (Long) that need their errata
     * caches updated
     */
    public static void updateCacheForChannelsAsync(List<Long> channelIdsToUpdate) {
        UpdateErrataCacheEvent uece = new UpdateErrataCacheEvent(
                UpdateErrataCacheEvent.TYPE_CHANNEL);
        uece.setChannels(channelIdsToUpdate);
        MessageQueue.publish(uece);
    }

    /**
     * Asynchronusly updates the errata caches for the channels passed in.
     * Deletes the entire cache for All servers in the channel VERY INEFFICIENT
     * @param channelsToUpdate - Channels that need their errata caches updated
     */
    public static void updateCacheForChannelsAsync(Set<Channel> channelsToUpdate) {
        log.debug("updateErrataCacheForChannelsAsync");
        List<Long> channels = new LinkedList();
        for (Channel c : channelsToUpdate) {
            channels.add(c.getId());
        }
        updateCacheForChannelsAsync(channels);
    }

    /**
     * Asynchronusly updates the errata caches for the channels passed in.
     * 
     * @param channelIdsToUpdate - channel IDs (Long) that need their errata
     * caches updated
     * @param errata the errata to update the cache for
     */
    public static void insertCacheForChannelErrataAsync(
            List channelIdsToUpdate, Errata errata) {
        UpdateErrataCacheEvent uece = new UpdateErrataCacheEvent(
                UpdateErrataCacheEvent.TYPE_CHANNEL_ERRATA);
        uece.setChannels(channelIdsToUpdate);
        uece.setErrataId(errata.getId());
        MessageQueue.publish(uece);
    }

    /**
     *updates the errata caches for the channels passed in.
     * @param channelIdsToUpdate - channel IDs (Long) that need their errata
     * caches updated
     * @param errata the errata to update the cache for
     */
    public static void insertCacheForChannelErrata(
            List<Long> channelIdsToUpdate, Errata errata) {
        for (Long cid : channelIdsToUpdate) {
            List<Long> pids = ErrataFactory.listErrataChannelPackages(cid, errata.getId());
            ErrataCacheManager.insertCacheForChannelPackages(cid, errata.getId(), pids);
        }
    }
    

    /**
     * Asynchronusly updates the errata caches for the channels passed in.
     * 
     * @param channelIdsToUpdate - channel IDs (Long) that need their errata
     * caches updated
     * @param packageIds list of package ids to insert cache entries for
     */
    public static void insertCacheForChannelPackagesAsync(
            List<Long> channelIdsToUpdate, List<Long> packageIds) {
        if (packageIds.isEmpty()) {
            return;
        }
        UpdateErrataCacheEvent uece = new UpdateErrataCacheEvent(
                UpdateErrataCacheEvent.TYPE_CHANNEL_ERRATA);
        uece.setChannels(channelIdsToUpdate);
        uece.setErrataId(null);
        uece.setPackageIds(packageIds);
        MessageQueue.publish(uece);
    }

    /**
     * Insert the new cache entries for a list of packages
     * @param cid the channel where packages were added to
     * @param eid the errata that 'pushed' these packages (can be null
     * @param pids the list of pids that were pushed.
     */
    public static void insertCacheForChannelPackages(Long cid, Long eid,
            List<Long> pids) {
        if (pids.isEmpty()) {
            return;
        }
        int count = 0;
        Map params = new HashMap();
        params.put("channel_id", cid);
        if (eid != null) {
            params.put("errata_id", eid);
            WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                    "insert_new_cache_entries_by_errata");
            count = m.executeUpdate(params, pids);
        }
        else {
            WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
            "insert_new_cache_entries_by_packages");
            count = m.executeUpdate(params, pids);
        }
        if (log.isDebugEnabled()) {
            log.debug("updateCacheForChannelErrata : " + "cache entries inserted: " + 
                    count);
        }

    }



    /**
     * Delete errata cache entries for systems belonging to a certain channel
     * @param cid the channel that the systems belong to
     * @param eids the errata to remove
     */
    public static void deleteCacheEntriesForChannelErrata(Long cid,
            List<Long> eids) {
        if (eids.isEmpty()) {
            return;
        }
        int count = 0;
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "delete_needed_cache_for_channel_errata");
        Map params = new HashMap();
        params.put("channel_id", cid);
        count = m.executeUpdate(params, eids);
        if (log.isDebugEnabled()) {
            log.debug("updateCacheForChannelErrata : " + "cache entries deleted: " + count);
        }
    }
    
    /**
     * Delete errata cache entries for systems belonging to a certain channel
     * @param eid the errata to remove
     * @param pids the packages to remove
     */
    public static void deleteCacheEntriesForErrataPackages(Long eid,
            List<Long> pids) {
        if (pids.isEmpty()) {
            return;
        }
        int count = 0;
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "delete_needed_cache_for_errata_packages");
        Map params = new HashMap();
        params.put("errata_id", eid);
        count = m.executeUpdate(params, pids);
        if (log.isDebugEnabled()) {
            log.debug("updateCacheForChannelErrata : " + "cache entries deleted: " + count);
        }
    }
    

    /**
     * Clear out and re-generate the entries in rhnServerNeededPackageCache and
     * rhnServerNeededErrataCache tables by channel. Usefull if the set of
     * errata or packages gets changed with a Channel
     * 
     * @param cid - channel to update caches for.
     */
    public static void updateErrataAndPackageCacheForChannel(Long cid) {
        // Clear em out

        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "delete_needed_cache_by_channel");
        Map params = new HashMap();
        params.put("channel_id", cid);
        int count = m.executeUpdate(params);
        if (log.isDebugEnabled()) {
            log.debug("updateErrataAndPackageCacheForChannel : " + 
                    "package_cache deleted: " + count);
        }

        // Insert into rhnServerNeededPackageCache
        m = ModeFactory.getWriteMode("ErrataCache_queries",
                "insert_needed_cache_by_channel");
        params = new HashMap();
        params.put("channel_id", cid);
        count = m.executeUpdate(params);
        if (log.isDebugEnabled()) {
            log.debug("updateErrataAndPackageCacheForChannel : " + 
                    "package_cache inserted: " + count);
        }

    }

    /**
     * Remove cache entries for particular packages usefull if you are removing
     * packages from a channel
     * @param cid the channel id
     * @param pids the package ids
     */
    public static void deleteCacheEntriesForChannelPackages(Long cid,
            List<Long> pids) {
        WriteMode m = ModeFactory.getWriteMode("ErrataCache_queries",
                "delete_needed_cache_for_channel_packages");
        Map params = new HashMap();
        params.put("channel_id", cid);
        int count = m.executeUpdate(params, pids);
        if (log.isDebugEnabled()) {
            log.debug("delete_needed_cache_for_channel_packages : " + 
                "package_cache deleted: " + count);
        }

    }
    
}
