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
package com.redhat.rhn.frontend.integration.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.integration.IntegrationService;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;


/**
 * @author mmccune
 *
 */
public class IntegrationServiceTest extends BaseTestCaseWithUser {

    public void testLogin() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        user = (User) reload(user);
        commitAndCloseSession();
        IntegrationService.get().authorize(user.getLogin(), "passoword");
        assertNull(IntegrationService.get().
                getAuthToken(TestUtils.randomString()));
        assertNotNull(IntegrationService.get().
                getAuthToken(user.getLogin()));
    }
}
