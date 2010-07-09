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
package com.redhat.rhn.domain.rhnpackage.profile.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.profile.ProfileFactory;
import com.redhat.rhn.domain.rhnpackage.profile.ProfileType;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.util.Iterator;
import java.util.List;

/**
 * ProfileFactoryTest
 * @version $Rev$
 */
public class ProfileFactoryTest  extends RhnBaseTestCase {

    public void testCreateProfile() {
        Profile p = ProfileFactory.createProfile(ProfileFactory.TYPE_NORMAL);
        assertNotNull(p);
        assertEquals(ProfileFactory.TYPE_NORMAL, p.getProfileType());
    }

    public void testLookupByLabel() {
        ProfileType pt = ProfileFactory.lookupByLabel("normal");
        assertNotNull("ProfileType is null", pt);
        assertEquals("Not equal to normal", ProfileFactory.TYPE_NORMAL, pt);

        pt = ProfileFactory.lookupByLabel("foo");
        assertNull("Found a ProfileType labeled foo", pt);
    }

    public void testCompatibleWithServer() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(user);
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        ProfileTest.createTestProfile(user, channel);
        Session session = HibernateFactory.getSession();

        // gotta make sure the Channel gets saved.
        session.flush();

        List list = ProfileFactory.compatibleWithServer(server, user.getOrg());
        assertNotNull("List is null", list);
        assertFalse("List is empty", list.isEmpty());
        for (Iterator itr = list.iterator(); itr.hasNext();) {
            Object o = itr.next();
            assertEquals("List contains something other than Profiles",
                    Profile.class, o.getClass());
        }
    }

    public void testLookupById() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        Profile p = ProfileTest.createTestProfile(user, channel);
        assertNotNull(p);
        assertEquals(ProfileFactory.TYPE_NORMAL, p.getProfileType());
        TestUtils.saveAndFlush(p);
        Profile p1 = ProfileFactory.lookupByIdAndOrg(p.getId(), user.getOrg());
        assertEquals(p, p1);
    }

    public void testFindByNameAndOrgId() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        Profile p = ProfileTest.createTestProfile(user, channel);
        String name = p.getName();
        Long orgid = p.getOrg().getId();
        assertNotNull(p);
        assertEquals(ProfileFactory.TYPE_NORMAL, p.getProfileType());
        TestUtils.saveAndFlush(p);
        Profile p1 = ProfileFactory.findByNameAndOrgId(name, orgid);
        assertEquals(p, p1);
    }
}
