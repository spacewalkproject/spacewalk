package com.redhat.satellite.search.index.tests;

import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.index.IndexingException;
import com.redhat.satellite.search.index.Result;
import com.redhat.satellite.search.index.QueryParseException;
import com.redhat.satellite.search.index.builder.BuilderFactory;
import com.redhat.satellite.search.index.builder.DocumentBuilder;
import com.redhat.satellite.search.index.builder.PackageDocumentBuilder;
import com.redhat.satellite.search.tests.BaseTestCase;
import com.redhat.satellite.search.tests.TestUtil;
import com.redhat.satellite.search.config.Configuration;

import org.apache.lucene.document.Document;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class IndexManagerTest extends BaseTestCase {
    
    private IndexManager indexManager;
    
    public void setUp() throws Exception {
        super.setUp();
        indexManager = (IndexManager)
            container.getComponentInstance(IndexManager.class);
    }

    public void testIndexing() throws IOException, IndexingException {
        String index = "foo";
        Long objectId = new Long(123);
        Map<String, String> meta = new HashMap<String, String>();
        meta.put("name", "foo");
        meta.put("desc", "A really nice foo");
        meta.put("size", "12345");
        meta.put("dateCreated", "7/13/2007");
        DocumentBuilder pdb = new PackageDocumentBuilder();
        Document doc = pdb.buildDocument(objectId, meta);
        indexManager.addToIndex(index, doc, "en");
    }

    public void testQuerying()
        throws IOException, IndexingException, QueryParseException {
        
        String index = "foo";
        Long objectId = new Long(123);
        Map<String, String> meta = new HashMap<String, String>();
        meta.put("name", "foo");
        meta.put("desc", "A really nice foo");
        meta.put("size", "12345");
        meta.put("dateCreated", "7/13/2007");
        DocumentBuilder pdb = new PackageDocumentBuilder();
        Document doc = pdb.buildDocument(objectId, meta);
        indexManager.addToIndex(index, doc, "en");
        List<Result> results = indexManager.search(index, "name:foo", "en");
        assertTrue(results.size() >= 1);
        results = indexManager.search(index, "desc:really", "en");
        assertTrue(results.size() >= 1);
    }

    
    public void StillNeedsWork_testQueryDocs()
    	throws IOException, IndexingException, QueryParseException {
    	
    	Configuration config = TestUtil.makeConfiguration();
    	config.setString("search.index_work_dir", "/usr/share/rhn/search/indexes/");
    	IndexManager indexMgr = new IndexManager(config);
    	//
    	// TODO: Revisit how docs data gets injected for testing. 
    	// Currently relying on docs data to already exist for now.
    	//
    	System.out.println("We are expecting nutch to have been run previously, " +
    			"and the index files to be copied to "+ config.getString("search.index_work_dir") +
			BuilderFactory.DOCS_TYPE);
    	
	String index = BuilderFactory.DOCS_TYPE;
    	String query = new String("redhat");
	List<Result> results = indexMgr.search(index, query, "en");
    	System.out.println("Number of results returned is " + results.size());
    	assertTrue(results.size() >= 1);
    	
    }
    
    @SuppressWarnings("unchecked")
    @Override
    protected Class[] getComponentClasses() {
        return TestUtil.buildComponentsList(IndexManager.class);
    }
    
    
}
