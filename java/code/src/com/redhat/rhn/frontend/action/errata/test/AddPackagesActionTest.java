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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.errata.AddPackagesAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * AddPackagesActionTest
 * @version $Rev$
 */
public class AddPackagesActionTest extends RhnBaseTestCase {

    public void testSwitchViews() throws Exception {
        AddPackagesAction action = new AddPackagesAction();
        
        ActionMapping mapping = new ActionMapping();
        ActionForward def = new ActionForward("default", "path", true);
        mapping.addForwardConfig(def);
        
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        
        RequestContext requestContext = new RequestContext(request);
        
        User user = requestContext.getLoggedInUser();
        
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(
                                              UserTestUtils.createOrg("testorg"));
        RhnSet pre = RhnSetDecl.PACKAGES_TO_ADD.get(user);
        //make sure the set is empty
        assertTrue(pre.isEmpty());
        
        request.setupAddParameter("eid", errata.getId().toString());
        request.setupAddParameter("items_on_page", "");
        request.setupAddParameter("items_selected", makeSelection(user));
        request.setupAddParameter("view_channel", "any_channel");
        request.setupAddParameter("lower", "2");
        request.setupAddParameter(RequestContext.FILTER_STRING, "");
        
        
        ActionForward result = action.switchViews(mapping, form, request, response);
        
        RhnSet post = RhnSetDecl.PACKAGES_TO_ADD.get(user);
        //make sure something is in the set
        assertTrue(post.size() > 0);
        //make sure we're going to the default forward
        assertEquals("default", result.getName());
    }

    private String[] makeSelection(User user) throws Exception {
        Package p = PackageTest.createTestPackage();
        p.setOrg(user.getOrg());
        return new String[] {p.getId().toString(), "-1"};
    }
    
    public void testSelectAll() throws Exception {
        AddPackagesAction action = new AddPackagesAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupProcessPagination();
        
        User user = ah.getUser();
        Errata errata = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        
        //Create a channel to put the errata in
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        
        for (int i = 0; i < 4; i++) {
            Package p = PackageTest.createTestPackage(user.getOrg());
            channel.addPackage(p);
        }
        ChannelFactory.save(channel);
        
        ah.getRequest().setupAddParameter("eid", errata.getId().toString());
        ah.getRequest().setupAddParameter("eid", errata.getId().toString()); //stupid mock
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        ah.getRequest().setupAddParameter("returnvisit", "false");
        ah.getRequest().setupAddParameter("view_channel", channel.getId().toString());
        ah.getRequest().setupAddParameter("view_channel", channel.getId().toString());
        ah.getRequest().setupAddParameter(RequestContext.FILTER_STRING, "");
        ah.executeAction("selectall");
        
        RhnSetActionTest.verifyRhnSetData(ah.getUser().getId(),
                "packages_to_add", 4);
    }
}
