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
package com.redhat.rhn.domain.org.test;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;


/**
 * MultiOrgTest
 * @version $Rev$
 */
public class MultiOrgTest extends RhnBaseTestCase {

    public void testAddMultiOrg() throws Exception {
        User user = UserTestUtils.findNewUser("test-morg", "testorg-morg", true);

        Org o = user.getOrg();
        UserTestUtils.addManagement(o);
        UserTestUtils.addProvisioning(o);
        UserTestUtils.addVirtualization(o);
        // Check to make sure we get an org greater than 1.
        assertTrue(o.getId().longValue() > 1);
    }

    public void testInitialOrgRoles() throws Exception {

    }

}
