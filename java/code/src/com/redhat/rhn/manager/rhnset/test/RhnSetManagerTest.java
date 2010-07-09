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
package com.redhat.rhn.manager.rhnset.test;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * RhnManagerTest
 * @version $Rev$
 */
public class RhnSetManagerTest extends RhnBaseTestCase {

    /** user id to be used when creating RhnSet tests */
    private Long userId = null;
    private TestSetCleanup cleanup;

    private static final String TEST_USER_NAME = "automated_test_user_jesusr";
    private static final String TEST_ORG_NAME = "automated_test_org_jesusr";

    protected void setUp() throws Exception {
        super.setUp();
        userId = UserTestUtils.createUser(TEST_USER_NAME, TEST_ORG_NAME);
        cleanup = new TestSetCleanup();
    }

    protected void tearDown() throws Exception {
        userId = null;
        cleanup = null;
        super.tearDown();
    }
    /**
     * Looks for an RhnSet for a non-existent user.
     */
    public void testGetByLabelInvalidUser() {
        RhnSet set = RhnSetManager.findByLabel(new Long(10), "foo", cleanup);
        assertNull(set);
    }

    /**
     * Creates an RhnSet then verifies that it was stored in the db
     * by trying to fetch it again.
     */
    public void testCreateDeleteRhnSet() throws Exception {
        String label = "test_rhn_set_label";

        RhnSet set = RhnSetManager.createSet(userId, label, cleanup);
        set.addElement(new Long(1234), new Long(0));
        assertNotNull(set);
        RhnSetManager.store(set);
        assertEquals(1, cleanup.callbacks);
        RhnSet foundSet = RhnSetManager.findByLabel(userId, label, cleanup);
        assertNotNull(foundSet);
        assertEquals(1, foundSet.getElements().size());

        // get rid of it.
        RhnSetManager.deleteByLabel(userId, label);
        assertNull(RhnSetManager.findByLabel(userId, label, cleanup));
        assertEquals(1, cleanup.callbacks);
    }

    /**
     * Creates an RhnSet, then Deletes verifies it was deleted.
     */
    public void testCreateDeleteMultipleRhnSet() {
        RhnSet set = RhnSetManager.createSet(userId,
                        "test_rhn_set_label_delete", cleanup);
        // need to add an element to make this work.
        set.addElement(new Long(1121), new Long(11));
        set.addElement(new Long(1111), new Long(12));
        set.addElement(new Long(1111), null);
        assertNotNull(set);
        assertEquals(3, set.getElements().size());

        // store a new set in the DB.
        RhnSetManager.store(set);
        assertEquals(1, cleanup.callbacks);

        // let's try to find it, we should.
        RhnSet set1 = RhnSetManager.findByLabel(userId,
                        "test_rhn_set_label_delete", cleanup);
        assertNotNull(set1);
        assertEquals(3, set1.getElements().size());

        // let's delete the above set from the DB.
        RhnSetManager.deleteByLabel(userId,
                        "test_rhn_set_label_delete");

        // let's try to find it again, we better
        // not find anything.
        RhnSet set2 = RhnSetManager.findByLabel(userId,
                        "test_rhn_set_label_delete", cleanup);
        assertNull(set2);
        assertEquals(1, cleanup.callbacks);
    }

    /**
     * Tests the remove method of RhnSetManager
     */
    public void testCreateRemoveRhnSet() {
        RhnSet set = RhnSetManager.createSet(userId,
                        "test_rhn_set_label_remove", cleanup);
        set.addElement(new Long(42), new Long(10));
        set.addElement(new Long(423), new Long(324));
        assertNotNull(set);
        assertEquals(2, set.getElements().size());

        // store the new set in the DB.
        RhnSetManager.store(set);
        assertEquals(1, cleanup.callbacks);

        RhnSet set1 = RhnSetManager.findByLabel(userId,
                        "test_rhn_set_label_remove", cleanup);
        assertNotNull(set1);
        assertEquals(2, set.getElements().size());

        RhnSetManager.remove(set1);

        // let's try to find it again, we better
        // not find anything.
        RhnSet set2 = RhnSetManager.findByLabel(userId,
                        "test_rhn_set_label_remove", cleanup);
        assertNull(set2);
        assertEquals(1, cleanup.callbacks);
    }

    /**
     * Testing the store method of RhnSetManager
     */
    public void testStore() throws Exception {
        String label = "test_rhn_set_label_store";

        //Stores Set with null second element
        RhnSet set = RhnSetManager.createSet(userId, label, cleanup);
        set.addElement(new Long(31));
        set.addElement(new Long(464));
        RhnSetManager.store(set);
        assertEquals(1, cleanup.callbacks);

        //Deletes the previous and stores a new set
        //with one of the same elements
        RhnSet set2 = RhnSetManager.createSet(userId, label, cleanup);
        set2.addElement(new Long(57));
        set2.addElement(new Long(464)); //same as above
        RhnSetManager.store(set2);
        assertEquals(2, cleanup.callbacks);

        //Deletes the previous and stores a new set
        //with non-null second element
        RhnSet set3 = RhnSetManager.createSet(userId, label, cleanup);
        set3.addElement(new Long(31), new Long(11));
        set3.addElement(new Long(464), new Long(236));
        RhnSetManager.store(set3);
        assertEquals(3, cleanup.callbacks);

        //Deletes the previous and stores a new set
        //with one of the same elements
        RhnSet set4 = RhnSetManager.createSet(userId, label, cleanup);
        set4.addElement(new Long(46), new Long(87));
        set4.addElement(new Long(31), new Long(11)); //same as above
        RhnSetManager.store(set4);
        assertEquals(4, cleanup.callbacks);

        //Attempts to store a set with two rows having the
        //same first element or same second element
        RhnSet set5 = RhnSetManager.createSet(userId, label, cleanup);
        set5.addElement(new Long(75), new Long(87));
        set5.addElement(new Long(75), new Long(11));
        set5.addElement(new Long(36), new Long(11));
        RhnSetManager.store(set5);
        assertEquals(5, cleanup.callbacks);

        set = RhnSetManager.findByLabel(userId, label, cleanup);
        assertEquals(3, set.size());
        assertEquals(5, cleanup.callbacks);
    }

    public void testStoreElement3() throws Exception {
        String label = "test_rhn_set_store_element_3";

        // Tests storing something in element 3
        RhnSet set = RhnSetManager.createSet(userId, label, cleanup);
        set.addElement(new Long(11), new Long(22), new Long(33));
        RhnSetManager.store(set);

        set = RhnSetManager.findByLabel(userId, label, cleanup);
        assertEquals(1, set.size());

        RhnSetElement element = set.getElements().iterator().next();
        assertEquals(new Long(11), element.getElement());
        assertEquals(new Long(22), element.getElementTwo());
        assertEquals(new Long(33), element.getElementThree());
    }

    public static final class TestSetCleanup extends SetCleanup {
        private int callbacks = 0;

        public TestSetCleanup() {
            super("test", "test");
        }

        protected int cleanup(RhnSet set) {
            return callbacks++;
        }
    }
}
