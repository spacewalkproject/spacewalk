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

import com.redhat.rhn.domain.user.RhnTimeZone;
import com.redhat.rhn.frontend.xmlrpc.serializer.RhnTimeZoneSerializer;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;

import junit.framework.TestCase;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;

/**
 * RhnTimeZoneSerializerTest
 * @version $Rev$
 */
public class RhnTimeZoneSerializerTest extends TestCase {

    private RhnTimeZoneSerializer serializer;

    public void setUp() {
        serializer = new RhnTimeZoneSerializer();
    }

    public void testGetSupportedClass() {
        assertEquals(RhnTimeZone.class, serializer.getSupportedClass());
    }

    public void testSerialize() throws XmlRpcException, IOException {
        RhnTimeZone tz = new RhnTimeZone();
        tz.setOlsonName("(GMT-0500) United States (Indiana)");
        tz.setTimeZoneId(7010);
        Writer output = new StringWriter();
        serializer.serialize(tz, output, new XmlRpcSerializer());

        assertEquals("<struct><member><name>time_zone_id</name>" +
                "<value><i4>7010</i4></value></member>\n" +
                "<member><name>olson_name</name><value>" +
                "<string>(GMT-0500) United States (Indiana)</string>" +
                "</value></member>\n</struct>\n",
                output.toString());
    }
}
