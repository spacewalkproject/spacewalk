/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.CachedStatement;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.MapColumnNotFoundException;
import com.redhat.rhn.common.db.datasource.Mode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.ModeNotFoundException;
import com.redhat.rhn.common.db.datasource.ParameterValueNotFoundException;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateHelper;
import com.redhat.rhn.common.util.manifestfactory.ManifestFactoryLookupException;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.hibernate.Session;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class DataSourceParserTest extends RhnBaseTestCase {

    public DataSourceParserTest() {
    }

    public void testGetModes() throws Exception {
        SelectMode m = ModeFactory.getMode("System_queries", "ssm_remote_commandable");
        assertNotNull(m);
    }

    public void testGetModesNoFile() throws Exception {
        try {
            ModeFactory.getMode("Garbage", "ssm_remote_commandable");
            fail("Should have received an exception");
        }
        catch (ManifestFactoryLookupException e) {
            // Expected this exception, Garbage isn't a valid file.
        }
    }

    public void testGetModesNoMode() throws Exception {
        try {
            ModeFactory.getMode("test_queries", "Garbage");
            fail("Should have received an exception");
        }
        catch (ModeNotFoundException e) {
            // Expected this exception, Garbage isn't a valid file.
        }
    }

    public void testExternalElaborator() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries",
                                           "user_tables_external_elaborator");
        assertNotNull(m);

        DataResult dr = m.execute(new HashMap());
        assertNotNull(dr);

        Iterator i = dr.iterator();
        int pos = 0;
        while (i.hasNext()) {
            HashMap hm = (HashMap)i.next();
            String name = (String)hm.get("username");

            if (name.equals("SYS")) {
                dr = (DataResult)dr.subList(pos, pos + 1);
            }
            pos++;
        }

        HashMap parameters = new HashMap();
        parameters.put("user_name", "SYS");
        dr.elaborate(parameters);
        assertNotNull(dr);

        i = dr.iterator();
        while (i.hasNext()) {
            Map hm = (Map)i.next();
            Map elab = (Map)hm.get("external_elaborator");
            assertTrue(((Long)elab.get("table_count")).intValue() > 0);
        }
    }

    public void testRunQuery() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "user_tables");
        assertNotNull(m);

        DataResult dr = m.execute(new HashMap());
        assertNotNull(dr);

        Iterator i = dr.iterator();
        int pos = 0;
        while (i.hasNext()) {
            HashMap hm = (HashMap)i.next();
            String name = (String)hm.get("username");

            if (name.equals("SYS")) {
                dr = (DataResult)dr.subList(pos, pos + 1);
            }
            pos++;
        }

        HashMap parameters = new HashMap();
        parameters.put("user_name", "SYS");
        dr.elaborate(parameters);
        assertNotNull(dr);

        i = dr.iterator();
        while (i.hasNext()) {
            Map hm = (Map)i.next();
            Map elab = (Map)hm.get("table_elaborator");
            assertTrue(((Long)elab.get("table_count")).intValue() > 0);
        }
    }

    private boolean shouldSkip(Mode m) {
        /* Don't do plans for queries that use system tables or for
         * dummy queries.
         */
        return (m != null && m.getQuery() != null &&
                (m.getName().equals("tablespace_overview") ||
                 m.getQuery().getOrigQuery().trim().startsWith("--")));
    }

    public void testPrepareAll() throws Exception {
        Session sess = HibernateFactory.getSession();
        Connection conn = sess.connection();
        PreparedStatement ps = null;
        try {
            Collection fileSet = ModeFactory.getKeys();
            Iterator i = fileSet.iterator();
            while (i.hasNext()) {
                String file = (String)i.next();
                Iterator j = ModeFactory.getFileKeys(file).values().iterator();

                while (j.hasNext()) {
                    Mode m = (Mode)j.next();

                    if (shouldSkip(m)) {
                        continue;
                    }
                    CachedStatement stmt = m.getQuery();
                    if (stmt != null) {
                        String query = m.getQuery().getQuery();

                        // HACK!  Some of the queries actually have %s in them.
                        // So, replace all %s with :rbb so that the explain plan
                        // can be generated.
                        query = query.replaceAll("%s", ":rbb");

                        ps = conn.prepareStatement(query);
                    }
                }
            }
        }
        finally {
            if (conn != null) {
                conn.commit();
            }
            HibernateHelper.cleanupDB(ps);
        }
    }

    private void runTestQuery(String queryName, String elabName) throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", queryName);
        assertNotNull(m);

        DataResult dr = m.execute(new HashMap());
        assertNotNull(dr);

        Iterator i = dr.iterator();
        // Pick the first three tables, just so that we aren't elaborating
        // all of the tables.
        dr = (DataResult)dr.subList(0, 3);

        dr.elaborate(new HashMap());
        assertNotNull(dr);
        assertEquals(3, dr.size());

        i = dr.iterator();
        while (i.hasNext()) {
            Map hm = (Map)i.next();
            List elab = (List)hm.get(elabName);
            assertTrue(elab.size() > 0);
            Iterator j = elab.iterator();
            while (j.hasNext()) {
                Map curr = (Map)j.next();
                assertTrue(((Long)curr.get("column_id")).intValue() > 0);
                assertNotNull(curr.get("column_name"));
                assertNotNull(curr.get("table_name"));
            }
        }
    }

    public void testPercentS() throws Exception {
        runTestQuery("all_tables", "elaborator0");
    }

    public void testBrokenDriving() throws Exception {
        try {
            runTestQuery("broken_driving", "elaborator0");
            fail("Should have thrown an exception");
        }
        catch (MapColumnNotFoundException e) {
            assertEquals("Column, id, not found in driving query results",
                         e.getMessage());
        }
    }

    public void testBrokenElaborator() throws Exception {
        try {
            runTestQuery("broken_elaborator", "elaborator0");
            fail("Should have thrown an exception");
        }
        catch (MapColumnNotFoundException e) {
            assertEquals("Column, id, not found in elaborator results",
                         e.getMessage());
        }
    }

    public void testAlias() throws Exception {
        runTestQuery("all_tables_with_alias", "details");
    }

    public void testExtraParams() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "all_tables");
        assertNotNull(m);

        HashMap params = new HashMap();
        params.put("foo", "bar");
        DataResult dr = m.execute(params);
        assertNotNull(dr);
    }

    public void testDrivingParams() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "user_tables_for_user");
        assertNotNull(m);

        HashMap hm = new HashMap();
        hm.put("username", "SYS");
        DataResult dr = m.execute(hm);
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
    }

    public void testNullParam() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "user_tables_for_user");
        assertNotNull(m);

        try {
            m.execute(new HashMap());
            fail("Should have received an exception");
        }
        catch (ParameterValueNotFoundException e) {
            assertEquals("Could not set null value for parameter: username",
                         e.getMessage());
        }
    }

    public void testSort() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "all_tables_with_sort");
        assertNotNull(m);

        DataResult dr = m.execute(new HashMap());
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        Iterator i = dr.iterator();
        Map first = (Map)i.next();
        Map second;
        while (i.hasNext()) {
            second = (Map)i.next();
            String t1 = (String)first.get("table_name");
            String t2 = (String)second.get("table_name");
            assertTrue(t1.compareTo(t2) <= 0);
            first = second;
        }
    }

    public void testSortChangeOrder() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "all_tables_with_sort");
        assertNotNull(m);

        DataResult dr = m.execute(new HashMap(), "table_name", "DESC");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        Iterator i = dr.iterator();
        Map first = (Map)i.next();
        Map second;
        while (i.hasNext()) {
            second = (Map)i.next();
            String t1 = (String)first.get("table_name");
            String t2 = (String)second.get("table_name");
            assertTrue(t1.compareTo(t2) >= 0);
            first = second;
        }
    }

    public void testSortColumn() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "all_tables_with_sort");
        assertNotNull(m);

        DataResult dr = m.execute(new HashMap(), "owner", "DESC");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        Iterator i = dr.iterator();
        Map first = (Map)i.next();
        Map second;
        while (i.hasNext()) {
            second = (Map)i.next();
            String t1 = (String)first.get("owner");
            String t2 = (String)second.get("owner");
            assertTrue(t1.compareTo(t2) >= 0);
            first = second;
        }
    }

    public void testIllegalSortColumn() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "all_tables_with_sort");
        assertNotNull(m);

        try {
            m.execute(new HashMap(), "foobar", "DESC");
            fail("Should have received exception");
        }
        catch (IllegalArgumentException e) {
            // Expected exception
        }
    }

    public void testExternalQuery() throws Exception {
        SelectMode m = ModeFactory.getMode("System_queries", "visible_to_uid");
        HashMap params = new HashMap();
        params.put("formvar_uid", new Long(12345));
        DataResult dr = m.execute(params);
        assertEquals(m, dr.getMode());
    }

    public void testSpecifiedClass() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "withClass");
        String clazz = m.getClassString();
        assertEquals("com.redhat.rhn.common.db.datasource.test.TableData", clazz);
    }

    public void testSpecifiedClassExecute() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "withClass");
        String clazz = m.getClassString();
        assertEquals("com.redhat.rhn.common.db.datasource.test.TableData", clazz);
        DataResult dr = m.execute(new HashMap(), "owner", "DESC");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        Iterator i = dr.iterator();
        TableData first = (TableData)i.next();
        assertTrue(first.getTableName().startsWith("RHN"));
    }

    public void testClassElaborateList() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "withClass");
        String clazz = m.getClassString();
        assertEquals("com.redhat.rhn.common.db.datasource.test.TableData", clazz);
        DataResult dr = m.execute(new HashMap(), "owner", "DESC");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        dr = (DataResult)dr.subList(0, 1);
        dr.elaborate(new HashMap());

        Iterator i = dr.iterator();
        TableData first = (TableData)i.next();
        assertTrue(first.getTableName().startsWith("RHN"));
        assertTrue(first.getColumnName().size() > 0);
        assertTrue(first.getColumnId().size() > 0);
    }

    public void testSpecifiedClassElaborate() throws Exception {
        SelectMode m = ModeFactory.getMode("test_queries", "user_class");
        String clazz = m.getClassString();
        assertEquals("com.redhat.rhn.common.db.datasource.test.UserData", clazz);
        HashMap hm = new HashMap();
        hm.put("username", "SYS");
        DataResult dr = m.execute(hm);
        assertNotNull(dr);
        assertTrue(dr.size() > 0);

        dr.elaborate(hm);

        Iterator i = dr.iterator();
        UserData first = (UserData)i.next();
        assertNotNull(first.getUsername());
        assertTrue(first.getTableCount().intValue() > 0);
    }
}
