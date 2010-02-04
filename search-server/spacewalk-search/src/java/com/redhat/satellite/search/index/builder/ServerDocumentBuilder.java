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
 * ServerDocumentBuilder
 * @version $Rev$
 */
public class ServerDocumentBuilder implements DocumentBuilder {

    /**
     * {@inheritDoc}
     */
    public Document buildDocument(Long objId, Map<String, String> metadata) {
        Document doc = new Document();
        // Keep 'id' UN_TOKENIZED, this is needed to determine 'uniqueness'
        // if you tokenize this it will break deleting documents, we'll
        // no longer have unique documents per id.

        doc.add(new Field("id", objId.toString(), Field.Store.YES,
                Field.Index.UN_TOKENIZED));
        // This is the tokenized form of 'id' so we can do searches on it and
        // use ngram flexibility
        doc.add(new Field("system_id", objId.toString(), Field.Store.YES,
                Field.Index.TOKENIZED));

        for (Iterator<String> iter = metadata.keySet().iterator(); iter.hasNext();) {
            Field.Store store = Field.Store.YES;
            Field.Index tokenize = Field.Index.TOKENIZED;

            String name = iter.next();
            String value = metadata.get(name);

            if (name.equals("name") || name.equals("cpuModel") ||
                    name.equals("hostname") || name.equals("ipaddr") ||
                    (name.equals("runningKernel"))) {
                store = Field.Store.YES;
            }
            else if (name.equals("checkin") || name.equals("registered") ||
                    name.equals("ram") || name.equals("swap") ||
                    name.equals("cpuMhz") | name.equals("cpuNumberOfCpus")) {
                store = Field.Store.YES;
                tokenize = Field.Index.UN_TOKENIZED;
            }

            doc.add(new Field(name, String.valueOf(value), store,
                    tokenize));
        }
        return doc;
    }

}
