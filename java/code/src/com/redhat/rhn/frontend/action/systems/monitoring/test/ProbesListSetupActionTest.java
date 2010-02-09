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
package com.redhat.rhn.frontend.action.systems.monitoring.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbesListSetupAction;
import com.redhat.rhn.frontend.dto.monitoring.ServerProbeDto;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * ProbesListSetupActionTest
 * @version $Rev: 59372 $
 */
public class ProbesListSetupActionTest extends RhnBaseTestCase {
    
    public void testExecute() throws Exception {

        ProbesListSetupAction action = new ProbesListSetupAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        
        ProbeSuite suite = ProbeSuiteTest.createTestProbeSuite(ah.getUser());
        ProbeSuiteTest.addTestServersToSuite(suite, ah.getUser());
        MonitoringManager.getInstance().storeProbeSuite(suite, ah.getUser());
        suite = (ProbeSuite) reload(suite);
        Object sobject = suite.getServersInSuite().iterator().next();
        // Gotta reload the server so the Action will get the MonitoredServer
        // instance instead of a regular Server object.
        reload(sobject);
        Server server = (Server) sobject;
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.setupClampListBounds();
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        DataResult dr = (DataResult) ah.getRequest().getAttribute(ListHelper.DATA_SET);
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertTrue(dr.getStart() == 1);
        assertTrue(dr.getEnd() > 0);
        assertTrue(dr.get(0) instanceof ServerProbeDto);
        ServerProbeDto pdt = (ServerProbeDto) dr.get(0);
        assertTrue(pdt.getIsSuiteProbe());
        assertNotNull(pdt.getProbeSuiteId());
        assertNotNull(pdt.getTemplateProbeId());
        assertNotNull(pdt.getStateOutputString());
        assertNotNull(pdt.getStateString());
        pdt.setState(null);
        assertTrue(pdt.getStateString().
                equals(MonitoringConstants.PROBE_STATE_PENDING));        
    }

    // Test for BZ 161584
    public void testExecuteNoProbes() throws Exception {

        ProbesListSetupAction action = new ProbesListSetupAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.getUser().addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(ah.getUser(), true);
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.getRequest().setupAddParameter("sid", server.getId().toString());
        ah.setupClampListBounds();
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        DataResult dr = (DataResult) ah.getRequest().getAttribute(ListHelper.DATA_SET);
        assertTrue(dr.size() == 0);
    }
    
    
}
