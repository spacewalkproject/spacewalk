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
package com.redhat.rhn.domain.user.test;

import com.redhat.rhn.domain.user.PaneFactory;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Test Class for the UserPane stuff.
 * UserPaneTest
 * @version $Rev$
 */
public class UserPaneTest extends BaseTestCaseWithUser {

    
    /**
     * Tests a new user
     *
     */
    public void testNewUser() {
        // There should be NO HIDDEN PANE attached  to the user.
        assertTrue(user.getHiddenPanes().isEmpty());
    }

    private List addPanes() {
        List panes = new ArrayList(PaneFactory.getAllPanes().values());
        UserFactory.save(user);
        Long id = user.getId();
        user = null;
        user = UserFactory.lookupById(id);
        
        Set userPanes = new HashSet();
        
        
        userPanes.add(panes.get(0));
        userPanes.add(panes.get(1));
        user.setHiddenPanes(userPanes);
        UserFactory.save(user);
        user = null;
        user = UserFactory.lookupById(id);
        assertEquals(new HashSet(panes.subList(0, 2)),
                        new HashSet(user.getHiddenPanes()));

        return panes.subList(0, 2);
    }

    /**
     * Tests the Add & Remove of Panes to the user.
     *
     */
    public void testAddRemovePane() {
        List hiddenPanes = addPanes();

        assertTrue(user.getHiddenPanes().contains(hiddenPanes.get(0)));

        Long id = user.getId();
        
        Set userPanes = new HashSet(user.getHiddenPanes());
        userPanes.remove(hiddenPanes.get(0));
        user.setHiddenPanes(userPanes);
        UserFactory.save(user);
        user = null;
        user = UserFactory.lookupById(id);
        assertFalse(user.getHiddenPanes().contains(hiddenPanes.get(0)));
    }
}
