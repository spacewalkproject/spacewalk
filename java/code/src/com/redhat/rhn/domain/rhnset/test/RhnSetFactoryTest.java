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

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.Iterator;
import java.util.Set;

/**
 * RhnSetFactoryTest
 * @version $Rev$
 */
public class RhnSetFactoryTest extends RhnBaseTestCase {
    
    public void testConstructor() {
        Long id = new Long(10);
        RhnSet set = RhnSetFactory.createRhnSet(id, null, SetCleanup.NOOP);
        assertNotNull(set);
        assertEquals(id, set.getUserId());
        
        Set elements = set.getElements();
        assertNotNull(elements);
        assertEquals(0, elements.size());
        assertNull(set.getLabel());
    }
    
    public void testBeanProperties() {
        Long num = new Long(10);
        RhnSet set = RhnSetFactory.createRhnSet(num, null, SetCleanup.NOOP);
        assertNotNull(set);
        assertEquals(num, set.getUserId());
        
        set.addElement(num, null);
        set.addElement(num, num);
        set.addElement(num, num, null);
        set.addElement(num, num, num);
        
        Set elements = set.getElements();
        assertNotNull(elements);
        assertEquals(set.size(), elements.size());
        assertEquals(3, set.size());

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
        
        set.setLabel("label");
        assertEquals("label", set.getLabel());
    }
}
