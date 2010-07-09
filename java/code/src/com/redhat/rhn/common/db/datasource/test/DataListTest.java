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

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class DataListTest extends RhnBaseTestCase {
    private HookedSelectMode hsm;
    private Map params;
    private Map elabParams;

    public void setUp() {
        hsm = new HookedSelectMode(
                ModeFactory.getMode("test_queries", "user_tables"));
        params = new HashMap();
        elabParams = new HashMap();
        elabParams.put("user_name", "RHN");
    }

    public void tearDown() {
        hsm = null;
        params = null;
        elabParams = null;
    }

    public void testElaborate() {
        DataList list = getList();
        list.iterator();
        assertTrue(hsm.isElaborated());
    }

    public void testSubList() {
        //work it like a list
        DataList list = getList();
        DataList sub = getSubList(list);

        //subList does not force elaboration
        assertFalse(hsm.isElaborated());
        //No elaboration until data is actually accessed.
        sub.toString();
        assertFalse(hsm.isElaborated());
        sub.isEmpty();
        assertFalse(hsm.isElaborated());
        sub.get(1);
        assertTrue(hsm.isElaborated());
    }

    public void testElaborateOnce() {
        //at first, nothing is elaborated
        List list = getList();
        assertEquals(0, hsm.getElaborated());

        //iterator causes elaboration
        list.iterator();
        assertEquals(1, hsm.getElaborated());
        //don't elaborate again
        list.get(1);
        assertEquals(1, hsm.getElaborated());

        DataList sub = getSubList((DataList)list);
        assertEquals(1, hsm.getElaborated());
        //sublist should also know that it is already elaborated
        sub.iterator();
        assertEquals(1, hsm.getElaborated());
        assertEquals(sub.getMode(), hsm);
    }

    private DataList getList() {
        //test the get method
        DataList list = DataList.getDataList(hsm, params, elabParams);
        assertTrue(list.size() > 0);
        assertFalse(hsm.isElaborated());
        return list;
    }

    private DataList getSubList(DataList list) {
        int end = list.size() < 11 ? list.size() - 1 : 10;
        List sub = list.subList(0, end);
        assertTrue(sub.size() == end);
        assertEquals(sub.getClass(), DataList.class);
        DataList subby = (DataList) sub;
        return subby;
    }


    public class HookedSelectMode extends SelectMode {
        private int elaborated;

        public HookedSelectMode(SelectMode m) {
            super(m);
            elaborated = 0;
        }

        public void elaborate(List resultList, Map param) {
            elaborated++;
            super.elaborate(resultList, param);
        }

        public boolean isElaborated() {
            return (elaborated > 0);
        }

        public int getElaborated() {
            return elaborated;
        }
    }

}
