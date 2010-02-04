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
package com.redhat.satellite.search.index;

import java.io.Reader;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.CharTokenizer;



/**
 * KeywordAnalyzer
 * Used to retain all characters associated with a search term.  Basically
 * use this if you don't want the search term to be tokenized.
 *  
 * @version $Rev$
 */
public class KeywordAnalyzer extends Analyzer {
    /**
     * Will return the exact test passed in.
     *@param fieldName ignored value
     *@param reader Reader containing data to parse
     *@return TokenStream which contains exact text passed in.
     */
    @Override
    public TokenStream tokenStream(String fieldName, Reader reader) {
       return new CharTokenizer(reader) {
           protected boolean isTokenChar(char c) {
               return true;
           }
       };
    }

}
