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
package com.redhat.rhn.domain.token.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.List;


public class ActivationKeyFactoryTest extends BaseTestCaseWithUser {


    public void testListAssociatedKickstarts() throws Exception {

        ActivationKey key = ActivationKeyTest.createTestActivationKey(user);

        List<KickstartData> list = ActivationKeyFactory.listAssociatedKickstarts(key);
        assertTrue(list.isEmpty());

        KickstartData data = KickstartDataTest.createTestKickstartData(user.getOrg());
        data.getDefaultRegTokens().add(key.getToken());

        list = ActivationKeyFactory.listAssociatedKickstarts(key);
        assertTrue(list.size() == 1);

    }

}
