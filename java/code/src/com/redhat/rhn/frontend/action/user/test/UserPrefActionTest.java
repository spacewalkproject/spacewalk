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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.user.UserPrefAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.TestUtils;

import com.mockobjects.servlet.MockHttpServletResponse;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * UserPrefActionTest
 * @version $Rev$
 */
public class UserPrefActionTest extends RhnBaseTestCase {

    private static final Integer PAGE_SIZE = new Integer(50);

    /**
     * 
     * @throws Exception on server init failure
     */    
    public void testPerformExecute() throws Exception {
        UserPrefAction action = new UserPrefAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward success = new ActionForward("success", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        MockHttpServletResponse response = new MockHttpServletResponse();

        mapping.addForwardConfig(success);
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = UserManager.lookupUser(requestContext.getLoggedInUser(),
                requestContext.getParamAsLong("uid"));
        request.setAttribute(RhnHelper.TARGET_USER, user);
        // we have to get the actual user here so we can call setupAddParamter
        // a second time.  The MockRequest counts the number of times getParamter
        // is called.

        request.setupAddParameter("uid", user.getId().toString());
        // populate with any set of information
        // then get the verify the user was changed correctly.
        form.set("emailNotif", Boolean.FALSE);
        form.set("email", Boolean.TRUE);
        form.set("call", Boolean.TRUE);
        form.set("fax", Boolean.TRUE);
        form.set("mail", Boolean.FALSE);
        form.set("pagesize", PAGE_SIZE);

        ActionForward rc = action.execute(mapping, form, request, response);

        // verify the correct ActionForward was returned
        assertTrue(rc.getName().equals("success"));
        assertEquals("path?uid=" + String.valueOf(user.getId()), rc.getPath());
        assertFalse(rc.getRedirect());


        assertEquals(PAGE_SIZE.intValue(), user.getPageSize());
    }
}
