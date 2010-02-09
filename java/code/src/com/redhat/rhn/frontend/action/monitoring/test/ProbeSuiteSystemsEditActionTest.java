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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.monitoring.suite.test.ProbeSuiteTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteSystemsEditAction;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteSystemsEditSetupAction;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.Globals;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;

/**
 * ProbeSuiteSystemsEditActionTest
 * @version $Rev: 55327 $
 */
public class ProbeSuiteSystemsEditActionTest extends RhnBaseTestCase {
    private Action action = null;
    private ActionHelper sah;
    private ProbeSuite suite;
    private User user;
    
    private void setUpAction(Action actionIn, String forwardName) throws Exception {
        super.setUp();
        action = actionIn;
        sah = new ActionHelper();
        sah.setUpAction(action, forwardName);
        // Make sure we use the User from the ActionHelper.
        user = sah.getUser();
        suite = ProbeSuiteTest.createTestProbeSuite(user);
        // Gotta do this three times since the action can execute
        // the fetch up too 3 times.
        sah.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                suite.getId().toString());
        sah.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                suite.getId().toString());
        sah.getRequest().setupAddParameter(RequestContext.SUITE_ID,
                suite.getId().toString());
        
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        // Setup the user and a System so we get one back
        user.addRole(RoleFactory.ORG_ADMIN);
        UserManager.storeUser(user);
        // Create a 2nd server that isn't in the suite 
        Server serverNotInSuite = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeMonitoringEntitled());
        SatCluster c = (SatCluster) 
            user.getOrg().getMonitoringScouts().iterator().next();        
        sah.getRequest().
            setupAddParameter("satCluster", 
                    c.getId().toString());
                
        sah.getRequest().setupAddParameter("items_selected",
            new String[] {serverNotInSuite.getId().toString()});
        
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("returnvisit", (String)null);
        sah.getRequest().setupAddParameter("submitted", "false");
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
    }
    
    public void testSetupExecute() throws Exception {
        Action a = new ProbeSuiteSystemsEditSetupAction() {
            protected void setupPageControl(PageControl pc) {
                pc.setFilter(false);
                pc.setStart(1);
            }
        };
        setUpAction(a, "default");
        //Add a ServerProbe to the suite.
        TemplateProbe tprobe = (TemplateProbe) MonitoringFactoryTest.
            createTestProbe(user, MonitoringConstants.getProbeTypeSuite());
        suite.addProbe(tprobe, user);
        // Create a test Server that we will add to the suite.
        // We want to make sure that the server we add to the suite
        // isnt included in the list returned back in getDataResult();
        Server serverInSuite = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeMonitoringEntitled());
        
        SatCluster c = (SatCluster) 
            user.getOrg().getMonitoringScouts().iterator().next();
        suite.addServerToSuite(c, serverInSuite, user);
        suite = (ProbeSuite) reload(suite);
        MonitoringFactory.saveProbeSuite(suite, user);
        reload(suite);
        reload(user);
        reload(serverInSuite);
        
        sah.executeAction();
        assertNotNull(sah.getRequest().getAttribute("probeSuite"));
        assertNotNull(sah.getRequest().getAttribute("pageList"));
        assertNotNull(sah.getRequest().getAttribute("satClusters"));
        DataResult dr = (DataResult) sah.getRequest().getAttribute("pageList");
        assertTrue(dr.size() > 0);
        for (int i = 0; i < dr.size(); i++) {
            SystemOverview so = (SystemOverview) dr.get(i);
            Long sid = new Long(so.getId().longValue());
            if (sid.equals(serverInSuite.getId())) {
                fail("ServerInSuite was in list.  List must" +
                        " hide already seleted Servers.");
            }
        }
    }
    
    
    /**
     * Make sure when the add systems button we do the right thing
     * @throws Exception if test fails
     */
    public void testSetupExecuteNoProbes() throws Exception {
        setUpAction(new ProbeSuiteSystemsEditSetupAction(), "preconditionfailed");
        ActionForward testforward = sah.executeAction();
        assertEquals(testforward.getName(), "preconditionfailed");
        assertNotNull(sah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
    }

    /**
     * Make sure when the add systems button we do the right thing
     * @throws Exception if test fails
     */
    public void testAddSystems() throws Exception {
        setUpAction(new ProbeSuiteSystemsEditAction(), "added");
        TemplateProbe tprobe = (TemplateProbe) MonitoringFactoryTest.
            createTestProbe(user, MonitoringConstants.getProbeTypeSuite());
        suite.addProbe(tprobe, user);

        assertTrue(suite.getServersInSuite().size() == 0);
        ActionForward testforward = sah.executeAction("addSystems");
        assertTrue(suite.getServersInSuite().size() > 0);
        assertEquals(testforward.getName(), "added");
        assertEquals("path?lower=10&" + RequestContext.SUITE_ID + "=" + suite.getId() 
                , testforward.getPath());
        RhnSet pset = RhnSetDecl.PROBE_SUITE_SYSTEMS_EDIT.get(user);
        assertTrue(pset.getElements().isEmpty());
    }
    
    public void testSelectAll() throws Exception {
        setUpAction(new ProbeSuiteSystemsEditAction(), "default");
        TemplateProbe tprobe = (TemplateProbe) MonitoringFactoryTest.
            createTestProbe(user, MonitoringConstants.getProbeTypeSuite());
        suite.addProbe(tprobe, user);
        RhnSetDecl decl = RhnSetDecl.PROBE_SUITE_SYSTEMS_EDIT;
        decl.clear(user);
        
        for (int i = 0; i < 5; i++) {
            ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeMonitoringEntitled());
        }
        int systems = 
            MonitoringManager.getInstance().systemsNotInSuite(user, suite, null).size();
        assertTrue(systems >= 5);
        sah.executeAction("selectall");
        RhnSetActionTest.verifyRhnSetData(user, decl, systems);
    }

}
