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

import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


import com.redhat.satellite.search.index.ngram.NGramAnalyzer;

import org.apache.log4j.Logger;
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
    private static Logger log = Logger.getLogger(NGramTestSetup.class);

    protected RAMDirectory ngramDir;
    protected RAMDirectory stanDir;
    
    protected double score_threshold = .10;
    protected int min_ngram = 1;
    protected int max_ngram = 5;

    protected List<Map<String,String>> items =
        new LinkedList<Map<String, String>>();

    public NGramTestSetup() {
        super();
    }

    protected void addItem(String name, String description, String filename) {
        Map<String, String> item = new HashMap<String, String>();
        item.put("name", name);
        item.put("description", description);
        item.put("filename", filename);
        items.add(item);
    }

    protected void initItems() {
        addItem("spellingbee", "spelling application", "spellingbee-1.0.rpm");
        addItem("aspelling", "another spelling program alternate spell",
                "aspelling-1.0.rpm");
        addItem("aspell", "another spelling program", "aspell-0.3.4.rpm");
        addItem("spell", "spelling program", "spell-4943.rpm");
        addItem("slelp", "application with spelling error", "slelp1-43.rpm");
        addItem("libvirt", "virtualization library", "virt-pkg-1.rpm");
        addItem("virt-manager", "blah blah application", "virt-pkg-1.rpm");
        addItem("virtualfactory", "virtual factory something",
                "virtfact-04.rpm");
        addItem("newFactory", "factory test application", "newFactory-1.9.rpm");
        addItem("gtk+-devel", "development library for gtk",
                "gtk+-devel-10.rpm");
        addItem("gtk+", "runtime library", "gtk+-30.rpm");
        addItem("gtk-doc", "documentation for gtk", "gtk-doc-393.rpm");
        addItem("authconfig-gtk", "authentication related gtk",
                "authconfig-gtk-039.rpm");
        addItem("mtr-gtk", "blah blah mtr gtk", "mtr-gtk-039.rpm");
        addItem("ghostscript-gtk", "printting support application gtk",
                "ghostscript-gtk-30.rpm");
        addItem("gnome-bluetooth-libs", "library for bluetooth support",
                "gnome-bluetooth-libs-3.4.rpm");
        addItem("scim-bridge-gtk", "blah blah scim gtk",
                "scim-bridge-gtk-494.rpm");
        addItem("kernel", "linux kernel package", "kernel-094.rpm");
        addItem("kernel-hugemem", "This package includes an SMP version of " +
                "the Linux kernel which supports systems with 16 Gigabytes " +
                "of memory or more.", "kernel-hugemem-2.6.9-84.EL.i686");
        addItem("kernel-hugemem-devel", "This package provides kernel " +
                "headers +and makefiles sufficient to build modules against " +
                "the hugemem kernel package.",
                "kernel-hugemem-devel-2.6.9-84.EL.i686");
    }
    /**
     * Creates an index in RAM
     * */
    public void setUp() throws Exception {
        super.setUp();
        initItems();
        this.stanDir = new RAMDirectory();
        IndexWriter stanWriter = new IndexWriter(this.stanDir, new StandardAnalyzer(), true);

        this.ngramDir = new RAMDirectory();
        IndexWriter ngramWriter = new IndexWriter(this.ngramDir, new NGramAnalyzer(min_ngram, max_ngram), true);

        for (Map<String, String> item: items) {
            String name = item.get("name");
            String descp = item.get("description");
            Document doc = new Document();
            doc.add(new Field("name", name, Field.Store.YES, Field.Index.TOKENIZED));
            doc.add(new Field("description", descp, Field.Store.YES,
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

    protected int thresholdHits(Hits hits) throws IOException {
        /** We could consider doing thresholding as a relative thing...
         * instead of checking against an absolute value, we grab top score
         * then filter based on difference from that...
         */
        int counter = 0;
        for (int i=0; i < hits.length(); i++) {
            if (hits.score(i) >= score_threshold) {
                counter++;
            }
            else {
                break;
            }
        }
        return counter;
    }

    protected void displayHits(Hits hits) throws IOException {
        for (int i = 0; i < hits.length(); i++) {
            Document doc = hits.doc(i);
            String name = doc.get("name");
            String description = doc.get("description");
            log.info("Hit<" + i + "> Score< " + hits.score(i) + ">  name = <" +
                    name + "> description = <" + description + ">");
        }
    }


}
