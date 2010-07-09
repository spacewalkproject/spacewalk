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
package com.redhat.rhn.manager.system.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ProductName;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.manager.system.UpdateBaseChannelCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.HashSet;
import java.util.Set;


/**
 * UpdateBaseChannelCommandTest
 * @version $Rev$
 */
public class UpdateBaseChannelCommandTest extends BaseTestCaseWithUser {
    public void testChannelPreservation() throws Exception {
        ProductName pn = ChannelFactoryTest.createProductName();
        Channel parent = ChannelFactoryTest.createBaseChannel(user);
        Channel child = ChannelFactoryTest.createTestChannel(user);

        child.setParentChannel(parent);
        child.setProductName(pn);

        TestUtils.saveAndFlush(child);
        TestUtils.saveAndFlush(parent);

        Channel parent1 = ChannelFactoryTest.createBaseChannel(user);
        Channel child1 = ChannelFactoryTest.createTestChannel(user);

        child1.setParentChannel(parent1);
        child1.setProductName(pn);

        TestUtils.saveAndFlush(child1);
        TestUtils.saveAndFlush(parent1);

        Server s = ServerFactoryTest.createTestServer(user, true,
                    ServerConstants.getServerGroupTypeEnterpriseEntitled());

        s.addChannel(parent);
        s.addChannel(child);
        ServerFactory.save(s);
        TestUtils.flushAndEvict(s);
        TestUtils.flushAndEvict(parent1);
        TestUtils.flushAndEvict(child1);
        TestUtils.flushAndEvict(parent);
        TestUtils.flushAndEvict(child);

        s = (Server) TestUtils.reload(s);

        Set <Channel> channels = new HashSet<Channel>();
        channels.add(parent);
        channels.add(child);
        assertEquals(channels, s.getChannels());

        UpdateBaseChannelCommand cmd = new UpdateBaseChannelCommand(user,
                                                            s, parent1.getId());
        cmd.store();

        channels.clear();
        channels.add(parent1);
        channels.add(child1);
        TestUtils.flushAndEvict(s);
        s = (Server) TestUtils.reload(s);
        assertEquals(channels, s.getChannels());
    }
}
