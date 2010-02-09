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

import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.PackageMetadata;
import com.redhat.rhn.frontend.xmlrpc.serializer.BigDecimalSerializer;
import com.redhat.rhn.frontend.xmlrpc.serializer.PackageMetadataSerializer;

import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;

import junit.framework.TestCase;
import redstone.xmlrpc.XmlRpcException;
import redstone.xmlrpc.XmlRpcSerializer;


public class PackageMetadataSerializerTest extends TestCase {
    private XmlRpcSerializer builtin;
    
    public void setUp() {
        builtin = new XmlRpcSerializer();
        builtin.addCustomSerializer(new BigDecimalSerializer());
    }
    public void testSerialize() throws XmlRpcException, IOException {
        
        PackageMetadataSerializer os = new PackageMetadataSerializer();
        
        // Configure the list item for this system:
        PackageListItem systemListItem = new PackageListItem();
        systemListItem.setEvr("2.2.23-5.3.el4");
        systemListItem.setName("fakepkg");
        systemListItem.setNameId(new Long(10));
        
        // Configure the list item for the other system:
        PackageListItem otherListItem = new PackageListItem();
        otherListItem.setEvr("2.2.25-5");
        
        // Configure package metadata:
        PackageMetadata pkgData = new PackageMetadata(systemListItem, otherListItem);
        pkgData.setComparison(4);
        
        Writer output = new StringWriter();
        os.serialize(pkgData, output, builtin);
        String result = output.toString();

        assertEquals(os.getSupportedClass(), PackageMetadata.class);
        
        assertTrue(result.contains("<name>package_name_id</name>"));
        assertTrue(result.contains("<name>package_name</name>"));
        assertTrue(result.contains("<name>this_system</name>"));
        assertTrue(result.contains("<name>other_system</name>"));
        assertTrue(result.contains("<name>comparison</name>"));

        assertTrue(result.contains("<i4>10</i4>"));
        assertTrue(result.contains("<string>fakepkg</string>"));
        assertTrue(result.contains("<string>2.2.23-5.3.el4</string>"));
        assertTrue(result.contains("<string>2.2.25-5</string>"));
        assertTrue(result.contains("<i4>4</i4>"));
    }
}
