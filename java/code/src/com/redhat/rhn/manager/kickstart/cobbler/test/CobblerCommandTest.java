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
package com.redhat.rhn.manager.kickstart.cobbler.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroDeleteCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroEditCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerLoginCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileDeleteCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileEditCommand;
import com.redhat.rhn.manager.kickstart.cobbler.XMLRPCHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * KickstartCloneCommandTest
 */
public class CobblerCommandTest extends BaseTestCaseWithUser {
    // Flip this to true if you want this test to actually call a cobbler
    // server.  Otherwise it uses a mock interface
    private static boolean callCobbler = true; 
    protected KickstartData ksdata;
    private String token;
    
    @Override
    public void setUp() throws Exception {
        super.setUp();
        Config.get().setString(XMLRPCHelper.class.getName(),
                XMLRPCHelper.class.getName());
        
        user = UserTestUtils.ensureUserExists("cobbler-test-user");
        this.ksdata = KickstartDataTest.createKickstartWithChannel(this.user.getOrg());
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        user = (User) reload(user);
        HibernateFactory.commitTransaction();
        
        String[] args = {user.getLogin(), UserTestUtils.TEST_PASSWORD};
        token = (String) new XMLRPCHelper().invokeXMLRPC("login", Arrays.asList(args)); 
        ksdata.setName("cobbler-java-test");
        ksdata = (KickstartData) TestUtils.saveAndReload(ksdata);
        CobblerDistroCreateCommand dcreate = new CobblerDistroCreateCommand(ksdata, token);
        dcreate.store();
    }

    public void testProfileCreate() throws Exception {
        CobblerProfileCreateCommand cmd = new CobblerProfileCreateCommand(ksdata, token);
        assertNull(cmd.store());
        Map profile = cmd.getProfile();
        System.out.println("Profile: " + profile);
        assertNotNull(profile);
        assertNotNull(profile.get("name"));
        assertEquals(ksdata.getName(), profile.get("name"));
    }

    public void testProfileEdit() throws Exception {

        CobblerProfileEditCommand cmd = new CobblerProfileEditCommand(ksdata, token);
        String newName = TestUtils.randomString();
        ksdata.setName(newName);
        assertNull(cmd.store());
        Map profile = cmd.getProfile(); 
        String profileName = (String) profile.get("name"); 
        assertNotNull(profileName);
        assertEquals(newName, profileName);
        
    }

    public void testProfileDelete() throws Exception {
        CobblerProfileDeleteCommand cmd = new CobblerProfileDeleteCommand(ksdata, token);
        assertNull(cmd.store());
        assertTrue(cmd.getProfile().isEmpty());
    }

    public void testDistroCreate() throws Exception {
        CobblerDistroCreateCommand cmd = new CobblerDistroCreateCommand(ksdata, token);
        assertNull(cmd.store());
        assertNotNull(cmd.getDistro());
    }

    public void testDistroEdit() throws Exception {
        CobblerDistroEditCommand cmd = new CobblerDistroEditCommand(ksdata, token);
        String newName = TestUtils.randomString();
        ksdata.getKsdefault().getKstree().setLabel(newName);
        assertNull(cmd.store());
        Map distro = cmd.getDistro(); 
        String distroName = (String) distro.get("name"); 
        assertNotNull(distroName);
        assertEquals(newName, distroName);
    }

    
    public void testDistroDelete() throws Exception {
        CobblerDistroDeleteCommand cmd = new CobblerDistroDeleteCommand(ksdata, token);
        assertNull(cmd.store());
        assertTrue(cmd.getDistro().isEmpty());
    }
    
    public void testLogin() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        user = (User) reload(user);
        CobblerLoginCommand cmd = new CobblerLoginCommand(user.getLogin(), "password");
        assertNotNull(cmd.login());
    }
    
    public Object mockInvoke(KickstartData ksData, String procName) {
        System.out.println("proc_name: " + procName);
        if (procName.equals("new_profile")) {
            return new String("1");
        }
        else if (procName.equals("get_profile")) {
            Map retval = new HashMap();
            retval.put("name", ksData.getName());
            return retval;
        }
        return new Object();
    }
    
    
}
