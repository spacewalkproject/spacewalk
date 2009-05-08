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

package com.redhat.satellite.search.rpc.handlers;

import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.scheduler.ScheduleManager;

import org.apache.log4j.Logger;

/**
 * XML-RPC handler which handles calls for administration
 * Updating indexes maybe more tasks later
 *
 * @version $Rev$
 */
public class AdminHandler {

    private static Logger log = Logger.getLogger(AdminHandler.class);
    private ScheduleManager scheduleManager;

    /**
     * Constructor
     *
     * @param idxManager
     *            Search engine interface
     */
    public AdminHandler(IndexManager idxManager, DatabaseManager dbMgr,
            ScheduleManager schedMgr) {
        log.info("** AdminHandler constructor invoked");
        scheduleManager = schedMgr;
    }
    /**
     * Causes the task associated with the indexName to run and index new data.
     *
     * @param indexName
     * @return true if index update is scheduled, false if unable to schedule.
     */
    public boolean updateIndex(String indexName) {
        if (log.isDebugEnabled()) {
            log.debug("AdminHandler::updateIndex(" + indexName);
        }
        return scheduleManager.triggerIndexTask(indexName);
    }
}
