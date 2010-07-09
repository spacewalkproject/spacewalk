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

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.user.AdminUserEditAction;
import com.redhat.rhn.frontend.action.user.SelfEditAction;
import com.redhat.rhn.frontend.action.user.UserActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import com.mockobjects.servlet.MockHttpServletResponse;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * UserEditActionTEst
 * @version $Rev$
 */
public class UserEditActionTest extends RhnBaseTestCase {

    /**
     * Test the SelfEditAction
     */
    public void testSelfEditAction() {
        SelfEditAction action = new SelfEditAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward success = new ActionForward("success", "path", false);
        ActionForward failure = new ActionForward("failure", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("userDetailsForm");
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        MockHttpServletResponse response = new MockHttpServletResponse();

        RequestContext requestContext = new RequestContext(request);

        mapping.addForwardConfig(success);
        mapping.addForwardConfig(failure);
        User user = UserManager.lookupUser(requestContext.getLoggedInUser(),
                requestContext.getParamAsLong("uid"));
        request.setAttribute(RhnHelper.TARGET_USER, user);

        //Try password mismatch
        request.setupAddParameter("uid", user.getId().toString());
        form.set("prefix", user.getPrefix());
        form.set("firstNames", user.getFirstNames());
        form.set("lastName", user.getLastName());
        form.set("title", user.getTitle());
        form.set(UserActionHelper.DESIRED_PASS, "foobar");
        form.set(UserActionHelper.DESIRED_PASS_CONFIRM, "foobar-foobar");

        ActionForward result = action.execute(mapping, form, request, response);
        assertTrue(result.getName().equals("failure"));

        //Try validation errors
        request.setupAddParameter("uid", user.getId().toString());
        form.set(UserActionHelper.DESIRED_PASS_CONFIRM, "foobar");
        form.set("firstNames", "");

        result = action.execute(mapping, form, request, response);
        assertTrue(result.getName().equals("failure"));

        //Try Valid edit
        request.setupAddParameter("uid", user.getId().toString());
        form.set("firstNames", "Larry");

        result = action.execute(mapping, form, request, response);
        assertTrue(result.getName().equals("success"));
        //make sure our user was updated
        assertEquals("Larry", user.getFirstNames());
    }

    /**
     * Test the AdminUserEditAction
     * @throws Exception
     */
    public void testAdminUserEdit() throws Exception {
        AdminUserEditAction action = new AdminUserEditAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward success = new ActionForward("success", "path", false);
        ActionForward failure = new ActionForward("failure", "path", false);
        ActionForward noaccess = new ActionForward("noaccess", "path", true);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("userDetailsForm");
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        MockHttpServletResponse response = new MockHttpServletResponse();

        RequestContext requestContext = new RequestContext(request);

        mapping.addForwardConfig(success);
        mapping.addForwardConfig(failure);
        mapping.addForwardConfig(noaccess);
        User user = UserManager.lookupUser(requestContext.getLoggedInUser(),
                requestContext.getParamAsLong("uid"));

        //Give the user org admin role
        user.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(user);
        ServerFactoryTest.createTestServer(user);
        UserTestUtils.assertOrgAdmin(user);

        request.setAttribute(RhnHelper.TARGET_USER, user);

        //Try taking away org admin status
        setupRoleParameters(request, user);

        form.set("prefix", user.getPrefix());
        form.set("firstNames", user.getFirstNames());
        form.set("lastName", user.getLastName());
        form.set("title", user.getTitle());
        form.set(UserActionHelper.DESIRED_PASS, "foobar");
        form.set(UserActionHelper.DESIRED_PASS_CONFIRM, "foobar");



        runSatTests(action, user, mapping, form, request, response);
    }

    private void setupRoleParameters(RhnMockHttpServletRequest request,
            User user) {
        request.setupAddParameter("uid", user.getId().toString());
        request.setupAddParameter("disabledRoles", "");
        request.setupAddParameter("role_" + RoleFactory.MONITORING_ADMIN.getLabel(),
                (String)null);
        request.setupAddParameter("role_" + RoleFactory.ORG_ADMIN.getLabel(),
                (String)null);
        request.setupAddParameter("role_" + RoleFactory.ORG_APPLICANT.getLabel(),
                (String)null);
        request.setupAddParameter("role_" + RoleFactory.CHANNEL_ADMIN.getLabel(),
                (String)null);
        request.setupAddParameter("role_" + RoleFactory.SAT_ADMIN.getLabel(),
                (String)null);
        request.setupAddParameter("role_" + RoleFactory.ACTIVATION_KEY_ADMIN.getLabel(),
                (String)null);
        request.setupAddParameter("role_" + RoleFactory.SYSTEM_GROUP_ADMIN.getLabel(),
                (String)null);
        request.setupAddParameter("role_" + RoleFactory.CONFIG_ADMIN.getLabel(),
                (String)null);
    }

    private void runSatTests(AdminUserEditAction action,
                             User user,
                             ActionMapping mapping,
                             RhnMockDynaActionForm form,
                             RhnMockHttpServletRequest request,
                             MockHttpServletResponse response) {

        /*
         * This should never happen, but just in case...
         */
        if (user.getOrg().numActiveOrgAdmins() < 2) {
            User otherAdmin = UserTestUtils.createUser("oadmin", user.getOrg().getId());
            otherAdmin.addRole(RoleFactory.ORG_ADMIN);
            UserManager.storeUser(otherAdmin);
        }

        assertTrue(user.getOrg().numActiveOrgAdmins() > 1);
        UserTestUtils.assertOrgAdmin(user);
        ActionForward result = action.execute(mapping, form, request, response);
        //should get noaccess
        assertTrue(result.getName().equals("noaccess"));
        user.addRole(RoleFactory.ORG_ADMIN);

        User user2 = UserTestUtils.createUser("foo", user.getOrg().getId());
        user2.addRole(RoleFactory.ORG_ADMIN);
        setupRoleParameters(request, user2);

        result = action.execute(mapping, form, request, response);

        assertTrue(result.getName().equals("success"));
        UserTestUtils.assertNotOrgAdmin(user2);
    }

}
