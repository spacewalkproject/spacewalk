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

import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.token.ActivationKeyManager;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.NonUniqueObjectException;

import java.util.List;

/**
 * ActivationKeyTest
 * @version $Rev$
 */
public class ActivationKeyTest extends BaseTestCaseWithUser {
    public void setUp() throws Exception {
        super.setUp();
        user.addRole(RoleFactory.ORG_ADMIN);
    }
    public void testKeyGeneration() throws Exception {

        ActivationKey k = createTestActivationKey(user);
        String note = k.getNote();
        String key = k.getKey();

        TestUtils.saveAndFlush(k);

        ActivationKey k2 = ActivationKeyFactory.lookupByKey(key);
        assertEquals(key, k2.getKey());
        assertEquals(note, k2.getNote());

        ActivationKey k3 = ActivationKeyFactory.lookupByKey(TestUtils.randomString());
        assertNull(k3);

        // Make sure we got the entitlements correct
        Server server = k2.getServer();
        assertEquals(1, server.getEntitlements().size());
        assertEquals(1, k2.getEntitlements().size());

        Entitlement e = (Entitlement) server.getEntitlements().iterator().next();
        ServerGroupType t2 = (ServerGroupType) k2.getEntitlements().iterator().next();
        assertEquals(e.getLabel(), t2.getLabel());

        // test out ActivationKeyManager.findByServer while we're here...
        ActivationKey k4 = (ActivationKey) ActivationKeyManager.
            getInstance().findByServer(server, user).iterator().next();
        assertNotNull(k4);
        assertEquals(key, k4.getKey());


        try {
            k3 = (ActivationKey) ActivationKeyManager.getInstance().
                findByServer(null, user).iterator().next();
            String msg = "Permission check failed :(.." +
                            " Activation key should not have existed" +
                            " for a server of 'null' id. An exception " +
                             "should have been raised for this.";
            fail(msg);
        }
        catch (Exception ie) {
         // great!.. Exception for passing in invalid keys always welcome
        }

        User user1 = UserTestUtils.findNewUser("testuser", "testorg");
        Server server2 = ServerFactoryTest.createTestServer(user1);
        try {
            k3 = (ActivationKey) ActivationKeyManager.getInstance().
                findByServer(server2, user1).iterator().next();
            String msg = "Permission check failed :(.." +
                            " Activation key should not have existed" +
                                " for a server of the associated id. An exception " +
                                "should have been raised for this.";
            fail(msg);
        }
        catch (Exception ie) {
            // great!.. Exception for passing in invalid keys always welcome
        }
     }
    public void testBadKeys()  throws Exception {
        ActivationKeyManager manager = ActivationKeyManager.getInstance();
        try {
            manager.createNewActivationKey(user, "A,B", "Cool", null, null, false);
            fail("Validator exception Not raised for an invalid name");
        }
        catch (ValidatorException ve) {
            //success . Name had invalid chars
        }
    }

    public void testKeyTrimming()  throws Exception  {
        ActivationKeyManager manager = ActivationKeyManager.getInstance();
        String keyName = " Test Space  ";
        ActivationKey k = manager.createNewActivationKey
            (user, keyName, "Cool Duplicate", null, null, false);
        assertEquals(ActivationKey.makePrefix(user.getOrg()) +
                keyName.trim().replace(" ", ""), k.getKey());
        String newKey = keyName + " FOO  ";
        manager.changeKey(newKey , k, user);
        assertNotNull(ActivationKey.makePrefix(user.getOrg()) + newKey.trim());
    }

    public void testLookupBySession() throws Exception {
        // Still have that weird error creating a test server
        // sometimes in hosted.
        ActivationKey k = createTestActivationKey(user);
        KickstartData ksdata = KickstartDataTest.
            createKickstartWithOptions(k.getOrg());
        KickstartFactory.saveKickstartData(ksdata);
        KickstartSession sess = KickstartSessionTest.createKickstartSession(ksdata,
                                                    k.getCreator());
        KickstartFactory.saveKickstartSession(sess);
        k.setKickstartSession(sess);
        ActivationKeyFactory.save(k);
        k = (ActivationKey) reload(k);

        ActivationKey lookedUp = ActivationKeyFactory.lookupByKickstartSession(sess);
        assertNotNull(lookedUp);
    }

    public void testNullServer() throws Exception {
        ActivationKey key = ActivationKeyFactory.createNewKey(user,
                TestUtils.randomString());
        assertNotNull(key.getEntitlements());
        assertTrue(key.getEntitlements().size() == 1);
    }

    // See BZ: 191007
    public void testCreateWithCustomGroups() throws Exception {
        Server s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ServerGroup testGroup = ServerGroupTestUtils.createManaged(user);
        s.getManagedGroups().add((ManagedServerGroup)testGroup);

        //Three, one for the server entitlement, one for the user permission to the
        //server, one as the testGroup.
        assertEquals(1, s.getManagedGroups().size());
        ActivationKey key = createTestActivationKey(user, s);
        assertNotNull(key);
        key = (ActivationKey) reload(key);
        assertNotNull(key.getId());
    }

    public void testAddGetKeys() throws Exception {

        ActivationKey k = createTestActivationKey(user);

        for (int i = 0; i < 5; i++) {
            Channel c = ChannelFactoryTest.
                createTestChannel(user);
            k.addChannel(c);
        }
        assertTrue(k.getChannels().size() == 5);
    }

    public void testLookupByServer() throws Exception {
        ActivationKey k = createTestActivationKey(user);
        Server s = k.getServer();
        createTestActivationKey(user, s);
        createTestActivationKey(user, s);
        createTestActivationKey(user, s);
        List keys = ActivationKeyFactory.lookupByServer(s);
        assertTrue(keys.size() == 4);
    }

    public void testCreateNewKeys() throws Exception {
        ActivationKey k = createTestActivationKey(user);
        Server s = k.getServer();
        for (int i = 0; i < 10; i++) {
            ActivationKey tk = createTestActivationKey(s.getCreator(), s);
            System.out.println("tk: " + tk.getKey());
        }
    }

    public static ActivationKey createTestActivationKey(User user) throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());

        return createTestActivationKey(user, server);
    }

    public static ActivationKey createTestActivationKey(User u, Server s) {

        String note = "" + TestUtils.randomString() +
                      " -- Java unit test activation key.";

        ActivationKey key = ActivationKeyManager.getInstance().
                                            createNewReActivationKey(u, s, note);
        ActivationKeyFactory.save(key);
        return key;
    }

    public void testDuplicateKeyCreation() throws Exception {
        String keyName = "Hey!";
        ActivationKeyManager.getInstance().createNewActivationKey
                (user, keyName, null, null, null, false);
        try {
            ActivationKeyManager.getInstance().createNewActivationKey
                                (user, keyName, "Cool Duplicate", null, null, false);
            String msg = "Duplicate Key exception not raised..";
            fail(msg);
        }
        catch (NonUniqueObjectException e) {
            //sweet duplicate object exception
        }
    }
}
