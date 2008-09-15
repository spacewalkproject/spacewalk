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
package com.redhat.satellite.search.index.ngram;

import org.apache.lucene.search.Query;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.analysis.Analyzer;

import org.apache.log4j.Logger;

/**
 * NGramQueryParser
 * Creates a custom query parser of ngram-tokenized search terms
 * 
 * @version $Rev$
 */
public class NGramQueryParser extends QueryParser {
    
    private static Logger log = Logger.getLogger(NGramQueryParser.class);
    
    /**
     * Constructor
     * @param f field name
     * @param a analyzer
     */
    public NGramQueryParser(String f, Analyzer a) {
        super(f, a);
    }
   
    protected Query getFieldQuery(String defaultField, 
            String queryText) throws ParseException {
        Query orig = super.getFieldQuery(defaultField, queryText);
        if (!(orig instanceof PhraseQuery)) {
            log.debug("Returning default query.  No phrase query translation.");
            return orig;
        }
        /**
         * A ngram when parsed will become a series of smaller search terms, 
         * these terms are grouped together into a PhraseQuery.  We are taking 
         * that PhraseQuery and breaking out each ngram term then combining all 
         * ngrams together to form a BooleanQuery.
         */
        PhraseQuery pq = (PhraseQuery)orig;
        return new NGramQuery(pq);
    }
}
