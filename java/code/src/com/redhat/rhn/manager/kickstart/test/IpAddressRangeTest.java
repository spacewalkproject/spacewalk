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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.manager.kickstart.IpAddressRange;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.Date;
import java.util.Set;

/**
 * IpAddressRangeTest - test for IpAddressRange
 * @version $Rev$
 */
public class IpAddressRangeTest extends BaseTestCaseWithUser {
    
    private static long [] minIp = { 192 , 168 , 1 , 1 };
    private static IpAddress min = new IpAddress(minIp);
    
    private static long [] maxIp = { 192 , 168 , 1 , 5 };
    private static IpAddress max = new IpAddress(maxIp);
    
    private static long [] minIp2 = { 192 , 168 , 1 , 1 };
    private static IpAddress min2 = new IpAddress(minIp2);
    
    private static long [] maxIp2 = { 192 , 168 , 1 , 5 };
    private static IpAddress max2 = new IpAddress(maxIp2);
    
    private static long [] minIp3 = { 192 , 168 , 1 , 1 };
    private static IpAddress min3 = new IpAddress(minIp3);
    
    private static long [] maxIp3 = { 192 , 168 , 1 , 9 };
    private static IpAddress max3 = new IpAddress(maxIp3);
    
    private static long [] minIp4 = { 192 , 168 , 1 , 2 };
    private static IpAddress min4 = new IpAddress(minIp4);

    private static long [] maxIp4 = { 192 , 168 , 1 , 4 };
    private static IpAddress max4 = new IpAddress(maxIp4);

    private static long [] minIp5 = { 192 , 168 , 1 , 11 };
    private static IpAddress min5 = new IpAddress(minIp5);

    private static long [] maxIp5 = { 192 , 168 , 1 , 13 };
    private static IpAddress max5 = new IpAddress(maxIp5);

    
    public void testRange() throws Exception {
        
        KickstartData k = KickstartDataTest.createTestKickstartData(user.getOrg());
        

        
        IpAddressRange range1 = new IpAddressRange(min, max, k.getId());
        IpAddressRange range2 = new IpAddressRange(min2, max2, k.getId());
        IpAddressRange range3 = new IpAddressRange(min3, max3, k.getId());

        assertTrue(range1.equals(range2));
        assertFalse(range1.equals(range3));
        assertEquals(range1.getMax().getNumber(), range2.getMax().getNumber());
        assertEquals(range1.getMin().getNumber(), range2.getMin().getNumber());
        
        KickstartIpRange ipr = new KickstartIpRange();
        assertNotNull(ipr);
        ipr.setKsdata(k);
        ipr.setMax(max.getNumber());
        ipr.setMin(min.getNumber());
        ipr.setModified(new Date());
        ipr.setOrg(k.getOrg());
        k.addIpRange(ipr);             
        
        Set s = k.getIps();
        assertEquals(1, s.size());
    }
    
    public void testSetTheory() throws Exception {
        KickstartData k = KickstartDataTest.createTestKickstartData(user.getOrg());
        IpAddressRange range1 = new IpAddressRange(min, max3, k.getId());
        IpAddressRange range2 = new IpAddressRange(min4, max4, k.getId());
        IpAddressRange range3 = new IpAddressRange(min5, max5, k.getId());
        
        assertTrue(range1.isSuperset(range2));
        assertTrue(range2.isSubset(range1));
        assertTrue(range3.isDisjoint(range1));
        assertTrue(range1.canCoexist(range2));
        assertTrue(range1.isRangeBefore(range3));
        assertTrue(range3.isRangeAfter(range1));
        assertTrue(range1.isIpAddressContained(min4));
    }
    
}
