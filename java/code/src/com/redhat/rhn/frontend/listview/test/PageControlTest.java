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

package com.redhat.rhn.frontend.listview.test;

import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.testing.RhnBaseTestCase;

public class PageControlTest extends RhnBaseTestCase {

    /**
     * Test the basic functionality of PageControl
     */
    public void testPageControl() {
        PageControl pc = new PageControl();      
        pc.setStart(5);
        pc.setFilterColumn("TestFilterColumn");
        pc.setFilterData("TestFilterData");
        pc.setIndexData(true);

        assertEquals(pc.getStart(), 5);
        assertEquals(pc.getEnd(), 29);
        assertEquals(pc.getFilterColumn(), "TestFilterColumn");
        assertEquals(pc.getFilterData(), "TestFilterData");
        assertEquals(pc.hasIndex(), true);
    }
    
    /**
     * Test the exception case of setStart.
     */        
    public void testIllegalArgument() {
        PageControl pc = new PageControl();
        boolean noexception = false;
        
        try {
            pc.setStart(0);
            noexception = true;
        }
        catch (IllegalArgumentException iae) {
            assertFalse(noexception);
        }
        
        try {
            pc.setStart(-10);
            noexception = true;
        }
        catch (IllegalArgumentException iae) {
            assertFalse(noexception);
        }
        
        try {
            pc.setStart(10);
            noexception = true;
        }
        catch (IllegalArgumentException iae) {
            assertTrue(noexception);
        }
    }
}
