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
package com.redhat.rhn.domain.config.test;

import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * ConfigRevisionTest
 * @version $Rev$
 */
public class ConfigRevisionTest extends BaseTestCaseWithUser {
    
    public void testCreateConfigRevision() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());

        ConfigRevision cr = ConfigTestUtils.createConfigRevision(user.getOrg());
        
        cr.setConfigFileType(ConfigFileType.dir());
        cr.setChangedById(user.getId());
        ConfigurationFactory.commit(cr);
        Long crid = cr.getId();
        flushAndEvict(cr);
        cr = ConfigurationFactory.lookupConfigRevisionById(crid);
        assertNotNull(cr);
        assertNotNull(cr.getId());
        assertNotNull(cr.getConfigFileType());
        assertEquals("directory", cr.getConfigFileType().getLabel());
        assertTrue(cr.isDirectory());
        
        assertNotNull(cr.getChangedById());
        assertTrue(cr.getChangedById().equals(user.getId()));
        assertNotNull(cr.getChangedBy());
        assertEquals(user.getLogin(), cr.getChangedBy().getLogin());
    }
}

