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
package com.redhat.rhn.frontend.action.rhnpackage.profile.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * @author mmccune
 * 
 */
public class SyncActionsTest extends RhnMockStrutsTestCase {

    public void testSyncSystemsSubmit() throws Exception {
        UserTestUtils.addManagement(user.getOrg());
        Server s1 = ServerFactoryTest.createTestServer(user);
        Server s2 = ServerFactoryTest.createTestServer(user);
        s1.setBaseEntitlement(EntitlementManager.MANAGEMENT);
        s2.setBaseEntitlement(EntitlementManager.MANAGEMENT);
    
        Channel testChannel = ChannelFactoryTest.createTestChannel(user);
        
        Package p1 = PackageManagerTest.addPackageToSystemAndChannel(
                "foo-package" + TestUtils.randomString(), s1, testChannel);

        PackageManagerTest.addPackageToSystemAndChannel(
                "foo-package" + TestUtils.randomString(), s2, testChannel);
        
        RhnSet selected = RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC.get(user); 
        selected.addElement(p1.getPackageName().getId());
        RhnSetManager.store(selected);
        
        addRequestParameter(RequestContext.SID, s1.getId().toString());
        addRequestParameter(RequestContext.SID + "_1", s2.getId().toString());
        addRequestParameter("use_date", Boolean.FALSE.toString());
        setRequestPathInfo("/systems/details/packages/profiles/SyncSystemsSubmit");
        addDispatchCall("schedulesync.jsp.schedulesync");
        actionPerform();
        assertTrue(getActualForward().
                startsWith("/systems/details/packages/profiles/MissingPackages.do"));
    }
}
