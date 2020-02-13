/**
 * Copyright (c) 2016 SUSE LLC
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

package com.redhat.rhn.manager.kickstart.tree.test;

import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.manager.kickstart.tree.BaseTreeEditOperation;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

/**
 * Base class for Tree operations tests
 */
public abstract class TreeOperationTestBase extends BaseTestCaseWithUser {

    protected void setTestTreeParams(BaseTreeEditOperation cmd) throws Exception {
        cmd.setInstallType(KickstartFactory.lookupKickstartInstallTypeByLabel("rhel_4"));
        cmd.setBasePath(KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath());
        cmd.setChannel(ChannelFactoryTest.createTestChannel(user));
        cmd.setLabel("some_label" + TestUtils.randomString());
    }

}
