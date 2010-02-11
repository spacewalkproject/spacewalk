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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.taskomatic.task.CleanCurrentAlerts;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * CleanCurrentAlertsTest
 * @version $Rev$
 */
public class CleanCurrentAlertsTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {
        //insert some test data into current_alerts
        Long id = new Long(System.currentTimeMillis() / 100);
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        WriteMode m = ModeFactory.getWriteMode("test_queries", "create_test_alert");
        Map params = new HashMap();
        params.put("recid", id);
        params.put("user_id", user.getId());
        int success = m.executeUpdate(params);
        assertEquals(1, success);
        
        //remove from rhnDaemonState
        //This ensures there are no entries for clean_current_alerts there and should be
        //exactly one after our execute method runs
        m = ModeFactory.getWriteMode("General_queries", "remove_daemon_state");
        params = new HashMap();
        params.put("label", "clean_current_alerts");
        m.executeUpdate(params);
        
        //Run CleanCurrentAlerts.execute()
        CleanCurrentAlerts cca = new CleanCurrentAlerts();
        cca.execute(null);
        
        //Make sure the table got updated correctly
        SelectMode s = ModeFactory.getMode("test_queries", "get_alert");
        params = new HashMap();
        params.put("recid", id);
        DataResult dr = s.execute(params);
        assertTrue(dr.size() > 0);
        Map alert = (Map) dr.iterator().next();
        
        //in_progress should now = 0 and date_completed should not be null
        assertEquals(new Integer(0), new Integer((String) alert.get("in_progress")));
        assertNotNull(alert.get("date_completed"));        
    }
}
