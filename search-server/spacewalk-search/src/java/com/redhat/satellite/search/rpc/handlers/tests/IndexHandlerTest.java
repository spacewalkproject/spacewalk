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

package com.redhat.satellite.search.rpc.handlers.tests;

import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.rpc.handlers.IndexHandler;
import com.redhat.satellite.search.scheduler.ScheduleManager;
import com.redhat.satellite.search.tests.BaseTestCase;
import com.redhat.satellite.search.tests.TestUtil;

import org.apache.log4j.Logger;

import java.util.List;

import redstone.xmlrpc.XmlRpcFault;

public class IndexHandlerTest extends BaseTestCase {

    private static Logger log = Logger.getLogger(IndexHandlerTest.class);

    @Override
    @SuppressWarnings("unchecked")
    protected Class[] getComponentClasses() {
        Class[] components = {IndexManager.class,
                              DatabaseManager.class,
                              ScheduleManager.class};
        
        return TestUtil.buildComponentsList(components);
    }

    public void testQuery() throws XmlRpcFault, InterruptedException {
        // Let the indexing task do some stuff
        Thread.sleep(15000);
        DatabaseManager db = (DatabaseManager)
            container.getComponentInstance(DatabaseManager.class);
        IndexManager idx = (IndexManager)
            container.getComponentInstance(IndexManager.class);
        ScheduleManager schedMgr = (ScheduleManager)
            container.getComponentInstance(ScheduleManager.class);
        IndexHandler handler = new IndexHandler(idx, db, schedMgr);
        handler.search(252437, "package", "description:package", "en");
        List results = handler.search(252437, "package", "kernel*", "en");
        log.info("kernel results 1: " + results);
        results = handler.search(252437, "package", "kernel", "en");
        log.info("kernel results 2: " + results);
    }

}
