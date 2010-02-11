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
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.profile.ProfileFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;

import java.util.Iterator;
import java.util.List;

/**
 * ProfileTest
 * @version $Rev$
 */
public class ProfileTest extends RhnBaseTestCase {
    
    private static Logger log = Logger.getLogger(ProfileTest.class);
    
    /**
     * Test the Equals method of Profile
     * @throws Exception
     */
    public void testProfileEquals() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        Profile p1 = createTestProfile(user, channel);      
        Profile p2 = new Profile();
        assertFalse(p1.equals(p2));
        
        /*
         * Get coverage on the "!(other instanceof Profile)" block
         * of Profile.equals() 
         */
        assertFalse(p1.equals(channel));
        
        p2 = lookupByIdAndOrg(p1.getId(), user.getOrg());
        assertTrue(p1.equals(p2));
    }
    
    /**
     * Helper method to get a Profile by id
     * @param id The profile id
     * @param org The org for this profile.
     * @return Returns the Profile corresponding to id
     * @throws Exception
     */
    public static Profile lookupByIdAndOrg(Long id, Org org) throws Exception {
        Session session = HibernateFactory.getSession();
        return (Profile) session.getNamedQuery("Profile.findByIdAndOrg")
                                    .setLong("id", id.longValue())
                                    .setLong("org_id", org.getId().longValue())
                                    .uniqueResult();
    }
    
    /**
     * Helper method to create a Profile for testing purposes
     * @return Returns a fresh Profile
     * @throws Exception
     */   
    public static Profile createTestProfile(User user, Channel channel)
        throws Exception {
        
        Profile p = new Profile();
        p.setInfo("Test information for a test Profile.");
        p.setName("RHN-JAVA" + TestUtils.randomString());
        p.setDescription("This is only a test.");
        p.setBaseChannel(channel);
        p.setOrg(user.getOrg());
        p.setProfileType(ProfileFactory.TYPE_NORMAL);
        
        assertNull(p.getId());
        TestUtils.saveAndFlush(p);
        assertNotNull(p.getId());
        
        return p;
    }
    
    public static void testCompatibleServer() throws Exception {
        // create a profile
        // create a channel
        // create a server
        // user and org
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(user);
        log.debug("CreateTest channel");
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        log.debug("Created test channel");
        createTestProfile(user, channel);
        Session session = HibernateFactory.getSession();
        
        // gotta make sure the Channel gets saved.
        session.flush();
        
        Query qry = session.getNamedQuery("Profile.compatibleWithServer");
        qry.setLong("sid", server.getId().longValue());
        qry.setLong("org_id", user.getOrg().getId().longValue());
        List list = qry.list();
        assertNotNull("List is null", list);
        assertFalse("List is empty", list.isEmpty());
        for (Iterator itr = list.iterator(); itr.hasNext();) {
            Object o = itr.next();
            assertEquals("Contains non Profile objects",
                    Profile.class, o.getClass());
        }
    }
}
