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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.action.errata.ErrataAction;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.dto.ErrataCacheDto;
import com.redhat.rhn.manager.BaseTransactionCommand;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * UpdateErrataCacheCommand
 * @version $Rev$
 */
public class UpdateErrataCacheCommand extends BaseTransactionCommand {
    private static Logger log = Logger
    .getLogger(UpdateErrataCacheCommand.class);

    /**
     * Default constructor
     */
    public UpdateErrataCacheCommand() {
        super(log);
    }

    /**
     * Updates the errata cache for orgs which have a server count less than
     * the threshold as defined by the configuration setting
     * <code>errata_cache_compute_threshold</code>
     * @param orgId Org whose errata cache needs updating.
     */
    public void updateErrataCache(Long orgId) {
        int threshold = Config.get().getInt(
                ConfigDefaults.ERRATA_CACHE_COMPUTE_THRESHOLD);

        Org org = OrgFactory.lookupById(orgId);

        int count = ErrataCacheManager.countServersInQueue(org);

        if (log.isDebugEnabled()) {
            log.debug("Number of servers [" + count +
                    "] threshold [" + threshold + "]");
        }

        if (count == 0 || count >= threshold) {
            return;
        }

        DataResult dr = ErrataCacheManager.allServerIdsForOrg(org);
        if (log.isDebugEnabled()) {
            log.debug("allservers returned [" + dr.size() + "]");
        }

        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            Map item = (Map) itr.next();
            Long sid = (Long) item.get("id");
            if (log.isDebugEnabled() && sid != null) {
                log.debug("Working on server [" + sid.toString() + "]");
            }
            Long serverId = new Long(sid.longValue());
            processServer(serverId, org);
            handleTransaction();
        }

        if (log.isDebugEnabled()) {
            log.debug("Deleting ErrataCache Queue");
        }
        ErrataCacheManager.deleteErrataCacheQueue(org);
    }

    /**
     * Updates the errata cache for the given server.
     * @param serverId Server id which needs to get updated.
     * @param orgId Org id which owns the server
     * @param commit commit the database transaction when complete
     * @return Map of results formatted like so:
     * Key: 'errata'   Value: list of erratas added
     * Key: 'packages' Value: list of packages added
     */
    public Map updateErrataCacheForServer(Long serverId, Long orgId, boolean commit) {
        log.info("Updating errata cache for server [" + serverId + "]");
        Map changes = null;
        try {
            Org org = OrgFactory.lookupById(orgId);
            processServer(serverId, org);
        }
        catch (Exception e) {
            log.error("Problem updating cache for server", e);
            HibernateFactory.rollbackTransaction();

        }
        finally {
            if (commit) {
                handleTransaction();
            }
        }
        log.info("Finished with servers in channel [" + serverId + "]");
        return changes;
    }


    /**
     * Updates the needed cache for particular packages within a channel
     *  This isn't a full regeneration, only the changes are handled
     * @param cid the channel affected
     * @param eid the erratum id
     */
    public void updateErrataCacheForErrata(Long cid, Long eid) {
        List<Long> pids = ErrataFactory.listErrataChannelPackages(cid, eid);
        updateErrataCacheForErrata(cid, eid, pids);
    }

    /**
     * Updates the needed cache for particular packages within a channel
     *  This isn't a full regeneration, only the changes are handled
     * @param cid the channel affected
     * @param eid the erratum id
     * @param pids the List of package ids that will be considered
     */
    public void updateErrataCacheForErrata(Long cid, Long eid, List<Long> pids) {
        log.info("Updating errata cache for servers in channel [" + cid + "] " +
                "and pacakges [" + eid + "]");
        try {
            ErrataCacheManager.insertCacheForChannelPackages(cid, eid, pids);
        }
        catch (Exception e) {
            log.error("Problem updating cache for servers in channel for errata", e);
            HibernateFactory.rollbackTransaction();
        }
        finally {
            handleTransaction();
        }
        log.info("Finished with servers in channel [" + cid + "] " +
                "and errata [" + eid + "]" + " with pids [" + pids + "]");
    }


    /**
     * Updates the errata cache for all the servers in the given channel.
     * @param cid Channel id whose servers need their cache updated.
     */
    public void updateErrataCacheForChannel(Long cid) {
        log.info("Updating errata cache for servers in channel [" + cid + "]");
        // get list of serverid for channel
        // for each call internalUpdateerrataCacheForServer
        try {
            ErrataCacheManager.updateErrataAndPackageCacheForChannel(cid);
        }
        catch (Exception e) {
            log.error("Problem updating cache for servers in channel", e);
            HibernateFactory.rollbackTransaction();
        }
        finally {
            handleTransaction();
        }
        log.info("Finished with servers in channel [" + cid + "]");
    }

    private Map internalUpdateErrataCacheForServer(Long serverId) {

        /*
         * get packages_needing_updates
         * foreach item put entry in pseen hashmap
         * get errata_needing_application
         * foreach item in get newpackages
         *    if not in pseen
         *       add to padded
         *    else
         *       delete from p_seen
         *       increment p_unchanged
         *
         * if there is anything in pseen
         *    call delete_needed_package_cache
         * if there is something in padded
         *    call insert_needed_package_cache
         *
         */

        // let's avoid the dreaded nullpointer
        if (serverId == null) {
            return null;
        }

        if (log.isDebugEnabled()) {
            log.debug("internalUpdateErrataCacheForServer - sid: " + serverId);
        }


        DataResult newpkgs = ErrataCacheManager.newPackages(serverId);
        DataResult pkgs = ErrataCacheManager.packagesNeedingUpdates(serverId);

        if (log.isDebugEnabled()) {
            log.debug("newpkgs: " + newpkgs);
            log.debug("Packages: " + pkgs);
        }

        new ArrayList();
        List pAdded = new ArrayList();


        Iterator itr = null;
        for (itr = newpkgs.iterator(); itr.hasNext();) {
            ErrataCacheDto ecd = (ErrataCacheDto) itr.next();
            if (log.isDebugEnabled()) {
                log.debug("newpkgs  - processing ErrataCacheDto: " + ecd.getErrataId());
            }

            if (!pkgs.contains(ecd)) {
                log.debug("pkgs doesn't contain current ecd");
                pAdded.add(ecd);
            }
            else {
                // remove the package we've already seen
                log.debug("removing ecd.");
                pkgs.remove(ecd);
            }
        }


        // delete the needed package cache
        if (!pkgs.isEmpty()) {
            for (itr = pkgs.iterator(); itr.hasNext();) {
                ErrataCacheDto ecd = (ErrataCacheDto) itr.next();
                log.debug("Deleting needed package cache.");
                ErrataCacheManager.deleteNeededPackageCache(
                        ecd.getServerId(), ecd.getErrataId(),
                        ecd.getPackageId());
            }
        }

        // reinsert the needed package cache
        if (!pAdded.isEmpty()) {
            for (itr = pAdded.iterator(); itr.hasNext();) {
                log.debug("reinsert the needed package cache.");
                ErrataCacheDto ecd = (ErrataCacheDto) itr.next();
                ErrataCacheManager.insertNeededPackageCache(
                        ecd.getServerId(), ecd.getErrataId(),
                        ecd.getPackageId());
            }
        }

        Map retval = new HashMap();
        if (pAdded != null && !pAdded.isEmpty()) {
            retval.put("packages", new LinkedList(pAdded));
        }

        if (log.isDebugEnabled()) {
            log.debug("retval: " + retval);
        }
        return retval;

    }

    private void processServer(Long serverId, Org org) {
        Server server = SystemManager.lookupByIdAndOrg(serverId, org);
        Map changes = internalUpdateErrataCacheForServer(serverId);
        log.debug("Scheduling auto errata updates for server [" + serverId + "]");
        if (SystemManager.serverHasFeature(serverId, "ftr_auto_errata_updates") &&
                server.getAutoUpdate() != null &&
                server.getAutoUpdate().equalsIgnoreCase("y")) {
            scheduleAutoUpdates(serverId, org, changes);
        }
        else {
            log.debug("Auto errata updates not enabled for server [" + serverId + "]");
        }
    }

    private void scheduleAutoUpdates(Long sid, Org org, Map updates) {
        log.debug("Scheduling auto updates");
        List errataAdded = (List) updates.get("errata");
        if (updates == null || errataAdded == null) {
            return;
        }
        log.debug("Have errata - scheduling");
        for (Iterator iter = errataAdded.iterator(); iter.hasNext();) {
            ErrataCacheDto ecd = (ErrataCacheDto) iter.next();
            Errata errata = ErrataManager.lookupPublishedErrata(ecd.getErrataId());
            ErrataAction errataAction =
                ActionManager.createErrataAction(org, errata);
            ActionManager.addServerToAction(sid, errataAction);
            ActionManager.storeAction(errataAction);
        }
        log.debug("Scheduling complete");

    }
}
