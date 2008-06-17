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
package com.redhat.rhn.frontend.xmlrpc.channel.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.xmlrpc.channel.ChannelHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * ChannelHandlerTest
 * @version $Rev$
 */
public class ChannelHandlerTest extends BaseHandlerTestCase {

    private ChannelHandler handler = new ChannelHandler();
    
    public void testListSoftwareChannels() throws Exception {
        
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        Object[] result = handler.listSoftwareChannels(adminKey);
        assertNotNull(result);
        assertTrue(result.length > 0);
        
        for (int i = 0; i < result.length; i++) {
            Map item = (Map) result[i];
            Set keys = item.keySet();
            for (Iterator itr = keys.iterator(); itr.hasNext();) {
                Object key = itr.next();
                // make sure we don't send out null
                assertNotNull(item.get(key));
            }
        }
    }
}
