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

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainEntry;
import com.redhat.rhn.domain.action.ActionChainEntryGroup;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.test.ActionChainFactoryTest;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.schedule.ActionChainEditAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnPostMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

/**
 * Tests for ActionChainEditActionTest.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ActionChainEditActionTest extends RhnPostMockStrutsTestCase {

    /**
     * Tests loading of the form.
     * @throws Exception if something bad happens
     */
    @SuppressWarnings("unchecked")
    public void testNotSubmitted() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        TestUtils.saveAndFlush(actionChain);

        addRequestParameter(ActionChainEditAction.ACTION_CHAIN_ID_PARAMETER, actionChain
            .getId().toString());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.FALSE.toString());
        setRequestPathInfo("/schedule/ActionChain");
        actionPerform();
        HttpServletRequest request = getRequest();

        assertEquals(actionChain,
            request.getAttribute(ActionChainEditAction.ACTION_CHAIN_ATTRIBUTE));

        Object datePicker = request.getAttribute(ActionChainEditAction.DATE_ATTRIBUTE);
        assertTrue(datePicker instanceof DatePicker);

        assertTrue(((List<ActionChainEntryGroup>) request
            .getAttribute(ActionChainEditAction.GROUPS_ATTRIBUTE)).isEmpty());
    }

    /**
     * Tests the Action's delete dispatch call.
     * @throws Exception if something bad happens
     */
    public void testDelete() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        TestUtils.saveAndFlush(actionChain);

        addRequestParameter(ActionChainEditAction.ACTION_CHAIN_ID_PARAMETER, actionChain
            .getId().toString());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addDispatchCall("actionchain.jsp.delete");
        setRequestPathInfo("/schedule/ActionChain");
        actionPerform();

        ActionChainFactoryTest.assertDeleted(actionChain);
    }

    /**
     * Tests the Action's schedule dispatch call.
     * @throws Exception if something bad happens
     */
    public void testSchedule() throws Exception {
        String label = TestUtils.randomString();
        ActionChain actionChain = ActionChainFactory.createActionChain(label, user);
        Action action = ActionFactory.createAction(ActionFactory.TYPE_ERRATA);
        action.setOrg(user.getOrg());
        ActionChainEntry entry = ActionChainFactory.queueActionChainEntry(action,
            actionChain, ServerFactoryTest.createTestServer(user), 0);
        TestUtils.saveAndFlush(actionChain);

        addRequestParameter(ActionChainEditAction.ACTION_CHAIN_ID_PARAMETER, actionChain
            .getId().toString());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addDispatchCall("actionchain.jsp.saveandschedule");
        setRequestPathInfo("/schedule/ActionChain");
        actionPerform();

        ActionChainFactoryTest.assertDeleted(actionChain);
        assertFalse(entry.getAction().getServerActions().isEmpty());
    }
}
