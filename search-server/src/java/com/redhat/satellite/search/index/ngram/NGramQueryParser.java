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

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.lucene.search.ConstantScoreRangeQuery;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.PhraseQuery;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.document.DateTools;
import org.apache.lucene.document.NumberTools;

import org.apache.log4j.Logger;

/**
 * NGramQueryParser
 * Creates a custom query parser of ngram-tokenized search terms
 * 
 * @version $Rev$
 */
public class NGramQueryParser extends QueryParser {
    
    private static Logger log = Logger.getLogger(NGramQueryParser.class);
    private boolean useMust = false;
    /**
     * Constructor
     * @param f field name
     * @param a analyzer
     * @param useMustIn boolean option set to true when doing a Free Form or
     * advanced search, it will force each NGramQuery to be constructed using
     * the BooleanClause.Occur.MUST.  This narrows returned search results and
     * is not recommended for regular searches which want spelling variances
     * to be tolerated.
     */
    public NGramQueryParser(String f, Analyzer a, boolean useMustIn) {
        super(f, a);
        this.setDateResolution(DateTools.Resolution.DAY);
        this.useMust = useMustIn;
    }
    
    /**
     * Constructor
     * @param f field name
     * @param a analyzer
     */
    public NGramQueryParser(String f, Analyzer a) {
        super(f, a);
        this.setDateResolution(DateTools.Resolution.DAY);
    }

    /**
     *
     * @return value for useMust
     */
    public boolean getUseMust() {
        return useMust;
    }

    /**
     *
     * @param value for useMust
     */
    public void setUseMust(boolean value) {
        useMust = value;
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
        return new NGramQuery(pq, useMust);
    }
    
    /**
     *
     * @param field
     * @return return   true if this looks to be a date string
     *                  false if this is not a date string
     */
    protected boolean isDate(String field) {
        if (field.length() == 12) {
            return true;
        }
        return false;
    }
    /** 
     * This will look to see if "part1" or "part2" are strings of all digits,
     * if they are, then they will be converted to a lexicographically safe string 
     * representation, then passed into the inherited getRangeQuery().  This is needed when
     * comparing something like "4" to be less than "10". 
     * If the strings don't fit the pattern of all digits, then they get passed through
     * to the inherited getRangeQuery().
     */
    protected Query getRangeQuery(String field,
            String part1,
            String part2,
            boolean inclusive) throws ParseException {
        if (isDate(part1) && isDate(part2)) {
            if (log.isDebugEnabled()) {
                log.debug("Detected passed in terms are dates, creating " +
                    "ConstantScoreRangeQuery(" + field + ", " + part1 + ", " +
                    part2 + ", " + inclusive + ", " + inclusive);
            }
            return new ConstantScoreRangeQuery(field, part1, part2, inclusive,
                    inclusive);
        }
        String newPart1 = part1;
        String newPart2 = part2;
        String regEx = "(\\d)*";
        Pattern pattern = Pattern.compile(regEx);
        Matcher matcher1 = pattern.matcher(part1);
        Matcher matcher2 = pattern.matcher(part2);
        if (matcher1.matches() && matcher2.matches()) {
            newPart1 = NumberTools.longToString(Long.parseLong(part1));
            newPart2 = NumberTools.longToString(Long.parseLong(part2));
            if (log.isDebugEnabled()) {
                log.debug("NGramQueryParser.getRangeQuery() Converted " + part1 + " to " +
                    newPart1 + ", Converted " + part2 + " to " + newPart2);
            }
        } 
        return super.getRangeQuery(field, newPart1, newPart2, inclusive);
    }
}
