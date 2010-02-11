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

import com.redhat.satellite.search.index.ngram.NGramAnalyzer;

import org.apache.lucene.analysis.Token;
import org.apache.lucene.analysis.TokenStream;

import org.apache.log4j.Logger;

import java.io.StringReader;

public class NGramAnalyzerTest extends NGramTestSetup {
	
	private static Logger log = Logger.getLogger(NGramAnalyzerTest.class);
	
    public NGramAnalyzerTest() {
        super();
    }
    
    public void testTokenStream() throws Exception {
        NGramAnalyzer nga = new NGramAnalyzer(min_ngram, max_ngram);
        TokenStream ngrams = nga.tokenStream(new StringReader("aspell"));
        Token token;
        String result = new String("");
        while ((token = ngrams.next()) != null) {
            result += new String(token.termBuffer()).trim() + ",";
        }
        log.info("Created a ngram token stream, this is what it looks like: " 
                + result);
        
        assertTrue("testTokenStream", result.compareTo("a,s,p,e,l,l,as,sp,pe," +
                "el,ll,asp,spe,pel,ell,aspe,spel,pell,aspel,spell,") == 0);
        
    }
}
