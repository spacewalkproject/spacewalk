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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

public class ChannelSystemsListSetupTest extends RhnMockStrutsTestCase {
    
    public void testExecuteNoFiles() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        
        ConfigChannel cc = ConfigTestUtils.createConfigChannel(user.getOrg());
        long ccid = cc.getId().longValue();
        setRequestPathInfo("/configuration/channel/ChannelSystems");
        addRequestParameter("ccid", "" + ccid);
        actionPerform();
        assertNotNull(request.getAttribute("pageList"));
        DataResult dr = (DataResult)request.getAttribute("pageList");
        assertEquals(0, dr.getTotalSize());
    }
}
