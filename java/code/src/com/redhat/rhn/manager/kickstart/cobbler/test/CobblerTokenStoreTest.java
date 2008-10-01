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
package com.redhat.rhn.manager.kickstart.cobbler.test;

import com.redhat.rhn.manager.kickstart.cobbler.CobblerTokenStore;
import com.redhat.rhn.testing.TestUtils;

import junit.framework.TestCase;

public class CobblerTokenStoreTest extends TestCase {

    public void testLookupToken() {
        String login = "admin";
        assertNull(CobblerTokenStore.get().getToken(login));
        CobblerTokenStore.get().setToken(login, TestUtils.randomString());
        assertNotNull(CobblerTokenStore.get().getToken(login));
    }

}
