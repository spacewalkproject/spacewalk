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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.taskomatic.task.DailySummary;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * DailySummaryTest
 * @version $Rev$
 */
public class DailySummaryTest extends RhnBaseTestCase {

    public void testDequeueOrg() {
        WriteMode clear = ModeFactory.getWriteMode("test_queries",
            "delete_from_daily_summary_queue");
        clear.executeUpdate(new HashMap());

        DailySummary ds = new DailySummary();
        Long oid = UserTestUtils.createOrg("testOrg");
        assertNotNull(oid);
        int rows = ds.dequeueOrg(oid);
        assertEquals(0, rows);

        WriteMode m = ModeFactory.getWriteMode("test_queries",
                "insert_into_daily_summary_queue");
        Map params = new HashMap();
        params.put("org_id", oid);
        rows = m.executeUpdate(params);
        assertEquals(1, rows);
        rows = ds.dequeueOrg(oid);
        assertEquals(1, rows);
    }

    public void testGetAwolServers() {
        return;
    }

    public void testGetActionInfo() {
        return;
    }

    public void aTestRenderAwolServersMessage() {
        return;
    }

    public void aTestPrepareEmail() {
        return;
    }

    public void aTestRenderActionMessage() {
        return;
    }

    public void testQueueOrgEmails() {
        return;
    }

    public void aTestExcecute() {
        // using jesusr_redhat orgid for this test.  Run only on hosted.
        // TODO: how do we create good test data for something like this?
        return;
    }
}
