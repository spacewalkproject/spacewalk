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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.servlets.RhnHttpServletRequest;
import com.redhat.rhn.manager.kickstart.KickstartOptionsCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * KickstartDetailsCommandTest - test for KickstartDetailsCommand
 * @version $Rev$
 */
public class KickstartOptionsCommandTest extends BaseTestCaseWithUser {

    private RhnHttpServletRequest request;
    private RhnMockHttpServletRequest mockRequest;

    public void testKickstartOptionsCommand() throws Exception {
        KickstartData k = KickstartDataTest.createKickstartWithOptions(user.getOrg());

        User ksUser = UserTestUtils.createUser("testuser", k.getOrg().getId());

        mockRequest = new RhnMockHttpServletRequest();
        mockRequest.setupGetRemoteAddr("127.0.0.1");
        request = new RhnHttpServletRequest(mockRequest);

        KickstartOptionsCommand command = new KickstartOptionsCommand(k.getId(), ksUser);

        assertNotNull(command);
        assertTrue(command.getDisplayOptions().size() > 0);
        assertTrue(command.getDisplayOptions().size() >=
            command.getKickstartData().getOptions().size());

    }


}
