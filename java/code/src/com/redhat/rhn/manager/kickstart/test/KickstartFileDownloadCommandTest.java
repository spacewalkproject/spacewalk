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
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

/**
 * KickstartFileDownloadCommandTest
 * @version $Rev$
 */
public class KickstartFileDownloadCommandTest extends
        BaseKickstartCommandTestCase {

    public void testDownload() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        Channel c = ChannelFactoryTest.createTestChannel(user);
        ksdata.getKickstartDefaults().getKstree().setChannel(c);
        KickstartDataTest.addKickstartPackagesToChannel(c, true);
        ksdata.getTree().setInstallType(KickstartFactory.
                lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_5));

        String fakeKey = "io89089sfd78r789y8989asf89asfd89we789789asfd";
        KickstartCommand keyCommand =
            KickstartFactory.createKickstartCommand(ksdata, "key");
        keyCommand.setArguments(fakeKey);
        RhnMockHttpServletRequest req = new RhnMockHttpServletRequest();
        //req.setRequestURI("http://localhost.redhat.com");
        req.setRequestURL("http://localhost.redhat.com/");
    }
}
