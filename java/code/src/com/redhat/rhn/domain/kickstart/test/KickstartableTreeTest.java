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
package com.redhat.rhn.domain.kickstart.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.util.FileUtils;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.KickstartTreeType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.RandomStringUtils;
import org.cobbler.Distro;
import org.hibernate.Session;

import java.io.File;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

/**
 * KickstartableTreeTest
 * @version $Rev$
 */
public class KickstartableTreeTest extends BaseTestCaseWithUser {

    public static final String TEST_BOOT_PATH = "test-boot-image-i186";
    public static final File KICKSTART_TREE_PATH = new File("/tmp/kickstart/images");

    public static void createKickstartTreeItems() throws Exception {
        createKickstartTreeItems(KICKSTART_TREE_PATH);
    }
    
    public static void createKickstartTreeItems(File basePath) throws Exception {
        //Alright setup things we need for trees
        createDirIfNotExists(basePath);
        KickstartableTree tree = new KickstartableTree();
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        tree.setChannel(ChannelTestUtils.createBaseChannel(user));
        tree.setBasePath(basePath.getAbsolutePath());
        tree.setOrg(user.getOrg());
        createKickstartTreeItems(tree);
    }    
    
    public static void createKickstartTreeItems(KickstartableTree tree) throws Exception {
        createDirIfNotExists(new File(tree.getKernelPath()).getParentFile());
        createDirIfNotExists(new File(tree.getKernelXenPath()).getParentFile());
        
        FileUtils.writeStringToFile("kernel", tree.getKernelPath());
        FileUtils.writeStringToFile("kernel-xen", tree.getKernelXenPath());

        createDirIfNotExists(new File(tree.getInitrdPath()).getParentFile());
        createDirIfNotExists(new File(tree.getInitrdXenPath()).getParentFile());
        
        FileUtils.writeStringToFile("initrd", tree.getInitrdPath());
        FileUtils.writeStringToFile("initrd-xen", tree.getInitrdXenPath());        
    }
    
    public void testKickstartableTree() throws Exception {
        KickstartableTree k = createTestKickstartableTree();
        assertNotNull(k);
        assertNotNull(k.getId());
        
        KickstartableTree k2 = lookupById(k.getId());
        assertEquals(k2.getLabel(), k.getLabel());
        
        Org o = OrgFactory.lookupById(k2.getOrgId());
        
        KickstartableTree k3 = KickstartFactory.
            lookupKickstartTreeByLabel(k2.getLabel(), o);
        assertEquals(k3.getLabel(), k2.getLabel());
        
        List trees = KickstartFactory.
            lookupKickstartTreesByChannelAndOrg(k2.getChannel().getId(), o); 
    
        assertNotNull(trees);
        assertTrue(trees.size() > 0);
        
        KickstartableTree kwithnullorg = createTestKickstartableTree();
        String label = "treewithnullorg: " + TestUtils.randomString();
        kwithnullorg.setLabel(label);
        kwithnullorg.setOrg(null);
        TestUtils.saveAndFlush(kwithnullorg);
        flushAndEvict(kwithnullorg);
        KickstartableTree lookedUp = KickstartFactory.lookupKickstartTreeByLabel(label, o);
        assertNotNull(lookedUp);
        assertNull(lookedUp.getOrgId());
    }
    
    public void testIsRhnTree() throws Exception {
        KickstartableTree k = createTestKickstartableTree();
        assertFalse(k.isRhnTree());
        k.setOrg(null);
        assertTrue(k.isRhnTree());
    }
    
    public void testDownloadLocation() throws Exception {
        KickstartableTree k = createTestKickstartableTree();
        String expected = "/ks/dist/org/" + k.getOrg().getId() + "/" +
                                k.getLabel();
        assertEquals(expected, k.getDefaultDownloadLocation("localhost"));
    }
    
    public void testKsDataByTree() throws Exception {
        KickstartableTree k = createTestKickstartableTree(
                ChannelFactoryTest.createTestChannel(user));
        KickstartData ksdata = KickstartDataTest.
            createKickstartWithOptions(user.getOrg());
        ksdata.getKickstartDefaults().setKstree(k);
        KickstartFactory.saveKickstartData(ksdata);
        flushAndEvict(ksdata);
        
        List profiles = KickstartFactory.lookupKickstartDatasByTree(k);
        assertNotNull(profiles);
        assertTrue(profiles.size() > 0);
    }
    
    
    /**
     * Helper method to lookup KickstartableTree by id
     * @param id Id to lookup
     * @return Returns the KickstartableTree
     * @throws Exception
     */
    private KickstartableTree lookupById(Long id) throws Exception {
        Session session = HibernateFactory.getSession();
        return (KickstartableTree) session.getNamedQuery("KickstartableTree.findById")
                          .setString("id", id.toString())
                          .uniqueResult();
    }
    
    /**
     * Creates KickstartableTree for testing purposes.
     * @return Returns a committed KickstartableTree
     * @throws Exception
     */
    public static KickstartableTree createTestKickstartableTree() throws Exception {
        Channel channel = ChannelFactoryTest.createTestChannel();
        ChannelTestUtils.addDistMapToChannel(channel);
        return createTestKickstartableTree(channel);
    }
    
    /**
     * Creates KickstartableTree for testing purposes.
     * @param treeChannel Channel this Tree uses.
     * @return Returns a committed KickstartableTree
     * @throws Exception
     */
    public static KickstartableTree 
        createTestKickstartableTree(Channel treeChannel) throws Exception {
        Date created = new Date();
        Date modified = new Date();
        Date lastmodified = new Date();
        
        Long testid = new Long(1);
        String query = "KickstartInstallType.findById";
        KickstartInstallType installtype = (KickstartInstallType)
                                            TestUtils.lookupFromCacheById(testid, query);
        
        query = "KickstartTreeType.findById";
        KickstartTreeType treetype = (KickstartTreeType)
                                     TestUtils.lookupFromCacheById(testid, query);
   
        KickstartableTree k = new KickstartableTree();
        k.setLabel("ks-" + treeChannel.getLabel() + 
                RandomStringUtils.randomAlphanumeric(5));
        
        k.setBasePath(KICKSTART_TREE_PATH.getAbsolutePath());
        k.setCreated(created);
        k.setModified(modified);
        k.setOrg(treeChannel.getOrg());
        k.setLastModified(lastmodified);
        k.setInstallType(installtype);
        k.setTreeType(treetype);
        k.setChannel(treeChannel);

        createKickstartTreeItems(k);
        
        Distro d = Distro.create(CobblerXMLRPCHelper.getConnection("test"),
                k.getLabel(), k.getKernelPath(), k.getInitrdPath(), new HashMap());
        Distro xend = Distro.create(CobblerXMLRPCHelper.getConnection("test"),
                k.getLabel(), k.getKernelPath(), k.getInitrdPath(), new HashMap());

        k.setCobblerId(d.getUid());
        k.setCobblerXenId(xend.getUid());
        
        TestUtils.saveAndFlush(k);
        
        
        return k;
    }
}
