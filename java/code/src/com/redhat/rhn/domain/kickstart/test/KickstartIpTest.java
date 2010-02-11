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
package com.redhat.rhn.domain.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * KickstartSessionTest
 * @version $Rev$
 */
public class KickstartIpTest extends BaseTestCaseWithUser {

    public void testKickstartDataTest() throws Exception {
        KickstartData k = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        assertNotNull(k);
        k = addIpRangesToKickstart(k);
        assertEquals(2, k.getIps().size());
    }
    
    public static KickstartData addIpRangesToKickstart(KickstartData ksdata) {
        KickstartIpRange ip1 = new KickstartIpRange();
        KickstartIpRange ip2 = new KickstartIpRange();

        ip1.setKsdata(ksdata);
        ip2.setKsdata(ksdata);
        ip1.setOrg(ksdata.getOrg());
        ip2.setOrg(ksdata.getOrg());
        ip1.setMin(3232236034L);
        ip1.setMax(3232236282L);
        ip2.setMin(3232236547L);
        ip2.setMax(3232236794L);
        ip1.setCreated(new Date());
        ip2.setCreated(new Date());
        ip1.setModified(new Date());
        ip2.setModified(new Date());

        ksdata.addIpRange(ip1);
        ksdata.addIpRange(ip2);
        TestUtils.saveAndFlush(ip1);
        TestUtils.saveAndFlush(ip2);
        KickstartFactory.saveKickstartData(ksdata);
        ksdata = (KickstartData) TestUtils.reload(ksdata);
        assertEquals(ip1.getKsdata(), ip2.getKsdata());
        return ksdata;
    }
    
}
