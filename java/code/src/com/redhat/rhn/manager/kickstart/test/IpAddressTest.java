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

import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * IpAddressTest - test for KickstartDetailsCommand
 * @version $Rev$
 */
public class IpAddressTest extends RhnBaseTestCase {
    
    public void testIp() throws Exception {
       
        long [] ip = { 192 , 168 , 1 , 1 };
        IpAddress addr = new IpAddress(ip);
        
        long ipNum = addr.getNumber();
        IpAddress addr2 = new IpAddress(ipNum);
        
        assertTrue(addr.equals(addr2));
        
        long packNum = Long.parseLong("3232235777");
        assertEquals(addr.getNumber(), packNum); //compare to what perl's pack returns
        assertEquals(addr2.getNumber(), packNum);
    }          
        
}
