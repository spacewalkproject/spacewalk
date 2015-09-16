/**
 * Copyright (c) 2015 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.test;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.mockobjects.servlet.MockHttpSession;
import com.redhat.rhn.common.db.ResetPasswordFactory;
import com.redhat.rhn.domain.common.ResetPassword;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.user.ResetPasswordSubmitAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * ResetPasswordSubmitActionTest
 * @version $Rev$
 */
public class ResetPasswordSubmitActionTest extends BaseTestCaseWithUser {

    private ActionForward mismatch, invalid, badpwd;
    private ActionMapping mapping;
    private RhnMockDynaActionForm form;
    private RhnMockHttpServletRequest request;
    private RhnMockHttpServletResponse response;
    private ResetPasswordSubmitAction action;
    private User adminUser;

    public void testPerformNoToken() {
        form.set("token", null);
        ActionForward rc = action.execute(mapping, form, request, response);
        assertEquals("No token", invalid.getName(), rc.getName());
    }

    public void testPerformInvalidToken() {
        ResetPassword rp = ResetPasswordFactory.createNewEntryFor(user);
        ResetPasswordFactory.invalidateToken(rp.getToken());
        form.set("token", rp.getToken());
        ActionForward rc = action.execute(mapping, form, request, response);
        assertEquals("Invalid token", invalid.getName(), rc.getName());
    }

    public void testPerformDisabledUser() {
        ResetPassword rp = ResetPasswordFactory.createNewEntryFor(user);
        UserFactory.getInstance().disable(user, adminUser);
        form.set("token", rp.getToken());
        ActionForward rc = action.execute(mapping, form, request, response);
        assertEquals("Disabled user", invalid.getName(), rc.getName());
    }

    public void testPerformPasswordMismatch() {
        ResetPassword rp = ResetPasswordFactory.createNewEntryFor(user);
        form.set("token", rp.getToken());
        form.set("password", "foobar");
        form.set("passwordConfirm", "foobarblech");
        ActionForward rc = action.execute(mapping, form, request, response);
        assertEquals(mismatch.getName(), rc.getName());
    }

    public void testPerformBadPassword() {
        ResetPassword rp = ResetPasswordFactory.createNewEntryFor(user);
        form.set("token", rp.getToken());
        form.set("password", "a");
        form.set("passwordConfirm", "a");
        ActionForward rc = action.execute(mapping, form, request, response);
        assertEquals("too short", badpwd.getName(), rc.getName());

        form.set("password",
        "12345678901234567890123456789012345678901234567890123456789012345678901234567890");
        form.set("passwordConfirm",
        "12345678901234567890123456789012345678901234567890123456789012345678901234567890");
        rc = action.execute(mapping, form, request, response);
        assertEquals("too long", badpwd.getName(), rc.getName());

        form.set("password", "123\t\n6");
        form.set("passwordConfirm", "123\t\n6");
        rc = action.execute(mapping, form, request, response);
        assertEquals("whitespace", badpwd.getName(), rc.getName());
    }

    @Override
    public void setUp() throws Exception {
        super.setUp();
        adminUser = UserTestUtils.findNewUser("testAdminUser", "testOrg" +
                        this.getClass().getSimpleName(), true);
        action = new ResetPasswordSubmitAction();

        mapping = new ActionMapping();
        mismatch = new ActionForward("mismatch", "path", false);
        invalid = new ActionForward("invalid", "path", false);
        badpwd = new ActionForward("badpwd", "path", false);
        form = new RhnMockDynaActionForm("resetPasswordForm");
        request = new RhnMockHttpServletRequest();
        response = new RhnMockHttpServletResponse();

        RequestContext requestContext = new RequestContext(request);

        MockHttpSession mockSession = new MockHttpSession();
        mockSession.setupGetAttribute("token", null);
        mockSession.setupGetAttribute("request_method", "GET");
        request.setSession(mockSession);
        request.setupServerName("mymachine.rhndev.redhat.com");
        WebSession s = requestContext.getWebSession();

        mapping.addForwardConfig(mismatch);
        mapping.addForwardConfig(invalid);
        mapping.addForwardConfig(badpwd);
    }
}
