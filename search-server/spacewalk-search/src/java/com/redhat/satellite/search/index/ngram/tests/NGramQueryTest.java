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

import com.redhat.satellite.search.index.ngram.NGramQuery;

import org.apache.lucene.search.Query;

import org.apache.log4j.Logger;

public class NGramQueryTest extends NGramTestSetup {
	
	private static Logger log = Logger.getLogger(NGramQueryTest.class);
    
    public NGramQueryTest() {
        super();
    }

    public void testCreateQuery() throws Exception {
        String term = "spell";
        Query q = new NGramQuery("name", term, min_ngram, max_ngram);
        log.info("NGramQuery("+term+") = " + q.toString());
        assertTrue(q != null);
    }

    public void testCreateQueryMinMax() throws Exception {
        String term = "spell";
        Query q = new NGramQuery("name", term, min_ngram, max_ngram);
        log.info("NGramQuery("+term+") = " + q.toString());
        assertTrue(q.toString().compareTo("name:s name:p name:e name:l " +
        		"name:l name:sp name:pe name:el name:ll name:spe name:pel " +
			"name:ell name:spel name:pell name:spell") == 0);
    }
}
