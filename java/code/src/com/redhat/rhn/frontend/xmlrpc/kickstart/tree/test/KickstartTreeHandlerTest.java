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
package com.redhat.rhn.frontend.xmlrpc.kickstart.tree.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.frontend.xmlrpc.kickstart.KickstartHandler;
import com.redhat.rhn.frontend.xmlrpc.kickstart.tree.KickstartTreeHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.io.File;
import java.util.List;

/**
 * KickstartHandlerTest
 * @version $Rev$
 */
public class KickstartTreeHandlerTest extends BaseHandlerTestCase {

    private KickstartTreeHandler handler = new KickstartTreeHandler();
    private KickstartHandler ksHandler = new KickstartHandler();

    public void testListKickstartableTrees() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin);
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        List ksTrees = handler.list(adminKey,
                baseChan.getLabel());
        assertTrue(ksTrees.size() > 0);

        boolean found = false;
        for (int i = 0; i < ksTrees.size(); i++) {
            KickstartableTree t = (KickstartableTree)ksTrees.get(i);
            if (t.getId().equals(testTree.getId())) {
                found = true;
                break;
            }
        }
        assertTrue(found);
    }

    public void testCreateKickstartableTree() throws Exception {
        String label = TestUtils.randomString();
        List trees = KickstartFactory.
            lookupAccessibleTreesByOrg(admin.getOrg());
        int origCount = 0;
        if (trees != null) {
            origCount = trees.size();
        }
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin);
        handler.create(adminKey, label,
                KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath(),
                baseChan.getLabel(), KickstartInstallType.RHEL_5);
        assertTrue(origCount + 1 == KickstartFactory.
                lookupAccessibleTreesByOrg(admin.getOrg()).size());
    }

    public void testEditKickstartableTree() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin);
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        String newBase = "/tmp/kickstart/new-base-path";
        KickstartableTreeTest.createKickstartTreeItems(new File(newBase));
        Channel newChan = ChannelFactoryTest.createTestChannel(admin);
        handler.update(adminKey, testTree.getLabel(),
                newBase, newChan.getLabel(),
                testTree.getInstallType().getLabel());

        assertEquals(testTree.getBasePath(), newBase);
        assertEquals(testTree.getChannel(), newChan);
        assertNotNull(testTree.getInstallType());
    }

    public void testRenameKickstartableTree() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin);
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        String newLabel = "newlabel-" + TestUtils.randomString();
        handler.rename(adminKey, testTree.getLabel(), newLabel);
        assertEquals(newLabel, testTree.getLabel());
    }

    public void testDeleteKickstartableTree() throws Exception {
        Channel baseChan = ChannelFactoryTest.createTestChannel(admin);
        KickstartableTree testTree = KickstartableTreeTest.
            createTestKickstartableTree(baseChan);
        String label = testTree.getLabel();
        handler.delete(adminKey, label);
        assertNull(KickstartFactory.lookupKickstartTreeByLabel(label, admin.getOrg()));
    }

    public void testDeleteTreeAndProfiles() throws Exception {

        KickstartData ks  = KickstartDataTest.createKickstartWithProfile(admin);
        KickstartableTree testTree = ks.getKickstartDefaults().getKstree();
        Channel channel = testTree.getChannel();

        // verify our setup... should have 1 tree and 1 profile associated w/it
        List ksTrees = handler.list(adminKey, channel.getLabel());
        List ksProfiles = ksHandler.listKickstarts(adminKey);
        assertNotNull(ksTrees);
        assertNotNull(ksProfiles);
        Integer numKsTrees = ksTrees.size();
        Integer numKsProfiles = ksProfiles.size();

        // execute test...
        int result = handler.deleteTreeAndProfiles(adminKey, testTree.getLabel());
        assertEquals(1, result);

        // verify that both the tree and associated profile no longer exist
        ksTrees = handler.list(adminKey, channel.getLabel());
        ksProfiles = ksHandler.listKickstarts(adminKey);
        assertNotNull(ksTrees);
        assertNotNull(ksProfiles);
        assertEquals(numKsTrees - 1, ksTrees.size());
        assertTrue(ksProfiles.size() < numKsProfiles);
    }

    public void testListTreeTypes() throws Exception {
        List types = handler.listInstallTypes(adminKey);
        assertNotNull(types);
        assertTrue(types.size() > 0);
        System.out.println("type: " + types.get(0).getClass().getName());
        assertTrue(types.get(0) instanceof KickstartInstallType);
    }
}
