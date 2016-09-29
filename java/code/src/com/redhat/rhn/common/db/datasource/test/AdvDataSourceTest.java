/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.common.db.datasource.test;

import com.redhat.rhn.common.ObjectCreateWrapperException;
import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.log4j.Logger;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

public class AdvDataSourceTest extends RhnBaseTestCase {

    private static Logger log = Logger.getLogger(AdvDataSourceTest.class);
    private final Random random = new Random();
    private String db_sufix;
    private String db_user;
    public AdvDataSourceTest(String name) {
        super(name);
        if (ConfigDefaults.get().isOracle()) {
            db_sufix = "_or";
        }
        else {
            db_sufix = "_pg";
        }
        db_user = Config.get().getString(ConfigDefaults.DB_USER);
    }

    private void lookup(String foobar, int id, int size) {
        SelectMode m = ModeFactory.getMode("test_queries", "find_in_table");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("foobar", foobar);
        params.put("id", new Integer(id));
        DataResult<AdvDataSourceDto> dr = m.execute(params);
        assertEquals(size, dr.size());
        if (size > 0) {
            assertEquals(foobar, dr.get(0).getFoobar());
            assertEquals(new Long(id), dr.get(0).getId());
        }
    }

    private void insert(String foobar, int id) throws Exception {
        WriteMode m = ModeFactory.getWriteMode("test_queries", "insert_into_table");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("foobar", foobar);
        params.put("id", Integer.valueOf(id));
        params.put("test_column", "test-" + TestUtils.randomString());
        params.put("pin", random.nextInt(100));
        int res = m.executeUpdate(params);
        assertEquals(1, res);
    }

    /**
     * Test for ModeFactory.getMode methods
     */
    public void testDate() {
        if (ConfigDefaults.get().isOracle()) {
            SelectMode m = ModeFactory.getMode("test_queries", "date_dto_test");
            DataResult dr = m.execute(new HashMap());
            assertTrue(dr.get(0) instanceof TestDateDto);
            TestDateDto d = (TestDateDto) dr.get(0);
            assertTrue(d.getCreated() instanceof Timestamp);
        }
    }

    public void testMaxRows() {
        if (ConfigDefaults.get().isOracle()) {
            SelectMode m = ModeFactory.getMode("test_queries", "withClass" + db_sufix);
            try {
                m.setMaxRows(-10);
                fail("setMaxRows should NOT allow negative numbers.");
            }
            catch (IllegalArgumentException e) {
                // expected.
            }
            m.setMaxRows(10);
            Map params = null;
            DataResult dr = m.execute(params);
            assertNotNull(dr);
            assertTrue(dr.size() == 10);
        }
    }

    /**
     * Test for ModeFactory.getMode methods
     */
    public void testModes() {
        if (ConfigDefaults.get().isOracle()) {
            SelectMode m = ModeFactory.getMode("test_queries", "withClass" + db_sufix);
            Map params = null;
            DataResult dr = m.execute(params);
            assertNotNull(dr);
            assertTrue(dr.size() > 1);
            Object obj = dr.iterator().next();
            /* The withClass query in test_queries should have a class defined. We don't
             * really care what it is as long as it isn't a Map.
             */
            assertTrue(!obj.getClass().getName().equals("java.util.Map"));

            //Try over-riding and getting a Map back
            SelectMode m2 = ModeFactory.getMode("test_queries",
                    "withClass" + db_sufix, Map.class);
            dr = m2.execute(params);
            assertNotNull(dr);
            assertTrue(dr.size() > 1);
            obj = dr.iterator().next();
            //make sure we got some sort of a Map back
            assertEquals("java.util.HashMap", obj.getClass().getName());

            //Try over-riding with something incompatible
            SelectMode m3 = ModeFactory.getMode("test_queries",
                    "withClass" + db_sufix, Set.class);
            try {
                dr = m3.execute(params);
                fail();
            }
            catch (ObjectCreateWrapperException e) {
                //success!
            }

            //Make sure our selectMode object was a copy and not the one cached
            SelectMode m2a = ModeFactory.getMode("test_queries", "withClass" + db_sufix);
            assertFalse(m2a.getClassString().equals("java.util.Set"));
            assertFalse(m2a.getClassString().equals("java.util.Map"));

            //finally, make sure that by default our DataResult objects contain Maps
            SelectMode m4 = ModeFactory.getMode("test_queries", "all_tables" + db_sufix);
            dr = m4.execute(params);
            assertNotNull(dr);
            assertTrue(dr.size() > 1);
            obj = dr.iterator().next();
            assertEquals("java.util.HashMap", obj.getClass().getName());
        }
    }

    public void testInsert() throws Exception {
        insert("insert_test", 3);
        // Close our Session so we test to make sure it
        // actually inserted.
        commitAndCloseSession();
        lookup("insert_test", 3, 1);
    }

    public void testDelete() throws Exception {
        // Take nothing for granted, make sure the data is there.
        insert("Blarg", 1);
        WriteMode m = ModeFactory.getWriteMode("test_queries", "delete_from_table");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("foobar", "Blarg");
        assertEquals(1, m.executeUpdate(params));
        // Close our Session so we test to make sure it
        // actually deleted.
        commitAndCloseSession();
        lookup("Blarg", 1, 0);
    }

    public void testUpdate() throws Exception {
        insert("update_test", 4);

        WriteMode m = ModeFactory.getWriteMode("test_queries", "update_in_table");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("foobar", "after_update");
        params.put("id", new Integer(4));
        int res = m.executeUpdate(params);
        assertEquals(1, res);
        // Close our Session so we test to make sure it
        // actually updated.
        commitAndCloseSession();
        lookup("after_update", 4, 1);
    }

    /** This test makes sure we can call "execute" multiple times
     * and re-use the existing internal transaction within the CommitableMode
     */
    public void testUpdateMultiple() throws Exception {
        insert("update_multi_test", 5);

        WriteMode m = ModeFactory.getWriteMode("test_queries", "update_in_table");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("foobar", "after_update_multi");
        params.put("id", new Integer(5));
        int res = m.executeUpdate(params);
        m = ModeFactory.getWriteMode("test_queries", "update_in_table");
        // Call it 5 times to make sure we can
        // execute it multipletimes.
        for (int i = 0; i < 5; i++) {
            res = m.executeUpdate(params);
            assertEquals(1, res);
        }
        lookup("after_update_multi", 5, 1);
    }

    public void testGetCallable() throws Exception {
        CallableMode m = ModeFactory.getCallableMode("test_queries",
                                        "stored_procedure_jdbc_format");
        assertNotNull(m);
    }

    public void testCollectionCreate() {
        List ll = new LinkedList();
        for (int i = 0; i < 13; i++) {
            ll.add("i" + i);
        }
        DataResult dr = new DataResult(ll);
        assertTrue(dr.size() == 13);
        assertTrue(dr.getStart() == 1);
        assertTrue(dr.getEnd() == 13);

    }

    public void testStoredProcedureJDBC() throws Exception {
        CallableMode m = ModeFactory.getCallableMode("test_queries",
                                        "stored_procedure_jdbc_format");
        Map inParams = new HashMap();
        Map outParams = new HashMap();
        inParams.put("label", "noarch");
        outParams.put("arch", new Integer(Types.NUMERIC));
        Map row = m.execute(inParams, outParams);
        assertNotNull(row);
        assertEquals(100, ((Long)row.get("arch")).intValue());

    }

    public void testStoredProcedureOracle() throws Exception {
        CallableMode m = ModeFactory.getCallableMode("test_queries",
                                        "stored_procedure_oracle_format");
        Map inParams = new HashMap();
        Map outParams = new HashMap();
        inParams.put("label", "noarch");
        outParams.put("arch", new Integer(Types.NUMERIC));
        Map row = m.execute(inParams, outParams);
        assertNotNull(row);
        assertEquals(100, ((Long)row.get("arch")).intValue());
    }

    public void testInClause() {
        SelectMode m = ModeFactory.getMode("test_queries", "select_in");
        List params = new ArrayList();
        params.add(1);
        params.add(2);
        params.add(3);
        DataResult result = m.execute(params);
        assertNotNull(result);
        assertNotEmpty(result);
    }

    public void testStressedElaboration() throws Exception {
        int startId = 1000;
        int endId = startId + 1500;

        for (int i = startId; i < endId; i++) {
            insert("foobar" + TestUtils.randomString(), i);
        }
        SelectMode m = ModeFactory.getMode("test_queries", "find_all_in_table");
        DataResult<AdvDataSourceDto> dr = m.execute(Collections.EMPTY_MAP);
        dr.elaborate();
        for (AdvDataSourceDto row : dr) {
            assertNotNull(row.getTestColumn());
            assertNotNull(row.getPin());
            assertNotNull(row.getFoobar());
        }
    }

    public void testMaxRowsWithElaboration() throws Exception {
        int startId = 1000;
        int endId = startId + 50;

        for (int i = startId; i < endId; i++) {
            insert("foobar" + TestUtils.randomString(), i);
        }
        SelectMode m = ModeFactory.getMode("test_queries", "find_all_in_table");
        m.setMaxRows(10);
        DataResult<AdvDataSourceDto> dr = m.execute(Collections.EMPTY_MAP);
        assertEquals(10, dr.size());
        dr.elaborate();
        assertTrue(dr.size() <= 10);
        for (AdvDataSourceDto row : dr) {
            assertNotNull(row.getTestColumn());
            assertNotNull(row.getPin());
            assertNotNull(row.getFoobar());
        }
    }

    public void testSelectInWithParams() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "select_in_withparams");
        List inclause = new ArrayList();
        inclause.add(500);
        inclause.add(1);
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("name", "jesusr");

        DataResult dr = m.execute(params, inclause);
        assertNotNull(dr);
        System.out.println(dr);
    }


    @Override
    protected void setUp() throws Exception {
        HibernateFactory.getSession().doWork(connection -> {
            Statement statement = connection.createStatement();
            try {
                if (ConfigDefaults.get().isOracle()) {
                    statement.execute("create table adv_datasource " +
                        "( " +
                        "  foobar VarChar2(32)," +
                        "  test_column VarChar2(25)," +
                        "  pin    number, " +
                        "  id     number" +
                        "         constraint adv_datasource_pk primary key" +
                        ")"
                    );
                }
                else {
                    statement.execute("create table adv_datasource " +
                        "( " +
                        "  foobar VarChar," +
                        "  test_column VarChar," +
                        "  pin    numeric, " +
                        "  id     numeric" +
                        "         constraint adv_datasource_pk primary key" +
                        ");"
                    );
                }
                connection.commit();
            }
            finally {
                HibernateHelper.cleanupDB(statement);
            }
        });
    }

    protected void tearDown() throws Exception {
        HibernateFactory.getSession().doWork(connection -> {
            Statement statement = null;
            try {
                statement = connection.createStatement();
                forceQuery(connection, "drop table adv_datasource");
                connection.commit();
            }
            finally {
                HibernateHelper.cleanupDB(statement);
            }
        });
    }

    private static void forceQuery(Connection c, String query) {
        try {
            Statement stmt = c.createStatement();
            stmt.execute(query);
        }
        catch (SQLException se) {
            log.warn("Failed to execute query " + query + ": " + se.toString());
        }
    }

    public void testFoo() {
        SelectMode mode = ModeFactory.getMode("Errata_queries",
                "unscheduled_relevant_to_system");
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("user_id", 1);
        params.put("sid", 1000010173);
        DataResult dr = mode.execute(params);
        dr.elaborate(params);
        System.out.println(dr);
    }
}
