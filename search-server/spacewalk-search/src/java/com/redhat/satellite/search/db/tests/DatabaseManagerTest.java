package com.redhat.satellite.search.db.tests;

import com.redhat.satellite.search.db.DatabaseManager;
import com.redhat.satellite.search.db.Query;
import com.redhat.satellite.search.db.models.RhnPackage;
import com.redhat.satellite.search.tests.BaseTestCase;
import com.redhat.satellite.search.tests.TestUtil;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class DatabaseManagerTest extends BaseTestCase {
    
    private DatabaseManager dm;
    
    @Override
    protected void setUp() throws Exception {
        super.setUp();
        dm = (DatabaseManager)
            container.getComponentInstance(DatabaseManager.class);
    }

    public void testObjectQuery() throws IOException, SQLException {
        Query<Long> maxidquery = dm.getQuery("maxPackageId");
        Long maxid = maxidquery.load();
        Query<RhnPackage> query = dm.getQuery("getPackageById");
        RhnPackage p = query.load(maxid);
        assertNotNull(p);
        assertEquals(p.getId(), maxid.longValue());
    }
 
    public void testListQuery() throws IOException, SQLException {
        Query<RhnPackage> query = dm.getQuery("listPackagesFromId");
        List<RhnPackage> results = query.loadList((long) 0);
        assertNotNull(results);
        assertTrue(results.size() > 0);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected Class[] getComponentClasses() {
        return TestUtil.buildComponentsList(DatabaseManager.class);
    }
}
