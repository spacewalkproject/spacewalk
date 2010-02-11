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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.kickstart.test.ActivationKeysTest;
import com.redhat.rhn.manager.kickstart.KickstartSessionCreateCommand;
import com.redhat.rhn.manager.profile.test.ProfileManagerTest;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartSessionCommandCreateTest
 * @version $Rev$
 */
public class KickstartSessionCommandCreateTest extends BaseKickstartCommandTestCase {

    public void testCreate() throws Exception {
        // We want to add a activation key to the kickstart data to validate
        // that we get both a one-time-key and the actual key associated with the KS
        // See BZ: 252980
        ActivationKeysTest.addKeysToKickstartData(user, ksdata);
        user.addRole(RoleFactory.ORG_ADMIN);
        Profile p = ProfileManagerTest.createProfileWithServer(user);
        ksdata.getKickstartDefaults().setProfile(p);
        TestUtils.saveAndFlush(ksdata);
        Channel toolsChannel = ChannelFactoryTest.createTestChannel(user);
        KickstartScheduleCommandTest.
            setupChannelForKickstarting(toolsChannel, user);
        toolsChannel.setParentChannel(ksdata.getChannel());
        ChannelFactory.save(toolsChannel);
        
        UserFactory.save(user);
        KickstartSessionCreateCommand cmd = new 
            KickstartSessionCreateCommand(user.getOrg(), ksdata, "127.0.0.1");
        assertNull(cmd.store());
        assertNotNull(cmd.getKickstartSession());
        KickstartSession sess = cmd.getKickstartSession();
        sess = (KickstartSession) reload(sess);
        assertNotNull(sess);
        assertNotNull(ActivationKeyFactory.
                lookupByKickstartSession(sess));
        // This assertion was added because of BZ:
        // https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=186969
        // Which was HOTFIXED
        assertNotNull(sess.getServerProfile());

    }
}
