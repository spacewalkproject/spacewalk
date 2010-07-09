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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.server.Network;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.util.Date;

/**
 * NetworkTest
 * @version $Rev$
 */
public class NetworkTest extends RhnBaseTestCase {

    public static final String HOSTNAME = "foo.bar.com";
    public static final String IP_ADDRESS = "192.168.0.101";

    /**
     * Creates a dummy instance of a network object
     * @return network instance
     */
    public static Network createNetworkInstance() {
        Network net = new Network();
        net.setHostname(HOSTNAME);
        net.setIpaddr(IP_ADDRESS);
        return net;
    }

    /**
     * Simple test to exercise the code paths in the Network class
     * @throws Exception
     */
    public void testNetwork() throws Exception {
        Network net1 = createTestNetwork();
        Network net2 = new Network();

        assertFalse(net1.equals(net2));
        assertFalse(net1.equals(new Date()));

        Session session = HibernateFactory.getSession();
        net2 = (Network) session.getNamedQuery("Network.findById")
                                      .setLong("id", net1.getId().longValue())
                                      .uniqueResult();
        assertEquals(net1, net2);
    }

    /**
     * Helper method to create a test Network object
     * @return Returns a test Network object
     * @throws Exception
     */
    public static Network createTestNetwork() throws Exception {
        Network net = createNetworkInstance();
        User user = UserTestUtils.createUser("testuser",
                                             UserTestUtils.createOrg("testorg"));
        Server s = ServerFactoryTest.createTestServer(user);
        net.setServer(s);

        assertNull(net.getId());
        TestUtils.saveAndFlush(net);
        assertNotNull(net.getId());

        return net;
    }
}
