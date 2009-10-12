/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.domain.monitoring.config.test;

import com.redhat.rhn.domain.monitoring.config.ConfigMacro;
import com.redhat.rhn.domain.monitoring.config.MonitoringConfigFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.List;

/**
 * MonitoringConfigTest
 * @version $Rev: 52080 $
 */
public class MonitoringConfigTest extends RhnBaseTestCase {

    public void testConfig() throws Exception {
        List macros = MonitoringConfigFactory.lookupConfigMacros(true);
        assertNotNull(macros);
        assertTrue(macros.size() > 0);
        assertTrue(macros.get(0) instanceof ConfigMacro);
    }
    
    public void testUpdateConfig() throws Exception {
        List macros = MonitoringConfigFactory.lookupConfigMacros(true);
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        ConfigMacro cr = (ConfigMacro) macros.get(0);
        assertNotNull(cr.getLastUpdateUser());
        cr.setLastUpdateUser(user.getLogin());
        MonitoringConfigFactory.saveConfigMacro(cr);
        String name = cr.getName();
        flushAndEvict(cr);
        cr = (ConfigMacro) TestUtils.lookupTestObject(
                "from com.redhat.rhn.domain.monitoring.config.ConfigMacro c where " +
                "c.name = '" + name + "'");
        assertTrue(cr.getLastUpdateUser().equals(user.getLogin()));
        
    }
    
    public void testLookupConfigMacro() throws Exception {

        ConfigMacro cm = MonitoringConfigFactory.lookupConfigMacroByName("MAIL_MX");
        assertNotNull(cm);
    }
    
}

