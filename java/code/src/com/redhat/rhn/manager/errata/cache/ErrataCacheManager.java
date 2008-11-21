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
package com.redhat.rhn.manager.errata.cache;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;

import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;
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
        WriteMode m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "delete_errata_cache_queue");
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
        return executeSelectMode(
                "ErrataCache_queries", "all_serverids_for_org", params);
    }
    
    /**
     * Returns packages needing updates for the given server id.
     * @param sid Server Id.
     * @return packages needing updates for the given server id.
     */
    public static DataResult packagesNeedingUpdates(Long sid) {
        Map params = new HashMap();
        params.put("server_id", sid);
        return executeSelectMode(
                "ErrataCache_queries", "packages_needing_updates", params);
    }
    
    /**
     * Returns the errata needing application for the given server id.
     * @param sid Server Id
     * @return the errata needing application for the given server id.
     */
    public static DataResult errataNeedingApplication(Long sid) {
        Map params = new HashMap();
        params.put("server_id", sid);
        return executeSelectMode("ErrataCache_queries",
                "errata_needing_application", params);
    }
    
    /**
     * Returns the new packages for the server id.
     * @param sid Server Id.
     * @return the new packages for the server id.
     */
    public static DataResult newPackages(Long sid) {
        Map params = new HashMap();
        params.put("server_id", sid);
        return executeSelectMode("ErrataCache_queries",
                "new_packages", params);
    }
    
    /**
     * Inserts record into NeededPackage cache table
     * @param sid Server Id
     * @param orgId Org Id
     * @param errataId Errata Id
     * @param packageId Package Id
     * @return number of rows affected.
     */
    public static int insertNeededPackageCache(Long sid, Long orgId,
            Long errataId, Long packageId) {
        WriteMode m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "insert_needed_package_cache");
        Map params = new HashMap();
        params.put("server_id", sid);
        params.put("org_id", orgId);
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
     * @param orgId Org Id
     * @param errataId Errata Id
     * @param packageId Package Id
     * @return number of rows affected.
     */    
    public static int deleteNeededPackageCache(Long sid, Long orgId,
            Long errataId, Long packageId) {
        if (errataId != null) {
            WriteMode m = ModeFactory.getWriteMode(
                    "ErrataCache_queries", "delete_needed_package_cache");
            Map params = new HashMap();
            params.put("server_id", sid);
            params.put("org_id", orgId);
            params.put("errata_id", errataId);
            params.put("package_id", packageId);
            return m.executeUpdate(params); 
        }
        else {
            WriteMode m = ModeFactory.getWriteMode(
                    "ErrataCache_queries", "delete_needed_package_cache_null_errata");
            Map params = new HashMap();
            params.put("server_id", sid);
            params.put("org_id", orgId);
            params.put("package_id", packageId);
            return m.executeUpdate(params); 
        }
    }

    /**
     * Delete all records from NeededPackage cache for the server provided.
     * @param sid Server Id
     * @param orgId Org Id
     * @return number of rows affected.
     */    
    public static int deleteNeededPackageCache(Long sid, Long orgId) {
        WriteMode m = ModeFactory.getWriteMode(
                "ErrataCache_queries", 
                "delete_needed_package_cache_all");
        Map params = new HashMap();
        params.put("server_id", sid);
        params.put("org_id", orgId);
        return m.executeUpdate(params);  
    }

    /**
     * Inserts record into NeededErrata cache table
     * @param sid Server Id
     * @param oid Org Id
     * @param eid Errata Id
     * @return number of rows affected.
     */
    public static int insertNeededErrataCache(Long sid, Long oid, Long eid) {
        WriteMode m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "insert_needed_errata_cache");
        Map params = new HashMap();
        params.put("server_id", sid);
        params.put("org_id", oid);
        params.put("errata_id", eid);
        return m.executeUpdate(params); 
    }
    
    /**
     * Deletes record from NeededErrata cache table.  If the Errata Id is null, all
     * errata cache for the server will be deleted.
     * @param sid Server Id
     * @param oid Org Id
     * @param eid Errata Id
     * @return number of rows affected.
     */
    public static int deleteNeededErrataCache(Long sid, Long oid, Long eid) {
        if (eid != null) {
            WriteMode m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "delete_needed_errata_cache");
            Map params = new HashMap();
            params.put("server_id", sid);
            params.put("org_id", oid);
            params.put("errata_id", eid);
            return m.executeUpdate(params);
        }
        else {
            WriteMode m = ModeFactory.getWriteMode(
                    "ErrataCache_queries", "delete_needed_errata_cache_null_errata");
                Map params = new HashMap();
                params.put("server_id", sid);
                params.put("org_id", oid);
                return m.executeUpdate(params);
        }
    }
    
    /**
     * Delete all records from NeededErrata cache for the server provided.
     * errata cache for the server will be deleted.
     * @param sid Server Id
     * @param oid Org Id
     * @return number of rows affected.
     */
    public static int deleteNeededErrataCache(Long sid, Long oid) {
        WriteMode m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "delete_needed_errata_cache_all");
            Map params = new HashMap();
            params.put("server_id", sid);
            params.put("org_id", oid);
            return m.executeUpdate(params);
    }
    
    /**
     * Asynchronusly updates the errata caches for the channels passed in.
     * 
     * @param channelIdsToUpdate - channel IDs (Long) that need their errata caches updated
     * @param orgIn - org who owns channels 
     */
    public static void updateErrataCacheForChannelsAsync(List channelIdsToUpdate, 
            Org orgIn) {
        UpdateErrataCacheEvent uece = 
            new UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_CHANNEL);
        uece.setChannels(channelIdsToUpdate);
        uece.setOrgId(orgIn.getId());
        
        MessageQueue.publish(uece);
    }    
    
    /**
     * Asynchronusly updates the errata caches for the channels passed in.
     * 
     * @param channelsToUpdate - Channels that need their errata caches updated
     * @param orgIn - org who owns channels 
     */
    public static void updateErrataCacheForChannelsAsync(Set channelsToUpdate, Org orgIn) {
        log.debug("updateErrataCacheForChannelsAsync");
        List channels = new LinkedList();
        Iterator i = channelsToUpdate.iterator();
        while (i.hasNext()) {
            Channel c = (Channel) i.next();
            channels.add(c.getId());
        }
        updateErrataCacheForChannelsAsync(channels, orgIn);
    }

    /**
     * Clear out and re-generate the entries in rhnServerNeededPackageCache and
     * rhnServerNeededErrataCache tables by channel.  Usefull if the set of 
     * errata or packages gets changed with a Channel
     * 
     * @param cid - channel to update caches for.
     */
    public static void updateErrataAndPackageCacheForChannel(Long cid) {
        // Clear em out


        WriteMode m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "delete_package_cache_by_channel");
        Map params = new HashMap();
        params.put("channel_id", cid);
        int count = m.executeUpdate(params); 
        log.debug("updateErrataAndPackageCacheForChannel : " +
                "package_cache deleted: " + count);

        // Insert into rhnServerNeededPackageCache
        m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "insert_package_cache_by_channel");
        params = new HashMap();
        params.put("channel_id", cid);
        count = m.executeUpdate(params); 
        log.debug("updateErrataAndPackageCacheForChannel : " +
                "package_cache inserted: " + count);
        
        m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "delete_errata_cache_by_channel");
        params = new HashMap();
        params.put("channel_id", cid);
        count = m.executeUpdate(params);
        log.debug("updateErrataAndPackageCacheForChannel : " +
                "errata_cache deleted: " + count);
        
        
        // Insert into rhnServerNeededErrataCache
        m = ModeFactory.getWriteMode(
                "ErrataCache_queries", "insert_errata_cache_by_channel");
        params = new HashMap();
        params.put("channel_id", cid);
        count = m.executeUpdate(params); 
        log.debug("updateErrataAndPackageCacheForChannel : " +
                "errata_cache inserted: " + count);
    }
}
