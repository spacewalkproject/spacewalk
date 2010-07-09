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
package com.redhat.rhn.manager.satellite.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.monitoring.config.ConfigMacro;
import com.redhat.rhn.domain.monitoring.config.MonitoringConfigFactory;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.satellite.ConfigureSatelliteCommand;
import com.redhat.rhn.manager.satellite.Executor;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * ConfigureSatelliteCommandTest - test for ConfigureSatelliteCommand
 * @version $Rev$
 */
public class ConfigureSatelliteCommandTest extends BaseTestCaseWithUser {

    private ConfigureSatelliteCommand cmd;
    private static final String TEST_CONFIG_BOOLEAN = "test.boolean_config.config_sat_test";
    private static final String TEST_CONFIG_STRING = "test.string_config.config_sat_test";
    private static final String TEST_CONFIG_NULL = "test.null_config.config_sat_test";


    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        // TODO Auto-generated method stub
        super.setUp();
        user.addRole(RoleFactory.SAT_ADMIN);
    }

    public void testCreateCommand() throws Exception {

        cmd = new ConfigureSatelliteCommand(user) {
            public ValidatorError[] storeConfiguration() {
                this.clearUpdates();
                return null;
            }
        };
        assertNotNull(cmd.getUser());
        boolean origValue = Config.get().getBoolean(TEST_CONFIG_BOOLEAN);
        String testString = "somevalue" + TestUtils.randomString();
        cmd.updateBoolean(TEST_CONFIG_BOOLEAN, new Boolean(!origValue));
        cmd.updateString(TEST_CONFIG_STRING, testString);
        cmd.updateString(TEST_CONFIG_NULL, "");
        assertEquals(3, cmd.getKeysToBeUpdated().size());
        assertTrue(cmd.getKeysToBeUpdated().contains(TEST_CONFIG_BOOLEAN));
        assertTrue(cmd.getKeysToBeUpdated().contains(TEST_CONFIG_STRING));
        assertTrue(cmd.getKeysToBeUpdated().contains(TEST_CONFIG_NULL));

        Map optionMap = new HashMap();
        Iterator i = cmd.getKeysToBeUpdated().iterator();
        while (i.hasNext()) {
            String key = (String) i.next();
            optionMap.put(key, Config.get().getString(key));
        }
        String[] cmdargs = cmd.getCommandArguments(Config.getDefaultConfigFilePath(),
                optionMap);

        assertEquals("--option=test.null_config.config_sat_test=", cmdargs[5]);
        assertEquals(9, cmdargs.length);
        assertNull(cmd.storeConfiguration());
        assertTrue(cmd.getKeysToBeUpdated().size() == 0);
        // Test setting back to the original value
        cmd.updateBoolean(TEST_CONFIG_BOOLEAN, new Boolean(origValue));
        assertEquals(1, cmd.getKeysToBeUpdated().size());
        assertNull(cmd.storeConfiguration());
        // Test NULL booleans
        cmd.updateBoolean(TEST_CONFIG_BOOLEAN, Boolean.TRUE);
        assertNull(cmd.storeConfiguration());
        cmd.updateBoolean(TEST_CONFIG_BOOLEAN, null);
        assertEquals(1, cmd.getKeysToBeUpdated().size());
        assertNull(cmd.storeConfiguration());

        // Now test to see if updating it to FALSE doesnt
        // indicate we need actual changes written out.
        cmd.updateBoolean(TEST_CONFIG_BOOLEAN, Boolean.FALSE);
        assertTrue(cmd.getKeysToBeUpdated().size() == 0);
        cmd.updateString(TEST_CONFIG_STRING, testString);
        assertTrue(cmd.getKeysToBeUpdated().size() == 0);

    }

    public void testEnableMonitoring() throws Exception {
        Config.get().setBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND,
                Boolean.FALSE.toString());

        // Delete the Scout so we can have the script re-set it up.
        if (user.getOrg().getMonitoringScouts() != null ||
                user.getOrg().getMonitoringScouts().size() != 0) {
            SatCluster cluster = (SatCluster)
                user.getOrg().getMonitoringScouts().iterator().next();

            TestUtils.removeObject(cluster);
            flushAndEvict(cluster);
            flushAndEvict(user.getOrg());
            user = (User) reload(user);
            assertEquals(0, user.getOrg().getMonitoringScouts().size());
            assertEquals(0, user.getNotificationMethods().size());

        }

        List configMacros = MonitoringConfigFactory.lookupConfigMacros(true);
        Iterator i = configMacros.iterator();
        while (i.hasNext()) {
            ConfigMacro cm = (ConfigMacro) i.next();
            cm.setDefinition("**" + cm.getName().toUpperCase() + "**");
            MonitoringConfigFactory.saveConfigMacro(cm);
            flushAndEvict(cm);
        }

        cmd = new ConfigureSatelliteCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };
        cmd.updateBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, Boolean.TRUE);
        assertNull(cmd.storeConfiguration());
        assertTrue(Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND));
        Long uid = user.getId();
        flushAndEvict(user.getOrg());
        flushAndEvict(user);
        User orgAdmin = UserFactory.lookupById(uid);
        assertTrue(orgAdmin.getOrg().getMonitoringScouts() != null);
        assertEquals(1, orgAdmin.getOrg().getMonitoringScouts().size());
        // Make sure we created the gritch dest
        assertEquals(1, orgAdmin.getNotificationMethods().size());
        assertNotNull(Config.get().getString(ConfigDefaults.WEB_SCOUT_SHARED_KEY));
        ConfigMacro cm = MonitoringConfigFactory.lookupConfigMacroByName("MAIL_MX");
        assertFalse(cm.getDefinition().startsWith("**"));
        assertFalse(cm.getDefinition().endsWith("**"));
        assertTrue(user.getOrg().hasRole(RoleFactory.MONITORING_ADMIN));
        user.addRole(RoleFactory.ORG_ADMIN);
        assertTrue(user.hasRole(RoleFactory.MONITORING_ADMIN));
        user.removeRole(RoleFactory.ORG_ADMIN);
    }

    public void testDisableMonitoring() throws Exception {
        cmd = new ConfigureSatelliteCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };
        cmd.updateBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, Boolean.TRUE);
        assertNull(cmd.storeConfiguration());
        assertTrue(Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND));

        cmd = new ConfigureSatelliteCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };
        cmd.updateBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, Boolean.FALSE);
        assertFalse(Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND));
    }

    public void testEnableMonitoringScout() throws Exception {
        cmd = new ConfigureSatelliteCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };
        cmd.updateBoolean(ConfigDefaults.WEB_IS_MONITORING_SCOUT, Boolean.TRUE);
        assertNull(cmd.storeConfiguration());
        assertTrue(Config.get().getBoolean(ConfigDefaults.WEB_IS_MONITORING_SCOUT));
    }

    public void testUpdateHostname() throws Exception {

        cmd = new ConfigureSatelliteCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };

        cmd.updateString(ConfigDefaults.JABBER_SERVER, "test.hostname.jabber");
        ValidatorError[] verrors = cmd.storeConfiguration();
        ConfigMacro sathostname = MonitoringConfigFactory.
                           lookupConfigMacroByName("RHN_SAT_HOSTNAME");
        assertNull(verrors);
        assertTrue(sathostname.getDefinition().equals("test.hostname.jabber"));
    }


    public void testMountPoint() throws Exception {

        cmd = new ConfigureSatelliteCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };

        String testmount = "/tmp/mount/point";
        cmd.updateString(ConfigDefaults.MOUNT_POINT, testmount);
        ValidatorError[] verrors = cmd.storeConfiguration();
        assertNull(verrors);
        assertEquals(testmount,
                Config.get().getString(ConfigDefaults.KICKSTART_MOUNT_POINT));
    }

    public void testRoles() throws Exception {

        user.removeRole(RoleFactory.SAT_ADMIN);
        try {
            cmd = new ConfigureSatelliteCommand(user);
            fail("Should have thrown an IllegalArgumentException");
        }
        catch (IllegalArgumentException iae) {
            // noop
        }
        user.addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.MONITORING_ADMIN);
        cmd = new ConfigureSatelliteCommand(user);
        assertNotNull(cmd);
    }

    public class TestExecutor implements Executor {
        public int execute(String[] args) {
            return 0;
        }

        public String getLastCommandOutput() {
            return null;
        }

        public String getLastCommandErrorMessage() {
            return null;
        }
    }
}
