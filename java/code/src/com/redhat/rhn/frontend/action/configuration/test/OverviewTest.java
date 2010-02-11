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
package com.redhat.rhn.frontend.action.configuration.test;

import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Map;

public class OverviewTest extends RhnMockStrutsTestCase {
    
    public void testExecute() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        
        
        TestUtils.saveAndFlush(user);
        
        //Make a file for the recentFiles list
        ConfigFile file = ConfigTestUtils.createConfigFile(user.getOrg());
        //Make a revision so that the query can get at the file type attribute
        ConfigTestUtils.createConfigRevision(file);
        
        ConfigTestUtils.giveUserChanAccess(user, file.getConfigChannel());
        ConfigurationFactory.commit(file);
        
        setRequestPathInfo("/configuration/Overview");
        actionPerform();
        
        Map summary = (Map)request.getAttribute("summary");
        verifyList("recentFiles", ConfigFileDto.class);
        assertNotNull(request.getAttribute("recentActions"));
        assertNotNull(summary);
        
        assertTrue(summary.containsKey("channels"));
        assertFalse(summary.containsKey("quota"));
        
    }

}
