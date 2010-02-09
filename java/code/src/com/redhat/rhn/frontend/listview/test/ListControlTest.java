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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.util.CharacterMap;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * ListControlTest
 * @version $Rev$
 */
public class ListControlTest extends RhnBaseTestCase {
    
    /**
     * Test the basic functionality of PageControl
     */
    public void testPageControl() {
        ListControl lc = new PageControl();     
        lc.setFilterColumn("TestFilterColumn");
        lc.setFilterData("TestFilterData");
        lc.setIndexData(true);
        
        assertEquals(lc.getFilterColumn(), "TestFilterColumn");
        assertEquals(lc.getFilterData(), "TestFilterData");
        assertEquals(lc.hasIndex(), true);
    }
    
    /** 
     * Test the createIndex method of PageControl
     */
    public void testCreateIndex() {
        PageControl pc = new PageControl();
        pc.setIndexData(true);
        pc.setFilterColumn("login");

        User user = UserTestUtils.findNewUser("zbeeblebrox", "H2G2");
        UserTestUtils.createUser("adent", user.getOrg().getId());
        UserTestUtils.createUser("fprefect", user.getOrg().getId());
        UserTestUtils.createUser("ffffffff", user.getOrg().getId());
    
        SelectMode m = ModeFactory.getMode("User_queries", "users_in_org");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        DataResult dr = m.execute(params);
        dr.setIndex(pc.createIndex(dr));

        CharacterMap cs1 = dr.getIndex();

        // We can't ensure that the characterSets are the same, because in a
        // satellite case they may not be.  This code should be uncommented
        // once we can delete users from the Org (because then the test can just
        // loop through deleting users before the test is run).
        //CharacterMap cs2 = new CharacterMap();
        //cs2.put('A', 1);
        //cs2.put('F', 2);
        //cs2.put('Z', 4);
    
        //Ensure that cs1 and cs2 are equal
        //assertTrue(cs1.equals(cs2));
        assertNotNull(cs1);

    }
}
