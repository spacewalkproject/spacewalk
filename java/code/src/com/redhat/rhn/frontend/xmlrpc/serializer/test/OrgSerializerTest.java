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

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.frontend.xmlrpc.serializer.OrgSerializer;
import com.redhat.rhn.testing.UserTestUtils;

import org.jmock.MockObjectTestCase;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


public class OrgSerializerTest extends MockObjectTestCase {

    public void testSerialize() throws XmlRpcException, IOException {
        OrgSerializer os = new OrgSerializer();


        Org org = UserTestUtils.findNewOrg("foo");

        Writer output = new StringWriter();
        os.serialize(org, output, new XmlRpcSerializer());
        String result = output.toString();
        assertEquals(os.getSupportedClass(), Org.class);
        assertTrue(result.contains("<name>id</name>"));
        assertTrue(result.contains(">" + org.getId() + "<"));
        assertTrue(result.contains("name>name</name"));
        assertTrue(result.contains(">" + org.getName() + "<"));
    }
}
