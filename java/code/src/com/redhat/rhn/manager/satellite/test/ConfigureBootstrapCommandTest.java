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

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.manager.satellite.ConfigureBootstrapCommand;
import com.redhat.rhn.manager.satellite.Executor;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

/**
 * ConfigureBootstrapCommandTest - test for ConfigureBootstrapCommand
 * @version $Rev$
 */
public class ConfigureBootstrapCommandTest extends BaseTestCaseWithUser {
    
    private ConfigureBootstrapCommand cmd;
    
    public void testCreateCommand() throws Exception {
        user.addRole(RoleFactory.SAT_ADMIN);
        cmd = new ConfigureBootstrapCommand(user) {
            protected Executor getExecutor() {
                return new TestExecutor();
            }
        };
        
        assertNotNull(cmd.getUser());
        cmd.setHostname("localhost");
        cmd.setSslPath("/tmp/somepath.cert");
        cmd.setAllowRemoteCommands(Boolean.TRUE);
        cmd.setAllowConfigActions(Boolean.TRUE);
        cmd.setEnableGpg(Boolean.FALSE);
        cmd.setEnableSsl(Boolean.FALSE);
        cmd.setHttpProxy("proxy-host.redhat.com");
        cmd.setHttpProxyUsername("username");
        cmd.setHttpProxyPassword("password");
        assertNull(cmd.storeConfiguration());
    }
    
    /**
     * TestExecutor - 
     * @version $Rev$
    */ 
    public class TestExecutor implements Executor {

        public int execute(String[] args) {
            if (args.length != 11) {
                return -1;
            }
            if (!args[0].equals("/usr/bin/sudo")) {
                return -2;
            }
            else if (!args[1].equals("/usr/bin/rhn-bootstrap")) {
                return -3;
            }
            else if (!args[2].equals("--allow-config-actions")) {
                return -4;
            }
            else if (!args[3].startsWith("--allow-remote-commands")) {
                return -5;
            }
            else if (!args[4].startsWith("--no-ssl")) {
                return -6;
            }
            else if (!args[5].startsWith("--no-gpg")) {
                return -7;
            }
            else if (!args[6].startsWith("--hostname=localhost")) {
                return -8;
            }
            else if (!args[7].startsWith("--ssl-cert=/tmp/somepath.cert")) {
                return -9;
            }
            else if (!args[8].startsWith("--http-proxy=proxy-host.redhat.com")) {
                return -10;
            }
            else if (!args[9].startsWith("--http-proxy-username=username")) {
                return -11;
            }
            else if (!args[10].startsWith("--http-proxy-password=password")) {
                return -12;
            }
            else {
                return 0;
            }
        }

        public String getLastCommandOutput() {
            return null;
        }

        public String getLastCommandErrorMessage() {
            return null;
        }
    }

}

