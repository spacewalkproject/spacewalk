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

package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.CharacterMap;
import com.redhat.rhn.testing.RhnBaseTestCase;

public class CharacterMapTest extends RhnBaseTestCase {

    public CharacterMapTest(final String name) {
        super(name);
    }

    public void testPut() {
        Character c = new Character('C');
        CharacterMap cm = new CharacterMap();
        assertTrue(cm.size() == 0);
        cm.put(c, new Integer(5));
        assertTrue(cm.containsKey(new Character('C')));
        assertTrue(cm.containsKey('C'));
        assertTrue(cm.size() == 1);
        assertTrue(cm.get(c).equals(new Integer(5)));
    }

    public void testEquals() {
        CharacterMap cm1 = new CharacterMap();
        CharacterMap cm2 = new CharacterMap();
        Character a = new Character('A');
        Character b = new Character('B');
        Integer i = new Integer(5);

        assertTrue(cm1.equals(cm1));
        assertTrue(cm1.equals(cm2));
        cm1.put(a, i);
        cm2.put(a, i);
        assertTrue(cm1.equals(cm1));
        assertTrue(cm1.equals(cm2));
        cm2.put(b, i);
        assertFalse(cm1.equals(cm2));

        CharacterMap cm3 = cm1;
        assertEquals(cm1, cm3);
        assertTrue(cm1.equals(cm3));

        //test hashCode while we're here...
        cm1.put(b, i);
        assertEquals(cm1.hashCode(), cm2.hashCode());
    }
}
