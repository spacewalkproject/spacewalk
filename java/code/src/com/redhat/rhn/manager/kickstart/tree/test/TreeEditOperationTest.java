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
package com.redhat.rhn.manager.kickstart.tree.test;

import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.manager.kickstart.tree.BaseTreeEditOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeCreateOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeDeleteOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeDeleteWithProfilesOperation;
import com.redhat.rhn.manager.kickstart.tree.TreeEditOperation;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

/**
 * TreeEditCommandTest
 * @version $Rev$
 */
public class TreeEditOperationTest extends BaseTestCaseWithUser {

    public void testCreate() throws Exception {
        TreeCreateOperation cmd = new TreeCreateOperation(user);
        setTreeParamsAndStore(cmd);
    }

    public void testEdit() throws Exception {
        KickstartableTree tree = KickstartableTreeTest.
            createTestKickstartableTree(ChannelFactoryTest.createTestChannel(user));
        TreeEditOperation cmd = new TreeEditOperation(tree.getId(), user);
        cmd.setBasePath(KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath());
        assertNotNull(cmd.getTree());
        String nlabel = "newlabel" + TestUtils.randomString();
        cmd.setLabel(nlabel);
        assertNull(cmd.store());
        flushAndEvict(cmd.getTree());
        tree = (KickstartableTree) reload(tree);
        assertEquals(nlabel, tree.getLabel());
    }

    public void testInvalidEdit() throws Exception {
        KickstartableTree tree = KickstartableTreeTest.
            createTestKickstartableTree(ChannelFactoryTest.createTestChannel(user));
        Long tid = tree.getId();
        TreeEditOperation cmd = new TreeEditOperation(tid, user);
        cmd.setBasePath(KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath());
        assertNull(cmd.store());
        flushAndEvict(cmd.getTree());

        TreeEditOperation newcmd = new TreeEditOperation(tid, user);
        newcmd.setLabel("testInvalidEdit " + TestUtils.randomString());
        assertNotNull(newcmd.store());
        flushAndEvict(newcmd.getTree());

        KickstartableTree lookedUp = KickstartFactory.
            lookupKickstartTreeByIdAndOrg(tid, user.getOrg());
        assertFalse(lookedUp.getLabel().startsWith("testInvalidEdit"));
    }

    public void testDelete() throws Exception {
        TreeCreateOperation cmd = new TreeCreateOperation(user);
        setTreeParamsAndStore(cmd);
        TreeDeleteOperation deleteCmd = new TreeDeleteOperation(
                                                     cmd.getTree().getId(), user);
        assertNotNull(deleteCmd);
        assertNull(deleteCmd.store());         // actually does a remove operation
        assertNull(KickstartFactory.
              lookupKickstartTreeByIdAndOrg(cmd.getTree().getId(), user.getOrg()));
    }

    public void testDeleteWithProfiles() throws Exception {
        TreeCreateOperation cmd = new TreeCreateOperation(user);
        setTreeParamsAndStore(cmd);
        KickstartData ksd = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        ksd.getKickstartDefaults().setKstree(cmd.getTree());
        KickstartFactory.saveKickstartData(ksd);
        flushAndEvict(ksd);

        TreeDeleteOperation deleteCmd = new TreeDeleteOperation(
                                                     cmd.getTree().getId(), user);
        assertNotNull(deleteCmd.store());   // Check to make sure we got an error message

        // Now delete associated profiles
        TreeDeleteWithProfilesOperation delCmd2 = new
            TreeDeleteWithProfilesOperation(cmd.getTree().getId(), user);
        assertNull(delCmd2.store());

    }

    private void setTreeParamsAndStore(BaseTreeEditOperation cmd) throws Exception {
        cmd.setInstallType(KickstartFactory.
                      lookupKickstartInstallTypeByLabel("rhel_4"));
        cmd.setBasePath(KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath());
        cmd.setChannel(ChannelFactoryTest.createTestChannel(user));
        cmd.setLabel("some_label" + TestUtils.randomString());
        assertNotNull(cmd.getUser());
        assertNotNull(cmd.getTree());
        assertNotNull(cmd.getTree().getInstallType());
        assertNotNull(cmd.getTree().getBasePath());
        assertNotNull(cmd.getTree().getChannel());
        assertNotNull(cmd.getTree().getLabel());
        assertNotNull(cmd.getTree().getTreeType());
        assertNotNull(cmd.getTree().getOrgId());
        assertNull(cmd.store());
    }
}
