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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringTestUtils;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.systems.monitoring.BaseProbeAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeCreateAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeDetailsAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.ForwardWrapper;

/**
 * ProbeCreateActionTest
 * @version $Rev$
 */
public class ProbeCreateActionTest extends ProbeCreateTestCase {

    private static final String REQ_ATTRS = "system," + BASE_REQ_ATTRS;
    
    protected void setUp() throws Exception {
        super.setUp();
    }
    
    protected void tearDown() throws Exception {
        super.tearDown();
    }
    
    public void testSubmitExecute() throws Exception {
        
        Probe orig = MonitoringFactoryTest.createTestProbe(user);

        modifyActionHelper("success");
        ah.getForm().set(RhnAction.SUBMITTED, Boolean.TRUE);
        setupCommand(ah, orig);
        setupProbeFields(ah, orig);
        
        MonitoringTestUtils.setupParamValues(ah, orig.getCommand(), 3);
        
        ForwardWrapper af = ah.executeAction();
        assertEquals("success", af.getName());
        
        // There seems to be no need for asserting 'NO' request 
        // attributes are bound.....
        // Issue here is RequestContext.lookupAndBindServer()
        // will bind the Server object to SYSTEM attribute
        // through out the life time, so server object
        // will always exist for the lifetime of this request.. 
        //so commenting out the following line
        //assertNoRequestAttributes(ah,REQ_ATTRS);
        Long probeID = af.getLongParam(BaseProbeAction.PROBEID);
        
        ServerProbe created = (ServerProbe) verifyProbe(orig, ServerProbe.class, probeID);
        assertEquals(firstScoutID(), created.getSatCluster().getId());
        MonitoringTestUtils.verifyParameters(created, orig.getCommand());
    }

    protected void modifyActionHelper(String forwardName) throws Exception {
        ah.setExpectedForward(forwardName);
        user.addRole(RoleFactory.ORG_ADMIN);
        Server s = ServerFactoryTest.createTestServer(user, true);
        HibernateFactory.getSession().flush();
        String id = s.getId().toString();
        ah.getRequest().setupAddParameter(ProbeDetailsAction.SID, id);
        ah.getRequest().setupAddParameter(ProbeDetailsAction.SID, id);
    }

    protected BaseProbeAction createProbeAction() {
        return new ProbeCreateAction();
    }

    protected String requestAttributes() {
        return REQ_ATTRS;
    }

}
