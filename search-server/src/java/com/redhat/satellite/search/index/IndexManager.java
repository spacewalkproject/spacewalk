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

package com.redhat.satellite.search.index;

import com.redhat.satellite.search.config.Configuration;
import com.redhat.satellite.search.index.ngram.NGramAnalyzer;
import com.redhat.satellite.search.index.ngram.NGramQueryParser;

import org.apache.log4j.Logger;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.CorruptIndexException;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.Term;
import org.apache.lucene.queryParser.ParseException;
import org.apache.lucene.queryParser.QueryParser;
import org.apache.lucene.search.Hits;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.LockObtainFailedException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Indexing workhorse class
 * 
 * @version $Rev$
 */
public class IndexManager {
    
    private static Logger log = Logger.getLogger(IndexManager.class);
    private String indexWorkDir;
    private int maxHits;
    private double score_threshold;
    private int min_ngram;
    private int max_ngram;
    public static final String DOCS_INDEX_NAME = "docs";
  
    
    /**
     * Constructor
     * 
     * @param config application config
     */
    public IndexManager(Configuration config) {
        maxHits = config.getInt("search.max_hits_returned", 50);
        indexWorkDir = config.getString("search.index_work_dir", null);
        if (indexWorkDir == null) {
            throw new IllegalArgumentException(
                    "search.index_work_dir config entry " + "is missing");
        }
        if (!indexWorkDir.endsWith("/")) {
            indexWorkDir += "/";
        }
        score_threshold = config.getDouble("search.score_threshold", .30);
        min_ngram = config.getInt("search.min_ngram", 1);
        max_ngram = config.getInt("search.max_ngram", 5);
    }

    /**
     * @return String of the index working directory
     */
    public String getIndexWorkDir() {
        return indexWorkDir;
    }
    
    /**
     * Query a index
     * 
     * @param indexName name of the index
     * @param query search query
     * @return list of hits
     * @throws IndexingException if there is a problem indexing the content.
     * @throws QueryParseException 
     */
    public List<Result> search(String indexName, String query)
            throws IndexingException, QueryParseException {
        IndexSearcher searcher = null;
        List<Result> retval = null;
        try {
            searcher = getIndexSearcher(indexName);
            QueryParser qp = getQueryParser(indexName);
            Query q = qp.parse(query);
            if (log.isDebugEnabled()) {
                log.debug("Original query was: " + query);
                log.debug("Parsed Query is: " + q.toString());
            }
            Hits hits = searcher.search(q);
            if (log.isDebugEnabled()) {
                log.debug(hits.length() + " results were found.");
            }
            retval = processHits(indexName, hits);
        }
        catch (IOException e) {
            throw new IndexingException(e);
        }
        catch (ParseException e) {
            throw new QueryParseException("Could not parse query: '" + query + "'");
        }
        finally {
            try {
                if (searcher != null) {
                    searcher.close();
                }
            }
            catch (IOException ex) {
                throw new IndexingException(ex);
            }
        }
        return retval;
    }

    /**
     * Adds a document to an index
     * 
     * @param indexName index to use
     * @param doc Document to be indexed.
     * @throws IndexingException something went wrong adding the document
     */
    public void addToIndex(String indexName, Document doc)
        throws IndexingException {

        try {
            IndexWriter writer = getIndexWriter(indexName);
            try {
                writer.addDocument(doc);
                writer.flush();
            }
            finally {
                try {
                    writer.close();
                }
                finally {
                    // unlock it if it is locked.
                    unlockIndex(indexName);
                }
            }
        }
        catch (CorruptIndexException e) {
            throw new IndexingException(e);
        }
        catch (LockObtainFailedException e) {
            throw new IndexingException(e);
        }
        catch (IOException e) {
            throw new IndexingException(e);
        }
    }

    /**
     * Remove a document from an index
     * 
     * @param indexName index to use
     * @param objectId unique document id
     * @throws IndexingException something went wrong removing the document
     */
    public void removeFromIndex(String indexName, String objectId)
            throws IndexingException {
        Term t = new Term("id", objectId);
        IndexReader reader;
        try {
            reader = getIndexReader(indexName);
            try {
                reader.deleteDocuments(t);
            }
            finally {
                if (reader != null) {
                    reader.close();
                }
            }
        }
        catch (CorruptIndexException e) {
            throw new IndexingException(e);
        }
        catch (IOException e) {
            throw new IndexingException(e);
        }

    }

    /**
     * Unlocks the index at the given directory if it is currently locked.
     * Otherwise, does nothing.
     * @param indexName index name
     * @throws IOException thrown if there is a problem unlocking the index.
     */
    private void unlockIndex(String indexName) throws IOException {
        String path = indexWorkDir + indexName;
        File f = new File(path);
        Directory dir = FSDirectory.getDirectory(f);
        if (IndexReader.isLocked(dir)) {
            IndexReader.unlock(dir);
        }
    }
    
    private IndexWriter getIndexWriter(String name)
            throws CorruptIndexException, LockObtainFailedException,
            IOException {
        String path = indexWorkDir + name;
        File f = new File(path);
        f.mkdirs();
        Analyzer analyzer = getAnalyzer(name);
        return new IndexWriter(path, analyzer);
    }
    
    private IndexReader getIndexReader(String indexName)
            throws CorruptIndexException, IOException {
        String path = indexWorkDir + indexName;
        File f = new File(path);
        IndexReader retval = IndexReader.open(FSDirectory.getDirectory(f));
        return retval;
    }

    private IndexSearcher getIndexSearcher(String indexName)
            throws CorruptIndexException, IOException {
        String path = indexWorkDir + indexName;
        IndexSearcher retval = new IndexSearcher(path);
        return retval;
    }
    
    private QueryParser getQueryParser(String indexName) {
        QueryParser qp;
        Analyzer analyzer = getAnalyzer(indexName);
        if (indexName.compareTo(DOCS_INDEX_NAME) == 0) {
            qp = new QueryParser("content", analyzer);
        } 
        else {
            qp = new NGramQueryParser("name", analyzer);
        }
        
        return qp;
    }
    
    private Analyzer getAnalyzer(String indexName) {
        if (indexName.compareTo(DOCS_INDEX_NAME) == 0) {
            log.debug(indexName + " choosing StandardAnalyzer");
            return new StandardAnalyzer();
        } 
        else {
            log.debug(indexName + " choosing PerFieldAnalyzerWrapper");
            PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new 
                    NGramAnalyzer(min_ngram, max_ngram));
            analyzer.addAnalyzer("arch", new KeywordAnalyzer());
            analyzer.addAnalyzer("version", new KeywordAnalyzer());
            analyzer.addAnalyzer("filename", new KeywordAnalyzer());
            analyzer.addAnalyzer("advisory", new KeywordAnalyzer());
            analyzer.addAnalyzer("advisoryName", new KeywordAnalyzer());
            return analyzer;
        } 
    }
    
    private List<Result> processHits(String indexName, Hits hits) 
        throws IOException {
        List<Result> retval = new ArrayList<Result>();
        for (int x = 0; x < hits.length(); x++) {
            Document doc = hits.doc(x);
            Result pr = null;
            if (indexName.compareTo(DOCS_INDEX_NAME) == 0) {
                // TODO:
                // Need to revist how the result is formed, I'm not positive
                // using "url" makes sense for the Result "id".
                pr = new Result(x, doc.getField("url").stringValue(),
                        doc.getField("title").stringValue(),
                        hits.score(x));
            }
            else {
                pr = new Result(x,
                        doc.getField("id").stringValue(),
                        doc.getField("name").stringValue(),
                        hits.score(x));
            }
            if (log.isDebugEnabled()) {
                log.debug("Hit[" + x + "] Score = " + hits.score(x) + ", Name = " + 
                doc.getField("name") + ", ID = " + doc.getField("id"));
            }
            if ((hits.score(x) < score_threshold) && (x > 10)) {
                if (log.isDebugEnabled()) {
                    log.debug("Filtering out search results from " + x + " to " + 
                            hits.length() + ", due to their score being below " +
                            "score_threshold = " + score_threshold);
                }
                break;
            }
            if (pr != null) {
                retval.add(pr);
            }
            if (x == maxHits) {
                break;
            }
        }
        return retval;
    }
    
}
