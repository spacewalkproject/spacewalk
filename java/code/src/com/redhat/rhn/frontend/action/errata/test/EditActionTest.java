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
import com.redhat.rhn.frontend.action.errata.EditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;

import com.mockobjects.servlet.MockHttpServletResponse;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;

/**
 * EditActionTest
 * @version $Rev$
 */
public class EditActionTest extends RhnBaseTestCase {

    public void testUpdateErrata() throws Exception {
        EditAction action = new EditAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward def = new ActionForward("default", "path", false);
        ActionForward failure = new ActionForward("failure", "path", false);
        ActionForward success = new ActionForward("updated", "path", true);
        mapping.addForwardConfig(def);
        mapping.addForwardConfig(failure);
        mapping.addForwardConfig(success);

        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("errataEditForm");
        //request.setSession(session);
        request.setupServerName("mymachine.rhndev.redhat.com");

        RequestContext requestContext = new RequestContext(request);

        //Create a new unpublished errata
        User user = requestContext.getLoggedInUser();
        Errata errata = ErrataFactoryTest
                .createTestUnpublishedErrata(user.getOrg().getId());
        //Create another for checking adv name uniqueness constraint
        Errata errata2 = ErrataFactoryTest
                .createTestUnpublishedErrata(user.getOrg().getId());

        request.setupAddParameter("eid", errata.getId().toString());
        request.setupAddParameter("eid", errata.getId().toString());

        //Execute setupAction to fillout form
        ActionForward result = action.unspecified(mapping, form, request, response);
        assertEquals("default", result.getName());
        //make sure form was filled out
        assertEquals(form.get("synopsis"), errata.getSynopsis());
        //add empty buglistId & buglistSummary so validator doesn't freak out
        form.set("buglistId", "");
        form.set("buglistSummary", "");

        //make sure we still get validation errors
        request.setupAddParameter("eid", errata.getId().toString());
        form.set("synopsis", ""); //required field, so we should get a validation error
        result = action.update(mapping, form, request, response);
        assertEquals("default", result.getName());

        //make sure adv name has to be unique
        request.setupAddParameter("eid", errata.getId().toString());
        form.set("synopsis", "this errata has been edited");
        form.set("advisoryName", errata2.getAdvisoryName());
        result = action.update(mapping, form, request, response);
        assertEquals("default", result.getName());

        //make sure adv name cannot start with rh
        request.setupAddParameter("eid", errata.getId().toString());
        form.set("advisoryName", "rh" + TestUtils.randomString());
        result = action.update(mapping, form, request, response);
        assertEquals("default", result.getName());

        //make sure we can edit an errata
        String newAdvisoryName = errata.getAdvisoryName() + "edited";
        /*
         * I hate it when Mock Objects don't act like the objects they mock
         */
        request.setupAddParameter("eid", errata.getId().toString());
        request.setupAddParameter("eid", errata.getId().toString());
        form.set("advisoryName", newAdvisoryName);
        //add a bug
        form.set("buglistIdNew", "123");
        form.set("buglistSummaryNew", "test bug for a test errata");
        //edit the keywords
        form.set("keywords", "yankee, hotel, foxtrot");
        Map params = new HashMap();
        params.put("eid", errata.getId().toString());
        params.put("buglistIdNew", "123");
        params.put("buglistSummaryNew", "test bug for a test errata");
        request.setupGetParameterMap(params);
        request.setupAddParameter("buglistIdNew", "123");
        request.setupAddParameter("buglistSummaryNew", "test bug for a test errata");
        result = action.update(mapping, form, request, response);
        assertEquals("default", result.getName());

        //errata has now been edited... let's look it back up from the db and make sure
        //our changes were saved.
        Long id = errata.getId();
        flushAndEvict(errata); //kick errata from session
        Errata edited = ErrataManager.lookupErrata(id, user);
        //make sure adv name was changed
        assertEquals(edited.getAdvisoryName(), newAdvisoryName);
        //make sure keywords were added
        assertEquals(3, edited.getKeywords().size());
        //make sure bug was added
        assertEquals(1, edited.getBugs().size());
    }

    public void testSetupExecute() throws Exception {
        EditAction action = new EditAction();

        ActionMapping mapping = new ActionMapping();
        ActionForward def = new ActionForward("default", "path", false);
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        MockHttpServletResponse response = new MockHttpServletResponse();
        mapping.addForwardConfig(def);

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        request.setupAddParameter("eid", errata.getId().toString());

        //make sure our form vars are null
        assertNull(form.get("synopsis"));
        //execute the action
        ActionForward result = action.unspecified(mapping, form, request, response);
        assertEquals(result.getName(), "default");
        //make sure form was filled out properly
        assertEquals(form.get("synopsis"), errata.getSynopsis());
        assertEquals(form.get("advisoryName"), errata.getAdvisoryName());
        //check select list to make sure correct one is selected
        assertEquals(form.get("advisoryType"), errata.getAdvisoryType());

        //We created a published errata above
        assertEquals(request.getAttribute("isPublished"), "true");
    }

}
