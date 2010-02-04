/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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

package com.redhat.satellite.search.rpc.handlers.tests;

import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.rpc.handlers.DatabaseHandler;
import com.redhat.satellite.search.scheduler.ScheduleManager;
import com.redhat.satellite.search.tests.BaseTestCase;
import com.redhat.satellite.search.tests.TestUtil;

import org.apache.log4j.Logger;

import java.util.List;

import redstone.xmlrpc.XmlRpcFault;


public class DatabaseHandlerTest extends BaseTestCase {

    private static Logger log = Logger.getLogger(DatabaseHandlerTest.class);

    @Override
    @SuppressWarnings("unchecked")
    protected Class[] getComponentClasses() {
        Class[] components = {IndexManager.class,
                              DatabaseManager.class,
                              ScheduleManager.class};

        return TestUtil.buildComponentsList(components);
    }

    public void testQuery() throws XmlRpcFault, InterruptedException {
        DatabaseManager db = (DatabaseManager)
            container.getComponentInstance(DatabaseManager.class);
        IndexManager idx = (IndexManager)
            container.getComponentInstance(IndexManager.class);
        ScheduleManager schedMgr = (ScheduleManager)
        container.getComponentInstance(ScheduleManager.class);
        DatabaseHandler handler = new DatabaseHandler(idx, db, schedMgr);
        String searchNamespace = "errata";
        String searchString = "listErrataByIssueDateRange:(2004-10-20, 2010-10-30)";
        log.info("Calling hander.search(1, " + searchNamespace + ", " + searchString + ")");
        List results = handler.search(1, searchNamespace, searchString);
        log.info("results = " + results);
        assertTrue(results.size() > 0);
    }
}
