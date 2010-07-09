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
import com.redhat.rhn.frontend.action.satellite.GeneralConfigAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * GeneralConfigActionTest
 * @version $Rev: 1 $
 */
public class GeneralConfigActionTest extends RhnMockStrutsTestCase {
    private static final String TEST_CONFIG_BOOLEAN =  "web.is_monitoring_backend";
    public void testTestValue() {

        assertTrue(GeneralConfigAction.ALLOWED_CONFIGS.
                contains(TEST_CONFIG_BOOLEAN));
    }

    public void testNonSubmit() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        setRequestPathInfo("/admin/config/GeneralConfig");
        Iterator i = GeneralConfigAction.ALLOWED_CONFIGS.iterator();
        Map originalConfigValues = new HashMap();
        while (i.hasNext()) {
            String config = (String) i.next();
            String value = Config.get().getString(config);
            if (value != null) {
                originalConfigValues.put(config, value);
                Config.get().setString(config, "1");
            }
        }
        i = GeneralConfigAction.ALLOWED_CONFIGS.iterator();
        actionPerform();
        DynaActionForm af = (DynaActionForm) getActionForm();
        while (i.hasNext()) {
            String config =
                GeneralConfigAction.translateFormPropertyName((String) i.next());
            String configValue = Config.get().getString(config);
            Object formValue = af.get(config);
            if (configValue != null) {
                assertNotNull(formValue);
                Config.get().setString(config,
                        (String) originalConfigValues.get(config));
            }
        }
    }

    public void testSubmit() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        setRequestPathInfo("/admin/config/GeneralConfig");
        Config.get().setString("web.com.redhat.rhn.frontend." +
                "action.satellite.GeneralConfigAction.command",
                TestConfigureSatelliteCommand.class.getName());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());

        boolean origValue = new Boolean(Config.get().
            getString(TEST_CONFIG_BOOLEAN)).booleanValue();

        boolean changedValue = !origValue;
        addRequestParameter(
                GeneralConfigAction.translateFormPropertyName(
                        TEST_CONFIG_BOOLEAN),
                            new Boolean(changedValue).toString());
        actionPerform();
        assertEquals(changedValue, Config.get().
                getBoolean(TEST_CONFIG_BOOLEAN));
        Config.get().setBoolean(TEST_CONFIG_BOOLEAN, new Boolean(origValue).toString());
        verifyForward("failure");

        addRequestParameter(
                GeneralConfigAction.translateFormPropertyName("traceback_mail"),
                "testuser@redhat.com");
        addRequestParameter(
                GeneralConfigAction.translateFormPropertyName("server.jabber_server"),
                "testbox");

        actionPerform();

        assertEquals("testuser@redhat.com", Config.get().getString("traceback_mail"));
        assertEquals("testbox", Config.get().getString("server.jabber_server"));

        verifyActionMessages(new String[] {"config.restartrequired"});


        Config.get().setBoolean(TEST_CONFIG_BOOLEAN, new Boolean(origValue).toString());
    }

}

