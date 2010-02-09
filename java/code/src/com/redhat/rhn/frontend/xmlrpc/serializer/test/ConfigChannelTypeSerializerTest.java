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

import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.frontend.xmlrpc.serializer.ConfigChannelTypeSerializer;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;

import junit.framework.TestCase;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * ConfigChannelTypeSerializer
 * @version $Rev$
 */
public class ConfigChannelTypeSerializerTest  extends TestCase {
    public void testSerialize() throws XmlRpcException, IOException {
        ConfigChannelTypeSerializer ccts = new ConfigChannelTypeSerializer();
        
        Writer output = new StringWriter();
        
        ConfigChannelType normal = ConfigChannelType.global();
        ccts.serialize(normal, output, new XmlRpcSerializer());
        String expected = "<struct><member><name>id</name>" +
                          "<value><i4>" + normal.getId() + "</i4></value></member>\n" +
                        "<member><name>label</name><value><string>" + normal.getLabel() +
                         "</string></value></member>\n<member><name>name" + 
                         "</name><value><string>" + normal.getName() +
                         "</string></value></member>\n<member><name>priority</name>" +
                         "<value><i4>" + normal.getPriority() + "</i4></value>" +
                         "</member>\n</struct>\n";
        assertEquals(expected, output.toString());
    }

}
