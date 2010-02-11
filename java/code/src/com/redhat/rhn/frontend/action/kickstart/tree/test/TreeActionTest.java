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
package com.redhat.rhn.frontend.action.kickstart.tree.test;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.action.BaseEditAction;
import com.redhat.rhn.frontend.action.kickstart.tree.TreeCreateAction;
import com.redhat.rhn.frontend.action.kickstart.tree.TreeEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.struts.util.LabelValueBean;

import java.util.Iterator;
import java.util.List;

/**
 * TreeCreateTest
 * @version $Rev: 1 $
 */
public class TreeActionTest extends RhnMockStrutsTestCase {
    
    public void testCreateNonSubmit() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        ChannelFactoryTest.createTestChannel(user);
        executeNonSubmit("/kickstart/TreeCreate");
    }

    public void testCreateSubmit() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        Channel c = ChannelFactoryTest.createTestChannel(user);
        executeSubmit("/kickstart/TreeCreate", c);
        verifyActionMessage("tree.create.success");
    }
    
    public void testCreateRefresh() throws Exception {
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        
        Channel rhel5BaseChan = createRhel5Channels();
        Channel rhel4BaseChan = createRhel4Channels();
        
        // Execute a non-submit to load the page initially:
        executeNonSubmit("/kickstart/TreeCreate");
        
        // Make sure the base channels we created are appearing in the dropdown list:
        assertNotNull(request.getAttribute(TreeCreateAction.CHANNELS));
        List channelLabels = (List)request.getAttribute(TreeCreateAction.CHANNELS);
        boolean foundRhel4BaseChan = false;
        boolean foundRhel5BaseChan = false;
        for (Iterator it = channelLabels.iterator(); it.hasNext();) {
            LabelValueBean chan = (LabelValueBean)it.next();
            if (chan.getLabel().equals(rhel4BaseChan.getName())) {
                foundRhel4BaseChan = true;
            }
            else if (chan.getLabel().equals(rhel5BaseChan.getName())) {
                foundRhel5BaseChan = true;
            }
        }
        assertTrue(channelLabels.size() >= 2);
        assertTrue(foundRhel4BaseChan);
        assertTrue(foundRhel5BaseChan);
        
        // Set fields on the form to verify values are saved after a refresh:
        String ksDistLabel = "somelabel" + TestUtils.randomString();
        addRequestParameter(TreeCreateAction.LABEL, ksDistLabel);
        addRequestParameter(TreeCreateAction.BASE_PATH, 
                    KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath());
       
        // Choose the RHEL 5 base channel so we can verify the package list is updated:
        addRequestParameter(TreeCreateAction.CHANNEL_ID, rhel5BaseChan.getId().toString());
        
        executeRefresh("/kickstart/TreeCreate");
        
        // Verify that things are as they should be after a refresh:
        verifyFormValue(TreeCreateAction.LABEL, ksDistLabel);
        verifyFormValue(TreeCreateAction.BASE_PATH,
                        KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath());
        verifyFormValue(TreeCreateAction.CHANNEL_ID, rhel5BaseChan.getId());

    }

    /**
     * Create a fake RHEL 5 base channel and associated fake RHN tools channel. 
     * The tools channel should contain a single rhn-kickstart package providing 
     * the kickstart capability.
     * @param kickstartCapability
     * @return The RHEL 5 base channel.
     * @throws Exception
     */
    private Channel createRhel5Channels() throws Exception {
        Channel rhel5BaseChan = ChannelTestUtils.createTestChannel(user);
        Channel rhel5ToolsChan = ChannelTestUtils.createChildChannel(user, rhel5BaseChan);
        PackageManagerTest.addKickstartPackageToChannel(
                ConfigDefaults.get().getKickstartPackageName(), rhel5ToolsChan);
        return rhel5BaseChan;
    }

    /**
     * Create a fake RHEL 4 base channel and associated fake RHN tools channel. 
     * The tools channel should contain several autokickstart packages.
     * @return The RHEL 4 base channel.
     * @throws Exception
     */
    private Channel createRhel4Channels() throws Exception {
        Channel rhel4BaseChan = ChannelTestUtils.createTestChannel(user); 
        Channel rhel4ToolsChan = ChannelTestUtils.createChildChannel(user, rhel4BaseChan);
        
        PackageManagerTest.addKickstartPackageToChannel(
                KickstartData.LEGACY_KICKSTART_PACKAGE_NAME + "ks-rh-i386-desktop-4", 
                rhel4ToolsChan);
        PackageManagerTest.addKickstartPackageToChannel(
                KickstartData.LEGACY_KICKSTART_PACKAGE_NAME + "ks-rh-i386-desktop-4-u1", 
                rhel4ToolsChan);
        PackageManagerTest.addKickstartPackageToChannel(
                KickstartData.LEGACY_KICKSTART_PACKAGE_NAME + "ks-rh-i386-desktop-4-u2", 
                rhel4ToolsChan);
        return rhel4BaseChan;
    }
    
    public void testEditSubmit() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        UserTestUtils.addProvisioning(user.getOrg());
        KickstartableTree t = KickstartableTreeTest.createTestKickstartableTree(c);
        addRequestParameter(RequestContext.KSTREE_ID, t.getId().toString());
        String newLabel = executeSubmit("/kickstart/TreeEdit", c);
        verifyFormValue(TreeEditAction.BASE_PATH, t.getBasePath());
        verifyFormValue(TreeEditAction.CHANNEL_ID, t.getChannel().getId());
        verifyFormValue(TreeEditAction.LABEL, t.getLabel());
        assertEquals(newLabel, t.getLabel());
        verifyActionMessage("tree.edit.success");
    }

    public void testEditNonSubmit() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        UserTestUtils.addProvisioning(user.getOrg());
        KickstartableTree t = KickstartableTreeTest.createTestKickstartableTree(c);
        addRequestParameter(RequestContext.KSTREE_ID, t.getId().toString());
        executeNonSubmit("/kickstart/TreeEdit");
        
        verifyFormValue(TreeEditAction.BASE_PATH, t.getBasePath());
        verifyFormValue(TreeEditAction.CHANNEL_ID, t.getChannel().getId());
        verifyFormValue(TreeEditAction.LABEL, t.getLabel());
        assertNotNull(request.getAttribute(RequestContext.KSTREE));
    }

    public void executeNonSubmit(String path) {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.FALSE.toString());
        execute(path);
    }

    public void executeRefresh(String path) {
        addRequestParameter(BaseEditAction.REFRESH, Boolean.TRUE.toString());
        execute(path);
    }

    private void execute(String path) {
        setRequestPathInfo(path);
        actionPerform();
        verifyNoActionErrors();
        assertNotNull(request.getAttribute(TreeCreateAction.CHANNELS));

        if (request.getAttribute(TreeCreateAction.INSTALLTYPES) == null) {
            assertNotNull(request.getAttribute(TreeCreateAction.HIDE_SUBMIT));
            assertNotNull(request.getAttribute(TreeCreateAction.NOINSTALLTYPES));
        }
        else {
            assertNotNull(request.getAttribute(TreeCreateAction.INSTALLTYPES));
        }
    }
    
    public String executeSubmit(String path, Channel c) throws Exception {
        String newLabel = "somelabel" + TestUtils.randomString();
        //KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree();
        //tree.setLabel(newLabel);

        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        setRequestPathInfo(path);
        addRequestParameter(TreeCreateAction.BASE_PATH,
                KickstartableTreeTest.KICKSTART_TREE_PATH.getAbsolutePath());
        addRequestParameter(TreeCreateAction.CHANNEL_ID, 
                c.getId().toString());
        addRequestParameter(TreeCreateAction.LABEL, newLabel);
        actionPerform();
        verifyNoActionErrors();
        return newLabel;
    }

    public void testDeleteConfirm() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        KickstartableTree t = KickstartableTreeTest.createTestKickstartableTree(c);
        KickstartData ksdata = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        ksdata.getKickstartDefaults().setKstree(t);
        KickstartFactory.saveKickstartData(ksdata);
        TestUtils.flushAndEvict(ksdata);
        assertNotNull(t);
        addRequestParameter(RequestContext.KSTREE_ID, t.getId().toString());
        addRequestParameter(TreeEditAction.BASE_PATH, t.getBasePath());
        addRequestParameter(TreeEditAction.CHANNEL_ID, 
                c.getId().toString());
        addRequestParameter(TreeEditAction.LABEL, t.getLabel());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.FALSE.toString());
        setRequestPathInfo("/kickstart/TreeDelete");
        actionPerform();
        verifyNoActionErrors();
        verifyForward("default");
        assertNotNull(request.getAttribute(RequestContext.PAGE_LIST));
        verifyPageList(KickstartData.class);
    }
    
    public void testDeleteSubmit() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        KickstartableTree t = KickstartableTreeTest.createTestKickstartableTree(c);
        assertNotNull(t);
        
        KickstartFactory.saveKickstartableTree(t);
        assertNotNull(KickstartFactory.   
                        lookupKickstartTreeByIdAndOrg(t.getId(), user.getOrg()));
        addRequestParameter(RequestContext.KSTREE_ID, t.getId().toString());
        addRequestParameter(TreeEditAction.BASE_PATH, t.getBasePath());        
        addRequestParameter(TreeEditAction.CHANNEL_ID, 
                c.getId().toString());
        addRequestParameter(TreeEditAction.LABEL, t.getLabel());
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        setRequestPathInfo("/kickstart/TreeDelete");
        actionPerform();
        verifyNoActionErrors();
        verifyForward("success");
        verifyActionMessage("tree.delete.success");
    }
    
}

