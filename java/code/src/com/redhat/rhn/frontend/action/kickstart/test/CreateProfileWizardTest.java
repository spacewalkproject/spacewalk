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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.RepoInfo;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.kickstart.crypto.test.CryptoTest;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.frontend.action.kickstart.CreateProfileWizardAction;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.DynaActionForm;

import java.util.Iterator;

public class CreateProfileWizardTest extends RhnMockStrutsTestCase {
    
    private String label;
    
    public void setUp() throws Exception {
        super.setUp();
        label = TestUtils.randomString();
        
        // Create some crypto keys that should get associated
        // with the new KickstartData
        CryptoKey sslkey = CryptoTest.createTestKey(user.getOrg());
        sslkey.setCryptoKeyType(KickstartFactory.KEY_TYPE_SSL);
        KickstartFactory.saveCryptoKey(sslkey);
        TestUtils.flushAndEvict(sslkey);            

        // Create a GPG key as well, so we can test that just SSL
        // keys are associated.
        CryptoKey gpgkey = CryptoTest.createTestKey(user.getOrg());
        gpgkey.setCryptoKeyType(KickstartFactory.KEY_TYPE_GPG);
        KickstartFactory.saveCryptoKey(gpgkey);
        TestUtils.flushAndEvict(gpgkey);            
        
    }
    
    public void testNoTreesOrChannels() throws Exception {
        setRequestPathInfo("/kickstart/CreateProfileWizard");
        actionPerform();
        verifyNoActionMessages();
        DynaActionForm form = (DynaActionForm) getActionForm();
        if (form.get(CreateProfileWizardAction.CHANNELS) == null) {
            assertNotNull(request.getAttribute(
                CreateProfileWizardAction.NOCHANNELS_PARAM));
        }
        if (form.get(CreateProfileWizardAction.KSTREES_PARAM) == null) {
            assertNotNull(request.getAttribute(
                CreateProfileWizardAction.NOTREES_PARAM));
        }

    }
    
    public void testRhel3() throws Exception {
        Channel treeChannel = ChannelFactoryTest.createTestChannel(user);
        KickstartableTree tree = KickstartableTreeTest.
            createTestKickstartableTree(treeChannel);
        tree.setInstallType(KickstartFactory.lookupKickstartInstallTypeByLabel("rhel_3"));
        KickstartFactory.saveKickstartableTree(tree);
        tree = (KickstartableTree) TestUtils.reload(tree);
        setRequestPathInfo("/kickstart/CreateProfileWizard");
        actionPerform();
        verifyNoActionMessages();
        
        // Step Three
        clearRequestParameters();
        addRequestParameter("wizardStep", "complete");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", tree.getId().toString());
        addRequestParameter("defaultDownload", "true");
        addRequestParameter("rootPassword", "blahh");
        addRequestParameter("rootPasswordConfirm", "blahh");
        actionPerform();
        verifyNoActionMessages();
        KickstartData ksdata = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                label, user.getOrg().getId()); 
        // This is the key step.  Make sure we don't have selinux for rhel3
        assertNull(ksdata.getCommand("selinux"));
    }
    
    public void testSuccess() throws Exception {
        
        Channel treeChannel = ChannelFactoryTest.createTestChannel(user);
        KickstartableTree tree = KickstartableTreeTest.
            createTestKickstartableTree(treeChannel);
        tree.setBasePath("rhn/kickstart/ks-rhel-i386-server-5");
        tree.setInstallType(KickstartFactory.
                lookupKickstartInstallTypeByLabel(KickstartInstallType.RHEL_5));
        setRequestPathInfo("/kickstart/CreateProfileWizard");
        actionPerform();
        verifyNoActionMessages();
        
        
        // Step One
        clearRequestParameters();
        addRequestParameter("wizardStep", "second");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", tree.getId().toString());
        actionPerform();
        
        verifyNoActionMessages();
        
        //Step Two
        clearRequestParameters();
        addRequestParameter("wizardStep", "third");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", tree.getId().toString());
        addRequestParameter("defaultDownload", "true");
        actionPerform();
        verifyNoActionMessages();
        
        // Step Three
        clearRequestParameters();
        addRequestParameter("wizardStep", "complete");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", tree.getId().toString());
        addRequestParameter("defaultDownload", "true");
        addRequestParameter("rootPassword", "blahh");
        addRequestParameter("rootPasswordConfirm", "blahh");
        actionPerform();
        verifyNoActionMessages();
        verifyKSCommandsDefaults(label);
    }
    
    public void testFtpDownload() throws Exception {
        Channel treeChannel = ChannelFactoryTest.createTestChannel(user);
        KickstartableTree tree = KickstartableTreeTest.
            createTestKickstartableTree(treeChannel);
        
        setRequestPathInfo("/kickstart/CreateProfileWizard");
        // Step Three
        clearRequestParameters();
        addRequestParameter("wizardStep", "third");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", tree.getId().toString());
        addRequestParameter("defaultDownload", "false");
        addRequestParameter("userDefinedDownload", "ftp://ftp.redhat.com");
        addRequestParameter("rootPassword", "blahh");
        addRequestParameter("rootPasswordConfirm", "blahh");
        actionPerform();
        verifyNoActionMessages();
        
    }
    
    
    public void testLabelValidation() {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard");
        addRequestParameter("wizardStep", "second");
        addRequestParameter("kstreeId", "12997");
        actionPerform();
        verifyForward("first");
    }
    
    public void testKsTreeIdValidation() {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard");
        addRequestParameter("wizardStep", "second");
        addRequestParameter("kickstartLabel", label);
        actionPerform();
        verifyForward("first");
    }
    
    public void testDownloadValidation() throws Exception {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard");        
        addRequestParameter("wizardStep", "third");
        addRequestParameter("kickstartLabel", label);
        KickstartVirtualizationType type = (KickstartVirtualizationType)  
            KickstartFactory.lookupVirtualizationTypes().iterator().next();
        addRequestParameter(CreateProfileWizardAction.VIRTUALIZATION_TYPE_LABEL_PARAM, 
                type.getLabel());
        Channel c = ChannelTestUtils.createBaseChannel(user);
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree(c);
        addRequestParameter("kstreeId", tree.getId().toString());
        actionPerform();
        verifyForward("second");
    }
    
    public void testUserDownloadValidation() throws Exception {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard");        
        addRequestParameter("wizardStep", "third");
        addRequestParameter("kickstartLabel", label);
        KickstartVirtualizationType type = (KickstartVirtualizationType)  
        KickstartFactory.lookupVirtualizationTypes().iterator().next();
        addRequestParameter(CreateProfileWizardAction.VIRTUALIZATION_TYPE_LABEL_PARAM, 
            type.getLabel());
        Channel c = ChannelTestUtils.createBaseChannel(user);
        KickstartableTree tree = KickstartableTreeTest.createTestKickstartableTree(c);
        addRequestParameter("kstreeId", tree.getId().toString());

        addRequestParameter("defaultDownload", "false");        
        actionPerform();
        verifyForward("second");
        
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard");        
        addRequestParameter("wizardStep", "third");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", tree.getId().toString());
        addRequestParameter(CreateProfileWizardAction.VIRTUALIZATION_TYPE_LABEL_PARAM, 
                type.getLabel());
        addRequestParameter("defaultDownload", "false");
        addRequestParameter("userDefinedDownload", "htp://blahblahblbah.com/blahblah");
        actionPerform();
        verifyForward("second");
        
    }
    
    public void testRootPasswordValidation() {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard");        
        addRequestParameter("wizardStep", "complete");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", "12997");
        addRequestParameter("defaultDownload", "true");
        addRequestParameter("rootPasswordConfirm", "blah");
        actionPerform();
        verifyForward("third");
    }
    
    public void testRootPasswordConfirmValidation() {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard");        
        addRequestParameter("wizardStep", "complete");
        addRequestParameter("kickstartLabel", label);
        addRequestParameter("kstreeId", "12997");
        addRequestParameter("defaultDownload", "true");
        addRequestParameter("rootPassword", "blah");
        actionPerform();
        verifyForward("third");        
    }
    
    public void testLabelAlreadyExists() throws Exception {
        KickstartData k = KickstartDataTest.createTestKickstartData(user.getOrg());
        String[] array = new String[1];
        array[0] = "kickstart.error.labelexists";
        clearRequestParameters();
        setRequestPathInfo("/kickstart/CreateProfileWizard"); 
        addRequestParameter("wizardStep", "second");
        addRequestParameter("kickstartLabel", k.getLabel());
        addRequestParameter("kstreeId", "12997");
        actionPerform();
        verifyForward("first");
        verifyActionErrors(array);
    }
 
    public void verifyKSCommandsDefaults(String labelIn) {
        KickstartData ksdata = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                                            labelIn, user.getOrg().getId()); 
        assertNotNull(ksdata);
        //checking to make sure defaults were set correctly
        assertNotNull(ksdata.getCommand("rootpw"));
        assertNotNull(ksdata.getCommand("lang"));
        assertNotNull(ksdata.getCommand("keyboard"));
        assertNotNull(ksdata.getCommand("bootloader"));
        assertNotNull(ksdata.getCommand("timezone"));
        assertNotNull(ksdata.getCommand("auth"));
        assertNotNull(ksdata.getCommand("zerombr"));
        assertNotNull(ksdata.getCommand("reboot"));
        assertNotNull(ksdata.getCommand("skipx"));
        assertNotNull(ksdata.getCommand("clearpart"));
        if (!ksdata.isLegacyKickstart()) {
            assertNotNull(ksdata.getCommand("selinux"));
        }
        assertNotNull(ksdata.getCommand("text"));
        assertNotNull(ksdata.getCommand("install"));
        assertNotNull(ksdata.getCommand("partitions"));
        
        boolean correctswap = false;
        boolean correctrepos = false;
        Iterator i = ksdata.getCommands().iterator();
        while (i.hasNext()) {
            KickstartCommand cmd = (KickstartCommand) i.next();
            if (cmd.getCommandName().getName().equals("partitions")) {
                if (cmd.getArguments().startsWith("swap")) {
                    correctswap = true;
                }
            }
            if (cmd.getCommandName().getName().equals("repo")) {
                RepoInfo repo = RepoInfo.parse(cmd);
                assertNotNull(repo);
                assertTrue(!StringUtils.isBlank(repo.getName()));
                assertTrue(!StringUtils.isBlank(repo.getUrl()));
                correctrepos = true;

            }
        }
        assertTrue(correctswap);
        assertTrue(correctrepos);
        
        
        //checking to make sure args for the defaults were set correctly
        assertTrue(ksdata.getCommand("lang").getArguments().equals("en_US"));
        assertTrue(ksdata.getCommand("keyboard").getArguments().equals("us"));
        assertTrue(ksdata.getCommand("zerombr").getArguments().length() == 0);
        assertTrue(ksdata.getCommand("clearpart").getArguments().equals("--all"));
        assertTrue(ksdata.getCommand("bootloader").getArguments()
                                                  .equals("--location mbr"));
        assertTrue(ksdata.getCommand("timezone").getArguments()
                                                .equals("America/New_York"));
        assertTrue(ksdata.getCommand("auth").getArguments()
                                            .equals("--enablemd5 --enableshadow"));
        
        // Test the keys associated with the profile.
        assertNotNull(ksdata.getCryptoKeys());
        assertTrue(ksdata.getCryptoKeys().size() > 0);
        i = ksdata.getCryptoKeys().iterator();
        while (i.hasNext()) {
            CryptoKey key = (CryptoKey) i.next();
            assertFalse(key.getCryptoKeyType().
                    equals(KickstartFactory.KEY_TYPE_GPG));
        }
        
        assertTrue(ksdata.getCommand("key").getArguments().equals("--skip"));
        
    }
}
