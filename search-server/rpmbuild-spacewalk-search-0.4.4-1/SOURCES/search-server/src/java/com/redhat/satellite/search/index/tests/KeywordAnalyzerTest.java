package com.redhat.satellite.search.index.tests;

import com.redhat.satellite.search.index.KeywordAnalyzer;

import org.apache.lucene.analysis.TokenStream;

import junit.framework.TestCase;

import java.io.StringReader;

public class KeywordAnalyzerTest extends TestCase {

    public void processString(String originalValue) throws Exception {
        KeywordAnalyzer ka = new KeywordAnalyzer();
        StringReader sr = new StringReader(originalValue);
        TokenStream ts = ka.tokenStream("ignoredField", sr);
        assertTrue("Text Should be Untouched", new String(ts.next().termBuffer()).trim().
        		compareTo(originalValue) == 0);
        assertTrue("Token should be null", ts.next() == null);
    }
    public void testBasicParse() throws Exception {
        processString("i386");
        processString("bx-gh-3&^0-993$#@!%^&*()-=+_><?/.,';:[]}{)");
        processString("j839,.     43    ..,.-=-=`1~!@#");
    }
}
