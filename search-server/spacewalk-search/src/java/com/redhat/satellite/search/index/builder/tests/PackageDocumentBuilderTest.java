/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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
package com.redhat.satellite.search.index.builder.tests;

import com.redhat.satellite.search.index.builder.BuilderFactory;
import com.redhat.satellite.search.index.builder.DocumentBuilder;
import com.redhat.satellite.search.index.builder.PackageDocumentBuilder;

import org.apache.lucene.document.Document;

import java.util.HashMap;
import java.util.Map;

import junit.framework.TestCase;


/**
 * PackageDocumentBuilderTest
 * @version $Rev$
 */
public class PackageDocumentBuilderTest extends TestCase {

    public void testBuildDocument() {
        Map<String, String> metadata = new HashMap<String, String>();
        metadata.put("name", "Name");
        metadata.put("version", "PrettyVersion");
        metadata.put("filename", "FileName");
        metadata.put("description", "Description");
        metadata.put("summary", "Summary");
        metadata.put("arch", "Arch");
        
        DocumentBuilder db = BuilderFactory.getBuilder(BuilderFactory.PACKAGES_TYPE);
        assertTrue(db instanceof PackageDocumentBuilder);
        Document doc = db.buildDocument(new Long(10), metadata);
        
        assertNotNull(doc);
        assertEquals(doc.getField("id").stringValue(), new Long(10).toString());
        assertEquals(doc.getField("name").stringValue(), "Name");
        assertEquals(doc.getField("version").stringValue(), "PrettyVersion");
        assertEquals(doc.getField("filename").stringValue(), "FileName");
        assertEquals(doc.getField("description").stringValue(), "Description");
        assertEquals(doc.getField("summary").stringValue(), "Summary");
        assertEquals(doc.getField("arch").stringValue(), "Arch");
    }
}
