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
package com.redhat.rhn.frontend.action.rhnpackage.profile.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.rhnpackage.profile.SyncSystemsProfilesAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Set;

/**
 * @author mmccune
 * 
 */
public class SyncActionsTest extends RhnMockStrutsTestCase {

    public void testSyncSystemsSubmit() throws Exception {

        UserTestUtils.addManagement(user.getOrg());

        Channel testChannel = ChannelFactoryTest.createTestChannel(user);
        Channel testChannel2 = ChannelFactoryTest.createTestChannel(user);

        Package p1 = PackageTest.createTestPackage(user.getOrg());
        Package p2 = PackageTest.createTestPackage(user.getOrg());
        Package p3 = PackageTest.createTestPackage(user.getOrg());

        testChannel.addPackage(p1);
        testChannel.addPackage(p2);
        testChannel2.addPackage(p3);
        ChannelFactory.save(testChannel);
        ChannelFactory.save(testChannel2);

        Server s1 = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        Server s2 = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());

        s1.addChannel(testChannel);
        s2.addChannel(testChannel);
        s2.addChannel(testChannel2);

        PackageManagerTest.associateSystemToPackageWithArch(s1, p1);
        PackageManagerTest.associateSystemToPackageWithArch(s2, p2);
        PackageManagerTest.associateSystemToPackageWithArch(s2, p3);

        ServerFactory.save(s1);
        ServerFactory.save(s2);

        // This call has an embedded transaction in the stored procedure:
        // lookup_transaction_package(:operation, :n, :e, :v, :r, :a)
        // which can cause deadlocks.  We are forced commit the transaction
        // and close the session.
        HibernateFactory.commitTransaction();
        HibernateFactory.closeSession();
        
        SyncSystemsProfilesAction action = new SyncSystemsProfilesAction();
        Set<String> sessionSet = SessionSetHelper.lookupAndBind(getRequest(), 
                action.getDecl(s1.getId()));
        
        StringBuilder idCombo = new StringBuilder();
        idCombo.append(p3.getPackageName().getId()).append("|");
        idCombo.append(p3.getPackageEvr().getId()).append("|");
        idCombo.append(p3.getPackageArch().getId());
        sessionSet.add(idCombo.toString());
        
        addRequestParameter(RequestContext.SID, s1.getId().toString());
        addRequestParameter(RequestContext.SID + "_1", s2.getId().toString());
        addRequestParameter("use_date", Boolean.FALSE.toString());
        setRequestPathInfo("/systems/details/packages/profiles/SyncSystemsSubmit");

        addDispatchCall("schedulesync.jsp.schedulesync");

        actionPerform();
        
        // we compared s1 to s2; however, s2 has a package (p3) on a channel (testchannel2)
        // that s1 does not have access to; therefore, we expect to go to the
        // MissingPackages...
        assertTrue(getActualForward().
                startsWith("/systems/details/packages/profiles/MissingPackages.do"));
    }
}
