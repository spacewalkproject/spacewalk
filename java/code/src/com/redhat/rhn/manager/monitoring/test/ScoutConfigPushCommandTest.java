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
package com.redhat.rhn.manager.monitoring.test;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.manager.monitoring.ScoutConfigPushCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

/**
 * ScoutConfigPushCommandTest
 * @version $Rev$
 */
public class ScoutConfigPushCommandTest extends BaseTestCaseWithUser {

    
    public void testPushConfig() throws Exception {
        if (!ConfigDefaults.get().isMonitoringBackend()) {
            return;
        }
        ScoutConfigPushCommand cmd = new ScoutConfigPushCommand(user);
        assertNotNull(user.getOrg().getMonitoringScouts());
        assertTrue(user.getOrg().getMonitoringScouts().size() > 0);
        assertNull(cmd.store());
    }
}
