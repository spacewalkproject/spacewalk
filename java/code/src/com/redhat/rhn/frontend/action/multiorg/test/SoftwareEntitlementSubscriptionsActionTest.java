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
package com.redhat.rhn.frontend.action.multiorg.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;

/**
 * SoftwareEntitlementSubscriptionsActionTest
 * @version $Rev: 1 $
 */
public class SoftwareEntitlementSubscriptionsActionTest extends RhnMockStrutsTestCase {
    private Org testOrg;
    private ChannelFamily family;
    
    public void setUp() throws Exception {
        super.setUp();
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        TestUtils.saveAndFlush(user);

        Server s = ServerTestUtils.createTestSystem(user);
        Channel chan = (Channel)s.getChannels().iterator().next();
        family = chan.getChannelFamily();
        testOrg = s.getOrg();
        
        
        setRequestPathInfo("/admin/multiorg/SoftwareEntitlementSubscriptions");
        addRequestParameter("cfid", family.getId().toString());
        actionPerform();
    }
        
    public void testSatelliteOrg() throws Exception {
        // Default org should not have any entry for the test channel family created:
        assertNull(request.getAttribute("satelliteOrgOverview"));
    }
        
}
