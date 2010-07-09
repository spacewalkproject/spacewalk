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
package com.redhat.rhn.frontend.action.rhnpackage.test;

import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.rhnpackage.PackageListSetupAction;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * PackageListSetupTest
 * @version $Rev$
 */
public class PackageListSetupTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        Server server = ServerFactoryTest.createTestServer(user, true);
        PackageManagerTest.addPackageToSystemAndChannel(
                "test-package-name" + TestUtils.randomString(), server,
                ChannelFactoryTest.createTestChannel(user));
        server = (Server)TestUtils.reload(server);
        //.do?sid=1000010000
        setRequestPathInfo("/systems/details/packages/PackageList");
        addRequestParameter("sid", server.getId().toString());
        actionPerform();
        verifyList(PackageListSetupAction.DATA_SET, PackageListItem.class);
    }
}
