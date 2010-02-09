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
package com.redhat.rhn.domain.kickstart.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.kickstart.test.KickstartDownloadActionTest;
import com.redhat.rhn.manager.kickstart.test.KickstartScheduleCommandTest;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

/**
 * CancelKickstartTest - test to verify that we cancel kickstarts and the actions correctly.
 * @version $Rev$
 */
public class CancelKickstartTest extends BaseTestCaseWithUser {

    public void testCanceledActions() throws Exception {
        Server s = ServerFactoryTest.createTestServer(user, true);
        KickstartData k = KickstartDataTest.
            createKickstartWithOptions(user.getOrg());
        
        Channel c = KickstartDownloadActionTest.setupKickstartDownloadTest(k, user);
        s.addChannel(c);
        
        KickstartSession cancelsession = 
            KickstartScheduleCommandTest.scheduleAKickstart(s, k).getKickstartSession();
        assertNotNull(cancelsession.getAction());
        Long aid1 = cancelsession.getAction().getId();
        cancelsession.markFailed("failed : " + TestUtils.randomString());
        KickstartFactory.saveKickstartSession(cancelsession);
        flushAndEvict(cancelsession);
        flushAndEvict(cancelsession.getAction());
        HibernateFactory.getSession().flush();
        Action lookupreload = ActionFactory.lookupById(aid1);
        lookupreload = (Action) reload(lookupreload);
        assertTrue(lookupreload.getServerActions() == null ||
                lookupreload.getServerActions().size() == 0);
    }

}
