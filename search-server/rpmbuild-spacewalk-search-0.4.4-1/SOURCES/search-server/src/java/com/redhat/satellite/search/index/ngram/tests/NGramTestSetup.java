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

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.Hits;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.RAMDirectory;

import junit.framework.TestCase;


public class NGramTestSetup extends TestCase {

    protected RAMDirectory ngramDir;
    protected RAMDirectory stanDir;
    
    protected int min_ngram = 1;
    protected int max_ngram = 4;

    static protected String[] names = {"aspell", "aspell-1.0", "libvirt", 
        "virt-manager", "virtualfactory", "xemacs", "spellingpackage",
        "gtk+-devel", "gtk+", "gtk-doc", "authconfig-gtk", "mtr-gtk", 
        "ghostscript-gtk", "gnome-bluetooth-libs", "scim-bridge-gtk"};

    public NGramTestSetup() {
        super();
    }

    /**
     * Creates an index in RAM
     * */
    public void setUp() throws Exception {
        super.setUp();
        this.stanDir = new RAMDirectory();
        IndexWriter stanWriter = new IndexWriter(this.stanDir, new StandardAnalyzer(), true);

        this.ngramDir = new RAMDirectory();
        IndexWriter ngramWriter = new IndexWriter(this.ngramDir, new NGramAnalyzer(min_ngram, max_ngram), true);

        for (int i = 0; i < names.length; i++) {
            Document doc = new Document();
            doc.add(new Field("name", String.valueOf(names[i]), Field.Store.YES,
                        Field.Index.TOKENIZED));
            stanWriter.addDocument(doc);
            ngramWriter.addDocument(doc);
        }
        stanWriter.close();
        ngramWriter.close();
    }

    public Hits performSearch(Directory dir, Analyzer alyz, String query) throws Exception {
        QueryParser parser = new QueryParser("name", alyz);
        IndexSearcher searcher = new IndexSearcher(dir);
        Query q = parser.parse(query);
        Hits hits = searcher.search(q);
        return hits;
    }


}
