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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.manager.kickstart.ProvisionVirtualInstanceCommand;

import java.util.Date;


/**
 * ProvisionVirtualInstanceCommandTest
 * @version $Rev$
 */
public class ProvisionVirtualInstanceCommandTest extends BaseKickstartCommandTestCase {

    public void testKickstartPackageName() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ProvisionVirtualInstanceCommand cmd = new
            ProvisionVirtualInstanceCommand(server.getId(), this.ksdata.getId(), user,
                    new Date(), "localhost");
        assertEquals(cmd.getKickstartPackageName(), "spacewalk-koan");
    }

}
