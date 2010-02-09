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

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.action.user.DeleteUserAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * DeleteUserActionTest
 * @version $Rev$
 */
public class DeleteUserActionTest extends RhnBaseTestCase {

    
    
    public void testExecute() throws Exception {
        DeleteUserAction action = new DeleteUserAction();
        ActionForward forward;
        
        ActionMapping mapping = new ActionMapping();
        ActionForward failure = new ActionForward("failure", "path", true);
        ActionForward success = new ActionForward("success", "path", true);
        mapping.addForwardConfig(failure);
        mapping.addForwardConfig(success);
        
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        
        RequestContext requestContext = new RequestContext(request);
        
        Long uid = new Long(Long.parseLong(request.getParameter("uid")));
        request.setupAddParameter("uid", uid.toString()); //put it back
        assertNotNull(UserFactory.lookupById(uid));
        
        
        //Not an org admin
        try {
            forward = action.execute(mapping, form, request, response);
            fail();
        }
        catch (PermissionException e) {
            //no op
        }
        
        //Null parameter
        request.getParameter("uid");
        request.setupAddParameter("uid", (String)null);
        requestContext.getLoggedInUser().addRole(RoleFactory.lookupByLabel("org_admin"));
        try {
            forward = action.execute(mapping, form, request, response);
            fail();
        }
        catch (BadParameterException e) {
            //no op
        }
        
        //try to delete self
        request.setupAddParameter("uid", uid.toString());
        forward = action.execute(mapping, form, request, response);
        failure.setPath("path?uid=" + uid.toString());
        assertEquals(failure.getName(), forward.getName());
        assertEquals(failure.getPath(), forward.getPath());
        
        //try to delete non-existing user
        request.setupAddParameter("uid", "-9999");
        try {
            forward = action.execute(mapping, form, request, response);
            fail();
        }
        catch (LookupException e) {
            //no op
        }
        
        //try to delete org admin
        failure.setPath("path");
        User usr = UserTestUtils.createUser("testUser", 
                requestContext.getLoggedInUser().getOrg().getId());
        usr.addRole(RoleFactory.lookupByLabel("org_admin"));
        request.setupAddParameter("uid", usr.getId().toString());
        forward = action.execute(mapping, form, request, response);
        failure.setPath("path?uid=" + usr.getId());
        assertEquals(failure.getName(), forward.getName());
        assertEquals(failure.getPath(), forward.getPath());
        
        //successful delete
        User usr2 = UserTestUtils.createUser("testUser", 
                requestContext.getLoggedInUser().getOrg().getId());
        request.setupAddParameter("uid", usr2.getId().toString());
        forward = action.execute(mapping, form, request, response);
        assertEquals(success, forward);
    }
    
}
