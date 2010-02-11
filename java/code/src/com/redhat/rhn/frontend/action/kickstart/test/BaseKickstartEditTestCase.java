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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.List;

/**
 * KickstartDetailsEditTest
 * @version $Rev: 1 $
 */
public class BaseKickstartEditTestCase extends RhnMockStrutsTestCase {
    
    protected KickstartData ksdata;    
    
    public void setUp() throws Exception {
        super.setUp();
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        this.ksdata = KickstartDataTest.createKickstartWithChannel(user.getOrg());
        TestUtils.saveAndFlush(ksdata);
        List channels = ChannelFactory.getKickstartableChannels(user.getOrg());
        assertNotNull(channels);
        assertTrue(channels.size() > 0);
        addRequestParameter(RequestContext.KICKSTART_ID, this.ksdata.getId().toString());
    }

}

