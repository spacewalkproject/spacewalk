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

import com.redhat.satellite.search.config.Configuration;
import com.redhat.satellite.search.index.builder.BuilderFactory;
import com.redhat.satellite.search.index.ngram.NGramAnalyzer;
import com.redhat.satellite.search.index.ngram.NGramQueryParser;
import com.redhat.satellite.search.rpc.handlers.IndexHandler;

import org.apache.hadoop.fs.FileSystem;

import org.apache.log4j.Logger;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.analysis.PerFieldAnalyzerWrapper;
import org.apache.lucene.document.DateTools;
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

import org.apache.nutch.analysis.AnalyzerFactory;
import org.apache.nutch.searcher.FetchedSegments;
import org.apache.nutch.searcher.HitDetails;
import org.apache.nutch.searcher.Summary;

import org.apache.nutch.util.NutchConfiguration;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

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
    private double system_score_threshold;
    private double errata_score_threshold;
    private double errata_advisory_score_threshold;
    private int min_ngram;
    private int max_ngram;
    private boolean filterDocResults = false;
    private boolean explainResults = false;
    private AnalyzerFactory nutchAnalyzerFactory;
    // Name conflict with our Configuration class and Hadoop's
    private org.apache.hadoop.conf.Configuration nutchConf;
    private Map<String, String> docLocaleLookUp = new HashMap<String, String>();
    private Map<String, FetchedSegments> docSegments;
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
        system_score_threshold = config.getDouble("search.system_score_threshold", .30);
        errata_score_threshold = config.getDouble("search.errata_score_threshold", .30);
        errata_advisory_score_threshold =
            config.getDouble("search.errata.advisory_score_threshold", .30);
        min_ngram = config.getInt("search.min_ngram", 1);
        max_ngram = config.getInt("search.max_ngram", 5);
        initDocLocaleLookup();
        filterDocResults = config.getBoolean("search.doc.limit_results");
        explainResults = config.getBoolean("search.log.explain.results");
        initDocSummary();
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
     * @param lang language
     * @return list of hits
     * @throws IndexingException if there is a problem indexing the content.
     * @throws QueryParseException 
     */
    public List<Result> search(String indexName, String query, String lang)
            throws IndexingException, QueryParseException {
        return search(indexName, query, lang, false);
    }

    /**
     * Query a index
     *
     * @param indexName name of the index
     * @param query search query
     * @param lang language
     * @param isFineGrained
     *      true:   will limit results, less are returned but they are closer
     *              to the search query, useful for advanced/free form queries
     *
     *      false:  will allow queries to be more flexible returning words
     *              which are spelled similarly
     *
     * @return list of hits
     * @throws IndexingException if there is a problem indexing the content.
     * @throws QueryParseException
     */
    public List<Result> search(String indexName, String query, String lang,
            boolean isFineGrained)
            throws IndexingException, QueryParseException {
        IndexSearcher searcher = null;
        IndexReader reader = null;
        List<Result> retval = null;
        try {
            reader = getIndexReader(indexName, lang);
            searcher = getIndexSearcher(indexName, lang);
            QueryParser qp = getQueryParser(indexName, lang, isFineGrained);
            Query q = qp.parse(query);
            if (log.isDebugEnabled()) {
                log.debug("Original query was: " + query);
                log.debug("Parsed Query is: " + q.toString());
            }
            Hits hits = searcher.search(q);
            if (log.isDebugEnabled()) {
                log.debug(hits.length() + " results were found.");
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
            retval = processHits(indexName, hits, queryTerms, query, lang);
            if (explainResults) {
                debugExplainResults(indexName, hits, searcher, q, queryTerms);
            }
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
     * @param lang language.
     * @throws IndexingException something went wrong adding the document
     */
    public void addToIndex(String indexName, Document doc, String lang)
        throws IndexingException {

        try {
            IndexWriter writer = getIndexWriter(indexName, lang);
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
     * @param lang language
     * @throws IndexingException
     */
    public void addUniqueToIndex(String indexName, Document doc,
            String uniqueField, String lang)
        throws IndexingException {
        IndexReader reader = null;
        int numFound = 0;
        try {
            reader = getIndexReader(indexName, lang);
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
        addToIndex(indexName, doc, lang);
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
            reader = getIndexReader(indexName, IndexHandler.DEFAULT_LANG);
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
    
    private IndexWriter getIndexWriter(String name, String lang)
            throws CorruptIndexException, LockObtainFailedException,
            IOException {
        String path = indexWorkDir + name;
        File f = new File(path);
        f.mkdirs();
        Analyzer analyzer = getAnalyzer(name, lang);
        IndexWriter writer = new IndexWriter(path, analyzer);
        writer.setUseCompoundFile(true);
        return writer;
    }
    
    private IndexReader getIndexReader(String indexName, String locale)
            throws CorruptIndexException, IOException {
        String path = "";
        if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
            path = indexWorkDir + File.separator +
                getDocIndexPath(locale);
        }
        else {
            path = indexWorkDir + indexName;
        }
        log.info("IndexManager::getIndexReader(" + indexName + ", " + locale +
                ") path = " + path);
        File f = new File(path);
        IndexReader retval = IndexReader.open(FSDirectory.getDirectory(f));
        return retval;
    }

    private IndexSearcher getIndexSearcher(String indexName, String locale)
            throws CorruptIndexException, IOException {
        String path = "";
        if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
            path = indexWorkDir + File.separator +
                getDocIndexPath(locale);
        }
        else {
            path = indexWorkDir + indexName;
        }
        log.info("IndexManager::getIndexSearcher(" + indexName + ", " + locale +
                ") path = " + path);
        IndexSearcher retval = new IndexSearcher(path);
        return retval;
    }
    
    private QueryParser getQueryParser(String indexName, String lang,
            boolean isFineGrained) {
        if (log.isDebugEnabled()) {
            log.debug("getQueryParser(" + indexName + ", " + lang + ", " +
                    isFineGrained + ")");
        }
        QueryParser qp;
        Analyzer analyzer = getAnalyzer(indexName, lang);
        if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
            qp = new QueryParser("content", analyzer);
        } 
        else {
            qp = new NGramQueryParser("name", analyzer, isFineGrained);
        }
        qp.setDateResolution(DateTools.Resolution.MINUTE);
        return qp;
    }
    

    private Analyzer getAnalyzer(String indexName, String lang) {
        if (log.isDebugEnabled()) {
            log.debug("getAnalyzer(" + indexName + ", " + lang + ")");
        }
        if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
            return getDocAnalyzer(lang);
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
            String query, String lang)
        throws IOException {
        List<Result> retval = new ArrayList<Result>();
        for (int x = 0; x < hits.length(); x++) {
            Document doc = hits.doc(x);
            Result pr = null;
            if (!isScoreAcceptable(indexName, hits, x, query)) {
                break;
            }
            if (indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) {
                pr = new DocResult(x, hits.score(x), doc);
                String summary = lookupDocSummary(doc, query, lang);
                if (summary != null) {
                    ((DocResult)pr).setSummary(summary);
                }
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
                log.debug("Hit[" + x + "] Score = " + hits.score(x) + ", Result = " + pr);
            }
            /**
             * matchingField will help the webUI to understand what field was responsible
             * for this match.  Later implementation should use "Explanation" to determine
             * field, for now we will simply grab one term and return it's field.
             */
            try {
                MatchingField match = new MatchingField(query, doc, queryTerms);
                pr.setMatchingField(match.getFieldName());
                pr.setMatchingFieldValue(match.getFieldValue());
                log.info("hit[" + x + "] matchingField is being set to: <" + 
                    pr.getMatchingField() + "> based on passed in query field.  " +
                    "matchingFieldValue = " + pr.getMatchingFieldValue());
            }
            catch (Exception e) {
                log.error("Caught exception: ", e);
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
    /**
     *
     * @param indexName
     * @param hits
     * @param x
     * @param query
     * @return  true - score is acceptable
     *          false - score is NOT acceptable
     * @throws IOException
     */
    private boolean isScoreAcceptable(String indexName, Hits hits, int x, String queryIn)
        throws IOException {
        String guessMainQueryTerm = MatchingField.getFirstFieldName(queryIn);

        if ((indexName.compareTo(BuilderFactory.DOCS_TYPE) == 0) &&
                (!filterDocResults)) {
            return true;
        }
        /**
         * Dropping matches which are a poor fit.
         * system searches are filtered based on "system_score_threshold"
         * other searches will return 10 best matches, then filter anything below
         * "score_threshold"
         */
        if ((indexName.compareTo(BuilderFactory.SERVER_TYPE) == 0) ||
                (indexName.compareTo(BuilderFactory.SERVER_CUSTOM_INFO_TYPE) == 0) ||
                (indexName.compareTo(BuilderFactory.SNAPSHOT_TAG_TYPE)  == 0) ||
                (indexName.compareTo(BuilderFactory.HARDWARE_DEVICE_TYPE) == 0)) {
            if (hits.score(x) < system_score_threshold) {
                if (log.isDebugEnabled()) {
                    log.debug("hits.score(" + x + ") is " + hits.score(x));
                    log.debug("Filtering out search results from " + x + " to " +
                            hits.length() + ", due to their score being below " +
                            "system_score_threshold = " + system_score_threshold);
                }
                return false;
            }
        }
        else if (indexName.compareTo(BuilderFactory.ERRATA_TYPE) == 0) {
            if (guessMainQueryTerm.compareTo("advisoryName") == 0) {
                if (hits.score(x) < errata_advisory_score_threshold) {
                    if (log.isDebugEnabled()) {
                        log.debug("hits.score(" + x + ") is " + hits.score(x));
                        log.debug("Filtering out search results from " + x + " to " +
                            hits.length() + ", due to their score being below " +
                            "errata_advisory_score_threshold = " +
                            errata_advisory_score_threshold);
                    }
                    return false;
                }
            }
            else {
                if (hits.score(x) < errata_score_threshold) {
                    if (log.isDebugEnabled()) {
                        log.debug("hits.score(" + x + ") is " + hits.score(x));
                        log.debug("Filtering out search results from " + x + " to " +
                            hits.length() + ", due to their score being below " +
                            "errata_score_threshold = " +
                            errata_score_threshold);
                    }
                    return false;
                }
            }
        }
        else if (((hits.score(x) < score_threshold) && (x > 10)) ||
                (hits.score(x) < 0.001)) {
            /**
             * Dropping matches which are a poor fit.
             * First term is configurable, it allows matches like spelling errors or
             * suggestions to be possible.
             * Second term is intended to get rid of pure and utter crap hits
             */
            if (log.isDebugEnabled()) {
                log.debug("hits.score(" + x + ") is " + hits.score(x));
                log.debug("Filtering out search results from " + x + " to " +
                        hits.length() + ", due to their score being below " +
                        "score_threshold = " + score_threshold);
            }
            return false;
        }
        return true;
    }
    
    /**
     * Removes any documents which are not related to the passed in Set of good value
     * @param ids Set of ids of all known/good values 
     * @param indexName index name to operate on
     * @param uniqField the name of the field in the Document to uniquely identify 
     * this record
     * @return the number of documents deleted
     */
    public int deleteRecordsNotInList(Set<String> ids, String indexName, 
            String uniqField) {
        int count = 0;
        IndexReader reader = null;
        try {
            reader = getIndexReader(indexName, IndexHandler.DEFAULT_LANG);
            int numDocs = reader.numDocs();
            for (int i = 0; i < numDocs; i++) {
                if (!reader.isDeleted(i)) {
                    Document doc = reader.document(i);
                    String uniqId = doc.getField(uniqField).stringValue();
                    if (!ids.contains(uniqId)) {
                        log.info(indexName + ":" + uniqField  + ":  <" + uniqId +
                                "> not found in list of current/good values " + 
                                "assuming this has been deleted from Database and we " + 
                                "should remove it.");
                        removeFromIndex(indexName, uniqField, uniqId);
                        count++;
                    }
                }
            }
        }
        catch (IOException e) {
            e.printStackTrace();
            log.info("deleteRecordsNotInList() caught exception : " + e);
        }
        catch (IndexingException e) {
            e.printStackTrace();
            log.info("deleteRecordsNotInList() caught exception : " + e);
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
        return count;
    }

    private void debugExplainResults(String indexName, Hits hits, IndexSearcher searcher,
            Query q, Set<Term> queryTerms)
        throws IOException {
        log.debug("Parsed Query is " + q.toString());
        log.debug("Looking at index:  " + indexName);
        for (int i = 0; i < hits.length(); i++) {
            if ((i < 10)) {
                Document doc = hits.doc(i);
                Float score = hits.score(i);
                Explanation ex = searcher.explain(q, hits.id(i));
                log.debug("Looking at hit<" + i + ", " + hits.id(i) + ", " + score +
                        ">: " + doc);
                log.debug("Explanation: " + ex);
                MatchingField match = new MatchingField(q.toString(), doc, queryTerms);
                String fieldName = match.getFieldName();
                String fieldValue = match.getFieldValue();
                log.debug("Guessing that matched fieldName is " + fieldName + " = " +
                        fieldValue);
            }
        }
    }

    private String getDocIndexPath(String lang) throws IOException {
        if (docLocaleLookUp.containsKey(lang)) {
            return BuilderFactory.DOCS_TYPE + File.separator +
                docLocaleLookUp.get(lang);
        }
        log.error("Unable to find docs index dir for language " + lang);
        throw new IOException("Unable to find docs index dir for language: " + lang);
    }


    private Analyzer getDocAnalyzer(String lang) {
        /**
         * We want to use the same Analyzer nutch is using when the indexes are
         * generated
         * */
        Analyzer analyzer = null;
        try {
            analyzer = nutchAnalyzerFactory.get(lang);
        }
        catch (Exception e) {
            log.info("Caught exception, nutch is most likely not installed");
            log.info("Defaulting to generic analyzer for Documentation Search");
            log.info("Install nutch package to get summary info and better matches.");
            analyzer = new StandardAnalyzer();
        }
        log.info("Language choice is " + lang + ", analyzer chosen is " +
                analyzer);
        return analyzer;
    }
    
    private Analyzer getServerAnalyzer() {
        PerFieldAnalyzerWrapper analyzer = new PerFieldAnalyzerWrapper(new
                NGramAnalyzer(min_ngram, max_ngram));
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
        analyzer.addAnalyzer("epoch", new KeywordAnalyzer());
        analyzer.addAnalyzer("version", new KeywordAnalyzer());
        analyzer.addAnalyzer("release", new KeywordAnalyzer());
        analyzer.addAnalyzer("filename", new KeywordAnalyzer());
        return analyzer;
    }

    private boolean initDocSummary() {
        /**
         * NOTE:  NutchConfiguration is expecting "nutch-default.xml" and "nutch-site.xml"
         * to be available in the CLASSPATH
         */
        try {
            nutchConf = NutchConfiguration.create();
            nutchAnalyzerFactory = new AnalyzerFactory(nutchConf);
            FileSystem fs = FileSystem.get(nutchConf);
            docSegments = new HashMap<String, FetchedSegments>();
            for (String key : docLocaleLookUp.keySet()) {
                String lang = docLocaleLookUp.get(key);
                String segmentsDir = indexWorkDir + File.separator +
                    getDocIndexPath(key) + File.separator + "segments";
                FetchedSegments segments = new FetchedSegments(fs, segmentsDir, nutchConf);
                if (segments == null) {
                    log.info("Unable to create docSegments for language: " + key);
                    docSegments.put(key, null);
                }
                String[] segNames = segments.getSegmentNames();
                if (segNames == null || segNames.length == 0) {
                    log.info("Unable to find any segments for language: " + key);
                    docSegments.put(key, null);
                }
                log.info("Adding Documentation segments for language: " + key);
                docSegments.put(key, segments);
            }
        }
        catch (Exception e) {
            log.error("ignoring exception - most likely Nutch isn't present, so" +
            " doc summaries will be empty");
            e.printStackTrace();
        }
        return true;
    }

    private String lookupDocSummary(Document doc, String queryString, String lang) {
        if (docSegments == null) {
            log.info("docSegments is null, doc summary not possible");
            log.info("nutch is probably not installed, install nutch to get summary info");
            return "";
        }
        if (!docSegments.containsKey(lang)) {
            log.info("Couldn't find segments info for " + lang);
            log.info("Summary info will be missing for " + lang);
            return "";
        }
        FetchedSegments segments = docSegments.get(lang);
        if (segments == null) {
            log.info("Segments info for " + lang + " is null");
            return "";
        }
        try {
            if (log.isDebugEnabled()) {
                log.debug("Attempting lookupDocSummary<" + lang + "> for " + doc);
            }
            HitDetails hd = new HitDetails(doc.getField("segment").stringValue(),
                doc.getField("url").stringValue());
            // NOTE: Name conflict with Nutch's Query versus Lucene Query
            org.apache.nutch.searcher.Query query =
                org.apache.nutch.searcher.Query.parse(queryString, nutchConf);
            Summary sum = segments.getSummary(hd, query);
            if (log.isDebugEnabled()) {
                log.debug("Will return summary<" + lang + "> = " + sum.toString());
            }
            return sum.toString();
        }
        catch (Exception e) {
            log.info("Failed to lookupDocSummary<" + lang + ">, caught Exception: " + e);
            e.printStackTrace();
        }
        return "";
    }

    private void initDocLocaleLookup() {
        docLocaleLookUp.put("bn_IN", "bn-IN");
        docLocaleLookUp.put("de", "de-DE");
        docLocaleLookUp.put("en_US", "en-US");
        docLocaleLookUp.put("es", "es-ES");
        docLocaleLookUp.put("fr", "fr-FR");
        docLocaleLookUp.put("gu", "gu-IN");
        docLocaleLookUp.put("hi", "hi-IN");
        docLocaleLookUp.put("it", "it-IT");
        docLocaleLookUp.put("ja", "ja-JP");
        docLocaleLookUp.put("ko", "ko-KR");
        docLocaleLookUp.put("pa", "pa-IN");
        docLocaleLookUp.put("pt_BR", "pt-BR");
        docLocaleLookUp.put("ru", "ru-RU");
        docLocaleLookUp.put("ta", "ta-IN");
        docLocaleLookUp.put("zh_CN", "zh-CN");
        docLocaleLookUp.put("zh_TW", "zh-TW");
        // Below exist in docs, but weren't available as a doc option from
        // satellite webui and they weren't available Locales on my machine
        // guessing at what they will look at.
        docLocaleLookUp.put("as", "as-IN");
        docLocaleLookUp.put("ml", "ml-IN");
        docLocaleLookUp.put("mr", "mr-IN");
        docLocaleLookUp.put("or", "or-IN");
        docLocaleLookUp.put("kn", "kn-IN");
        docLocaleLookUp.put("si_lk", "si-LK");
        docLocaleLookUp.put("te", "te-IN");
    }

}
