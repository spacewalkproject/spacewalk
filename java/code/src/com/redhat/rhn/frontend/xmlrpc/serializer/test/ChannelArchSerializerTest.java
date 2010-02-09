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

import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.frontend.xmlrpc.serializer.ChannelArchSerializer;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;

import junit.framework.TestCase;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


public class ChannelArchSerializerTest extends TestCase {

    public void testSerialize() throws XmlRpcException, IOException {
        ChannelArchSerializer cas = new ChannelArchSerializer();
        ChannelArch ca = new ChannelArch();
        ca.setName("name");
        ca.setLabel("label");
        Writer output = new StringWriter();
        cas.serialize(ca, output, new XmlRpcSerializer());
        String actual = output.toString();
        assertTrue(actual.contains("<name>name</name>"));
        assertTrue(actual.contains("<name>label</name>"));
        assertTrue(actual.contains("<string>name</string>"));
        assertTrue(actual.contains("<string>label</string>"));
    }
}
