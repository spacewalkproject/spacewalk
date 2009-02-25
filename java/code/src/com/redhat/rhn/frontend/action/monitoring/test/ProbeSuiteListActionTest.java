/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteListAction;
import com.redhat.rhn.frontend.dto.monitoring.ProbeSuiteDto;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * ProbeSuiteListActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuiteListActionTest extends RhnBaseTestCase {
    private Action action = null;
    
    public void setUp() throws Exception {
        super.setUp();
        action = new ProbeSuiteListAction();
    }
    
    /**
     * Test that we forward to confirm
     * @throws Exception if test fails
     */
    public void testForwardToConfirm() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action, "remove");
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
        sah.setupClampListBounds();
        ActionForward testforward = sah.executeAction("forwardToConfirm");
        assertEquals("path?lower=10", testforward.getPath());
        assertEquals("remove", testforward.getName());
    }
    
    /**
     * Test that we forward to confirm
     * @throws Exception if test fails
     */
    public void testNothingSeleted() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action, "default");
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        List ids = new LinkedList();
        for (int i = 0; i < 5; i++) {
            ProbeSuite ps = ProbeSuiteTest.createTestProbeSuite(sah.getUser());
            ids.add(ps.getId().toString());
        }

        sah.getRequest().setupAddParameter("items_selected",
                (String[]) null);
        sah.setupClampListBounds();
        ActionForward testforward = sah.executeAction("forwardToConfirm");
        assertEquals("path?lower=10", testforward.getPath());
        assertEquals("default", testforward.getName());
    }

    
    public void testSelectAll() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        int selectable = countSelectableSuites(sah.getUser());
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        sah.getRequest().setupAddParameter("items_selected", (String[]) null);
        for (int i = 0; i < 3; i++) {
            ProbeSuiteTest.createTestProbeSuite(sah.getUser());
        }
        
        sah.executeAction("selectall");
        RhnSetActionTest.verifyRhnSetData(sah.getUser(), RhnSetDecl.PROBE_SUITES_TO_DELETE,
                selectable + 3);
    }

    private int countSelectableSuites(User user) {
        DataResult suites = 
            MonitoringManager.getInstance().listProbeSuites(user, null);
        int result = 0;
        for (Iterator i = suites.iterator(); i.hasNext();) {
            ProbeSuiteDto dto = (ProbeSuiteDto) i.next();
            if (dto.isSelectable()) {
                result += 1;
            }
        }
        return result;
    }
    
    

}
