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
package com.redhat.rhn.frontend.action.rhnpackage.test;

import com.redhat.rhn.domain.rhnpackage.PatchSet;
import com.redhat.rhn.domain.rhnpackage.test.PatchSetTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.rhnpackage.InstallPatchSetSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.TestUtils;

import com.mockobjects.servlet.MockHttpServletResponse;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * EditSetupActionTest
 * @version $Rev$
 */
public class InstallPatchSetSetupTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {
        InstallPatchSetSetupAction action = new InstallPatchSetSetupAction();

        PatchSet patchset = PatchSetTest.createTestPatchSet();

        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();

        user.addRole(RoleFactory.ORG_ADMIN);
        Server system = ServerFactoryTest.createTestServer(user);

        ActionMapping mapping = new ActionMapping();
        ActionForward def = new ActionForward("default", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        MockHttpServletResponse response = new MockHttpServletResponse();
        mapping.addForwardConfig(def);

        request.setupAddParameter("pid", patchset.getId().toString());
        request.setupAddParameter("sid", system.getId().toString());

        //execute the action
        ActionForward result = action.execute(mapping, form, request, response);
        assertEquals(result.getName(), "default");
    }
}
