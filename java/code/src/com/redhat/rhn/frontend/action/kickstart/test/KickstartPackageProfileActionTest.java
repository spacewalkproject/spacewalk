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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.action.kickstart.KickstartPackageProfileSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.profile.test.ProfileManagerTest;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartPackageProfilesEditActionTest
 * @version $Rev: 1 $
 */
public class KickstartPackageProfileActionTest extends RhnMockStrutsTestCase {

    private KickstartData ksdata;
    
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        ksdata = KickstartDataTest.createKickstartWithProfile(user);
        ksdata.getKickstartDefaults().setProfile(null);
        addRequestParameter(RequestContext.KICKSTART_ID, ksdata.getId().toString());
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) TestUtils.reload(ksdata);
        assertNull(ksdata.getKickstartDefaults().getProfile());
        TestUtils.flushAndEvict(ksdata);
    }

    public void testExecute() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        setRequestPathInfo("/kickstart/KickstartPackageProfileEdit");
        actionPerform();
        assertNotNull(request.getParameter(RequestContext.KICKSTART_ID));
    }
    
    public void testSubmit() throws Exception {
        assertNull(ksdata.getKickstartDefaults().getProfile());
        user.addRole(RoleFactory.ORG_ADMIN);
        Profile p = ProfileManagerTest.createProfileWithServer(user);
        ksdata.getKickstartDefaults().setProfile(p);
        addDispatchCall(KickstartPackageProfileSetupAction.CLEAR_METHOD);
        setRequestPathInfo("/kickstart/KickstartPackageProfileEdit");
        actionPerform();
        // Gotta make sure we can update the profile to the same entry twice
        actionPerform();
        ksdata = (KickstartData) TestUtils.reload(ksdata);
        assertNull(ksdata.getKickstartDefaults().getProfile());
        setRequestPathInfo("/kickstart/KickstartPackageProfileEdit");
        // Need to test that the SetupAction works after we 
        // add the profile to the Kickstart
        actionPerform();
    }

}

