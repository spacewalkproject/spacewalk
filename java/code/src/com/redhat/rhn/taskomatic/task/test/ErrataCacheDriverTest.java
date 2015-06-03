/**
 * Copyright (c) 2015 SUSE LLC
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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.taskomatic.task.TaskConstants;
import com.redhat.rhn.taskomatic.task.errata.ErrataCacheDriver;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import org.apache.log4j.Logger;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;

/**
 * Tests for ErrataCacheDriver class.
 */
public class ErrataCacheDriverTest extends BaseTestCaseWithUser {

    /**
     * Test the consolidation of tasks in getCandidates().
     *
     * @throws Exception in case of a problem
     */
    public void testGetCandidates() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user);
        insertErrataCacheTask(server);
        insertErrataCacheTask(server);
        insertErrataCacheTask(server);
        insertErrataCacheTask(server);

        // Get the candidates and verify
        ErrataCacheDriver driver = new ErrataCacheDriver();
        driver.setLogger(Logger.getLogger(ErrataCacheDriverTest.class));
        int candidateCount = 0;
        for (Task task : driver.getCandidates()) {
            if (task.getData().equals(server.getId())) {
                candidateCount++;
            }
        }
        assertEquals(1, candidateCount);
    }

    /**
     * Insert an errata cache task for a given server.
     *
     * @param server the server
     */
    private void insertErrataCacheTask(Server server) {
        WriteMode mode = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                "insert_into_task_queue");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("org_id", server.getOrg().getId());
        params.put("task_name", "update_server_errata_cache");
        params.put("task_data", server.getId());
        params.put("earliest", new Timestamp(System.currentTimeMillis()));
        mode.executeUpdate(params);
    }
}
