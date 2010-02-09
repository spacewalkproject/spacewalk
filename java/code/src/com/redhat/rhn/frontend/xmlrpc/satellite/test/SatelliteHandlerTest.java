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
package com.redhat.rhn.frontend.xmlrpc.satellite.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.xmlrpc.satellite.SatelliteHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

import java.util.Map;


public class SatelliteHandlerTest extends BaseHandlerTestCase {

    private SatelliteHandler handler = new SatelliteHandler();
    
    public void testListProxies() throws Exception {
        Server server = ServerFactoryTest.createTestProxyServer(admin, false);        
        Object[] list = handler.listProxies(adminKey);
        assertEquals(1, list.length);
        assertEquals(server.getId(), ((Map)list[0]).get("id"));
    }
    
    public void testListEntitlements() throws Exception {
        
        //Can't really do that much testing, since it isn't that easy to test
        //  these values.  Just some basic class checking done to make sure nothing has
        //  really gone crazy
        
        Map map = handler.listEntitlements(adminKey);
        Object[] systemEnts = (Object[]) map.get("system");
        assertNotNull(systemEnts);
        for (int i = 0; i < systemEnts.length; i++) {
            assertTrue(systemEnts[i].getClass() == EntitlementServerGroup.class);
        }
        
        Object[] channelEnts = (Object[]) map.get("channel");
        assertNotNull(channelEnts);
        
        for (int i = 0; i < channelEnts.length; i++) {
            assertTrue(channelEnts[i].getClass() == ChannelOverview.class);
        }  
    }
    
    
    public void testGetCertificateExpiration() throws Exception  {
        admin.addRole(RoleFactory.SAT_ADMIN);
        handler.getCertificateExpirationDate(adminKey);
    }
    
    
}
