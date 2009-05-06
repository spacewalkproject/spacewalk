package com.redhat.satellite.search.scheduler.tests;

import com.redhat.satellite.search.index.IndexManager;
import com.redhat.satellite.search.index.IndexingException;
import com.redhat.satellite.search.index.QueryParseException;
import com.redhat.satellite.search.index.Result;
import com.redhat.satellite.search.index.builder.BuilderFactory;
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
            List<Result>hits = mgr.search("package", "description:package",
                    "en");
            assertTrue(hits.size() > 0);
        }
        catch (InterruptedException e) {
            return;
        }
    }
    
    public void testTriggerIndexTask() {
        ScheduleManager sm = new ScheduleManager(null, null);
        assertTrue(sm.triggerIndexTask(BuilderFactory.ERRATA_TYPE));
        assertTrue(sm.triggerIndexTask(BuilderFactory.HARDWARE_DEVICE_TYPE));
        assertTrue(sm.triggerIndexTask(BuilderFactory.PACKAGES_TYPE));
        assertTrue(sm.triggerIndexTask(BuilderFactory.SERVER_CUSTOM_INFO_TYPE));
        assertTrue(sm.triggerIndexTask(BuilderFactory.SERVER_TYPE));
        assertTrue(sm.triggerIndexTask(BuilderFactory.SNAPSHOT_TAG_TYPE));
        assertFalse(sm.triggerIndexTask(BuilderFactory.DOCS_TYPE));
        assertFalse(sm.triggerIndexTask(null));
        assertFalse(sm.triggerIndexTask("biteme"));
        assertFalse(sm.triggerIndexTask(""));
    }
}
