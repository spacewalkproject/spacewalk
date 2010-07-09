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
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.monitoring.config.ConfigMacro;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.satellite.MonitoringConfigAction;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.ActionForward;

import java.util.List;

/**
 * ProbeDetailsActionTest
 * @version $Rev: 53047 $
 */
public class MonitoringConfigActionTest extends RhnBaseTestCase {

    private MonitoringConfigAction action;
    private boolean restartCalled = false;
    private ActionHelper ah;

    public void setUp() throws Exception {
        super.setUp();
        // If this is in HOSTED, dont run the test

        restartCalled = false;
        // Heheh, lovely, eh?  Makes sure
        // that the MonitoringManager doesn't actually call
        // runtime.exec() and restart services on the person
        // who is running this test.
        action = new MonitoringConfigAction() {
            protected MonitoringManager getManager() {
                MonitoringManager man = new MonitoringManager() {
                    protected void restartService(String serviceName) {
                        restartCalled = true;
                        return;
                    }
                };
                return man;
            }
        };


        ah = new ActionHelper();
        ah.setUpAction(action);
        User user = ah.getUser();
        user.addRole(RoleFactory.MONITORING_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        Config.get().setString("web.com.redhat.rhn.frontend." +
                "action.satellite.MonitoringConfigAction.command",
                TestConfigureSatelliteCommand.class.getName());

    }

    public void testSetupExecute() throws Exception {
        // If this is in HOSTED, dont run the test

        ah.getForm().set(MonitoringConfigAction.SUBMITTED, new Boolean(false));
        setupExpectedProperties(ah);
        ActionForward af = ah.executeAction();
        assertFalse(restartCalled);
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("configList"));
        assertNotNull(ah.getForm().get(MonitoringConfigAction.IS_MONITORING_SCOUT));

    }

    public void testSaveExecute() throws Exception {

        // If this is in HOSTED, dont run the test

        ah.getForm().set(MonitoringConfigAction.SUBMITTED, new Boolean(true));
        boolean oldScoutValue = Config.get().getBoolean(
                ConfigDefaults.WEB_IS_MONITORING_SCOUT);
        ah.getForm().set(MonitoringConfigAction.IS_MONITORING_SCOUT,
                new Boolean(!oldScoutValue));
        User user = ah.getUser();

        // Save the original email so we can revert after this test
        String originalEmail = null;
        List configs = MonitoringManager.getInstance().
            getEditableConfigMacros(user);
        for (int i = 0; i < configs.size(); i++) {
            ConfigMacro cm = (ConfigMacro) configs.get(i);
            if (cm.getName().equals("RHN_ADMIN_EMAIL")) {
                originalEmail = cm.getDefinition();
                // Change the admin email to the test user
                ah.getRequest().setupAddParameter("RHN_ADMIN_EMAIL", user.getEmail());
            }
            else {
                ah.getRequest().setupAddParameter(cm.getName(), cm.getDefinition());
            }
        }

        // Change the admin email to the test user
        ah.getRequest().setupAddParameter("RHN_ADMIN_EMAIL", user.getEmail());
        ActionForward af = ah.executeAction();
        assertTrue(restartCalled);
        assertEquals(!oldScoutValue,
                Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_SCOUT));
        assertEquals("default", af.getName());
        assertNotNull(ah.getRequest().getAttribute("configList"));

        // Check that it saved
        boolean changed = false;
        configs = MonitoringManager.getInstance().
            getEditableConfigMacros(user);
        for (int i = 0; i < configs.size(); i++) {
            ConfigMacro cm = (ConfigMacro) configs.get(i);
            if (cm.getName().equals("RHN_ADMIN_EMAIL")) {
                assertTrue(cm.getDefinition().equals(user.getEmail()));
                changed = true;
                cm.setDefinition(originalEmail);
                MonitoringManager.getInstance().storeConfigMacro(cm);
            }
        }
        assertTrue(changed);
        assertTrue(TestUtils.validateUIMessage(ah, "monitoring.services.restarted"));
        Config.get().setBoolean(ConfigDefaults.WEB_IS_MONITORING_SCOUT,
                new Boolean(oldScoutValue).toString());
    }

    public void testNoChanges() throws Exception {

        ah.getForm().set(MonitoringConfigAction.SUBMITTED, new Boolean(true));
        ah.getForm().set(MonitoringConfigAction.IS_MONITORING_SCOUT,
                new Boolean(Config.get().getBoolean(
                        ConfigDefaults.WEB_IS_MONITORING_SCOUT)));
        setupExpectedProperties(ah);
        ah.executeAction();
        assertTrue(TestUtils.validateUIMessage(ah, "monitoring.services.novalueschanged"));
    }

    private void setupExpectedProperties(ActionHelper ahIn) {

        List configs = MonitoringManager.getInstance().
                     getEditableConfigMacros(ahIn.getUser());
        for (int i = 0; i < configs.size(); i++) {
            ConfigMacro cm = (ConfigMacro) configs.get(i);
            ahIn.getRequest().setupAddParameter(cm.getName(), cm.getDefinition());
        }

    }

}
