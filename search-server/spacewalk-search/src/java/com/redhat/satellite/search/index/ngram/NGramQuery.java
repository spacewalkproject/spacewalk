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


package com.redhat.satellite.search.index.ngram;

import org.apache.lucene.analysis.Token;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.BooleanClause;
import org.apache.lucene.index.Term;

import java.io.IOException;
import java.io.StringReader;

/**
 * NGramQuery
 * A custom BooleanQuery, it takes each ngram-token and adds as an OR term.
 * @version $Rev$
 */
public class NGramQuery extends BooleanQuery {

   private static final long serialVersionUID = 1L;
   
   /**
     * Constructor
     * @param field name of the field 
     * @param queryTerms String containing a term or a series of terms to search.
     * The string will be parsed and will be broken up into a series of NGrams.
     * @throws IOException something went wrong parsing queryTerms
     * */
    public NGramQuery(String field, String queryTerms, int min, int max) 
        throws IOException {
        NGramAnalyzer nga = new NGramAnalyzer(min, max);
        TokenStream ngrams = nga.tokenStream(new StringReader(queryTerms));
        Token token;
        while ((token = ngrams.next()) != null) {
            Term t = new Term(field, new String(token.termBuffer()).trim());
            add(new TermQuery(t), BooleanClause.Occur.SHOULD);
        }
    }

    /**
     * 
     * @param pq PhraseQuery to break up and convert to NGramQuery
     * Forms a BooleanQuery with each term in the original PhraseQuery OR'd.
     * Note:  Assumes that each term has already been tokenized into a ngram, 
     * this method will not re-tokenize terms.
     * @param useMust controls if BooleanClause.Occur SHOULD or MUST is used.
     */
    public NGramQuery(PhraseQuery pq, boolean useMust) {
        Term[] terms = pq.getTerms();
        for (int i = 0; i < terms.length; i++) {
            BooleanClause.Occur occur = BooleanClause.Occur.SHOULD;
            if (useMust) {
                occur = BooleanClause.Occur.MUST;
            }
            add(new TermQuery(terms[i]), occur);
        }
    }

}
