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
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.action.satellite.BootstrapConfigAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.apache.struts.action.DynaActionForm;

/**
 * BootstrapConfigActionTest
 * @version $Rev: 1 $
 */
public class BootstrapConfigActionTest extends RhnMockStrutsTestCase {
    
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        Config.get().setString("web.com.redhat.rhn.frontend." +
                "action.satellite.BootstrapConfigAction.command", 
                TestConfigureBootstrapCommand.class.getName());
    }

    public void testNonSubmitExecute() throws Exception {
        String expectedHostname = Config.get().getString(ConfigDefaults.JABBER_SERVER);
        if (expectedHostname == null) {
            expectedHostname = "localhost";
            Config.get().setString(ConfigDefaults.JABBER_SERVER, expectedHostname);
        }
        addRequestParameter(RhnAction.SUBMITTED, Boolean.FALSE.toString());
        setRequestPathInfo("/admin/config/BootstrapConfig");
        actionPerform();
        DynaActionForm form = (DynaActionForm) getActionForm();
        assertEquals(expectedHostname, 
                form.getString(BootstrapConfigAction.HOSTNAME));
        assertEquals(BootstrapConfigAction.DEFAULT_CERT_PATH, 
                form.getString(BootstrapConfigAction.SSL_CERT));
        assertEquals(Boolean.TRUE, 
                form.get(BootstrapConfigAction.ENABLE_SSL));
        assertEquals(Boolean.TRUE, 
                form.get(BootstrapConfigAction.ENABLE_GPG));
        assertEquals(Boolean.TRUE, 
                form.get(BootstrapConfigAction.ALLOW_CONFIG_ACTIONS));
        assertEquals(Boolean.TRUE, 
                form.get(BootstrapConfigAction.ALLOW_REMOTE_COMMANDS));
        assertEquals("", form.getString(BootstrapConfigAction.HTTP_PROXY));
        assertEquals("", form.getString(BootstrapConfigAction.HTTP_PROXY_USERNAME));
        assertEquals("", form.getString(BootstrapConfigAction.HTTP_PROXY_PASSWORD));
        
        
    }
    
    public void testSubmitExecute() throws Exception {
        
        String expectedHostname = Config.get().getString(ConfigDefaults.JABBER_SERVER);
        if (expectedHostname == null) {
            expectedHostname = "localhost";
            Config.get().setString(ConfigDefaults.JABBER_SERVER, expectedHostname);
        }
        
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(BootstrapConfigAction.HOSTNAME, "localhost");
        setRequestPathInfo("/admin/config/BootstrapConfig");
        actionPerform();
        verifyActionMessages(new String[]{"bootstrap.config.success"});
    }
}

