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
package com.redhat.rhn.frontend.xmlrpc.serializer.test;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.xmlrpc.serializer.ServerSerializer;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

import java.io.StringWriter;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcSerializer;


public class ServerSerializerTest extends BaseHandlerTestCase {

    public void testSerialize() throws Exception {
        Server server = ServerFactoryTest.createTestServer(admin, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        Writer output = new StringWriter();

        ServerSerializer serializer = new ServerSerializer();
        serializer.serialize(server, output, new XmlRpcSerializer());
        String finalOutput = output.toString();

        assertTrue(finalOutput.indexOf(server.getName()) >= 0);
        assertTrue(finalOutput.indexOf(EntitlementManager.ENTERPRISE_ENTITLED) >= 0);
        assertTrue(finalOutput.indexOf("addon_entitlements") >= 0);
        assertTrue(finalOutput.indexOf("auto_update") >= 0);
        assertTrue(finalOutput.indexOf("description") >= 0);

        assertTrue(finalOutput.indexOf("address1") >= 0);
        assertTrue(finalOutput.indexOf("address2") >= 0);
        assertTrue(finalOutput.indexOf("city") >= 0);
        assertTrue(finalOutput.indexOf("state") >= 0);
        assertTrue(finalOutput.indexOf("country") >= 0);
        assertTrue(finalOutput.indexOf("building") >= 0);
        assertTrue(finalOutput.indexOf("room") >= 0);
        assertTrue(finalOutput.indexOf("rack") >= 0);
        assertTrue(finalOutput.indexOf("lock_status") >= 0);
    }

}
