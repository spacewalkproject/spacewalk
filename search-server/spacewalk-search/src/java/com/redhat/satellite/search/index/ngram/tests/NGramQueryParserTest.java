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
package com.redhat.satellite.search.index.ngram.tests;

import java.io.IOException;

import com.redhat.satellite.search.index.ngram.NGramAnalyzer;
import com.redhat.satellite.search.index.ngram.NGramQueryParser;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
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
                "name:spel name:pell name:spell") == 0);
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

    public Hits performSearch(Directory dir, String query, boolean useMust)
        throws Exception {

        NGramQueryParser parser = new NGramQueryParser("name",
                new NGramAnalyzer(min_ngram, max_ngram), useMust);
        IndexSearcher searcher = new IndexSearcher(dir);
        Query q = parser.parse(query);
        Hits hits = searcher.search(q);
        log.info("Original Query = " + query);
        log.info("Parsed Query = " + q.toString());
        log.info("Hits.length() = " + hits.length());
        for (int i=0; i < hits.length(); i++) {
            log.debug("Document<"+hits.id(i)+"> = " + hits.doc(i));
            //Explanation explain = searcher.explain(q, hits.id(i));
            //log.debug("explain = " + explain.toString());
        }
        return hits;
    }
    
    public void testFreeFormQueryParse() throws Exception {
        String queryString = new String("name:spell -description:another");
        log.info("Original query: "  + queryString);

        NGramQueryParser parser = new NGramQueryParser("name",
                new NGramAnalyzer(min_ngram, max_ngram), true);
        Query q = parser.parse(queryString);
        log.info("NGramQueryParser parsed query:  " + q.toString());

        QueryParser origParser = new QueryParser("name", new StandardAnalyzer());
        q = origParser.parse(queryString);
        log.info("QueryParser parsed query = " + q.toString());
    }



    public void testFreeFormSearch() throws Exception {
        Hits hits = null;
        String query = null;
        boolean useMust = true;
        // Grab all packages with name "spell" AND
        //  description does NOT contain "another"
        query = "name:spell -description:another";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(hits.length() == 2);

        // Grab all packages with name "virt" AND
        //  description MUST have "factory" in it
        query = "name:virt +description:factory";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(hits.length() == 2);

        // Grab all packages with name "virt"
        query = "name:virt description:factory";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(hits.length() == 4);

        query = "name:virt OR description:factory";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(hits.length() == 4);

        query = "name:virt AND description:factory";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(hits.length() == 1);

        query = "name:virt -description:factory";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(hits.length() == 2);
    }
    /**
     * 
     * */
    public void testBasicSearch() throws Exception {
        Hits hits;
        String query;
        boolean useMust = false;
        query = "spell";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(thresholdHits(hits) == 5);
        assertTrue(hits.length() == 16);

        query = "aspelll";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(thresholdHits(hits) == 4);
        assertTrue(hits.length() == 17);
        
        query = "aspell";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(thresholdHits(hits) == 4);
        assertTrue(hits.length() == 17);
        
        query = "pel";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(thresholdHits(hits) == 8);
        assertTrue(hits.length() == 16);
        
        query = "gtk";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(thresholdHits(hits) == 7);
        assertTrue(hits.length() == 17);


        // We want a search for kernel-hugemem to return kernel-hugemem as top hit
        //   but currently, kernel-hugemem-devel is matchin instead.  This test
        //   is a placeholder as we explore ways to fix this.
        query = "((name:kernel-hugemem)^2 (description:kernel-hugemem) " +
            "(filename:kernel-hugemem))";
        hits = performSearch(this.ngramDir, query, useMust);
        displayHits(hits);
        assertTrue(thresholdHits(hits) == 3);
        assertTrue(hits.length() == 20);
        String firstHitName = hits.doc(0).get("name");
        assertTrue(firstHitName.compareToIgnoreCase("kernel-hugemem-devel") == 0);
    }
}
