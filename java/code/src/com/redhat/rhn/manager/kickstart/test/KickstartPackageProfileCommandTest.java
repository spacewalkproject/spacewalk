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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.manager.kickstart.KickstartPackageProfileCommand;

/**
 * KickstartPackageProfileCommandTest
 * @version $Rev$
 */
public class KickstartPackageProfileCommandTest extends BaseKickstartCommandTestCase {
    
    public void testProfileCommand() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        KickstartData k = KickstartDataTest.createKickstartWithProfile(user);
        Profile p = k.getKickstartDefaults().getProfile();
        k.getKickstartDefaults().setProfile(null);
        KickstartFactory.saveKickstartData(k);
        k = (KickstartData) reload(k);
        assertNull(k.getKickstartDefaults().getProfile());
        flushAndEvict(k);
        
        KickstartPackageProfileCommand cmd = new 
            KickstartPackageProfileCommand(k.getId(), user);
        
        cmd.setProfile(p);
        cmd.store();
        k = (KickstartData) reload(k);
        assertNotNull(k.getKickstartDefaults().getProfile());
    }

}
