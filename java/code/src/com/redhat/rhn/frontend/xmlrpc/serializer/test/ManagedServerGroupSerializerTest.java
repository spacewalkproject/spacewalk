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
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.frontend.xmlrpc.serializer.ManagedServerGroupSerializer;

import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;

import java.io.StringWriter;
import java.io.Writer;

import redstone.xmlrpc.XmlRpcSerializer;


public class ManagedServerGroupSerializerTest extends MockObjectTestCase {

    private XmlRpcSerializer serializer;

    public void setUp() {
        serializer = new XmlRpcSerializer();
    }

    public void testSerialize() throws Exception {
        ManagedServerGroupSerializer sgs = new ManagedServerGroupSerializer();
        Long id = new Long(10);
        String name = "name";
        String description = "Description";
        Long currentMembers = new Long(20);
        Long orgId = new Long(122);
        Writer output = new StringWriter();
        Mock mockOrg = mock(Org.class);
        mockMethod(mockOrg, "getId", orgId);
        Mock mock = mock(ManagedServerGroup.class);
        mockMethod(mock, "getId", id);
        mockMethod(mock, "getName", name);
        mockMethod(mock, "getDescription", description);
        mockMethod(mock, "getCurrentMembers", currentMembers);
        mockMethod(mock, "getOrg", (Org) mockOrg.proxy());
        ManagedServerGroup sg = (ManagedServerGroup) mock.proxy();

        sgs.serialize(sg, output, serializer);
        String out = output.toString();
        assertExists("name", name, out);
        assertExists("id", id, out);
        assertExists("description", description, out);
        assertExists(ManagedServerGroupSerializer.CURRENT_MEMBERS, currentMembers, out);
        assertExists("org_id", orgId, out);
    }

    /**
     * Quick method to assert a property is property constructed bean
     * @param map the map obtained by mapifying a bean
     * @param name the key name
     * @param value the  value.
     */
    private void assertExists(String name,
                                    Object value,
                                    String beanOut) throws Exception {
        Writer output = new StringWriter();
        serializer.serialize(value, output);

        String nameTag = "<name>" + name + "</name>";
        String valueTag = output.toString();

        String msg = "Cannot find property with tag [" + nameTag + "]" +
                                " in bean [" + beanOut + "]";
        assertTrue(msg, beanOut.indexOf(nameTag) > -1);

        msg = "Cannot find property value with Value-> [" + valueTag + "]" +
                                                   " in bean [" + beanOut + "]";
        assertTrue(msg, beanOut.indexOf(valueTag) > -1);

    }

    private void mockMethod(Mock mock, String method, Object value) {
        mock.expects(once())
            .method(method)
            .withNoArguments()
            .will(returnValue(value));
    }
}
