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
package com.redhat.rhn.domain.rhnset.test;

import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.rhnset.RhnSetImpl;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.Iterator;
import java.util.Set;

/**
 * RhnSetTest
 * @version $Rev$
 */
public class RhnSetTest extends RhnBaseTestCase {
    private static final String[] TEST_ELEMS = {"100", "150", "300", "175", "35"};
    private RhnSetImpl set;

    protected void setUp() throws Exception {
        super.setUp();
        set = new RhnSetImpl();
        set.sync();
    }

    protected void tearDown() throws Exception {
        super.tearDown();
        set = null;
    }

    public void testUserId() {
        Long id = new Long(10);
        set.setUserId(id);
        assertEquals(id, set.getUserId());
    }

    public void testLabel() {
        set.setLabel("set_label");
        assertEquals("set_label", set.getLabel());
    }

    public void testElement() {
        Long num = new Long(10);
        set.addElement(num, null);
        set.addElement(num, num);
        set.addElement(num, num, null);
        set.addElement(num, num, num);

        Set elements = set.getElements();
        assertNotNull(elements);
        assertEquals(set.size(), elements.size());
        assertEquals(3, set.size());
        assertAddRemove(3, 0);

        int i = 0;
        for (Iterator itr = elements.iterator(); itr.hasNext();) {
            RhnSetElement element = (RhnSetElement) itr.next();
            if (element.getElementTwo() != null && element.getElementThree() != null) {
                assertEquals(num, element.getElement());
                assertEquals(num, element.getElementTwo());
                assertEquals(num, element.getElementThree());
            }
            else if (element.getElementTwo() != null && element.getElementThree() == null) {
                assertEquals(num, element.getElement());
                assertEquals(num, element.getElementTwo());
                assertNull(element.getElementThree());
            }
            else if (element.getElementTwo() == null && element.getElementThree() != null) {
                assertEquals(num, element.getElement());
                assertNull(element.getElementTwo());
                assertEquals(num, element.getElementThree());
            }
            else {
                assertEquals(num, element.getElement());
                assertNull(element.getElementTwo());
                assertNull(element.getElementThree());
            }
            i++;
        }

        assertEquals(3, i);

        set.removeElement(num, num);

        assertEquals(2, set.size());
        assertTrue(set.contains(num));
        assertFalse(set.contains(num, num));
        assertAddRemove(2, 0);

        set.setLabel("label");
        assertEquals("label", set.getLabel());
    }

    public void testGetElementValues() {
        set.addElement(new Long(100));
        set.addElement(new Long(101));

        Set values = set.getElementValues();
        assertEquals(2, values.size());
        assertTrue(values.contains(new Long(100)));
        assertTrue(values.contains(new Long(101)));
    }

    public void testAddElements() {
        set.addElements(TEST_ELEMS);

        Set elements = set.getElements();
        assertNotNull(elements);
        assertEquals(TEST_ELEMS.length, elements.size());
        assertEquals(5, elements.size());

        String[] testElems2 = {"100|50", "10|90", "30|30"};

        set.addElements(testElems2);
        elements = set.getElements();
        assertEquals(8, elements.size());
        assertTrue(set.contains(new Long("150")));
        assertTrue(set.contains(new Long("100"), new Long("50")));
        assertFalse(set.contains(new Long("10"), new Long("91")));
        assertAddRemove(8, 0);
    }

    public void testRemoveElements() {
        String[] removeElems = {"100", "300"};

        set.addElements(TEST_ELEMS);

        set.removeElements(removeElems);

        assertTrue(set.contains(new Long("150")));
        assertFalse(set.contains(new Long("350")));
        assertFalse(set.contains(new Long("300")));
        assertAddRemove(3, 0);
    }

    public void testMark() {
        set.addElements(TEST_ELEMS);
        set.sync();
        assertAddRemove(0, 0);
        set.removeElement(new Long(100));
        assertAddRemove(0, 1);
        set.addElement(new Long(100));
        assertAddRemove(0, 0);
        set.addElement(new Long(42));
        assertAddRemove(1, 0);
        set.sync();
        assertAddRemove(0, 0);
    }

    public void testNullAddElements() {
        // make sure we don't cause a NullPointerException
        try {
            set.addElements(null);

            Set elements = set.getElements();
            assertNotNull(elements);
            assertEquals(0, elements.size());

            String[] testElems2 = {"100|50", "10|90", "30|30"};

            set.addElements(testElems2);
            elements = set.getElements();
            assertEquals(3, elements.size());
            assertTrue(set.contains(new Long("100"), new Long("50")));
            assertFalse(set.contains(new Long("10"), new Long("91")));
            assertAddRemove(3, 0);
        }
        catch (NullPointerException npe) {
            fail("addElements didn't accept a null array");
        }
    }

    public void testNullRemoveElements() {
        try {
            set.removeElements(null);
            Set elements = set.getElements();
            assertNotNull(elements);
            assertEquals(0, elements.size());
        }
        catch (NullPointerException npe) {
            fail("removeElements didn't accept a null array");
        }
    }

    private void assertAddRemove(int added, int removed) {
        assertEquals(added, set.getAdded().size());
        assertEquals(removed, set.getRemoved().size());
    }
}
