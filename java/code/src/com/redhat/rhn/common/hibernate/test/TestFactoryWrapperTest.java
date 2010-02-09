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
package com.redhat.rhn.common.hibernate.test;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.HibernateHelper;
import com.redhat.rhn.domain.test.TestFactory;
import com.redhat.rhn.domain.test.TestInterface;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.List;

import junit.extensions.TestSetup;
import junit.framework.Test;
import junit.framework.TestSuite;

/*
 * $Rev$
 */
public class TestFactoryWrapperTest extends RhnBaseTestCase {
    private static Logger log = Logger.getLogger(TestFactoryWrapperTest.class);

    public TestFactoryWrapperTest(String name) {
        super(name);
    }

    public void testLookupReturnNull() throws Exception {
        TestInterface obj = TestFactory.lookupByFoobar("NOTFOUND");
        assertNull(obj);
    }
    
    // This is a trivial test, but it proves that we can create a simple
    // SQL query automatically from the table definition.
    public void testLookup() throws Exception {
        TestInterface obj = TestFactory.lookupByFoobar("Blarg");
        assertEquals("Blarg", obj.getFoobar()); 
        // 1 is a magic number, this is basically checking that the id is set
        // correctly.  We know this will be 1, because we create the sequence
        // to start at 0, and Blarg is the first value inserted.
        assertTrue(obj.getId().longValue() == 1); 
    }

     public void testNullIntoPrimitive() throws Exception {
         TestInterface obj = TestFactory.lookupByFoobar("Blarg");
         assertEquals("Blarg", obj.getFoobar());
         assertNull(obj.getPin());
         // 1 is a magic number, this is basically checking that the id is set
         // correctly.  We know this will be 1, because we create the sequence
         // to start at 0, and Blarg is the first value inserted.
         assertTrue(obj.getId().longValue() == 1);
     }

    public void testNewInsert() throws Exception {
        TestInterface obj = TestFactory.createTest();
        obj.setFoobar("testNewInsert");
        TestFactory.save(obj);
        assertTrue(obj.getId().longValue() != 0L);
        TestFactory.lookupByFoobar("testNewInsert");
        assertEquals("testNewInsert", obj.getFoobar()); 
        assertTrue(obj.getId().longValue() != 0); 
    }


    public void testUpdate() throws Exception {

        TestInterface obj = TestFactory.createTest();
        obj.setFoobar("update_Multi_test");
        obj.setPin(new Integer(12345));
        TestFactory.save(obj);
        TestInterface result = TestFactory.lookupByFoobar("update_Multi_test");
        assertEquals("update_Multi_test", result.getFoobar()); 

        result.setFoobar("After_multi_change");
        result.setPin(new Integer(54321));
        TestFactory.save(result);
        TestInterface updated = TestFactory.lookupByFoobar("After_multi_change");
        assertEquals("After_multi_change", updated.getFoobar()); 
        assertEquals(54321, updated.getPin().intValue()); 
    }

    public void testUpdateAfterCommit() throws Exception {
        TestInterface obj = TestFactory.createTest();
        obj.setFoobar("update_test");
        TestFactory.save(obj);
        TestFactory.save(obj);
        // Make sure we make it here without exception
        assertTrue(true);
    }

    public void testLookupMultipleObjects() throws Exception {
        List allTests = TestFactory.lookupAll();
        assertTrue(allTests.size() > 0);
    }
    
    public void testUpdateToNullValue() throws Exception {
        TestInterface obj = TestFactory.createTest();
        obj.setFoobar("update_test3");
        obj.setTestColumn("AAA");
        TestFactory.save(obj);
        TestInterface result = TestFactory.lookupByFoobar("update_test3");
        assertEquals("update_test3", result.getFoobar()); 

        result.setFoobar("After_change3");
        // This is the critical part where we set a value
        // that once had a value to a NULL value
        result.setTestColumn(null);
        TestFactory.save(result);
        result = TestFactory.lookupByFoobar("After_change3");
        assertTrue(result.getTestColumn() == null); 
    }

    public void testLotsOfTransactions() throws Exception {
    
        for (int i = 0; i < 20; i++) {
            SelectMode m = ModeFactory.getMode("test_queries", "date_dto_test");
            m.execute(new HashMap());
            HibernateFactory.commitTransaction();
            HibernateFactory.closeSession();
        }
        
    }
    
    
    public static Test suite() 
        throws Exception {
        TestSuite suite = new TestSuite(TestFactoryWrapperTest.class);
        TestSetup wrapper = new TestSetup(suite) {
            protected void setUp() throws Exception {
                oneTimeSetup();
            }

            protected void tearDown() throws Exception {
                oneTimeTeardown();
            }
        };

        return wrapper;
    }

    protected static void oneTimeSetup() throws Exception {
        Connection c = null;
        Statement stmt = null;
        Session session = null;
        try {
            session = HibernateFactory.getSession();
            c = session.connection();
            stmt = c.createStatement();
            stmt.executeQuery("select 1 from persist_test");
        }
        catch (SQLException e) {
            // let's clean up anything that MAY have been left
            // over 
            forceQuery(c, "drop sequence persist_sequence");
            forceQuery(c, "drop table persist_test");
            // Couldn't select 1, so the table didn't exist, create it
            stmt.execute("create sequence persist_sequence");
            stmt.execute("create table persist_test " +
                    "( " +
                    "  foobar VarChar2(32)," +
                    "  test_column VarChar2(5)," +
                    "  pin    number, " +
                    "  hidden VarChar(32), " + 
                    "  id     number" +
                    "         constraint persist_test_pk primary key," +
                    "  created date" +
                    ")");

            stmt.execute("insert into persist_test (foobar, id) " +
                    "values ('Blarg', persist_sequence.nextval)");
            stmt.execute("insert into persist_test (foobar, id) " +
                    "values ('duplicate', persist_sequence.nextval)");
            stmt.execute("insert into persist_test (foobar, id) " +
                    "values ('duplicate', persist_sequence.nextval)");
            stmt.execute("insert into persist_test (foobar, hidden, id) " +
                    "values ('duplicate', 'xxxxx', persist_sequence.nextval)");
                    
            c.commit();
        }
        finally {
            HibernateHelper.cleanupDB(stmt);
        }
    }

    protected static void oneTimeTeardown() throws Exception {
           
        Connection c = null;
        Statement stmt = null;
        Session session = null;        
        try {
            session = HibernateFactory.getSession();
            c = session.connection();
            stmt = c.createStatement();
            // Couldn't select 1, so the table didn't exist, create it
            forceQuery(c, "drop sequence persist_sequence");
            forceQuery(c, "drop table persist_test");
        }
        finally {
            HibernateHelper.cleanupDB(stmt);
        }
    }

    private static void forceQuery(Connection c, String query) {
        try {
            Statement stmt = c.createStatement();
            stmt.execute(query);
        }
        catch (SQLException se) {
            log.warn("Failed to execute query " + query + ": " +
                           se.toString());
        }
    }
}
