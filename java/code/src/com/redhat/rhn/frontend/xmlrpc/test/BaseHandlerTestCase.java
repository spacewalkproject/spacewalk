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
package com.redhat.rhn.frontend.xmlrpc.test;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

public class BaseHandlerTestCase extends RhnBaseTestCase {
    /*
     * admin - Org Admin
     * regular - retgular user
     * adminKey/regularKey - session keys for respective users
     */

    protected User admin;
    protected User regular;
    protected String adminKey;
    protected String regularKey;

    public void setUp() throws Exception {
        super.setUp();
        admin = UserTestUtils.createUserInOrgOne();
        admin.addRole(RoleFactory.ORG_ADMIN);
        TestUtils.saveAndFlush(admin);

        regular = UserTestUtils.createUser("testUser2", admin.getOrg().getId());
        regular.removeRole(RoleFactory.ORG_ADMIN);

        assertTrue(admin.hasRole(RoleFactory.ORG_ADMIN));
        assertTrue(!regular.hasRole(RoleFactory.ORG_ADMIN));

        //setup session keys
        adminKey = XmlRpcTestUtils.getSessionKey(admin);
        regularKey = XmlRpcTestUtils.getSessionKey(regular);

        //make sure the test org has the channel admin role
        Org org = admin.getOrg();
        org.addRole(RoleFactory.CHANNEL_ADMIN);
        org.addRole(RoleFactory.SYSTEM_GROUP_ADMIN);
    }

    protected void addRole(User user, Role role) {
        user.getOrg().addRole(role);
        user.addRole(role);
    }
}
