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
package com.redhat.rhn.frontend.action.monitoring.test;

import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuitesRemoveAction;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.Globals;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;

import java.util.LinkedList;
import java.util.List;

/**
 * ProbeSuitesRemoveActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuitesRemoveActionTest extends RhnBaseTestCase {
    private Action action = null;

    public void setUp() throws Exception {
        super.setUp();
        action = new ProbeSuitesRemoveAction();
    }

    /**
     * Test to make sure we delete the probesuites.
     * @throws Exception if test fails
     */
    public void testRemoveProbeSuites() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        List ids = new LinkedList();
        for (int i = 0; i < 5; i++) {
            ProbeSuite ps = ProbeSuiteTest.createTestProbeSuite(sah.getUser());
            ids.add(ps.getId().toString());
        }

        sah.getRequest().setupAddParameter("items_selected",
                (String[]) ids.toArray(new String[0]));

        ActionForward testforward = sah.executeAction("removeProbeSuites");
        assertEquals("path?lower=10", testforward.getPath());
        assertNotNull(sah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
        assertNull(MonitoringManager.getInstance().
                lookupProbeSuite(new Long(ids.get(0).toString()), sah.getUser()));
    }

    public void testSelectAll() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        List ids = new LinkedList();
        for (int i = 0; i < 5; i++) {
            ProbeSuite ps = ProbeSuiteTest.createTestProbeSuite(sah.getUser());
            ids.add(ps.getId().toString());
        }

        sah.getRequest().setupAddParameter("items_selected",
                (String[]) ids.toArray(new String[0]));

        ActionForward testforward = sah.executeAction("removeProbeSuites");
        assertEquals("path?lower=10", testforward.getPath());
        assertNotNull(sah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
        assertNull(MonitoringManager.getInstance().
                lookupProbeSuite(new Long(ids.get(0).toString()), sah.getUser()));
    }



}
