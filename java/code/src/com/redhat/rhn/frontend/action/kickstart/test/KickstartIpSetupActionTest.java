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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

/**
 * KickstartsSetupActionTest
 * @version $Rev: 1 $
 */
public class KickstartIpSetupActionTest extends RhnMockStrutsTestCase {

    public void testKickstartIpList() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());

        // Create a kickstart and the ranges so the list
        // will return something.
        KickstartData k = KickstartDataTest.createTestKickstartData(user.getOrg());

        KickstartIpRange ip1 = new KickstartIpRange();
        KickstartIpRange ip2 = new KickstartIpRange();

        ip1.setKsdata(k);
        ip2.setKsdata(k);
        ip1.setOrg(k.getOrg());
        ip2.setOrg(k.getOrg());
        ip1.setMin(3232236800L);
        ip1.setMax(3232236850L);
        ip2.setMin(3232236900L);
        ip2.setMax(3232236950L);
        ip1.setCreated(new Date());
        ip2.setCreated(new Date());
        ip1.setModified(new Date());
        ip2.setModified(new Date());

        k.addIpRange(ip1);
        k.addIpRange(ip2);

        TestUtils.saveAndFlush(k);

        setRequestPathInfo("/kickstart/KickstartIpRanges");
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() >= 2);
    }

}

