/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.kickstart.crypto.test.CryptoTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.kickstart.KickstartHelper;
import com.redhat.rhn.manager.kickstart.KickstartScheduleCommand;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;
import com.redhat.rhn.manager.kickstart.test.KickstartScheduleCommandTest;
import com.redhat.rhn.testing.TestUtils;

import java.io.ByteArrayOutputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * RenderKickstartFileActionTest
 * @version $Rev$
 */
public class RenderKickstartFileActionTest extends BaseKickstartEditTestCase {
    
    public void testRhnKickstart() throws Exception {
        // Set orgId to null to indicate that this kickstart tree is
        // *owned* by Red Hat.
        ksdata.getTree().setOrgId(null);
        KickstartHelper helper = new KickstartHelper(getRequest());
        
        // Simulate a default download URL:
        String output = executeDownloadTest("/some/fake/kickstart/path");
        
        // Check to make sure we tinyfied the url
        assertTrue(output.indexOf("/ty/") > 0);
    }
    
    public void testProxyDownload() throws Exception {
        // Set orgId to null to indicate that this kickstart tree is
        // *owned* by Red Hat.
        ksdata.getTree().setOrgId(null);
        
        // Setup proxy header
        String proxyheader = "1006681409::1151513167.96:21600.0:VV/xFNEmCYOuHx" +
        "EBAs7BEw==:fjs-0-08.rhndev.redhat.com,1006681408::1151513034." +
        "3:21600.0:w2lm+XWSFJMVCGBK1dZXXQ==:fjs-0-11.rhndev.redhat.com" +
        ",1006678487::1152567362.02:21600.0:t15lgsaTRKpX6AxkUFQ11A==:f" +
        "js-0-12.rhndev.redhat.com";
        
        String kickstartPath = "rhn/kickstart/ks-rhel-i386-as-4"; 
        
        request.setHeader(KickstartHelper.XRHNPROXYAUTH, proxyheader);
        ksdata.getTree().setBasePath(kickstartPath);
        
        // KickstartHelper helper = new KickstartHelper(getRequest());
        String output = executeDownloadTest("http://rlx-3-04.rhndev.redhat.com/");

        // TODO: Test fix but exact expected outcome is TBD. Recent change causes the
        // kickstart URL to no longer be magically changed if hitting from a proxy.
        // Check to make sure we didn't tinyfy the url:
        assertFalse(output.indexOf("/ty/") > 0);
        assertTrue(output.indexOf("rlx-3-04.rhndev.redhat.com") > 0);
//        assertTrue(output.indexOf("fjs-0-08.rhndev.redhat.com") > 0);
        
    }
    
    public void testLegacyKickstart() throws Exception {
        String host = new KickstartHelper(request).getKickstartHost();
        ksdata.getTree().setOrgId(null);
        String output = 
            executeDownloadTest("/kickstart/dist/ks-rhel-i386-as-4/");
        assertTrue(output.indexOf("/ty/") > 0);
    }
    

    public void testExternalKickstart() throws Exception {
        // Make sure we are using an 'org' owned kstree
        assertTrue(ksdata.getTree().getOrgId() != null);
        String output = 
            executeDownloadTest("http://someserver.somedomain.com/kstree/rhel4");
        assertTrue(output.
                indexOf("url --url http://someserver.somedomain.com/kstree/rhel4") > 0);
    }

    public void testExternalKickstartWithKeys() throws Exception {

        // Add 5 keys to make sure it renders the rhnreg_ks command correctly
        for (int i = 0; i < 5; i++) {
            ActivationKeysTest.addKeysToKickstartData(user, ksdata);
        }
        // Make sure we are using an 'org' owned kstree        
        assertTrue(ksdata.getTree().getOrgId() != null);
        String output = 
            executeDownloadTest("http://someserver.somedomain.com/kstree/rhel4");
        assertTrue(output.
                indexOf("url --url http://someserver.somedomain.com/kstree/rhel4") > 0);
        Pattern p = Pattern.compile("rhnreg_ks.*");
        Matcher m = p.matcher(output);
        assertTrue(m.find());
        assertTrue(m.group().indexOf(",") > 0);
        assertTrue(m.group().indexOf("profilename") > 0);
        
    }
    
    public void testGpgSslKeys() throws Exception {

        // Add 5 keys to make sure it renders key stuff properly
        for (int i = 0; i < 5; i++) {
            CryptoKey key = CryptoTest.createTestKey(user.getOrg());
            
            KickstartFactory.saveCryptoKey(key);
            key = (CryptoKey) TestUtils.reload(key);
            ksdata.addCryptoKey(key);
            
        }
        String output = 
            executeDownloadTest("http://someserver.somedomain.com/kstree/rhel4");
        assertTrue(output.indexOf("cat > /tmp/gpg-key-5") > 0);
    }
        
    

    /**
     * Test a "view_label" style download.
     * @throws Exception
     */
    public void testNoSessionRender() throws Exception {
        // Add 5 keys to make sure it renders the rhnreg_ks command correctly
        for (int i = 0; i < 5; i++) {
            ActivationKeysTest.addKeysToKickstartData(user, ksdata);
        }
        
        assertTrue(ksdata.getTree().getOrgId() != null);
        KickstartWizardHelper wcmd = new KickstartWizardHelper(user);
        wcmd.createCommand("url", 
                "--url http://someserver.somedomain.com/kstree/rhel4", ksdata);
        KickstartDownloadActionTest.setupKickstartDownloadTest(ksdata, user);
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        getMockResponse().setOutputStream(bos);
        String url = "/org/" + user.getOrg().getId() + "/view_label/" + ksdata.getLabel();
        addRequestParameter("ksurl", url);
        setRequestPathInfo("/kickstart/DownloadFile");
        actionPerform();
        String output = bos.toString();
        Pattern p = Pattern.compile("rhnreg_ks.*");
        Matcher m = p.matcher(output);
        assertTrue(m.find());
        assertTrue(m.group().indexOf(",") > 0);
        assertTrue(m.group().indexOf("profilename") < 0);
        
        
    }
    

    private String executeDownloadTest(String urlIn) throws Exception {
        
        // http://dept.rhndev.redhat.com/dist/RHEL-4/GOLD/AS/i386/tree/
        KickstartWizardHelper wcmd = new KickstartWizardHelper(user);
        // -url http://rlx-3-10.rhndev.redhat.comrhn/kickstart/ks-rhel-i386-as-4
        wcmd.createCommand("url", "--url " + urlIn, ksdata);
        
        Channel c = KickstartDownloadActionTest.setupKickstartDownloadTest(ksdata, user);
        Server server = ServerFactoryTest.createTestServer(user);
        server.addChannel(c);
        KickstartScheduleCommand cmd = KickstartScheduleCommandTest.
            scheduleAKickstart(server, ksdata);
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        getMockResponse().setOutputStream(bos);
        String encodedSession = SessionSwap.encodeData(
                cmd.getKickstartSession().getId().toString());
        
        
        String url = "/session/" + encodedSession;
        addRequestParameter("ksurl", url);
        setRequestPathInfo("/kickstart/DownloadFile");
        actionPerform();
        String ksFileContents = bos.toString();
        assertTrue(ksFileContents.indexOf("url --url") > 0);
        assertTrue(ksFileContents.indexOf("rhnreg_ks") > 0);
        assertTrue(ksFileContents.indexOf("--profilename=") > 0);
        assertTrue(ksFileContents.indexOf("perl -npe 's/xmlrpc.rhn.redhat.com/") > 0);
        
        return ksFileContents;
        
    }
    

}
