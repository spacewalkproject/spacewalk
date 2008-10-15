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
import com.redhat.satellite.search.index.builder.BuilderFactory;
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
import org.apache.lucene.search.Explanation;
import org.apache.lucene.search.Hits;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import org.apache.lucene.store.LockObtainFailedException;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;

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
        IndexReader reader = null;
        List<Result> retval = null;
        try {
            reader = getIndexReader(indexName);
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
                //debugDisplay(indexName, hits, searcher, q);
            }
            Set<Term> queryTerms = null;
            try {
                queryTerms = new HashSet<Term>();
                Query newQ = q.rewrite(reader);
                newQ.extractTerms(queryTerms);
            }
            catch (Exception e) {
                e.printStackTrace();
                throw new QueryParseException(e);
            }
            retval = processHits(indexName, hits, queryTerms, query);
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
                if (reader != null) {
                    reader.close();
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
     * @param indexName
     * @param doc document with data to index
     * @param uniqueField field in doc which identifies this uniquely
     * @throws IndexingException
     */
    public void addUniqueToIndex(String indexName, Document doc, String uniqueField)
        throws IndexingException {
        IndexReader reader = null;
        int numFound = 0;
        try {
            reader = getIndexReader(indexName);
            Term term = new Term(uniqueField, doc.get(uniqueField));
            numFound = reader.docFreq(term);
        }
        catch (FileNotFoundException e) {
            // Index doesn't exist, so this add will be unique
            // we don't need to do anything/
        }
        catch (IOException e) {
            throw new IndexingException(e);
        }
        finally {
            if (reader != null) {
                try {
                    reader.close();
                }
                catch (IOException e) {
                    //
                }
            }
        }
        if (numFound > 0) {
            log.info("Found " + numFound + " <" + indexName + " docs for " +
                    uniqueField + ":" + doc.get(uniqueField) +
                    " will remove them now.");
            removeFromIndex(indexName, uniqueField, doc.get(uniqueField));
        }
        addToIndex(indexName, doc);
    }

    /**
     * Remove a document from an index
     * 
     * @param indexName index to use
     * @param uniqueField field name which represents this data's unique id
     * @param objectId unique document id
     * @throws IndexingException something went wrong removing the document
     */
    public void removeFromIndex(String indexName, String uniqueField, String objectId)
            throws IndexingException {
        log.info("Removing <" + indexName + "> " + uniqueField + ":" +
                objectId);
        Term t = new Term(uniqueField, objectId);
        IndexReader reader;
        try {
            reader = getIndexReader(indexName);
            try {
                reader.deleteDocuments(t);
                reader.flush();
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
        IndexWriter writer = new IndexWriter(path, analyzer);
        writer.setUseCompoundFile(true);
        return writer;
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
        if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
            qp = new QueryParser("content", analyzer);
        } 
        else {
            qp = new NGramQueryParser("name", analyzer);
        }
        
        return qp;
    }
    

    private Analyzer getAnalyzer(String indexName) {
        if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
            log.debug(indexName + " choosing StandardAnalyzer");
            return new StandardAnalyzer();
        } 
        else if (indexName.compareTo(BuilderFactory.SERVER_TYPE) == 0) {
            return getServerAnalyzer();
        }
        else if (indexName.compareTo(BuilderFactory.SNAPSHOT_TAG_TYPE) == 0) {
            return getSnapshotTagAnalyzer();
        }
        else if (indexName.compareTo(BuilderFactory.HARDWARE_DEVICE_TYPE) == 0) {
            return getHardwareDeviceAnalyzer();
        }
        else if (indexName.compareTo(BuilderFactory.SERVER_CUSTOM_INFO_TYPE) == 0) {
            return getServerCustomInfoAnalyzer();
        }
        else {
            log.debug(indexName + " using getDefaultAnalyzer()");
            return getDefaultAnalyzer();
        } 
    }
    
    private List<Result> processHits(String indexName, Hits hits, Set<Term> queryTerms, 
            String query)
        throws IOException {
        List<Result> retval = new ArrayList<Result>();
        for (int x = 0; x < hits.length(); x++) {
            Document doc = hits.doc(x);
            Result pr = null;
            if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
                // TODO:
                // Need to revist how the result is formed, I'm not positive
                // using "url" makes sense for the Result "id".
                pr = new Result(x, doc.getField("url").stringValue(),
                        doc.getField("title").stringValue(),
                        hits.score(x));
            }
            else if (indexName.compareTo(BuilderFactory.HARDWARE_DEVICE_TYPE) == 0) {
                pr = new HardwareDeviceResult(x, hits.score(x), doc);
            }
            else if (indexName.compareTo(BuilderFactory.SNAPSHOT_TAG_TYPE)  == 0) {
                pr = new SnapshotTagResult(x, hits.score(x), doc);
            }
            else if (indexName.compareTo(BuilderFactory.SERVER_CUSTOM_INFO_TYPE) == 0) {
                pr = new ServerCustomInfoResult(x, hits.score(x), doc);
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
            /**
             * matchingField will help the webUI to understand what field was responsible
             * for this match.  Later implementation should use "Explanation" to determine
             * field, for now we will simply grab one term and return it's field.
             */
            if (queryTerms.size() > 0) {
                Iterator<Term> iter = queryTerms.iterator();
                if (iter.hasNext()) {
                    Term t = iter.next();
                    log.info("For hit[" + x + "] setting matchingField to '" +
                            t.field() + "'");
                    pr.setMatchingField(t.field());
                }
                else {
                    log.info("hit[" + x + "] odd queryTerms iterator doesn't " + 
                            "have a first element, matchingField is left as: <" +
                            pr.getMatchingField() + ">");
                }
            }
            else {
                String field = getFirstFieldName(query);
                pr.setMatchingField(field);
                log.info("hit[" + x + "] matchingField is being set to: <" + 
                        pr.getMatchingField() + "> based on passed in query field.");
            }

            /**
             * Dropping matches which are a poor fit.
             * First term is configurable, it allows matches like spelling errors or
             * suggestions to be possible.
             * Second term is intended to get rid of pure and utter crap hits
             */
            if (((hits.score(x) < score_threshold) && (x > 10)) || (hits.score(x) < 0.01)) {
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
    
    private String getFirstFieldName(String query) {
        StringTokenizer tokens = new StringTokenizer(query, ":");
        return tokens.nextToken();
    }
    
    private void printExplanationDetails(Explanation ex) {
        log.warn("Explanation.getDescription() = " + ex.getDescription());
        log.warn("Explanation.getValue() = " + ex.getValue());
        for (Explanation detail : ex.getDetails()) {
            printExplanationDetails(detail);
        }
    }
    private void debugDisplay(String indexName, Hits hits, IndexSearcher searcher,
            Query q)
        throws IOException {
        log.warn("Looking at index:  " + indexName);
        for (int i = 0; i < hits.length(); i++) {
            if ((i < 10)) {
                Document doc = hits.doc(i);
                Float score = hits.score(i);
                Explanation ex = searcher.explain(q, hits.id(i));
                log.warn("Looking at hit<" + i + ", " + hits.id(i) + ", " + score +
                        ">: " + doc);
                log.warn("Explanation: " + ex);
                log.warn("Explanation.getDescription() = " + ex.getDescription());
                log.warn("Explanation.getValue() = " + ex.getValue());
                printExplanationDetails(ex);


                String data = ex.toString();
                String matcher = "(field=";
                int startLoc = data.indexOf(matcher);
                if (startLoc < 0) {
                    return;
                }
                int endLoc = data.indexOf(",", startLoc + matcher.length());
                if (endLoc < 0) {
                    return;
                }
                String fieldName = data.substring(startLoc + matcher.length(), endLoc);
                log.warn("Guessing that matched fieldName is " + fieldName);
            }
        }
    }

    
    private Analyzer getServerAnalyzer() {
        PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new
                NGramAnalyzer(min_ngram, max_ngram));
        analyzer.addAnalyzer("id", new KeywordAnalyzer());
        analyzer.addAnalyzer("checkin", new KeywordAnalyzer());
        analyzer.addAnalyzer("registered", new KeywordAnalyzer());
        analyzer.addAnalyzer("ram", new KeywordAnalyzer());
        analyzer.addAnalyzer("swap", new KeywordAnalyzer());
        analyzer.addAnalyzer("cpuMhz", new KeywordAnalyzer());
        analyzer.addAnalyzer("cpuNumberOfCpus", new KeywordAnalyzer());


        return analyzer;
    }
    
    private Analyzer getSnapshotTagAnalyzer() {
        PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new
                NGramAnalyzer(min_ngram, max_ngram));
        analyzer.addAnalyzer("id", new KeywordAnalyzer());
        analyzer.addAnalyzer("snapshotId", new KeywordAnalyzer());
        analyzer.addAnalyzer("orgId", new KeywordAnalyzer());
        analyzer.addAnalyzer("serverId", new KeywordAnalyzer());
        analyzer.addAnalyzer("tagNameId", new KeywordAnalyzer());
        analyzer.addAnalyzer("created", new KeywordAnalyzer());
        analyzer.addAnalyzer("modified", new KeywordAnalyzer());
        return analyzer;
    }
    
    private Analyzer getHardwareDeviceAnalyzer() {
        PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new
                NGramAnalyzer(min_ngram, max_ngram));
        analyzer.addAnalyzer("id", new KeywordAnalyzer());
        analyzer.addAnalyzer("serverId", new KeywordAnalyzer());
        analyzer.addAnalyzer("pciType", new KeywordAnalyzer());
        return analyzer;
    }
    
    private Analyzer getServerCustomInfoAnalyzer() {
        PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new
                NGramAnalyzer(min_ngram, max_ngram));
        analyzer.addAnalyzer("id", new KeywordAnalyzer());
        analyzer.addAnalyzer("serverId", new KeywordAnalyzer());
        analyzer.addAnalyzer("created", new KeywordAnalyzer());
        analyzer.addAnalyzer("modified", new KeywordAnalyzer());
        analyzer.addAnalyzer("createdBy", new KeywordAnalyzer());
        analyzer.addAnalyzer("lastModifiedBy", new KeywordAnalyzer());
        return analyzer;
    }
    
    private Analyzer getDefaultAnalyzer() {
        PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new 
                NGramAnalyzer(min_ngram, max_ngram));
        analyzer.addAnalyzer("id", new KeywordAnalyzer());
        analyzer.addAnalyzer("arch", new KeywordAnalyzer());
        analyzer.addAnalyzer("version", new KeywordAnalyzer());
        analyzer.addAnalyzer("filename", new KeywordAnalyzer());
        analyzer.addAnalyzer("advisory", new KeywordAnalyzer());
        analyzer.addAnalyzer("advisoryName", new KeywordAnalyzer());
        return analyzer;
    }
}
