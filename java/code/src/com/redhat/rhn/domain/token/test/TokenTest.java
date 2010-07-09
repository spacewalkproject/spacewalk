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
package com.redhat.rhn.domain.token.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelListProcessor;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.token.TokenFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.util.ArrayList;
import java.util.List;

/**
 * TokenTest
 * @version $Rev$
 */
public class TokenTest extends RhnBaseTestCase {

    /**
     * Simple test to check Token creation and the equals method.
     * @throws Exception
     */
    public void testEquals() throws Exception {
        Token token1 = createTestToken();
        Token token2 = new Token();

        assertFalse(token1.equals(token2));

        Session session = HibernateFactory.getSession();
        token2 = (Token) session.getNamedQuery("Token.findById")
                                   .setLong("id", token1.getId().longValue())
                                   .uniqueResult();

        assertEquals(token1, token2);
        assertFalse(token1.isTokenDisabled());
        token1.disable();
        assertTrue(token1.isTokenDisabled());
        assertEquals(2, token1.getEntitlements().size());
        assertEquals(token1.getEntitlements().size(), token2.getEntitlements().size());
    }

    public void testLookupByServer() throws Exception {
        Token t = createTestToken();
        Server s = t.getServer();
        flushAndEvict(t);
        assertNotNull(TokenFactory.lookupByServer(s));
    }

    public void testRemoveToken() throws Exception {
        Token t = createTestToken();
        Long id = t.getId();
        TokenFactory.removeToken(t);
        flushAndEvict(t);
        assertNull(TokenFactory.lookupById(id));
    }

    public void testChannel() throws Exception {
        Token t = createTestToken();
        Channel c = ChannelFactoryTest.createTestChannel(t.getCreator());
        t.addChannel(c);
        TokenFactory.save(t);
        t = (Token) reload(t);
        assertNotNull(t.getChannels());
        assertEquals(1, t.getChannels().size());

    }

    public void testConfigChannels() throws Exception {
        Token t = createTestToken();
        User user = UserTestUtils.createUser("testuser1", t.getOrg().getId());
        UserTestUtils.addProvisioning(user.getOrg());
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);

        // Create a global channel
        ConfigChannel global1 = ConfigTestUtils.createConfigChannel(user.getOrg(),
                ConfigChannelType.global());
        ConfigChannel global2 = ConfigTestUtils.createConfigChannel(user.getOrg(),
                ConfigChannelType.global());

        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();

        proc.add(t.getConfigChannelsFor(user), global1);
        proc.add(t.getConfigChannelsFor(user), global2);

        TokenFactory.save(t);
        List ls = new ArrayList();
        ls.add(global1);
        ls.add(global2);

        t = (Token) reload(t);
        assertNotNull(t.getConfigChannelsFor(user));
        assertEquals(2, t.getConfigChannelsFor(user).size());
        assertEquals(ls, t.getConfigChannelsFor(user));
    }

    /**
     * Helper method to create a test Token
     * @return Returns a Token
     * @throws Exception
     */
    public static Token createTestToken() throws Exception {
        Token token = new Token();
        token.enable();
        token.setDeployConfigs(true);
        token.setNote("RHN-JAVA test note");
        token.setUsageLimit(new Long(42));
        User user = UserTestUtils.createUser("testuser",
                                             UserTestUtils.createOrg("testorg"));
        token.setCreator(user);
        token.setOrg(user.getOrg());
        token.setServer(ServerFactoryTest.createTestServer(user));

        token.addEntitlement(ServerConstants.getServerGroupTypeEnterpriseEntitled());
        token.addEntitlement(ServerConstants.getServerGroupTypeProvisioningEntitled());

        assertNull(token.getId());
        TestUtils.saveAndFlush(token);
        assertNotNull(token.getId());

        return token;
    }
}
