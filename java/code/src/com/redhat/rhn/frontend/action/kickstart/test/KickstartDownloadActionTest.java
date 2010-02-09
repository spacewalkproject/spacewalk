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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.user.User;

/**
 * KickstartPreActionTest
 * @version $Rev: 1 $
 */
public class KickstartDownloadActionTest extends BaseKickstartEditTestCase {
    
    
    public void testDownloadFile() throws Exception {
        setupKickstartDownloadTest(ksdata, user);
        setRequestPathInfo("/kickstart/KickstartFileDownload");
        actionPerform();
        verifyNoActionErrors();
    }

    public static Channel setupKickstartDownloadTest(KickstartData ksdata, 
            User user) throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        ksdata.getKickstartDefaults().getKstree().setChannel(c);
        KickstartDataTest.addKickstartPackagesToChannel(c, true);
        return c;
    }

}


