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
package com.redhat.rhn.frontend.action.rhnset.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.action.rhnset.SetItemSelectionAction;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.Action;

/**
 * SetItemSelectionActionTest
 * @version $Rev$
 */
public class SetItemSelectionActionTest extends RhnBaseTestCase {

    public void testNoSystems() throws Exception {
        ActionHelper ah = new ActionHelper();
        Action action = new SetItemSelectionAction();
        ah.setUpAction(action);

        ah.getRequest().setupAddParameter(SetItemSelectionAction.IDS, new String[] {});
        ah.getRequest().setupAddParameter(SetItemSelectionAction.CHECKED, "on");
        ah.getRequest().setupAddParameter(SetItemSelectionAction.SET_LABEL,
                                                          SetLabels.SYSTEM_LIST);
        ah.getRequest().setupAddParameter(SetItemSelectionAction.SET_LABEL,
                SetLabels.SYSTEM_LIST);
        ah.executeAction("execute", false);
        String str = ah.getResponse().getHeader(SetItemSelectionAction.JSON_HEADER);

        String expectedResponse = "({\"header\":\"No systems selected\"," +
        "\"pagination\":\"(0 selected)\"})";
        assertEquals(expectedResponse, str);
    }

    public void testOneSystem() throws Exception {
        ActionHelper ah = new ActionHelper();
        Action action = new SetItemSelectionAction();
        ah.setUpAction(action);

        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(user);

        Server serverOne = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        String sidOne = serverOne.getId().toString();

        ah.getRequest().setupAddParameter(SetItemSelectionAction.IDS,
                                                       new String[] { sidOne });
        ah.getRequest().setupAddParameter(SetItemSelectionAction.CHECKED, "on");
        ah.getRequest().setupAddParameter(SetItemSelectionAction.SET_LABEL,
                                                         SetLabels.SYSTEM_LIST);
        ah.getRequest().setupAddParameter(SetItemSelectionAction.SET_LABEL,
                SetLabels.SYSTEM_LIST);
        ah.executeAction("execute", false);
        String str = ah.getResponse().getHeader(SetItemSelectionAction.JSON_HEADER);

        String expectedResponse = "({\"header\":\"1 system selected\"," +
                                    "\"pagination\":\"(1 selected)\"})";


        assertEquals(expectedResponse, str);
    }

    public void testTwoSystems() throws Exception {
        ActionHelper ah = new ActionHelper();
        Action action = new SetItemSelectionAction();
        ah.setUpAction(action);

        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(user);

        Server serverOne = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        String sidOne = serverOne.getId().toString();

        Server serverTwo = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        String sidTwo = serverTwo.getId().toString();

        ah.getRequest().setupAddParameter(SetItemSelectionAction.IDS,
                                               new String[] { sidOne, sidTwo });
        ah.getRequest().setupAddParameter(SetItemSelectionAction.CHECKED, "on");
        ah.getRequest().setupAddParameter(SetItemSelectionAction.SET_LABEL,
                                                         SetLabels.SYSTEM_LIST);
        ah.getRequest().setupAddParameter(SetItemSelectionAction.SET_LABEL,
                SetLabels.SYSTEM_LIST);

        ah.executeAction("execute", false);
        String str = ah.getResponse().getHeader(SetItemSelectionAction.JSON_HEADER);

        String expectedResponse = "({\"header\":\"2 systems selected\"," +
                                        "\"pagination\":\"(2 selected)\"})";

        assertEquals(expectedResponse, str);
    }

    public void testInvalidRequest() throws Exception {
        ActionHelper ah = new ActionHelper();
        Action action = new SetItemSelectionAction();
        ah.setUpAction(action);

        ah.getRequest().setupAddParameter(SetItemSelectionAction.IDS, new String[] {});
        ah.getRequest().setupAddParameter(SetItemSelectionAction.CHECKED, "on");
        ah.getRequest().setupAddParameter(SetItemSelectionAction.SET_LABEL,
                                                            "invalid set label");

        ah.executeAction("execute", false);
        String str = ah.getResponse().getOutputStreamContents();

        assertEquals(str, "");
    }
}
