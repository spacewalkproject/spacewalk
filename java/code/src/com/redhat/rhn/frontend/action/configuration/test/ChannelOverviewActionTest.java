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

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.manager.configuration.ChannelSummary;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

public class ChannelOverviewActionTest extends RhnMockStrutsTestCase {

    public void testExecuteNoFiles() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);

        ConfigChannel cc = ConfigTestUtils.createConfigChannel(user.getOrg());
        ConfigFile cf = ConfigTestUtils.createConfigFile(cc);

        long ccid = cc.getId().longValue();
        setRequestPathInfo("/configuration/ChannelOverview");
        addRequestParameter("ccid", "" + ccid);
        actionPerform();
        assertNotNull(request.getAttribute("ccid"));
        assertTrue(request.getAttribute("ccid") instanceof Long);
        assertEquals(ccid, ((Long)request.getAttribute("ccid")).longValue());
        assertNotNull(request.getAttribute("channel"));
        assertNotNull(request.getAttribute("summary"));
        assertTrue(request.getAttribute("channel") instanceof ConfigChannel);
        assertTrue(request.getAttribute("summary") instanceof ChannelSummary);
    }

}
