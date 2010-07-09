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
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * ConfigActionTest
 * @version $Rev$
 */
public class ConfigActionTest extends RhnBaseTestCase {

    public void testCreate() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");

        ConfigAction testAction = (ConfigAction)ActionFactoryTest.createAction(usr,
                ActionFactory.TYPE_CONFIGFILES_DEPLOY);
        ConfigRevisionActionTest.createTestRevision(usr, testAction);
        ActionFactory.save(testAction);
        flushAndEvict(testAction);
        /**
         * Get action back out of db and make sure it committed correctly
         */
        Action same = ActionFactory.lookupById(testAction.getId());
        assertTrue(same instanceof ConfigAction);
        ConfigAction sameAction = (ConfigAction) same;

        assertNotNull(sameAction.getConfigRevisionActions());
        assertEquals(sameAction.getConfigRevisionActions().size(), 2);
        assertNotNull(sameAction.getConfigRevisionActions().toArray()[0]);
        assertNotNull(sameAction.getConfigRevisionActions().toArray()[1]);
        assertEquals(sameAction.getName(), testAction.getName());
        assertEquals(sameAction.getId(), testAction.getId());
    }

}
