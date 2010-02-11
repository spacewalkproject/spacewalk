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
import com.redhat.satellite.search.index.builder.ErrataDocumentBuilder;

import org.apache.lucene.document.Document;

import java.util.HashMap;
import java.util.Map;

import junit.framework.TestCase;


/**
 * ErrataDocumentBuilderTest
 * @version $Rev$
 */
public class ErrataDocumentBuilderTest extends TestCase {

    public void testBuildDocument() {
        Map<String,String> metadata = new HashMap<String,String>();
        metadata.put("id", new Long(10).toString());
        metadata.put("advisory", "Advisory");
        metadata.put("advisoryType", "AdvisoryType");
        metadata.put("advisoryName", "AdvisoryName");
        metadata.put("advisoryRel", new Long(100).toString());
        metadata.put("product", "Product");
        metadata.put("description", "Description");
        metadata.put("synopsis", "Synopsis");
        metadata.put("topic", "Topic");
        metadata.put("solution", "Solution");
        metadata.put("issueDate", "IssueDate");
        metadata.put("updateDate", "UpdateDate");
        metadata.put("notes", "Notes");
        metadata.put("orgId", "OrgId");
        metadata.put("created", "Created");
        metadata.put("modified", "Modified");
        metadata.put("lastModified", "LastModified");
        metadata.put("severityId", new Long(1).toString());
        metadata.put("name", "Advisory");
        
        DocumentBuilder db = BuilderFactory.getBuilder(BuilderFactory.ERRATA_TYPE);
        assertTrue(db instanceof ErrataDocumentBuilder);
        Document doc = db.buildDocument(new Long(10), metadata);

        assertNotNull(doc);
        assertEquals(doc.getField("id").stringValue(), new Long(10).toString());
        assertEquals(doc.getField("advisory").stringValue(), "Advisory");
        assertEquals(doc.getField("advisoryType").stringValue(), "AdvisoryType");
        assertEquals(doc.getField("advisoryName").stringValue(), "AdvisoryName");
        assertEquals(doc.getField("advisoryRel").stringValue(), new Long(100).toString());
        assertEquals(doc.getField("product").stringValue(), "Product");
        assertEquals(doc.getField("description").stringValue(), "Description");
        assertEquals(doc.getField("synopsis").stringValue(), "Synopsis");
        assertEquals(doc.getField("topic").stringValue(), "Topic");
        assertEquals(doc.getField("solution").stringValue(), "Solution");
        assertEquals(doc.getField("issueDate").stringValue(), "IssueDate");
        assertEquals(doc.getField("updateDate").stringValue(), "UpdateDate");
        assertEquals(doc.getField("notes").stringValue(), "Notes");
        assertEquals(doc.getField("orgId").stringValue(), "OrgId");
        assertEquals(doc.getField("created").stringValue(), "Created");
        assertEquals(doc.getField("modified").stringValue(), "Modified");
        assertEquals(doc.getField("lastModified").stringValue(), "LastModified");
        assertEquals(doc.getField("severityId").stringValue(), new Long(1).toString());
        assertEquals(doc.getField("name").stringValue(), "Advisory");
    }
}
