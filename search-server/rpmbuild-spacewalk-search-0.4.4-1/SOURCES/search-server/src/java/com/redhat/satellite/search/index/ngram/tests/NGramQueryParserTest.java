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
package com.redhat.satellite.search.index.ngram.tests;

import com.redhat.satellite.search.index.ngram.NGramAnalyzer;
import com.redhat.satellite.search.index.ngram.NGramQueryParser;

import org.apache.log4j.Logger;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.BooleanQuery;
import org.apache.lucene.search.Hits;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.store.Directory;

public class NGramQueryParserTest extends NGramTestSetup {
    
	private static Logger log = Logger.getLogger(NGramQueryParserTest.class);
	
    public NGramQueryParserTest() {
        super();
    }

    public void testBasicQueryParse() throws Exception {
        String defaultField = new String("name");
        NGramQueryParser parser = new NGramQueryParser(defaultField, new NGramAnalyzer(min_ngram, max_ngram));
        String txt = new String("spell");
        Query q = parser.parse(txt);
        log.info("testBasicQueryParse() query = " + q.toString());
        assertTrue(q.toString().compareTo("name:s name:p name:e name:l name:l " +
                "name:sp name:pe name:el name:ll name:spe name:pel name:ell " +
                "name:spel name:pell") == 0);
    }

    /**
     * We want to make sure that when searching for multiple terms, each term will become it's
     * own BooleanQuery.
     * */
    public void testMultiPhraseQueryParse() throws Exception {
        String defaultField = new String("name");
        NGramQueryParser parser = new NGramQueryParser(defaultField, new NGramAnalyzer(min_ngram, max_ngram));
        String txt = new String("spell* virt manager");
        Query q = parser.parse(txt);
        assertTrue(q instanceof BooleanQuery);
        BooleanQuery bq = (BooleanQuery)q;
        assertTrue(bq.getClauses().length == 3);
    }

    public void testWildcardQueryParse() throws Exception {
        NGramQueryParser parser = new NGramQueryParser("name", new NGramAnalyzer(min_ngram, max_ngram));
        String txt = new String("spell*");
        Query q = parser.parse(txt);
        log.info("Wildcard query = " + q.toString());
        assertTrue(q.toString().compareTo("name:spell*") == 0);
    }

    public void testQueryParseWithSpecialChars() throws Exception {
        String queryString = new String("spell* virt- manager+");
        log.info("testQueryParserWithSpecialChars(): query string is: " + queryString);
        NGramQueryParser parser = new NGramQueryParser("name", new NGramAnalyzer(min_ngram, max_ngram));
        Query q = parser.parse(queryString);
        log.info("Using NGramQueryParser query = " + q.toString());

        QueryParser origParser = new QueryParser("name", new StandardAnalyzer());
        q = origParser.parse(queryString);
        log.info("Using QueryParser query = " + q.toString());
    }

    public Hits performSearch(Directory dir, String query) throws Exception {
        NGramQueryParser parser = new NGramQueryParser("name", new NGramAnalyzer(min_ngram, max_ngram));
        IndexSearcher searcher = new IndexSearcher(dir);
        Query q = parser.parse(query);
        Hits hits = searcher.search(q);
        log.info("Query = " + q.toString());
        log.info("Hits.length() = " + hits.length());
        for (int i=0; i < hits.length(); i++) {
            log.debug("Document<"+hits.id(i)+"> = " + hits.doc(i));
            //Explanation explain = searcher.explain(q, hits.id(i));
            //log.debug("explain = " + explain.toString());
        }
        return hits;
    }
    

    /**
     * 
     * */
    public void testBasicSearch() throws Exception {
        Hits hits;
        String query;
        query = "spell";
        hits = performSearch(this.ngramDir, query);
        assertTrue(hits.length() > 0);
        
        query = "aspell";
        hits = performSearch(this.ngramDir, query);
        assertTrue(hits.length() > 0);
        
        query = "pel";
        hits = performSearch(this.ngramDir, query);
        assertTrue(hits.length() > 0);
        
        query = "gtk";
        hits = performSearch(this.ngramDir, query);
        assertTrue(hits.length() > 0);
    }
}
