/**
 * Copyright (c) 2014 SUSE
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
package com.redhat.rhn.domain.action.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainEntry;
import com.redhat.rhn.domain.action.ActionChainEntryGroup;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.hibernate.ObjectNotFoundException;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ActionChainFactoryTest extends BaseTestCaseWithUser {

    /**
     * Tests createActionChain() and getActionChain().
     * @throws Exception if something bad happens
     */
    public void testCreateActionChain() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        assertNotNull(actionChain);

        ActionChain retrievedActionChain = ActionChainFactory.getActionChain(label);
        assertNotNull(retrievedActionChain);
        assertEquals(label, retrievedActionChain.getLabel());
        assertEquals(user, retrievedActionChain.getUser());

        retrievedActionChain = ActionChainFactory.getActionChain(actionChain.getId());
        assertNotNull(retrievedActionChain);
        assertEquals(label, retrievedActionChain.getLabel());
        assertEquals(user, retrievedActionChain.getUser());
    }

    /**
     * Tests delete().
     * @throws Exception if something bad happens
     */
    public void testDelete() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        assertNotNull(actionChain);

        ActionChainFactory.delete(actionChain);

        try {
            ActionChainFactory.getActionChain(actionChain.getId());
            fail();
        }
        catch (ObjectNotFoundException e) {
            // correct
        }
    }

    /**
     * Tests getActionChains().
     * @throws Exception if something bad happens
     */
    public void testGetActionChains() throws Exception {
        int previousSize = ActionChainFactory.getActionChains().size();

        ActionChainFactory.createActionChain(TestUtils.randomString(), user);
        ActionChainFactory.createActionChain(TestUtils.randomString(), user);
        ActionChainFactory.createActionChain(TestUtils.randomString(), user);

        assertEquals(previousSize + 3, ActionChainFactory.getActionChains().size());
    }

    /**
     * Tests getOrCreateActionChain().
     * @throws Exception if something bad happens
     */
    public void testGetOrCreateActionChain() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.getActionChain(label);
        assertNull(actionChain);

        ActionChain newActionChain = ActionChainFactory.getOrCreateActionChain(label, user);
        assertNotNull(newActionChain);

        ActionChain retrievedActionChain = ActionChainFactory.getActionChain(label);
        assertNotNull(retrievedActionChain);
    }

    /**
     * Tests queueActionChainEntry().
     * @throws Exception if something bad happens
     */
    public void testQueueActionChainEntry() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        Action action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
        action.setOrg(user.getOrg());
        Server server = ServerFactoryTest.createTestServer(user);

        assertEquals(0, actionChain.getEntries().size());

        ActionChainEntry entry = ActionChainFactory.queueActionChainEntry(action,
            actionChain, server);
        assertNotNull(entry);
        assertEquals(0, entry.getSortOrder().intValue());

        // test that entries are correct after reload()
        HibernateFactory.reload(actionChain);
        assertEquals(1, actionChain.getEntries().size());

        ActionChainEntry secondEntry = ActionChainFactory.queueActionChainEntry(action,
            actionChain, server);
        assertNotNull(secondEntry);
        assertEquals(1, secondEntry.getSortOrder().intValue());

        // test that entries are correct after flush()
        HibernateFactory.getSession().flush();
        HibernateFactory.getSession().clear();
        assertEquals(2, actionChain.getEntries().size());

        ActionChain secondActionChain = ActionChainFactory.createActionChain(
            TestUtils.randomString(), user);
        ActionChainEntry thirdEntry = ActionChainFactory.queueActionChainEntry(action,
            secondActionChain, server);
        assertNotNull(thirdEntry);
        assertEquals(0, thirdEntry.getSortOrder().intValue());
    }

    /**
     * Tests testGetActionChainEntry().
     * @throws Exception if something bad happens
     */
    public void testGetActionChainEntry() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        Action action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
        action.setOrg(user.getOrg());
        ActionChainEntry entry = ActionChainFactory.queueActionChainEntry(action,
            actionChain, ServerFactoryTest.createTestServer(user), 0);

        HibernateFactory.getSession().flush();

        ActionChainEntry retrievedEntry = ActionChainFactory.getActionChainEntry(entry
            .getId());
        assertEquals(entry.getServerId(), retrievedEntry.getServerId());
        assertEquals(entry.getSortOrder(), retrievedEntry.getSortOrder());
    }

    /**
     * Tests getActionChainEntryGroups().
     * @throws Exception if something bad happens
     */
    public void testGetActionChainEntryGroups() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        for (int i = 0; i < 5; i++) {
            Action action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
            action.setOrg(user.getOrg());
            ActionChainFactory.queueActionChainEntry(action, actionChain,
                ServerFactoryTest.createTestServer(user), 0);
        }
        for (int i = 5; i < 10; i++) {
            Action action = ActionFactory.createAction(ActionFactory.TYPE_PACKAGES_UPDATE);
            action.setOrg(user.getOrg());
            ActionChainFactory.queueActionChainEntry(action, actionChain,
                ServerFactoryTest.createTestServer(user), 1);
        }

        List<ActionChainEntryGroup> result = ActionChainFactory
            .getActionChainEntryGroups(actionChain);
        ActionChainEntryGroup secondGroup = result.get(0);
        assertEquals(ActionFactory.TYPE_ERRATA.getLabel(),
            secondGroup.getActionTypeLabel());
        assertEquals((Integer) 0, secondGroup.getSortOrder());
        assertEquals((Long) 5L, secondGroup.getSystemCount());

        ActionChainEntryGroup firstGroup = result.get(1);
        assertEquals(ActionFactory.TYPE_PACKAGES_UPDATE.getLabel(),
            firstGroup.getActionTypeLabel());
        assertEquals((Integer) 1, firstGroup.getSortOrder());
        assertEquals((Long) 5L, firstGroup.getSystemCount());
    }

    /**
     * Test getActionChainEntries().
     * @throws Exception if something bad happens
     */
    public void testGetActionChainEntries() throws Exception {
        ActionChain actionChain = ActionChainFactory.createActionChain(
            TestUtils.randomString(), user);
        for (int i = 0; i < 10; i++) {
            Action action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
            action.setOrg(user.getOrg());
            ActionChainFactory.queueActionChainEntry(action, actionChain,
                ServerFactoryTest.createTestServer(user), i % 2);
        }

        List<ActionChainEntry> entries = ActionChainFactory.getActionChainEntries(
            actionChain, 0);
        assertEquals(5, entries.size());
        for (ActionChainEntry entry : entries) {
            assertEquals(actionChain.getId(), entry.getActionChainId());
            assertEquals((Integer) 0, entry.getSortOrder());
        }
    }

    /**
     * Tests schedule().
     * @throws Exception if something bad happens
     */
    public void testSchedule() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        Server server1 = ServerFactoryTest.createTestServer(user);
        Server server2 = ServerFactoryTest.createTestServer(user);
        Map<Long, Integer> sortOrders = new HashMap<Long, Integer>();
        for (int i = 0; i < 10; i++) {
            Action action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
            action.setOrg(user.getOrg());
            ActionChainFactory.queueActionChainEntry(action, actionChain, server1, i);
            TestUtils.saveAndFlush(action);
            sortOrders.put(action.getId(), i);
            if (i % 2 == 0) {
                action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
                action.setOrg(user.getOrg());
                ActionChainFactory.queueActionChainEntry(action, actionChain, server2, i);
                TestUtils.saveAndFlush(action);
                sortOrders.put(action.getId(), i);
            }
        }

        ActionChainFactory.schedule(actionChain, new Date());

        // check action chain does not exist anymore
        try {
            ActionChainFactory.getActionChain(actionChain.getId());
            fail();
        }
        catch (ObjectNotFoundException e) {
            // correct
        }

        // check actions are scheduled in correct order
        for (ActionChainEntry entry : actionChain.getEntries()) {
            Action action = entry.getAction();
            Action prerequisite = action.getPrerequisite();
            if (prerequisite != null) {
                assertTrue(sortOrders.get(action.getId()) > sortOrders.get(prerequisite
                    .getId()));
            }
        }

        // check ServerAction objects have been created
        for (ActionChainEntry entry : actionChain.getEntries()) {
            assertNotEmpty(entry.getAction().getServerActions());
        }
    }
}
