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

import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.monitoring.test.MonitoringTestUtils;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeDetailsAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeEditAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

import java.util.List;

/**
 * ProbeDetailsActionTest
 * @version $Rev: 53047 $
 */
public class ProbeEditActionTest extends RhnBaseTestCase {
    
    private User user;
    private Probe probe;
    private ProbeEditAction action;
    private ActionHelper ah;
    
    protected void setUp() throws Exception {
        super.setUp();
        
        action = new ProbeEditAction();
        
        ah = new ActionHelper();
        ah.setUpAction(action);
        
        user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        Server s = ServerFactoryTest.createTestServer(user, true);
        
        probe = MonitoringFactoryTest.createTestProbe(user);
        
        ah.getForm().setFormName("probeEditForm");
        String pid = probe.getId().toString();
        ah.getRequest().setupAddParameter(ProbeDetailsAction.PROBEID, pid);
        ah.getRequest().setupAddParameter(ProbeDetailsAction.PROBEID, pid);
        ah.getRequest().setupAddParameter(ProbeDetailsAction.SID,
                s.getId().toString());
    }

    protected void tearDown() throws Exception {
        user = null;
        probe = null;
        action = null;
        ah = null;
        super.tearDown();
    }
    
    public void testExecute() throws Exception {
        

        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("probe"));
        assertNotNull(ah.getRequest().getAttribute("system"));
        assertNotNull(ah.getRequest().getAttribute("intervals"));
        assertNotNull(ah.getRequest().getAttribute("contactGroups"));
        assertNotNull(ah.getRequest().getAttribute("paramValueList"));
        List pvalues = (List) ah.getRequest().getAttribute("paramValueList");
        assertTrue(pvalues.size() > 0);
        
    }
    
    public void testSubmitExecute() throws Exception {
        ah.setExpectedForward("success");
        ah.getForm().set(ProbeEditAction.SUBMITTED, new Boolean(true));
        ah.getForm().set("description", probe.getDescription());
        ah.getForm().set("notification", new Boolean(true));
        ah.getForm().set("check_interval_min", probe.getCheckIntervalMinutes());
        ah.getForm().set("notification_interval_min", 
                probe.getNotificationIntervalMinutes());
        MonitoringTestUtils.setupParamValues(ah, probe.getCommand(), 3);
        
        ActionForward af = ah.executeAction();
        assertEquals("success", af.getName());
        
        ServerProbe edited = (ServerProbe) reload(probe);
        assertPropertyEquals("checkIntervalMinutes", probe, edited);
        assertPropertyEquals("description", probe, edited);
        assertEquals(Boolean.TRUE, edited.getNotifyCritical());
        MonitoringTestUtils.verifyParameters(edited, probe.getCommand());
    }

    public void testBadIntervalValue() throws Exception {
        ah.getForm().set(ProbeEditAction.SUBMITTED, new Boolean(true));
        ah.getForm().set("description", probe.getDescription());
        ah.getForm().set("notification", new Boolean(true));
        ah.getForm().set("check_interval_min", new Long(10));
        ah.getForm().set("notification_interval_min", 
                new Long(5));
        MonitoringTestUtils.setupParamValues(ah, probe.getCommand(), 3);
        
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        
    }
    
}

