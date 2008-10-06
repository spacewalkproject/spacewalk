/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;


/**
 * Test for urlhelper
 * 
 * @version $Rev $
 */
public class KickstartUrlHelperTest extends BaseKickstartCommandTestCase {
    
    private KickstartUrlHelper helper;
    
    @Override
    public void setUp() throws Exception {
        super.setUp();
        helper = new KickstartUrlHelper(ksdata, "spacewalk.example.com");
    }

    public void testGetKickstartFileUrl() {
        System.out.println("1: " + helper.getKickstartFileUrl());
        String expected = "http://spacewalk.example.com/" +
            "kickstart/ks/org/" + ksdata.getOrg().getId() + "/label/" +
            ksdata.getLabel(); 
        assertEquals(expected, helper.getKickstartFileUrl());
    }

    public void testGetKickstartFileUrlBase() {
        System.out.println("2: " + helper.getKickstartFileUrlBase());
        String expected = "http://spacewalk.example.com/" +
                "kickstart/ks/org/" + ksdata.getOrg().getId();
        assertEquals(expected, helper.getKickstartFileUrlBase());

    }

    public void testGetKickstartFileUrlIpRange() {
        System.out.println("3: " + helper.getKickstartFileUrlIpRange());
        String expected = "http://spacewalk.example.com/" +
            "kickstart/ks/org/" + ksdata.getOrg().getId() + "/mode/ip_range"; 
        assertEquals(expected, helper.getKickstartFileUrlIpRange());

    }
}
