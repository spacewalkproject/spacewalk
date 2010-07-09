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
package com.redhat.rhn.frontend.action.user.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.action.user.UserActionHelper;
import com.redhat.rhn.frontend.action.user.UserEditSetupAction;
import com.redhat.rhn.frontend.action.user.UserRoleStatusBean;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.TestUtils;

import java.util.Iterator;
import java.util.List;

/**
 * UserEditSetupActionTest
 * @version $Rev: 1635 $
 */
public class UserEditSetupActionTest extends RhnBaseTestCase {

    public void testPerformExecute() throws Exception {
        UserEditSetupAction action = new UserEditSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.getRequest().setRequestURL("foo");

        User user = sah.getUser();
        user.setTitle("Test title");
        // Lets add some roles
        Iterator it = UserFactory.IMPLIEDROLES.iterator();
        user.addRole(RoleFactory.ORG_ADMIN);
        while (it.hasNext()) {
            Role cr = (Role) it.next();
            user.getOrg().addRole(cr);
            user.addRole(cr);
        }

        setupExpectations(sah.getForm(), sah.getUser());

        // Below we test to make sure that some of
        // the strings in the form are localized
        TestUtils.enableLocalizationDebugMode();
        try {
            sah.executeAction();

            // verify the dyna form got the right values we expected.
            sah.getForm().verify();

            assertNotNull(sah.getRequest().getAttribute("lastLoggedIn"));
            // Verify some more intensive stuff
            assertNotNull(sah.getRequest().getAttribute("adminRoles"));
            assertNotNull(sah.getRequest().getAttribute("regularRoles"));
            List<UserRoleStatusBean> regularRoles = (List<UserRoleStatusBean>)
                sah.getRequest().getAttribute("regularRoles");
            assertEquals(5, regularRoles.size());
            UserRoleStatusBean lv = regularRoles.get(0);
            assertTrue(TestUtils.isLocalized(lv.getName()));
            assertEquals(true, lv.isDisabled());
            assertNotNull(sah.getRequest().getAttribute("disabledRoles"));
            assertTrue(sah.getRequest().getAttribute("user") instanceof User);

            //If we have pam setup where we're testing, make sure displaypam was set
            String pamAuthService = Config.get().getString(
                    ConfigDefaults.WEB_PAM_AUTH_SERVICE);
            if (pamAuthService != null && pamAuthService.trim().length() > 0) {
                assertNotNull(sah.getRequest().getAttribute("displaypam"));
            }
        }
        finally {
            TestUtils.disableLocalizationDebugMode();
        }
    }

    public void testNoParamExecute() throws Exception {
        UserEditSetupAction action = new UserEditSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.getRequest().setRequestURL("rdu.redhat.com/rhn/users/UserDetails.do");
        setupExpectations(sah.getForm(), sah.getUser());

        sah.getRequest().setupAddParameter("uid", (String)null);
        sah.getRequest().getParameterValues("uid"); //now uid = null

        try {
            sah.executeAction();
            fail(); //should never get this far
        }
        catch (BadParameterException e) {
            //no op
        }
    }

    private void setupExpectations(RhnMockDynaActionForm form, User user) {

        form.addExpectedProperty("uid", user.getId());
        form.addExpectedProperty("firstNames", user.getFirstNames());
        form.addExpectedProperty("lastName", user.getLastName());
        form.addExpectedProperty("title", user.getTitle());
        form.addExpectedProperty("prefix", user.getPrefix());
        form.addExpectedProperty(UserActionHelper.DESIRED_PASS, "******");
        form.addExpectedProperty(UserActionHelper.DESIRED_PASS_CONFIRM, "******");

    }
}
