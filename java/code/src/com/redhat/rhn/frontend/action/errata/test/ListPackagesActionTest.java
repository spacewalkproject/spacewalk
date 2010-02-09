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
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.action.errata.ListPackagesAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * ListPackagesActionTest
 * @version $Rev$
 */
public class ListPackagesActionTest extends RhnBaseTestCase {

    public void testConfirm() throws Exception {
        ListPackagesAction action = new ListPackagesAction();
        
        ActionMapping mapping = new ActionMapping();
        ActionForward confirm = new ActionForward("confirm", "path", true);
        mapping.addForwardConfig(confirm);
        
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(
                                              UserTestUtils.createOrg("testorg"));
        
        Package pkg = PackageTest.createTestPackage();
        String[] selected = {pkg.getId().toString()};
        
        RhnSet pre = RhnSetDecl.PACKAGES_TO_REMOVE.get(requestContext.getLoggedInUser());
        //make sure the set is empty
        assertTrue(pre.isEmpty());
        
        request.setupAddParameter("eid", errata.getId().toString());
        request.setupAddParameter("items_on_page", "");
        request.setupAddParameter("items_selected", selected);
        request.setupAddParameter("lower", "2");
        
        ActionForward result = action.confirm(mapping, form, request, response);
        
        RhnSet post = RhnSetDecl.PACKAGES_TO_REMOVE.get(requestContext.getLoggedInUser());
        //make sure something is in the set
        assertFalse(post.isEmpty());
        //make sure we're going to the confirm forward
        assertEquals("confirm", result.getName());
    }
}
