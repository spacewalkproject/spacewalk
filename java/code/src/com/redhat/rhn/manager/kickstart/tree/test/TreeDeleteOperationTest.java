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

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.manager.kickstart.tree.TreeCreateOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeDeleteOperation;

/**
 * Tests the {@link com.redhat.rhn.manager.kickstart.tree.TreeDeleteOperation} class
 */
public class TreeDeleteOperationTest extends TreeOperationTestBase {

    public void testDelete() throws Exception {
        TreeCreateOperation cmd = new TreeCreateOperation(user);
        setTestTreeParams(cmd);
        cmd.store();
        TreeDeleteOperation deleteCmd = new TreeDeleteOperation(
                                                     cmd.getTree().getId(), user);
        assertNotNull(deleteCmd);
        assertNull(deleteCmd.store());         // actually does a remove operation
        assertNull(KickstartFactory.
              lookupKickstartTreeByIdAndOrg(cmd.getTree().getId(), user.getOrg()));
    }

}
