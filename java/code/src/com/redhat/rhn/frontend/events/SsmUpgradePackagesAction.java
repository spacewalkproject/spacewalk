/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.events;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.apache.log4j.Logger;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.ssm.SsmOperationManager;

/**
 * Handles removing packages from servers in the SSM.
 *
 * @see com.redhat.rhn.frontend.events.SsmUpgradePackagesEvent
 */
public class SsmUpgradePackagesAction extends AbstractDatabaseAction {

    /** Number of servers to process at once. */
    private static final int SERVER_CHUNK_SIZE = 1000;

    private static Logger log = Logger.getLogger(SsmUpgradePackagesAction.class);

    /** {@inheritDoc} */
    protected void doExecute(EventMessage msg) {
        log.debug("Executing package upgrades.");

        SsmUpgradePackagesEvent event = (SsmUpgradePackagesEvent) msg;

        User user = UserFactory.lookupById(event.getUserId());

        LocalizationService ls = LocalizationService.getInstance();
        long operationId = SsmOperationManager.createOperation(user,
            ls.getMessage("ssm.package.upgrade.operationname"), null);

        // Explicitly call handle transactions here so the operation creation above
        // is persisted before the potentially long running logic below
        handleTransactions();

        try {
            scheduleUpgrades(user, event);
        }
        catch (Exception e) {
            log.error("Error while scheduling package upgrades for event: " + event, e);
        }
        finally {
            SsmOperationManager.completeOperation(user, operationId);
        }

        log.debug("Done.");
    }

    private void scheduleUpgrades(User user, SsmUpgradePackagesEvent event) {

        /* We already have the data result which contains the server IDs that will
           have package upgrades installed as well as the list of each package to
           apply (in the elaborator). Until we can correct the ActionManager code to
           not require the full sever load, we do the following:

           - Load the servers in batches of 1K (batched to avoid database limitation)
           - Create the package lists (munging the IDs) for each of the 1K servers
           - Schedule the actions for these 1K systems
           - Repeat as much as necessary

           The big savings here is the reduction of calls to load the servers by a factor
           of 1000. We need to be careful to finish work on the 1K system batches and
           releasing any references to the objects involved *before* moving on to the
           next batch for memory reasons. If we were to hold on to all system/package
           references until the end we'd end up smashing our memory footprint.

           It should be noted that this solution should not be considered the final (best)
           answer. This is being implemented under the upcoming Satellite 5.3 deadline.
           Ideally the ActionManager APIs should be revisited to better support working
           with groups of servers. So when revisiting this in the future, realize the
           outside influences before proclaiming that this code is insane. :)

           jdobies, Jul 10, 2009
         */

        long actionStart = System.currentTimeMillis();

        DataResult result = event.getResult();
        Date earliest = event.getEarliest();

        List<Long> chunkServerIds = new ArrayList<Long>(1000);
        List<Server> chunkServers = new ArrayList<Server>(1000);
        Map<Long, List<Map<String, Long>>> chunkServerToPackages =
            new HashMap<Long, List<Map<String, Long>>>(1000);

        List<DataResult> allServerChunks = split(result);
        for (DataResult chunk : allServerChunks) {

            long chunkStart = System.currentTimeMillis();

            // Loop over each server in the chunk
            for (Iterator it = chunk.iterator(); it.hasNext();) {

                Map data = (Map) it.next();

                // Keep a running list of what servers we've processed in this chunk
                Long sid = (Long) data.get("id");
                chunkServerIds.add(sid);

                // Get the packages out of the elaborator for this server
                List elabList = (List) data.get("elaborator0");

                // Handle each package for the server
                List<PackageListItem> packages =
                    new ArrayList<PackageListItem>(elabList.size());

                for (Iterator elabIt = elabList.iterator(); elabIt.hasNext();) {
                    Map elabData = (Map) elabIt.next();
                    String idCombo = (String) elabData.get("id_combo");
                    PackageListItem item = PackageListItem.parse(idCombo);
                    packages.add(item);
                }

                // Convert to data type needed for API and associate with this server
                List<Map<String, Long>> packageListData =
                    PackageListItem.toKeyMaps(packages);
                chunkServerToPackages.put(sid, packageListData);
            }

            // Batch load all servers found in this chunk
            chunkServers.addAll(ServerFactory.lookupByIdsAndUser(chunkServerIds, user));

            // For each server we just loaded, look up its packages and make the action
            for (Server server : chunkServers) {
                List<Map<String, Long>> packageListData =
                    chunkServerToPackages.get(server.getId());

                ActionManager.schedulePackageUpgrade(user, server,
                    packageListData, earliest);
            }

            // Clean up before the next chunk
            chunkServerIds.clear();
            chunkServers.clear();
            chunkServerToPackages.clear();

            // Close out the transactions
            HibernateFactory.commitTransaction();
            HibernateFactory.getSession().flush();

            if (log.isDebugEnabled()) {
                log.debug("Time to schedule chunk: " +
                    (System.currentTimeMillis() - chunkStart));
            }
        } // end chunk loop

        if (log.isDebugEnabled()) {
            log.debug("Time to schedule all actions: " +
                (System.currentTimeMillis() - actionStart));
        }
    }

    private List<DataResult> split(DataResult result) {
        List<DataResult> listOfSubLists = new ArrayList<DataResult>();

        int chunkNumber = 1;
        while (chunkNumber * SERVER_CHUNK_SIZE < result.size()) {
            int start = (chunkNumber - 1) * SERVER_CHUNK_SIZE;
            int end = chunkNumber * SERVER_CHUNK_SIZE; // subList is exclusive on end

            DataResult subList = result.subList(start, end);
            listOfSubLists.add(subList);

            chunkNumber++;
        }

        // Pick up extras
        int start = (chunkNumber - 1) * SERVER_CHUNK_SIZE;
        DataResult lastSubList = result.subList(start, result.size());
        listOfSubLists.add(lastSubList);

        return listOfSubLists;
    }
}

