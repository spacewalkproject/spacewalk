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
package com.redhat.rhn.frontend.xmlrpc.proxy.test;

import com.redhat.rhn.common.client.ClientCertificate;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.proxy.ProxyHandler;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

public class ProxyHandlerTest extends RhnBaseTestCase {


    public void testDeactivateProxyWithReload() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestProxyServer(user, true);
        assertTrue(server.isProxy());
        server = SystemManager.deactivateProxy(server);
        assertFalse(server.isProxy());
    }

    public void testActivateProxy() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        UserTestUtils.addProvisioning(user.getOrg());
        ProxyHandler ph = new ProxyHandler();

        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled(),
                ServerFactoryTest.TYPE_SERVER_NORMAL);

        SystemManager.entitleServer(server, EntitlementManager.PROVISIONING);


        ClientCertificate cert = SystemManager.createClientCertificate(server);
        cert.validate(server.getSecret());

        int rc = ph.activateProxy(cert.toString(), "5.0");
        assertEquals(1, rc);


    }

    public void testDeactivateProxy() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled(),
                ServerFactoryTest.TYPE_SERVER_PROXY);

        // TODO: need to actually create a valid proxy server, the
        // above doesn't come close to creating a REAL server.

        ClientCertificate cert = SystemManager.createClientCertificate(server);
        cert.validate(server.getSecret());

        ProxyHandler ph = new ProxyHandler();
        int rc = ph.deactivateProxy(cert.toString());
        assertEquals(1, rc);
    }

    public void aTestWithExistingProxy() throws Exception {
        Server server = ServerFactory.lookupById(new Long(1005012107));
        ClientCertificate cert = SystemManager.createClientCertificate(server);
        cert.validate(server.getSecret());
        ProxyHandler ph = new ProxyHandler();
        int rc = ph.deactivateProxy(cert.toString());
        assertEquals(1, rc);
    }

    public void testLameTest() {
        assertNotNull(new ProxyHandler());
    }
}
