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
package com.redhat.rhn.frontend.xmlrpc.serializer.util.test;

import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.StringWriter;
import java.io.Writer;

import junit.framework.TestCase;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * SimpleSerializerTest
 * @version $Rev$
 */
public class SerializerHelperTest extends TestCase {
    
    public void testSerialize() throws Exception {
        SerializerHelper sl = new SerializerHelper(new XmlRpcSerializer());
        sl.add("foo", new Long(12));
        sl.add("bar", "barValue");
        String expected = "<struct><member><name>foo</name><value><i4>12</i4>" +
                  "</value></member>\n<member><name>bar</name><value><string>" +
                  "barValue</string></value></member>\n</struct>\n";
        Writer actual = new StringWriter();
        sl.writeTo(actual);
        assertEquals(expected, actual.toString());
        sl.clear();
        actual = new StringWriter();
        sl.writeTo(actual);
        assertEquals("<struct></struct>\n", actual.toString());
    }
}
