/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.manager.org.test;

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * OrgManagerTest
 */
public class OrgManagerTest extends RhnBaseTestCase {

    /**
     * TestOrgsInsat
     * @throws Exception if error
     */
    public void testOrgsInSat() throws Exception {

        User user = UserTestUtils.findNewUser("test-morg", "testorg-foo", true);
        Org o = user.getOrg();
        // add satellite_admin since its not one of the implied roles
        o.addRole(RoleFactory.SAT_ADMIN);
        user.addPermanentRole(RoleFactory.SAT_ADMIN);
        UserFactory.save(user);

        UserTestUtils.addManagement(o);
        UserTestUtils.addVirtualization(o);

        DataList orgs = OrgManager.activeOrgs(user);
        assertNotNull(orgs);
        assertTrue(orgs.size() > 0);
    }
}
