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
package com.redhat.rhn.domain.task.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.task.Task;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.util.List;

/**
 * TaskTest
 * @version $Rev$
 */
public class TaskTest extends RhnBaseTestCase {

    public void testTask() throws Exception {

        Org org = UserTestUtils.findNewOrg("testOrg");
        String testname = "task_object_unit_test_" + TestUtils.randomString();
        Long testdata = new Long(42);
        Task t = TaskFactory.createTask(org, testname, testdata);
        
        flushAndEvict(t);
        
        //look the sucker back up
        Session session = HibernateFactory.getSession();
        Task t2 = TaskFactory.lookup(org, testname, testdata); 
        // need to flush and evict t2 here otherwise
        // the TaskFactory.lookup() down below will return the
        // SAME reference and cause the equals to fail.
        flushAndEvict(t2);
        
        assertNotNull(t2);
        assertEquals(testname, t2.getName());
        assertEquals(testdata, t2.getData());
        assertEquals(0, t.getPriority());
       
        Task t3 = null;
        assertFalse(t2.equals(t3));
        assertFalse(t2.equals(session));
        t3 = TaskFactory.lookup(org, testname, testdata); 
        
        assertEquals(t2, t3);
        t3.setName("foo");
        assertFalse("t2 should not be equal to t3", t2.equals(t3));
    }
    
    public void testLookupNameLike() throws Exception {
        Org org = UserTestUtils.findNewOrg("testOrg");
        String testname = "task_object_unit_test_" + TestUtils.randomString();
        Long testdata = new Long(42);
        Task t = TaskFactory.createTask(org, testname, testdata);
        
        List lookedup = TaskFactory.getTaskListByNameLike("task_object_unit_test_");
        assertNotNull(lookedup);
        assertTrue(lookedup.size() > 0);
        assertTrue(lookedup.get(0) != null);
        assertTrue(lookedup.get(0) instanceof Task);
    }
}
