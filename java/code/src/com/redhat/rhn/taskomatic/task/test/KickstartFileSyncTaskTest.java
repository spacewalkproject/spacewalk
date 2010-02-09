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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.taskomatic.task.KickstartFileSyncTask;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.cobbler.Profile;

import java.io.File;

public class KickstartFileSyncTaskTest extends RhnBaseTestCase {
    
    
    
    public void testTask() throws Exception {
        
        User user = UserTestUtils.createUserInOrgOne();
        user.addRole(RoleFactory.ORG_ADMIN);
        
        KickstartData ks = KickstartDataTest.createTestKickstartData(user.getOrg());
        ks.setKickstartDefaults(KickstartDataTest.createDefaults(ks, user));       
        KickstartDataTest.createCobblerObjects(ks);
        KickstartFactory.saveKickstartData(ks);
        
        
        ks = (KickstartData) TestUtils.saveAndReload(ks);
        
        Profile p = Profile.lookupById(CobblerXMLRPCHelper.getConnection(user), 
                ks.getCobblerId());
        
        File f = new File(p.getKickstart());
        assertTrue(f.exists());
        f.delete();
        assertFalse(f.exists());
        KickstartFileSyncTask task = new KickstartFileSyncTask();
        task.execute(null);
        assertTrue(f.exists());
        
    }

}
