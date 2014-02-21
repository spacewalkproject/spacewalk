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
package com.redhat.rhn.frontend.action.schedule.test;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainEntry;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.schedule.ActionChainSaveAction;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.stringtree.json.JSONReader;

import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Tests for ActionChainSaveAction.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ActionChainSaveActionTest extends BaseTestCaseWithUser {
    /**
     * Tests save().
     * @throws Exception if something bad happens
     */
    @SuppressWarnings("unchecked")
    public void testSave() throws Exception {
        ActionChainSaveAction saveAction = new ActionChainSaveAction();
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        for (int i = 0; i < 6; i++) {
            Action action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
            action.setOrg(user.getOrg());
            ActionFactory.save(action);
            ActionChainFactory.queueActionChainEntry(action, actionChain,
                ServerFactoryTest.createTestServer(user), i / 2);
        }
        Action lastAction = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
        lastAction.setOrg(user.getOrg());
        ActionFactory.save(lastAction);
        ActionChainFactory.queueActionChainEntry(lastAction, actionChain,
            ServerFactoryTest.createTestServer(user), 3);

        String newLabel = TestUtils.randomString();
        List<Long> deletedEntries = new LinkedList<Long>();
        deletedEntries.add(lastAction.getId());
        List<Integer> deletedSortOrders = new LinkedList<Integer>();
        deletedSortOrders.add(0);
        deletedSortOrders.add(3);
        List<Integer> reorderedSortOrders = new LinkedList<Integer>();
        reorderedSortOrders.add(2);
        reorderedSortOrders.add(1);
        String resultString = saveAction.save(actionChain.getId(), newLabel,
            deletedEntries, deletedSortOrders, reorderedSortOrders);

        Map<String, Object> result = (Map<String, Object>) new JSONReader()
            .read(resultString);
        assertEquals(true, result.get(ActionChainSaveAction.SUCCESS_FIELD));
        assertEquals(LocalizationService.getInstance().getMessage("actionchain.jsp.saved"),
            result.get(ActionChainSaveAction.TEXT_FIELD));
        assertEquals(newLabel, actionChain.getLabel());

        Set<ActionChainEntry> entries = actionChain.getEntries();
        assertEquals(4, entries.size());

        List<ActionChainEntry> sortedEntries = new LinkedList<ActionChainEntry>();
        sortedEntries.addAll(entries);
        Collections.sort(sortedEntries, new Comparator<ActionChainEntry>() {
            @Override
            public int compare(ActionChainEntry entry1, ActionChainEntry entry2) {
                return entry1.getId().compareTo(entry2.getId());
            }
        });
        for (int i = 0; i < sortedEntries.size(); i++) {
            assertEquals((Integer) (1 - i / 2), sortedEntries.get(i).getSortOrder());
        }
    }
}
