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
package com.redhat.rhn.frontend.struts.test;

import com.mockobjects.servlet.MockHttpServletRequest;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.DynaActionForm;
import org.stringtree.json.JSONWriter;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ActionChainHelperTest extends BaseTestCaseWithUser {

    /**
     * Tests readActionChain().
     */
    public void testReadActionChain() {
        ActionChain chain = ActionChainFactory.createActionChain(TestUtils.randomString(),
            user);

        // poor-man's DynaActionForm mocking
        final Map<String, Object> formMap = new HashMap<String, Object>();
        DynaActionForm form = new DynaActionForm() {
            @Override
            public Object get(String nameIn) {
                return formMap.get(nameIn);
            }
        };

        assertNull(ActionChainHelper.readActionChain(form, user));

        formMap.put(DatePicker.USE_DATE, false);
        formMap.put(ActionChainHelper.LABEL_PROPERTY_NAME, chain.getLabel());

        ActionChain retrievedChain = ActionChainHelper.readActionChain(form, user);
        assertNotNull(retrievedChain);
        assertEquals(chain.getId(), retrievedChain.getId());

        formMap.put(ActionChainHelper.LABEL_PROPERTY_NAME, TestUtils.randomString());
        ActionChain newChain = ActionChainHelper.readActionChain(form, user);
        assertNotNull(newChain);
        assertTrue(!chain.getId().equals(newChain.getId()));
    }

    /**
     * Tests prepopulateActionChains().
     */
    public void testPrepopulateActionChains() {
        List<ActionChain> actionChains = new LinkedList<ActionChain>();
        for (int i = 0; i < 10; i++) {
            actionChains.add(ActionChainFactory.createActionChain(
                i + TestUtils.randomString(), user));
        }

        List<Map<String, String>> result = new LinkedList<Map<String, String>>();

        for (ActionChain actionChain : ActionChainFactory.getActionChains()) {
            Map<String, String> map = new HashMap<String, String>();
            map.put("id", actionChain.getLabel());
            map.put("text", actionChain.getLabel());
            result.add(map);
        }

        MockHttpServletRequest request = new MockHttpServletRequest();
        String s = new JSONWriter().write(result);
        request.addExpectedSetAttribute(
            ActionChainHelper.EXISTING_ACTION_CHAINS_PROPERTY_NAME, s);

        ActionChainHelper.prepopulateActionChains(request);
    }
}
