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
package com.redhat.satellite.search.index.builder;

import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;

import java.util.Iterator;
import java.util.Map;


/**
 * ServerCustomInfoDocumentBuilder
 * @version $Rev$
 */
public class ServerCustomInfoDocumentBuilder implements DocumentBuilder {

    /**
     * {@inheritDoc}
     */
    public Document buildDocument(Long objId, Map<String, String> metadata) {
        Document doc = new Document();
        doc.add(new Field("id", objId.toString(), Field.Store.YES,
                Field.Index.UN_TOKENIZED));

        for (Iterator<String> iter = metadata.keySet().iterator(); iter.hasNext();) {
            Field.Store store = Field.Store.YES;
            Field.Index tokenize = Field.Index.TOKENIZED;

            String name = iter.next();
            String value = metadata.get(name);

            if (name.equals("value")) {
                store = Field.Store.YES;
            }
            else if (name.equals("created") || (name.equals("modified"))) {
                store = Field.Store.YES;
                tokenize = Field.Index.UN_TOKENIZED;
            }
            else if (name.equals("serverId") || name.equals("createdBy") ||
                    name.equals("lastModifiedBy")) {
                store = Field.Store.YES;
                tokenize = Field.Index.UN_TOKENIZED;
            }

            doc.add(new Field(name, String.valueOf(value), store,
                    tokenize));
        }
        return doc;
    }

}
