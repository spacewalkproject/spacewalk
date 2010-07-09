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
package com.redhat.rhn.frontend.action.configuration.test;

import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.dto.ConfigChannelDto;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * CompareCopyActionTest
 * @version $Rev$
 */
public class CompareCopyActionTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {
        //Make the user a config admin
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());

        //Create the revision to compare
        ConfigRevision revision = ConfigTestUtils.createConfigRevision(user.getOrg());
        Long cfid = revision.getConfigFile().getId();
        Long crid = revision.getId();

        //Create another revision, file, and channel to appear in the list
        String path = revision.getConfigFile().getConfigFileName().getPath();
        ConfigFile file = ConfigTestUtils.createConfigFile(user.getOrg(), path);
        ConfigTestUtils.createConfigRevision(file);

        setRequestPathInfo("/configuration/file/CompareCopy");
        addRequestParameter("cfid", cfid.toString());
        addRequestParameter("crid", crid.toString());
        actionPerform();
        verifyPageList(ConfigChannelDto.class);
    }
}

