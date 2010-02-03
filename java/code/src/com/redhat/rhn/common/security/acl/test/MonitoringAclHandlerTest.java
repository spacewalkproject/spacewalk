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
package com.redhat.rhn.common.security.acl.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.security.acl.Acl;
import com.redhat.rhn.common.security.acl.MonitoringAclHandler;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * SystemAclHandlerTest
 * @version $Rev: 54296 $
 */
public class MonitoringAclHandlerTest extends RhnBaseTestCase {

    public void testShowMonitoring() {
        
        Config c = Config.get();

        Acl acl = new Acl();
        acl.registerHandler(new MonitoringAclHandler());

        Map context = new HashMap();
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        context.put("user", user);
        assertFalse(acl.evalAcl(context, "show_monitoring()"));
        
        user.getOrg().getEntitlements()
            .add(OrgFactory.lookupEntitlementByLabel("rhn_monitor"));
        String orig = c.getString(ConfigDefaults.WEB_IS_MONITORING_BACKEND);
        c.setBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, "1");
        assertFalse(acl.evalAcl(context, "show_monitoring()"));
        
        user.addRole(RoleFactory.MONITORING_ADMIN);
        assertTrue(acl.evalAcl(context, "show_monitoring()"));
        
        c.setBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, "0");
        assertFalse(acl.evalAcl(context, "show_monitoring()"));
        
        c.setBoolean(ConfigDefaults.WEB_IS_MONITORING_BACKEND, orig);
    }

}
