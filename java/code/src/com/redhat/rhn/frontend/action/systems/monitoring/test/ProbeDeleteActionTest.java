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
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeDeleteAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeDetailsAction;
import com.redhat.rhn.frontend.action.systems.monitoring.ProbeEditAction;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * ProbeDetailsActionTest
 * @version $Rev: 53047 $
 */
public class ProbeDeleteActionTest extends RhnBaseTestCase {

    private User user;
    private Probe probe;
    private ProbeDeleteAction action;
    private ActionHelper ah;


    public void setUpAction(String expectedFwd) throws Exception {
        super.setUp();
        action = new ProbeDeleteAction();
        ah = new ActionHelper();
        ah.setUpAction(action, expectedFwd);

        user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        Server s = ServerFactoryTest.createTestServer(user, true);
        probe = MonitoringFactoryTest.createTestProbe(user);

        ah.getForm().setFormName("probeEditForm");
        ah.getRequest().setupAddParameter(ProbeDetailsAction.PROBEID,
                probe.getId().toString());
        ah.getRequest().setupAddParameter(ProbeDetailsAction.SID,
                s.getId().toString());

    }

    public void testExecute() throws Exception {

        setUpAction("default");
        ActionForward af = ah.executeAction();
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("probe"));
        assertNotNull(ah.getRequest().getAttribute("system"));
    }

    public void testSubmitExecute() throws Exception {
        setUpAction("deleted");
        ah.getForm().set(ProbeEditAction.SUBMITTED, new Boolean(true));
        Long pid = probe.getId();
        ActionForward af = ah.executeAction();
        flushAndEvict(probe);
        assertEquals("deleted", af.getName());
        assertNotNull(ah.getRequest().getAttribute("probe"));
        assertNotNull(ah.getRequest().getAttribute("system"));
        assertNull(MonitoringManager.
                getInstance().lookupProbe(user, pid));

    }

}

