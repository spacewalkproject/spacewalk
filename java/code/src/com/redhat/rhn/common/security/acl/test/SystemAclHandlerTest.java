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
package com.redhat.rhn.common.security.acl.test;

import com.redhat.rhn.common.security.acl.SystemAclHandler;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ServerTestUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * SystemAclHandlerTest
 * @version $Rev$
 */
public class SystemAclHandlerTest extends BaseTestCaseWithUser {
    private Server srvr;
    
    public void setUp() throws Exception {
        super.setUp();
        srvr = ServerFactoryTest.createTestServer(user);
        Long version = new Long(1);
        SystemManagerTest.giveCapability(srvr.getId(),
                SystemManager.CAP_CONFIGFILES_BASE64_ENC, version);
    }

    public void testClientCapable() {
        SystemAclHandler sah = new SystemAclHandler();

        Map ctx = new HashMap();
        ctx.put("sid", srvr.getId());

        String[] params = { SystemManager.CAP_CONFIGFILES_BASE64_ENC };
        boolean rc = sah.aclClientCapable(ctx, params);
        assertTrue(rc);
        
        String[] params1 = { "" };
        rc = sah.aclClientCapable(ctx, params1);
        assertFalse(rc);
        
        rc = sah.aclClientCapable(ctx, null);
        assertFalse(rc);
    }

    public void testSystemHasKickstartSession() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        SystemAclHandler sah = new SystemAclHandler();
        Map ctx = new HashMap();
        ctx.put("sid", srvr.getId());
        assertFalse(sah.aclSystemKickstartSessionExists(ctx, null));
        
        // Test positive
        KickstartData k = KickstartDataTest.createTestKickstartData(user.getOrg());
        KickstartSession sess = KickstartSessionTest.createKickstartSession(k, user);
        ctx.put("sid", sess.getOldServer().getId());
        // TestUtils.saveAndFlush(sess);
        KickstartFactory.saveKickstartSession(sess);
        flushAndEvict(sess);
        assertTrue(sah.aclSystemKickstartSessionExists(ctx, null));
    }
    
    public void testIsVirtual() throws Exception {
        Server host = ServerTestUtils.createVirtHostWithGuests(user, 1);
        Server guest = ((VirtualInstance) host.getGuests().iterator().next()).
            getGuestSystem();
        
        SystemAclHandler sah = new SystemAclHandler();
        Map ctx = new HashMap();
        ctx.put("sid", guest.getId());
        ctx.put("user", user);
        assertTrue(sah.aclSystemIsVirtual(ctx, null));
    }
    
}
