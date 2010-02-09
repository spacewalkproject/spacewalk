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
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.errata.RemovePackagesAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.RhnMockHttpSession;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashSet;

/**
 * RemovePackagesActionTest
 * @version $Rev$
 */
public class RemovePackagesActionTest extends RhnBaseTestCase {

    public void testRemovePackagesFromErrata() throws Exception {
        RemovePackagesAction action = new RemovePackagesAction();
        
        ActionMapping mapping = new ActionMapping();
        ActionForward success = new ActionForward("success", "path", true);
        mapping.addForwardConfig(success);
        
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        RhnMockHttpSession session = new RhnMockHttpSession();
        request.setSession(session);
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        
        Package p1 = PackageTest.createTestPackage(user.getOrg());
        Package p2 = PackageTest.createTestPackage(user.getOrg());
        errata.addPackage(p1);
        errata.addPackage(p2);
        
        ErrataManager.storeErrata(errata);
        assertTrue(errata.getPackages().size() == 3);
        
        //add some crap to the packages_to_remove set for this user
        RhnSet set = RhnSetManager.createSet(user.getId(), "packages_to_remove", 
                SetCleanup.NOOP);
        set.addElement(p1.getId());
        set.addElement(p2.getId());
        RhnSetManager.store(set);
        
        request.setupAddParameter("eid", errata.getId().toString());
        
        errata.setChannels(new HashSet());
        
        ActionForward result = action.removePackagesFromErrata(mapping, form, 
                                                               request, response);
        
        assertEquals("success", result.getName());
        assertTrue(RhnSetDecl.PACKAGES_TO_REMOVE.get(user).isEmpty());
        
        Long id = errata.getId();
        flushAndEvict(errata);
        
        Errata e2 = ErrataManager.lookupErrata(id, user);
        assertTrue(e2.getPackages().size() == 1);
    }
}
