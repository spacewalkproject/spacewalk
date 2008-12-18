/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import java.util.Map;


/**
 * DocumentBuilder
 * @version $Rev$
 */
public interface DocumentBuilder {
    /**
     * Builds a Lucene Document using the given object id and metadata map.
     * The document will contain an "id" field with the value of the object id,
     * and fields corresponding to the keys of the metadata and their values.
     * @param objId Object id
     * @param metadata key:value pairs describing the object.
     * @return Lucene Document for indexing.
     */
    Document buildDocument(Long objId, Map<String, String> metadata);
}
