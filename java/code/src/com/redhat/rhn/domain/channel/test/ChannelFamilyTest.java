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
package com.redhat.rhn.domain.channel.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.common.CommonConstants;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.HashSet;
import java.util.Set;

/**
 * ChannelFamilyTest
 * @version $Rev$
 */
public class ChannelFamilyTest extends BaseTestCaseWithUser {
    
    public void testChannelFamily() throws Exception {

        ChannelFamily cfam = ChannelFamilyFactory.
                            lookupOrCreatePrivateFamily(user.getOrg());

        //add a channel
        Channel c = ChannelFactoryTest.createTestChannel(user);
        c.setChannelFamily(cfam);

        assertEquals(c.getChannelFamilies().size(), 1);
        ChannelFamilyFactory.save(cfam);

        ChannelFamily cfam2 = c.getChannelFamily();
        assertEquals(cfam, cfam2);

        ChannelFamily cfam3 = ChannelFamilyFactory.lookupById(cfam.getId());
        
        assertEquals(cfam.getId(), cfam3.getId());
        assertEquals(cfam.getLabel(), cfam3.getLabel());
        assertEquals(cfam.getName(), cfam3.getName());
        assertEquals(cfam.getProductUrl(), cfam3.getProductUrl());
        assertEquals(cfam.getOrg(), cfam3.getOrg());
    }
    
    public void testVirtSubType() throws Exception {
        ChannelFamily cfam = ChannelFamilyFactory.
                                lookupOrCreatePrivateFamily(user.getOrg());
        Set levels = new HashSet();
        levels.add(CommonConstants.getVirtSubscriptionLevelFree());
        levels.add(CommonConstants.getVirtSubscriptionLevelPlatformFree());
        cfam.setVirtSubscriptionLevels(levels);
        ChannelFamilyFactory.save(cfam);
        cfam = (ChannelFamily) reload(cfam);
        assertNotNull(cfam.getVirtSubscriptionLevels());
        assertTrue(cfam.getVirtSubscriptionLevels().size() >= 2);
    }
}
