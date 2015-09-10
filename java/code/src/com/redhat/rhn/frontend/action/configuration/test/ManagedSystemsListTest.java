/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

public class ManagedSystemsListTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);

        //Make a channel so it will appear in the list.
        ConfigChannel channel = ConfigTestUtils.createConfigChannel(user.getOrg(),
                ConfigChannelType.local());
        Server serv = ConfigTestUtils.giveUserChanAccess(user, channel);
        //This list only shows channels that actually have files in them
        //  it is more of a managed systems list, rather than a local channel list.
        ConfigFile file = ConfigTestUtils.createConfigFile(channel);
        ConfigurationFactory.commit(file);

        setRequestPathInfo("/configuration/system/ManagedSystems");
        actionPerform();

        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);

        assertTrue("Your list: pageList is NOT Empty", dr.isEmpty());

        ConfigTestUtils.giveConfigCapabilities(serv);
        actionPerform();
        verifyList(RequestContext.PAGE_LIST, ConfigSystemDto.class);
    }
}
