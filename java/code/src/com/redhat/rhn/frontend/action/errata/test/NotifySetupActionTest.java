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
package com.redhat.rhn.frontend.action.errata.test;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.action.errata.NotifySetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.TestUtils;

import com.mockobjects.servlet.MockHttpServletResponse;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * NotifySetupActionTest
 * @version $Rev$
 */
public class NotifySetupActionTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {
        NotifySetupAction action = new NotifySetupAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward def = new ActionForward("default", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        MockHttpServletResponse response = new MockHttpServletResponse();
        mapping.addForwardConfig(def);

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        Errata published = ErrataFactoryTest
                .createTestPublishedErrata(user.getOrg().getId());
        Errata unpublished = ErrataFactoryTest
                .createTestUnpublishedErrata(user.getOrg().getId());

        //test bad parameter exception
        request.setupAddParameter("eid", unpublished.getId().toString());
        try {
            action.execute(mapping, form, request, response);
            fail();
        }
        catch (BadParameterException e) {
            //Success!!!
        }

        //test default case
        request.setupAddParameter("eid", published.getId().toString());
        request.setupAddParameter("eid", unpublished.getId().toString());
        ActionForward result = action.execute(mapping, form, request, response);
        assertEquals("default", result.getName());
        assertNotNull(request.getAttribute("advisory"));
    }
}
