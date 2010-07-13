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
package com.redhat.rhn.frontend.xmlrpc.channel.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.xmlrpc.channel.ChannelHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * ChannelHandlerTest
 * @version $Rev$
 */
public class ChannelHandlerTest extends BaseHandlerTestCase {

    private final ChannelHandler handler = new ChannelHandler();

    public void testListSoftwareChannels() throws Exception {

        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        Object[] result = handler.listSoftwareChannels(adminKey);
        assertNotNull(result);
        assertTrue(result.length > 0);

        for (int i = 0; i < result.length; i++) {
            Map item = (Map) result[i];
            Set keys = item.keySet();
            for (Iterator itr = keys.iterator(); itr.hasNext();) {
                Object key = itr.next();
                // make sure we don't send out null
                assertNotNull(item.get(key));
            }
        }
    }

    public void testListAllChannels() throws Exception {
        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        // execute
        Object[] result = handler.listAllChannels(adminKey);

        // verify
        assertNotNull(result);
        assertTrue(result.length > 0);

        boolean foundChannel = false;
        for (int i = 0; i < result.length; i++) {
            ChannelTreeNode item = (ChannelTreeNode) result[i];
            if (item.getName() != null) {
                if (item.getName().equals(channel.getName())) {
                    foundChannel = true;
                    break;
                }
            }
        }
        assertTrue(foundChannel);
    }

    public void testListPopularChannels() throws Exception {
        // setup
        Server server = ServerFactoryTest.createTestServer(admin, true);

        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        channel.setParentChannel(null);  // base channel
        SystemManager.subscribeServerToChannel(admin, server, channel);

        // execute
        Object[] result = handler.listPopularChannels(adminKey, 1);

        // verify
        assertNotNull(result);
        assertTrue(result.length > 0);

        boolean foundChannel = false;
        for (int i = 0; i < result.length; i++) {
            ChannelTreeNode item = (ChannelTreeNode) result[i];
            if (item.getName() != null) {
                if (item.getName().equals(channel.getName())) {
                    foundChannel = true;
                    break;
                }
            }
        }
        assertTrue(foundChannel);

        // execute
        result = handler.listPopularChannels(adminKey, 50000);

        // verify
        assertNotNull(result);
        assertEquals(0, result.length);
    }

    public void testListMyChannels() throws Exception {
        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        // execute
        Object[] result = handler.listMyChannels(adminKey);

        // verify
        assertNotNull(result);
        assertTrue(result.length > 0);

        boolean foundChannel = false;
        for (int i = 0; i < result.length; i++) {
            ChannelTreeNode item = (ChannelTreeNode) result[i];
            if (item.getName() != null) {
                if (item.getName().equals(channel.getName())) {
                    foundChannel = true;
                    break;
                }
            }
        }
        assertTrue(foundChannel);
    }

    public void testListSharedChannels() throws Exception {
        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);

        Org org2 = createOrg();
        Org org3 = createOrg();
        org2.addTrust(admin.getOrg());
        org3.addTrust(admin.getOrg());
        channel.getTrustedOrgs().add(org2);
        channel.getTrustedOrgs().add(org3);
        channel.setAccess(Channel.PUBLIC);

        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        // execute
        Object[] result = handler.listSharedChannels(adminKey);

        // verify
        assertNotNull(result);
        assertTrue(result.length > 0);
        boolean foundChannel = false;
        for (int i = 0; i < result.length; i++) {
            ChannelTreeNode item = (ChannelTreeNode) result[i];
            if (item.getName() != null) {
                if (item.getName().equals(channel.getName())) {
                    foundChannel = true;
                    break;
                }
            }
        }
        assertTrue(foundChannel);
    }

    public void testListRetiredChannels() throws Exception {
        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        Date date = new Date();
        date.setTime(0); // Initialize date to Jan 1, 1970 00:00:00
        channel.setEndOfLife(date);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        // execute
        Object[] result = handler.listRetiredChannels(adminKey);

        // verify
        assertNotNull(result);
        assertTrue(result.length > 0);

        boolean foundChannel = false;
        for (int i = 0; i < result.length; i++) {
            ChannelTreeNode item = (ChannelTreeNode) result[i];
            if (item.getName() != null) {
                if (item.getName().equals(channel.getName())) {
                    foundChannel = true;
                    break;
                }
            }
        }
        assertTrue(foundChannel);
    }

    private Org createOrg() throws Exception {
        TestUtils.randomString();
        Org org = OrgFactory.createOrg();
        org.setName("org created by OrgFactory test: " + TestUtils.randomString());
        org = OrgFactory.save(org);
        assertTrue(org.getId().longValue() > 0);
        return org;
    }
}
