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
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * RhnSetElementTest
 * @version $Rev$
 */
public class RhnSetElementTest extends RhnBaseTestCase {

    public void testDefaultCtor() {
        RhnSetElement rse = new RhnSetElement();
        assertNotNull(rse);
        assertNull(rse.getUserId());
        assertNull(rse.getLabel());
        assertNull(rse.getElement());
        assertNull(rse.getElementTwo());
    }
    
    public void testArgCtorWithNulls() {
        RhnSetElement rse = new RhnSetElement(null, null, null, null);
        assertNotNull(rse);
        assertNull(rse.getUserId());
        assertNull(rse.getLabel());
        assertNull(rse.getElement());
        assertNull(rse.getElementTwo());
    }
    
    public void testTwoArgCtor() {
        Long id = new Long(10);
        Long elem = new Long(400);
        String label = "label foo";
        RhnSetElement rse = new RhnSetElement(id, label, elem, elem);
        assertNotNull(rse);
        assertEquals(id, rse.getUserId());
        assertEquals(label, rse.getLabel());
        assertEquals(elem, rse.getElement());
        assertEquals(elem, rse.getElementTwo());
    }
    
    public void testThreeArgCtor() {
        Long id = new Long(10);
        Long elem = new Long(400);
        String label = "label foo";
        RhnSetElement rse = new RhnSetElement(id, label, elem, elem, elem);
        assertNotNull(rse);
        assertEquals(id, rse.getUserId());
        assertEquals(label, rse.getLabel());
        assertEquals(elem, rse.getElement());
        assertEquals(elem, rse.getElementTwo());
        assertEquals(elem, rse.getElementThree());
    }

    public void testBeanProperties() {
        Long id = new Long(10);
        Long elem = new Long(400);
        String label = "label foo";
        RhnSetElement rse = new RhnSetElement();
        assertNotNull(rse);
        rse.setUserId(id);
        assertEquals(id, rse.getUserId());
        
        rse.setLabel(label);
        assertEquals(label, rse.getLabel());
        
        rse.setElement(elem);
        assertEquals(elem, rse.getElement());

        rse.setElement(null);
        assertNull(rse.getElement());

        rse.setElementTwo(elem);
        assertEquals(elem, rse.getElementTwo());

        rse.setElementTwo(null);
        assertNull(rse.getElementTwo());
        
        rse.setElementThree(elem);
        assertEquals(elem, rse.getElementThree());

        rse.setElementThree(null);
        assertNull(rse.getElementThree());
    }
    
    public void testEquals() {
        Long uid = new Long(42);
        Long elem = new Long(3131);
        Long elemTwo = new Long(3132);
        Long elemThree = new Long(3133);
        String label = "testEquals label";
        
        RhnSetElement r1 = new RhnSetElement();
        RhnSetElement r2 = new RhnSetElement();
        assertEquals(r1, r2);
        
        r1.setUserId(uid);
        r2.setUserId(uid);
        assertEquals(r1, r2);
        r1.setLabel(label);
        r2.setLabel(label);
        assertEquals(r1, r2);
        r1.setElement(elem);
        r2.setElement(elem);
        assertEquals(r1, r2);

        r1.setElementTwo(elemTwo);
        r2.setElementTwo(elemTwo);
        assertEquals(r1, r2);
        r2.setElementTwo(elem);
        assertFalse(r1.equals(r2));
        r2.setElementTwo(null);
        assertFalse(r2.equals(r1));
        assertFalse(r1.equals(r2));
        r1.setElementTwo(null);
        assertEquals(r1, r2);
        
        r1.setElementThree(elemThree);
        r2.setElementThree(elemThree);
        assertEquals(r1, r2);
        r2.setElementThree(elem);
        assertFalse(r1.equals(r2));
        r2.setElementThree(null);
        assertFalse(r2.equals(r1));
        assertFalse(r1.equals(r2));
        r1.setElementThree(null);
        assertEquals(r1, r2);

    }
    
    public void testStringConstructor() {
        Long uid = new Long(42);
        String label = "testEquals label";
        Long elem = new Long(3131);
        Long elemTwo = new Long(3132);
        RhnSetElement r1 = new RhnSetElement(uid, label,
                                                    elem + "|" + elemTwo);
        RhnSetElement r2 = new RhnSetElement(uid, label,
                                                    elem, elemTwo);
        assertEquals(r1, r2);

        Long elemThree = new Long(3133);
        r1 = new RhnSetElement(uid, label, elem + "|" + elemTwo + "|" + elemThree);
        r2 = new RhnSetElement(uid, label, elem, elemTwo, elemThree);

        assertEquals(r1, r2);
    }
}
