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

import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.errata.DeleteBugAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.RhnMockHttpSession;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * DeleteBugActionTest
 * @version $Rev$
 */
public class DeleteBugActionTest extends RhnBaseTestCase {

    public void testDeleteBug() throws Exception {
        DeleteBugAction action = new DeleteBugAction();
        
        ActionMapping mapping = new ActionMapping();
        ActionForward def = new ActionForward("default", "path", true);
        mapping.addForwardConfig(def);
        
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        RhnMockHttpSession session = new RhnMockHttpSession();
        request.setSession(session);
        request.setupServerName("mymachine.rhndev.redhat.com");
        
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        
        RequestContext requestContext = new RequestContext(request);
        
        //Create a test errata with a bug
        User user = requestContext.getLoggedInUser();
        Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        Long bugId = new Long(42);
        String bugSummary = "This bug is tagged for destruction";
        Bug bug = ErrataManager.createNewPublishedBug(bugId, bugSummary);
        e.addBug(bug);
        ErrataManager.storeErrata(e);
        Long eid = e.getId();
        
        assertEquals(1, e.getBugs().size());
        //setup the request
        request.setupAddParameter("eid", eid.toString());
        request.setupAddParameter("bid", bugId.toString());
        
        ActionForward result = action.execute(mapping, form, request, response);
        assertEquals(result.getName(), "default");

        flushAndEvict(e); //get rid of e
        
        Errata e2 = ErrataManager.lookupErrata(eid, user);
        assertTrue(e2.getBugs().isEmpty()); //make sure bug was removed
    }
}
