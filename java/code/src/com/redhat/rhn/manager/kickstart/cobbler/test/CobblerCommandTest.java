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
        
        user = UserTestUtils.createUserInOrgOne();
        this.ksdata = KickstartDataTest.createKickstartWithChannel(this.user.getOrg());
        this.ksdata.getTree().setBasePath("/var/satellite/rhn/kickstart/ks-f9-x86_64/");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        user = (User) reload(user);
        HibernateFactory.commitTransaction();
        
        String[] args = {user.getLogin(), UserTestUtils.TEST_PASSWORD};
        token = (String) new XMLRPCHelper().invokeXMLRPC("login", Arrays.asList(args)); 
        ksdata.setLabel("cobbler-java-test");
        ksdata = (KickstartData) TestUtils.saveAndReload(ksdata);
        CobblerDistroCreateCommand dcreate = new 
            CobblerDistroCreateCommand(ksdata.getTree(), token);
        dcreate.store();
    }

    public void testProfileCreate() throws Exception {
        CobblerProfileCreateCommand cmd = new CobblerProfileCreateCommand(
                ksdata, token, "http://localhost/ks");
        assertNull(cmd.store());
        Map profile = cmd.getProfileMap();
        assertNotNull(profile);
        assertNotNull(profile.get("name"));
        assertEquals(ksdata.getLabel(), profile.get("name"));
    }

    public void testProfileEdit() throws Exception {
        // create one first
        CobblerProfileCreateCommand cmd = new CobblerProfileCreateCommand(
                ksdata, token, "http://localhost/ks");
        assertNull(cmd.store());

        // Now test edit
        CobblerProfileEditCommand pec = new 
            CobblerProfileEditCommand(ksdata, token, "http://localhost/ks");
        String newName = "some-new-name-" + System.currentTimeMillis();
        ksdata.setLabel(newName);
        assertNull(pec.store());
        Map profile = pec.getProfileMap(); 
        String profileName = (String) profile.get("name"); 
        assertNotNull(profileName);
        assertEquals(newName, profileName);
        
    }

    public void testProfileDelete() throws Exception {
        CobblerProfileDeleteCommand cmd = new CobblerProfileDeleteCommand(ksdata, token);
        assertNull(cmd.store());
        assertTrue(cmd.getProfileMap().isEmpty());
    }

    public void testDistroCreate() throws Exception {
        CobblerDistroCreateCommand cmd = new 
            CobblerDistroCreateCommand(ksdata.getTree(), token);
        assertNull(cmd.store());
        assertNotNull(cmd.getDistroMap());
    }

    public void testDistroEdit() throws Exception {
        CobblerDistroEditCommand cmd = new 
            CobblerDistroEditCommand(ksdata.getTree(), token);
        String newName = TestUtils.randomString();
        ksdata.getKsdefault().getKstree().setLabel(newName);
        assertNull(cmd.store());
        Map distro = cmd.getDistroMap(); 
        String distroName = (String) distro.get("name"); 
        assertNotNull(distroName);
        assertEquals(newName, distroName);
    }

    
    public void testDistroDelete() throws Exception {
        CobblerDistroDeleteCommand cmd = new 
            CobblerDistroDeleteCommand(ksdata.getTree(), token);
        assertNull(cmd.store());
        assertTrue(cmd.getDistroMap().isEmpty());
    }
    
    public void testLogin() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        user = (User) reload(user);
        CobblerLoginCommand cmd = new CobblerLoginCommand(user.getLogin(), "password");
        assertNotNull(cmd.login());
    }
    
    public Object mockInvoke(KickstartData ksData, String procName) {
        if (procName.equals("new_profile")) {
            return new String("1");
        }
        else if (procName.equals("get_profile")) {
            Map retval = new HashMap();
            retval.put("name", ksData.getLabel());
            return retval;
        }
        return new Object();
    }
    
    
}
