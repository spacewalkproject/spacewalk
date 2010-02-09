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
import com.redhat.rhn.domain.user.Address;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.user.EditAddressAction;
import com.redhat.rhn.frontend.struts.RequestContext;
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
 * EditAddressSubmitActionSubmitTest
 * @version $Rev: 694 $
 */
public class EditAddressActionTest extends RhnBaseTestCase {

    private EditAddressAction action;
    private ActionMapping mapping;
    private ActionForward success;
    private RhnMockDynaActionForm form;
    private RhnMockHttpServletRequest request;
    private MockHttpServletResponse response;
    private User usr;

    private void setUpFailure() {
        action = new EditAddressAction();
        mapping = new ActionMapping();
        success = new ActionForward("success", "path", false);
        form = new RhnMockDynaActionForm("editAddressForm");
        request = TestUtils.getRequestWithSessionAndUser();
        response = new MockHttpServletResponse();
        // Make sure we aren't operating on the logged in user
        // we want to edit the address associated with the UID field
        // in the Request.
        usr = UserTestUtils.findNewUser("differentUser", "differentOrg");
        // Have to grab the UID out of the request so we can reset it
        String userIdRaw = request.getParameter("uid");
        userIdRaw = usr.getId().toString();
        // Put it back into the Request
        request.setupAddParameter("uid", userIdRaw);
    }

    private void setUpSuccess() {
        action = new EditAddressAction();
        mapping = new ActionMapping();
        success = new ActionForward("success", "path", false);
        form = new RhnMockDynaActionForm("editAddressForm");
        request = TestUtils.getRequestWithSessionAndUser();
        response = new MockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);

        // The logged in user needs to be the OrgAdmin of his Org in order
        // for him to be able to edit somebody else's address information.
        User loggedInUser = requestContext.getLoggedInUser();
        loggedInUser.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(loggedInUser);

        usr = UserTestUtils.createUser("differentUser", loggedInUser.getOrg().getId());
        // Have to grab the UID out of the request so we can reset it
        String userIdRaw = request.getParameter("uid");
        userIdRaw = usr.getId().toString();
        // Put it back into the Request
        request.setupAddParameter("uid", userIdRaw);
    }

    private void executeAction(String addressType) {

        mapping.addForwardConfig(success);
        form.set("type", addressType);
        form.set("phone", "650-555-1212");
        form.set("fax", "650-555-1212");
        String newAddr1 = "444 Castro St " + TestUtils.randomString();
        form.set("address1", newAddr1);
        form.set("address2", "#1200");
        form.set("city", "Mountain View");
        form.set("country", "US");
        form.set("state", "something");
        form.set("zip", "something");

        action.execute(mapping, form, request, response);

        User user = UserFactory.lookupById(usr.getId());

        // If we get here, then we should have changed the address, so check that.
        assertEquals(user.getAddress1(), newAddr1);
    }

    public void testPerformExecuteNewAddressFailure() throws Exception {
        setUpFailure();
        // Creating a user automatically creates a MARKETING address, so as long
        // as that is the only address in the User, we know there is no SHIPPING
        // address.
        try {
            executeAction(Address.TYPE_MARKETING);
            fail("Should have failed.");
        }
        catch (RuntimeException e) {
            // expected
        }
    }

    public void testPerformExecuteNewAddressSuccess() throws Exception {
        setUpSuccess();
        // Creating a user automatically creates a MARKETING address, so as long
        // as that is the only address in the User, we know there is no SHIPPING
        // address.
        executeAction(Address.TYPE_MARKETING);
    }
}
