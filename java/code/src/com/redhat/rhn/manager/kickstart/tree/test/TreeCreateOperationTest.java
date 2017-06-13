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

import com.redhat.rhn.manager.kickstart.tree.TreeCreateOperation;

/**
 * Tests the {@link com.redhat.rhn.manager.kickstart.tree.TreeCreateOperation} class
 */
public class TreeCreateOperationTest extends TreeOperationTestBase {

    public void testCreate() throws Exception {
        TreeCreateOperation cmd = new TreeCreateOperation(user);
        setTestTreeParams(cmd);
        assertNull(cmd.store());
        assertNotNull(cmd.getUser());
        assertNotNull(cmd.getTree());
        assertNotNull(cmd.getTree().getInstallType());
        assertNotNull(cmd.getTree().getBasePath());
        assertNotNull(cmd.getTree().getChannel());
        assertNotNull(cmd.getTree().getLabel());
        assertNotNull(cmd.getTree().getTreeType());
        assertNotNull(cmd.getTree().getOrgId());
    }

}
