/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.errata.AddPackagesConfirmAction;
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
import org.hibernate.Session;

import java.util.List;

/**
 * AddPackagesConfirmActionTest
 * @version $Rev$
 */
public class AddPackagesConfirmActionTest extends RhnBaseTestCase {

    public void testAddPackagesToErrata() throws Exception {
        AddPackagesConfirmAction action = new AddPackagesConfirmAction();
        
        ActionMapping mapping = new ActionMapping();
        ActionForward success = new ActionForward("success", "path", true);
        mapping.addForwardConfig(success);
        
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        
        RhnMockHttpSession session = new RhnMockHttpSession();
        request.setSession(session);
        
        User user = requestContext.getLoggedInUser();
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        
        //add some channels
        Channel c1 = ChannelFactoryTest.createTestChannel();
        Channel c2 = ChannelFactoryTest.createTestChannel();
        errata.addChannel(c1);
        errata.addChannel(c2);
        ErrataManager.storeErrata(errata);
        
        //add some crap to the packages_to_add set for this user
        RhnSet set = RhnSetManager.createSet(user.getId(), "packages_to_add", 
                SetCleanup.NOOP);
        set.addElement(new Long(42));
        set.addElement(new Long(43));
        RhnSetManager.store(set);
        
        request.setupAddParameter("eid", errata.getId().toString());

        ActionForward result = action.addPackagesToErrata(mapping, form, request, response);
        
        assertEquals("success", result.getName());
        assertTrue(RhnSetDecl.PACKAGES_TO_ADD.get(user).isEmpty());
    }
    
    private List lookupTaskList(Org org) throws Exception {
        Session session = HibernateFactory.getSession();
        return session.getNamedQuery("Task.lookupByOrgAndName")
                          .setEntity("org", org)
                          .setString("name", "update_errata_cache_by_channel")
                          .list();
    }
}
