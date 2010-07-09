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
package com.redhat.rhn.frontend.xmlrpc.channel.access.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.xmlrpc.InvalidAccessValueException;
import com.redhat.rhn.frontend.xmlrpc.channel.access.ChannelAccessHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

/**
 * ChannelAccessHandlerTest
 * @version $Rev$
 */
public class ChannelAccessHandlerTest extends BaseHandlerTestCase {

    private ChannelAccessHandler handler = new ChannelAccessHandler();

    public void testEnableUserRestrictions() throws Exception {

        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        // restrictions are disabled by default
        assertTrue(channel.isGloballySubscribable(admin.getOrg()));

        // execute
        int result = handler.enableUserRestrictions(adminKey, channel.getLabel());

        // verify
        assertEquals(1, result);

        channel = ChannelFactory.lookupByLabelAndUser(channel.getLabel(), admin);
        assertFalse(channel.isGloballySubscribable(admin.getOrg()));
    }

    public void testDisableUserRestrictions() throws Exception {

        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        channel.setGloballySubscribable(false, channel.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        assertFalse(channel.isGloballySubscribable(admin.getOrg()));

        // execute
        int result = handler.disableUserRestrictions(adminKey, channel.getLabel());

        // verify
        assertEquals(1, result);

        channel = ChannelFactory.lookupByLabelAndUser(channel.getLabel(), admin);
        assertTrue(channel.isGloballySubscribable(admin.getOrg()));
    }

    public void testGetOrgSharing() throws Exception {

        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        channel.setAccess(Channel.PUBLIC);
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        assertEquals(Channel.PUBLIC, channel.getAccess());

        // execute
        String result = handler.getOrgSharing(adminKey, channel.getLabel());

        // verify
        assertEquals(Channel.PUBLIC, result);
    }

    public void testSetOrgSharing() throws Exception {

        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        assertEquals(Channel.PRIVATE, channel.getAccess());

        // execute
        int result = handler.setOrgSharing(adminKey, channel.getLabel(), Channel.PROTECTED);

        // verify
        assertEquals(1, result);

        channel = ChannelFactory.lookupByLabelAndUser(channel.getLabel(), admin);
        assertEquals(Channel.PROTECTED, channel.getAccess());
    }

    public void testSetOrgSharingInvalidAccess() throws Exception {

        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);
        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        try {
            handler.setOrgSharing(adminKey, channel.getLabel(), "invalid");
            fail("should have gottent an invalid access value exception.");
        }
        catch (InvalidAccessValueException e) {
            //success
        }
    }
}
