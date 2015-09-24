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
package com.redhat.rhn.manager.errata.cache;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.manager.BaseTransactionCommand;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;
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

        if (org == null) {
            log.error("Org with id " + orgId + " was not found");
            return;
        }

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
            processServer(serverId);
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
     * @param commit commit the database transaction when complete
     */
    public void updateErrataCacheForServer(Long serverId, boolean commit) {
        log.info("Updating errata cache for server [" + serverId + "]");
        try {
            processServer(serverId);
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
        log.info("Finished errata cache for server [" + serverId + "]");
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
                "and packages [" + eid + "]");
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

    private void processServer(Long serverId) {
        CallableMode m = ModeFactory.getCallableMode(
                "System_queries", "update_needed_cache");
        Map inParams = new HashMap();
        inParams.put("server_id", serverId);

        m.execute(inParams, new HashMap());
    }
}
