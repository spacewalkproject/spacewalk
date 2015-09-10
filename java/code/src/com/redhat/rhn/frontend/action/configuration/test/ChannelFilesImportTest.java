/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.configuration.test;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnPostMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * Tests both Setup and Submit Actions
 * ChannelFilesImportTest
 */
public class ChannelFilesImportTest extends RhnPostMockStrutsTestCase {

    public void testExecuteNoFiles() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);

        //create a file that is not in this channel
        ConfigTestUtils.createConfigFile(user.getOrg());

        ConfigChannel cc = ConfigTestUtils.createConfigChannel(user.getOrg());
        long ccid = cc.getId().longValue();
        setRequestPathInfo("/configuration/ChannelImportFiles");
        addRequestParameter("ccid", "" + ccid);
        actionPerform();
    }

    public void testSubmitNoFiles() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);

        ConfigChannel cc = ConfigTestUtils.createConfigChannel(user.getOrg());
        long ccid = cc.getId().longValue();
        setRequestPathInfo("/configuration/ChannelImportFilesSubmit");
        addRequestParameter("ccid", "" + ccid);
        actionPerform();
    }
}
