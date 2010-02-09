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

import com.redhat.rhn.frontend.action.errata.CreateAction;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.RhnMockHttpSession;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * CreateActionTest
 * @version $Rev$
 */
public class CreateActionTest extends RhnBaseTestCase {

    public void testCreateErrata() {
        CreateAction action = new CreateAction();
        
        ActionMapping mapping = new ActionMapping();
        ActionForward failure = new ActionForward("failure", "path", false);
        ActionForward success = new ActionForward("success", "path", false);
        mapping.addForwardConfig(failure);
        mapping.addForwardConfig(success);
        
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        RhnMockHttpSession session = new RhnMockHttpSession();
        request.setSession(session);
        request.setupServerName("mymachine.rhndev.redhat.com");
        
        RhnMockDynaActionForm form = fillOutForm();
        form.set("synopsis", ""); //required field, so we should get a validation error
        
        ActionForward result = action.execute(mapping, form, request, response);
        assertEquals(result.getName(), "failure");
        
        //fillout form correctly
        form = fillOutForm();
        
        result = action.execute(mapping, form, request, response);
        assertEquals(result.getName(), "success");
    }
    
    public RhnMockDynaActionForm fillOutForm() {
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("errataCreateForm");
        
        form.set("synopsis", "synopsis");
        form.set("advisoryName", TestUtils.randomString());
        form.set("advisoryRelease", "2");
        form.set("advisoryType", "Security Advisory");
        form.set("product", "product");
        form.set("buglistId", "42");
        form.set("buglistSummary", "bug list summary");
        form.set("topic", "topic");
        form.set("description", "description");
        form.set("solution", "solution");
        form.set("keywords", "  test1  , test2, test3,test4,, ,,,   ");
        form.set("refersTo", "refers to");
        form.set("notes", "notes");
        
        return form;
    }
}
