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
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.manager.satellite.ConfigureCertificateCommand;
import com.redhat.rhn.manager.satellite.Executor;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

/**
 * ConfigureCertificateCommandTest - test for ConfigureSatelliteCommand
 * @version $Rev$
 */
public class ConfigureCertificateCommandTest extends BaseTestCaseWithUser {
    
    private ConfigureCertificateCommand cmd;
    
    public void testCreateCommand() throws Exception {
        String originalConfigParent =
                        Config.get().getString(ConfigDefaults.SATELLITE_PARENT);
        String originalConfigDisconnected =
                        Config.get().getString(ConfigDefaults.DISCONNECTED);

        Config.get().setString(ConfigDefaults.SATELLITE_PARENT, 
                "satellite.webqa.redhat.com");
        Config.get().setBoolean(ConfigDefaults.DISCONNECTED, "1");
        user.addRole(RoleFactory.SAT_ADMIN);
        cmd = new ConfigureCertificateCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };
        
        assertNotNull(cmd.getUser());
        
        cmd.setCertificateText("some text");
        assertNotNull(cmd.getCertificateText());
        assertNull(cmd.storeConfiguration());
        
        if (originalConfigParent == null) {
            Config.get().setString(ConfigDefaults.SATELLITE_PARENT, "");
        } 
        else {
            Config.get().setString(ConfigDefaults.SATELLITE_PARENT, originalConfigParent);
        }
        if (originalConfigDisconnected == null) {
            Config.get().setBoolean(ConfigDefaults.DISCONNECTED, "");
        }
        else {
            Config.get().setBoolean(ConfigDefaults.DISCONNECTED,
                                                originalConfigDisconnected);
        }
    }
    
    public void testCreateCommandIgnoreMismatch() throws Exception {
        String originalConfigParent =
                        Config.get().getString(ConfigDefaults.SATELLITE_PARENT);
        String originalConfigDisconnected =
                        Config.get().getString(ConfigDefaults.DISCONNECTED);

        Config.get().setString(ConfigDefaults.SATELLITE_PARENT,
                "satellite.webqa.redhat.com");
        Config.get().setBoolean(ConfigDefaults.DISCONNECTED, "1");
        user.addRole(RoleFactory.SAT_ADMIN);
        cmd = new ConfigureCertificateCommand(user) {
            protected Executor getExecutor() {
                TestExecutor testExecutor = new TestExecutor();
                testExecutor.shouldIgnoreMismatch = true;
                return testExecutor;
            }
        };
        
        assertNotNull(cmd.getUser());
        
        cmd.setCertificateText("some text");
        cmd.setIgnoreVersionMismatch(true);
        
        assertNotNull(cmd.getCertificateText());
        assertNull(cmd.storeConfiguration());
        if (originalConfigParent == null) {
            Config.get().setString(ConfigDefaults.SATELLITE_PARENT, "");
        } 
        else {
            Config.get().setString(ConfigDefaults.SATELLITE_PARENT, originalConfigParent);
        }
        if (originalConfigDisconnected == null) {
            Config.get().setBoolean(ConfigDefaults.DISCONNECTED, "");
        }
        else {
            Config.get().setBoolean(ConfigDefaults.DISCONNECTED,
                                                originalConfigDisconnected);
        }
    }
    
    /**
     * TestExecutor - 
     * @version $Rev$
     */
    private class TestExecutor implements Executor {

        protected boolean shouldIgnoreMismatch;
        
        public int execute(String[] args) {
            if (!args[0].equals("/usr/bin/sudo")) {
                return -1;
            }
            else if (!args[1].equals("/usr/bin/rhn-satellite-activate")) {
                return -1;
            }
            else if (!args[2].equals("--rhn-cert")) {
                return -1;
            }
            else if (!args[3].startsWith("/tmp/cert_text")) {
                return -1;
            }
            else if (!args[4].equals("--disconnected")) {
                return -1;
            }
            else if (shouldIgnoreMismatch) {
                if (args.length != 6 || !args[5].equals("--ignore-version-mismatch")) { 
                    return -1;
                }
            }
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

