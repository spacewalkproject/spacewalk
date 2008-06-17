/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.rhnpackage.PackageListSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.Action;

/**
 * PackageListSetupTest
 * @version $Rev$
 */
public class PackageListSetupTest extends RhnBaseTestCase {
    private Action action = null;
    
    public void setUp() {
        action = new PackageListSetupAction();
    }

    public void testExecute() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        // Use the User created by the Helper
        User user = sah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true);
        PackageManagerTest.addPackageToSystemAndChannel(
                "test-package-name" + TestUtils.randomString(), server, 
                ChannelFactoryTest.createTestChannel(user));
        server = (Server) reload(server);
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("sid", server.getId().toString());
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.executeAction();
        
        
        RhnMockHttpServletRequest request = sah.getRequest();
        RequestContext requestContext = new RequestContext(request);
        user = requestContext.getLoggedInUser();
        RhnSet set = (RhnSet) request.getAttribute("set");
        
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertNotNull(set);
        assertEquals("removable_package_list", set.getLabel());
    }
}
