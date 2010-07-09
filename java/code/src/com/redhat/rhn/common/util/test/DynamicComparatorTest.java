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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DynamicComparator;
import com.redhat.rhn.common.validator.test.TestObject;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnJmockBaseTestCase;

import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

public class DynamicComparatorTest extends RhnJmockBaseTestCase {

    public void testComparatorMaps() {
        List list = generateRandomList();
        DynamicComparator comp = new DynamicComparator("stringField",
                RequestContext.SORT_ASC);
        Collections.sort(list, comp);
        assertTrue(((TestObject) list.get(0)).getStringField().equals("A"));
        assertTrue(((TestObject) list.get(list.size() - 1)).getStringField().equals("Z"));
    }

    public static List generateRandomList() {
        List retval = new LinkedList();
        List letters = LocalizationService.getInstance().getAlphabet();
        Collections.shuffle(letters);
        Iterator i = letters.iterator();
        while (i.hasNext()) {
            TestObject to = new TestObject();
            to.setStringField((String) i.next());
            retval.add(to);
        }
        return retval;
    }



}
