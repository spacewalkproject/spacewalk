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
package com.redhat.rhn.manager.satellite.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.frontend.action.kickstart.test.KickstartTestHelper;
import com.redhat.rhn.manager.satellite.UpgradeCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.List;


public class UpgradeCommandTest extends BaseTestCaseWithUser {

    public void testUpgradeProfiles() throws Exception {
        KickstartData ksd = KickstartTestHelper.createTestKickStart(user);
        
        KickstartSession ksession = 
            KickstartFactory.lookupDefaultKickstartSessionForKickstartData(ksd);
        assertNull(ksession);
        TaskFactory.createTask(user.getOrg(), 
                UpgradeCommand.UPGRADE_KS_PROFILES, new Long(0));
        
        List l = TaskFactory.getTaskListByNameLike(
                UpgradeCommand.UPGRADE_KS_PROFILES);
        assertTrue(l.get(0) instanceof Task);

        // UpgradeCommand its its own transaction so we gotta commit.
        commitAndCloseSession();
        
        UpgradeCommand cmd = new UpgradeCommand();
        cmd.store();
        
        // Check to see if the upgrade command created the default profile.
        ksession = 
            KickstartFactory.lookupDefaultKickstartSessionForKickstartData(ksd);
        assertNotNull(ksession);
        
        l = TaskFactory.getTaskListByNameLike(
                UpgradeCommand.UPGRADE_KS_PROFILES);
        assertTrue((l == null || l.isEmpty()));
    }
}
