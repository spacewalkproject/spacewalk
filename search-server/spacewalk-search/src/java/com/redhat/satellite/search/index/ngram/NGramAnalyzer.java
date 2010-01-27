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

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.LowerCaseFilter;
import org.apache.lucene.analysis.standard.StandardTokenizer;
import org.apache.lucene.analysis.standard.StandardFilter;
import org.apache.lucene.analysis.TokenStream;
// From Lucene Sandbox
import org.apache.lucene.analysis.ngram.NGramTokenFilter;

import java.io.Reader;

/**
 * NGramAnalyzer
 * A ngram will take a term and break it up into a series of smaller
 * permutations of different letter combinations. 
 * @version $Rev$
 */
public class NGramAnalyzer extends Analyzer {
    //Controls minimum size ngram to construct
    protected int min_ngram;
    //Controls maximum size ngram to construct
    protected int max_ngram;
    
  /**
   * Constructor
   * @param min min length of ngram to generate
   * @param max max length of ngram to generate
   */
    public NGramAnalyzer(int min, int max) {
        super();
        min_ngram = min;
        max_ngram = max;
    }
    /**
     * Constructs a pre populated 
     * @param reader contains data to parse
     * @return TokenStream of ngrams
     */
    public TokenStream tokenStream(Reader reader) {
        return tokenStream(null, reader);
    }
    
    /**
     * @param fieldName ignored param
     * @param reader contains data to parse
     * @return TokenStream of ngrams
     */
    public TokenStream tokenStream(String fieldName, Reader reader) {
        return new NGramTokenFilter(
                new LowerCaseFilter(
                    new StandardFilter(
                        new StandardTokenizer(reader))), min_ngram, max_ngram);
    }
}
