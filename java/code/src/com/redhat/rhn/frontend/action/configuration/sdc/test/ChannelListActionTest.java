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
package com.redhat.rhn.frontend.action.configuration.sdc.test;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.ConfigChannelDto;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * ChannelListActionTest
 * @version $Rev$
 */
public class ChannelListActionTest extends RhnMockStrutsTestCase {
    
    public void testExecute() throws Exception {
        //Create a config channel and a server
        ConfigChannel channel = ConfigTestUtils.createConfigChannel(user.getOrg());
        Server server = ServerFactoryTest.createTestServer(user, true, 
                ServerConstants.getServerGroupTypeProvisioningEntitled());
        //associate the two.
        server.subscribe(channel);
        SystemManager.storeServer(server);
        
        setRequestPathInfo("/systems/details/configuration/ConfigChannelList");
        addRequestParameter("sid", server.getId().toString());
        actionPerform();
        verifyPageList(ConfigChannelDto.class);
    }

}
