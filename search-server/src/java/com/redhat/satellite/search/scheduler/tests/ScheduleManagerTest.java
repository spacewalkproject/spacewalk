package com.redhat.satellite.search.scheduler.tests;

import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.index.IndexingException;
import com.redhat.satellite.search.index.Result;
import com.redhat.satellite.search.index.QueryParseException;
import com.redhat.satellite.search.scheduler.ScheduleManager;
import com.redhat.satellite.search.tests.BaseTestCase;
import com.redhat.satellite.search.tests.TestUtil;

import java.util.List;

public class ScheduleManagerTest extends BaseTestCase {
    @SuppressWarnings("unchecked")
    @Override
    protected Class[] getComponentClasses() {
        return TestUtil.buildComponentsList(ScheduleManager.class);
    }
    
    public void testIndexing() throws IndexingException, QueryParseException {
        try {
            Thread.sleep(30000);
            IndexManager mgr = (IndexManager)
                container.getComponentInstance(IndexManager.class);
            List<Result>hits = mgr.search("package", "description:package");
            assertTrue(hits.size() > 0);
        }
        catch (InterruptedException e) {
            return;
        }
    }
}
