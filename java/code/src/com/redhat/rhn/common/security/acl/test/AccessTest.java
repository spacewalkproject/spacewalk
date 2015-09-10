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
package com.redhat.rhn.common.security.acl.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.security.acl.Access;
import com.redhat.rhn.common.security.acl.Acl;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.legacy.UserImpl;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * AccessTest
 */
public class AccessTest extends BaseTestCaseWithUser {

    private Acl acl;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        acl = new Acl();
        acl.registerHandler(new Access());
    }

    public void testAccessNotFoundEntry() {
        Access access = new Access();
        String[] foo = {"FOO"};
        boolean rc = access.aclIs(null, foo);
        assertFalse(rc);
    }

    public void testAccessValidEntry() {
        Config c = Config.get();
        c.setBoolean("test.true", "true");
        c.setBoolean("test.TrUe", "TrUe");
        c.setBoolean("test.one", "1");
        c.setBoolean("test.yes", "y");
        c.setBoolean("test.YES", "Y");
        c.setBoolean("test.on", "on");
        c.setBoolean("test.ON", "ON");

        Access access = new Access();
        String[] foo = new String[1];

        foo[0] = "test.true";
        assertTrue("test.true is false", access.aclIs(null, foo));
        foo[0] = "test.TrUe";
        assertTrue("test.TrUe is false", access.aclIs(null, foo));
        foo[0] = "test.one";
        assertTrue("test.one is false", access.aclIs(null, foo));
        foo[0] = "test.yes";
        assertTrue("test.yes is false", access.aclIs(null, foo));
        foo[0] = "test.YES";
        assertTrue("test.YES is false", access.aclIs(null, foo));
        foo[0] = "test.on";
        assertTrue("test.on is false", access.aclIs(null, foo));
        foo[0] = "test.ON";
        assertTrue("test.ON is false", access.aclIs(null, foo));
    }

    public void testAccessWithInvalidAcl() {
        Map context = new HashMap();
        boolean rc = acl.evalAcl(context, "is(foo)");
        assertFalse(rc);
    }

    public void testAccessWithValidAcl() {
        Config c = Config.get();
        c.setBoolean("test.true", "true");
        c.setBoolean("test.TrUe", "TrUe");
        c.setBoolean("test.one", "1");
        c.setBoolean("test.yes", "y");
        c.setBoolean("test.YES", "Y");
        c.setBoolean("test.on", "on");
        c.setBoolean("test.ON", "ON");

        Map context = new HashMap();

        assertTrue("test.true is false", acl.evalAcl(context, "is(test.true)"));
        assertTrue("test.TrUe is false", acl.evalAcl(context, "is(test.TrUe)"));
        assertTrue("test.one is false", acl.evalAcl(context, "is(test.one)"));
        assertTrue("test.yes is false", acl.evalAcl(context, "is(test.yes)"));
        assertTrue("test.YES is false", acl.evalAcl(context, "is(test.YES)"));
        assertTrue("test.on is false", acl.evalAcl(context, "is(test.on)"));
        assertTrue("test.ON is false", acl.evalAcl(context, "is(test.ON)"));
    }

    public void testForFalse() {
        Config c = Config.get();
        c.setBoolean("test.false", "false");
        c.setBoolean("test.FaLse", "FaLse");
        c.setBoolean("test.zero", "0");
        c.setBoolean("test.no", "n");
        c.setBoolean("test.NO", "N");
        c.setBoolean("test.off", "off");
        c.setBoolean("test.OFF", "OFF");

        Map context = new HashMap();

        assertFalse("test.false is true", acl.evalAcl(context, "is(test.false)"));
        assertFalse("test.FaLse is true", acl.evalAcl(context, "is(test.FaLse)"));
        assertFalse("test.zero is true", acl.evalAcl(context, "is(test.zero)"));
        assertFalse("test.no is true", acl.evalAcl(context, "is(test.no)"));
        assertFalse("test.NO is true", acl.evalAcl(context, "is(test.NO)"));
        assertFalse("test.off is true", acl.evalAcl(context, "is(test.off)"));
        assertFalse("test.OFF is true", acl.evalAcl(context, "is(test.OFF)"));
    }

    public void testUserRoleAcl() {
        Map context = new HashMap();
        User user = new MockUser();
        user.addPermanentRole(RoleFactory.ORG_ADMIN);
        context.put("user", user);
        boolean rc = acl.evalAcl(context, "user_role(org_admin)");
        assertTrue(rc);
    }

    public void testUserCanManageChannelAcl() {
        Map context = new HashMap();
        User user =  UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        user.addPermanentRole(RoleFactory.CHANNEL_ADMIN);
        context.put("user", user);
        boolean rc = acl.evalAcl(context, "user_can_manage_channels()");
        assertTrue(rc);
    }

    public void testUserRoleAclFalse() {
        Map context = new HashMap();
        User user = new MockUser();
        user.addPermanentRole(RoleFactory.ORG_ADMIN);
        context.put("user", user);
        boolean rc = acl.evalAcl(context, "user_role(channel_admin)");
        assertFalse(rc);
    }

    public void testNeedsFirstUser() {
        boolean rc = acl.evalAcl(new HashMap(), "need_first_user()");
        assertFalse(rc);
    }

    public void testSystemFeature() throws Exception {
        Map context = new HashMap();
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        context.put("user", user);
        Server s = ServerFactoryTest.createTestServer(user, false);
        context.put("sid", new String[] {s.getId().toString()});
        boolean rc = acl.evalAcl(context, "system_feature(ftr_kickstart)");
        assertTrue(rc);
        rc = acl.evalAcl(context, "not system_feature(ftr_kickstart)");
        assertFalse(rc);
    }

    public void testAclSystemHasManagementEntitlement() throws Exception {
        Map context = new HashMap();

        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());

        Server s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        context.put("sid", new String[] {s.getId().toString()});
        context.put("user", user);
        assertTrue(acl.evalAcl(context, "system_has_management_entitlement()"));

        s = ServerFactoryTest.createUnentitledTestServer(user, true,
                ServerFactoryTest.TYPE_SERVER_NORMAL, new Date());
        context.put("sid", new String[] {s.getId().toString()});
        assertFalse(acl.evalAcl(context, "system_has_management_entitlement()"));


    }



    public void testUnimplementedMethods() {

        String[] methods = { "user_authenticated()" };

        for (int i = 0; i < methods.length; i++) {
            evalAclAssertFalse(acl, methods[i]);
        }
    }

    public void testGlobalConfigIsGone() {
        Map context = new HashMap();
        try {
            acl.evalAcl(context, "global_config(foo)");
            fail("global_config is back, what moron undid my change!");
        }
        catch (IllegalArgumentException e) {
            // doo nothing
        }
    }

    public void testCanAccessChannel() {
        try {
            Map context = new HashMap();
            User user =  UserTestUtils.findNewUser("testUser",
                    "testOrg" + this.getClass().getSimpleName());
            context.put("user", user);
            user.addPermanentRole(RoleFactory.CHANNEL_ADMIN);

            Channel chan = ChannelFactoryTest.createBaseChannel(user);
            assertTrue(acl.evalAcl(context, "can_access_channel(" + chan.getId() + ")"));
        }
        catch (Exception e) {
            fail("channel validation failed");
        }
    }

    public void testFormvarExists() {
        Map context = new HashMap();
        assertFalse(acl.evalAcl(context, "formvar_exists(cid)"));
        context.put("cid", "161");
        assertTrue(acl.evalAcl(context, "formvar_exists(cid)"));
        assertFalse(acl.evalAcl(context, "formvar_exists(pid)"));
        assertFalse(acl.evalAcl(context, "formvar_exists()"));
    }

    private void evalAclAssertFalse(Acl aclIn, String aclStr) {
        Map context = new HashMap();
        // acl methods must be in the following form
        // aclXxxYyy(Object context, String[] params) and invoked
        // xxx_yyy(param);
        boolean rc = aclIn.evalAcl(context, aclStr);
        assertFalse(rc);
    }

    public void testIsVirtual() throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest = host.getGuests().iterator().next().getGuestSystem();

        Access a = new Access();
        Map ctx = new HashMap();
        ctx.put("sid", guest.getId());
        ctx.put("user", user);
        assertTrue(a.aclSystemIsVirtual(ctx, null));
    }

    /**
     * Override the methods in User that talk to the database
     */
    class MockUser extends UserImpl {
        private final Set mockRoles;

        public MockUser() {
            mockRoles = new HashSet();
        }

        /**
         * This is the key method that needs to be overriden
         * There is a check in User that looks up the Org
         * that isn't necessary for this Unit Test
         */
        @Override
        public void addPermanentRole(Role label) {
            mockRoles.add(label);
        }

        /** @see com.redhat.rhn.domain.user.User#hasRole */
        @Override
        public boolean hasRole(Role label) {
            return mockRoles.contains(label);
        }
    }


}
