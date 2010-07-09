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
package com.redhat.rhn.domain.action.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionFormatter;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * ActionFormatterTest  - test the formatters associated with the Actions.
 * @version $Rev$
 */
public class ActionFormatterTest extends RhnBaseTestCase {

    private User user;

    public void setUp() throws Exception {
        super.setUp();
        user = UserTestUtils.findNewUser("testUser", "testOrg");
    }
    /**
     * Test formatting an Action
     * @throws Exception
     */
    public void testActionFormatter() throws Exception {
        Action a = ActionFactoryTest.createAction(user,
                ActionFactory.TYPE_HARDWARE_REFRESH_LIST);
        a.setSchedulerUser(user);

        ActionFormatter af = a.getFormatter();
        assertNotNull(af);
        assertTrue(af.getName().equals("RHN-JAVA Test Action"));
        assertTrue(af.getActionType().equals("Hardware List Refresh"));
        assertTrue(af.getNotes().equals("(none)"));
        assertTrue(af.getScheduler().equals(a.getSchedulerUser().getLogin()));
        assertNotNull(af.getEarliestDate());

    }

    /**
     * Test formatting an Action
     * @throws Exception
     */
    public void testActionLinks() throws Exception {
        // We know that TYPE_REBOOT has ServerActions associated with it
        Action areboot = ActionFactoryTest.createAction(user,
                ActionFactory.TYPE_REBOOT);
        ActionFormatter af = areboot.getFormatter();
        ServerAction sa = (ServerAction) areboot.getServerActions().toArray()[0];
        sa.setStatus(ActionFactory.STATUS_FAILED);
        sa = (ServerAction) TestUtils.saveAndReload(sa);
        assertTrue(af.getNotes().startsWith(
                "<a href=\"/rhn/schedule/FailedSystems.do?aid="));
        assertTrue(af.getNotes().endsWith(
                ">1 system</a></strong> failed to complete this action.<br/><br/>"));

        sa.setStatus(ActionFactory.STATUS_COMPLETED);
        sa = (ServerAction) TestUtils.saveAndReload(sa);
        assertTrue(af.getNotes().startsWith(
                "<a href=\"/rhn/schedule/CompletedSystems.do?aid="));
        assertTrue(af.getNotes().endsWith(
                ">1 system</a></strong> successfully completed this action.<br/><br/>"));

    }

    /**
     * Test formatting an Action
     * @throws Exception
     */
    public void testErrataFormatter() throws Exception {

        Action a = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ActionFormatter af = a.getFormatter();
        assertNotNull(af);
        assertTrue(af.getActionType().equals("Errata Update"));
        String start = "<strong><a href=\"/rhn/errata/details/Details.do?eid=";
        String end = "</a></strong><br/><br/><strong>Test synopsis</strong><br/>" +
            "<br/>" + ErrataFactory.ERRATA_TYPE_BUG +
            "<br/><br/>test topic<br/>Test desc ..<br/>";
        assertTrue(af.getNotes().startsWith(start));
        assertTrue(af.getNotes().endsWith(end));
    }

    /**;
     * Test formatting an Action
     * @throws Exception
     */
    public void testScriptFormatter() throws Exception {

        Action a = ActionFactoryTest.createAction(user, ActionFactory.TYPE_SCRIPT_RUN);
        a = (Action) reload(a);
        a.setSchedulerUser(user);
        ActionFormatter af = a.getFormatter();
        assertNotNull(af);
        assertTrue(af.getActionType().equals("Run an arbitrary script"));
        String start = "Run as:<strong>AFTestTestUser:AFTestTestGroup";
        String end = "</strong><br/><br/><div style=\"padding-left: 1em\">" +
            "<code>#!/bin/csh<br/>ls -al</code></div><br/>";
        assertTrue(af.getNotes().startsWith(start));
        assertTrue(af.getNotes().endsWith(end));

    }

}

