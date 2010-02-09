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
package com.redhat.rhn.frontend.action.satellite.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.action.satellite.RestartAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.apache.struts.action.DynaActionForm;

/**
 * RestartActionTest
 * @version $Rev: 1 $
 */
public class RestartActionTest extends RhnMockStrutsTestCase {

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        setRequestPathInfo("/admin/config/Restart");
        Config.get().setString("web.com.redhat.rhn.frontend." +
                "action.satellite.RestartAction.command", 
                TestRestartCommand.class.getName());
        
    }
    
    public void testExecuteNoSubmit() throws Exception {

        actionPerform();
        DynaActionForm form = (DynaActionForm) getActionForm();
        assertFalse(((Boolean) form.get(RestartAction.RESTART)).booleanValue());
    }
    
    public void testExecuteSubmitTrue() throws Exception {

        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(RestartAction.RESTART, Boolean.TRUE.toString());
        actionPerform();
        verifyActionMessages(new String[]{"restart.config.success"});
        assertTrue((request.getParameter(RestartAction.RESTART).
                    equals(Boolean.TRUE.toString())));
    }

    public void testExecuteSubmitFalse() throws Exception {

        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(RestartAction.RESTART, Boolean.FALSE.toString());
        actionPerform();
        verifyActionMessages(new String[]{"restart.config.norestart"});
        assertTrue((request.getParameter(RestartAction.RESTART).
                    equals(Boolean.FALSE.toString())));
    }
    
    public void testExecuteRefresh() throws Exception {
        
        addRequestParameter(RhnAction.SUBMITTED, Boolean.FALSE.toString());
        addRequestParameter(RestartAction.RESTART, Boolean.FALSE.toString());
        addRequestParameter(RestartAction.RESTARTED, Boolean.TRUE.toString());
        actionPerform();
        verifyActionMessages(new String[]{"restart.config.restarted"});
    }
}

