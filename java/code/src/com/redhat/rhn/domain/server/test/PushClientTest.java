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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.domain.server.PushClient;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

/**
 * PushClientTest
 * @version $Rev$
 */
public class PushClientTest extends RhnBaseTestCase {

    public static final String JABBER_ID = "Test Jabber Id";
    public static final String CLIENT_NAME = "Test Client Name";
    public static final String SHARED_KEY = "Test shared key";

    /**
     * Simple test to exercise codepaths in PushClient class
     * @throws Exception
     */
    public void testPushClient() throws Exception {
        PushClient pc1 = createTestPushClient();
        PushClient pc2 = new PushClient();

        assertFalse(pc1.equals(pc2));
        assertFalse(pc1.equals(new Date()));
    }

    /**
     * Helper method to create a test PushClient object
     * @throws Exception
     */
    public PushClient createTestPushClient() throws Exception {
        PushClient pc = new PushClient();
        pc.setJabberId(JABBER_ID);
        pc.setName(CLIENT_NAME);
        pc.setSharedKey(SHARED_KEY);
        pc.setNextActionTime(new Date());
        pc.setLastMessageTime(new Date());
        pc.setLastPingTime(new Date());

        User user = UserTestUtils.createUser("testuser",
                UserTestUtils.createOrg("testorg"));
        Server s = ServerFactoryTest.createTestServer(user,
                                                    true,
                                                    ServerConstants.
                                                    getServerGroupTypeEnterpriseEntitled(),
                                                    ServerFactoryTest.
                                                    TYPE_SERVER_SATELLITE);

        pc.setServer(s);
        return pc;
    }
}
