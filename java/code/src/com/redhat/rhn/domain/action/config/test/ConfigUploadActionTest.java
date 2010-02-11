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
package com.redhat.rhn.domain.action.config.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.config.ConfigFileNameAssociation;
import com.redhat.rhn.domain.action.config.ConfigUploadAction;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Set;


public class ConfigUploadActionTest extends RhnBaseTestCase {
    
    public void testLookup() throws Exception {
        //create the action
        User user = UserTestUtils.findNewUser("bob", "ibm");
        Action a = 
            ActionFactoryTest.createAction(user, ActionFactory.TYPE_CONFIGFILES_UPLOAD);
        
        //look it back up
        Action lookedUp = ActionFactory.lookupByUserAndId(user, a.getId());
        assertNotNull(lookedUp);
        assertTrue(lookedUp instanceof ConfigUploadAction);
        
        //see that we have an expected collection
        Set set = ((ConfigUploadAction)lookedUp).getRhnActionConfigFileName();
        assertNotNull(set);
        assertEquals(2, set.size());
        
        //check one of the collection elements
        Object o = set.iterator().next();
        assertTrue(o instanceof ConfigFileNameAssociation);
        assertEquals(((ConfigFileNameAssociation)o).getParentAction(), lookedUp);
    }

}
