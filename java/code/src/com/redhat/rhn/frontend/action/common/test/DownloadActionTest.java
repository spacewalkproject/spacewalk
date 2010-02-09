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
package com.redhat.rhn.frontend.action.common.test;

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.io.File;
import java.util.Map;

/**
 * TinyUrlActionTest
 * @version $Rev$
 */
public class DownloadActionTest extends RhnMockStrutsTestCase {
    
    private KickstartData ksdata;
    private KickstartableTree tree;

    @Override
    public void setUp() throws Exception {
        super.setUp();
        ksdata = KickstartDataTest.createKickstartWithChannel(user.getOrg());
        tree = ksdata.getTree();
        tree.setBasePath("/tmp");
        File images = new File("/tmp/images");
        if (!images.exists()) {
            images.mkdir();
        }
        File boot = new File("/tmp/images/boot.iso");
        if (!boot.exists()) {
            boot.createNewFile();
        }
        setRequestPathInfo("/common/DownloadFile");
    }

    public void testKsDownload() throws Exception {
        // /ks/dist/f9-x86_64-distro/images/boot.iso
        addRequestParameter("url", "/ks/dist/" + tree.getLabel() + "/images/boot.iso");
        request.setQueryString("url=/ks/dist/" + tree.getLabel() + "/images/boot.iso");
        actionPerform();
        assertNull(getActualForward());
        assertEquals("application/octet-stream", getResponse().getContentType());
        assertNotNull(request.getAttribute("params"));
        Map params = (Map) request.getAttribute("params");
        String filename = (String) params.get("filename");
        assertNotNull(filename);
    }
    
    public void testKSPackageDownload() throws Exception {
        //  /ks/dist/rhel5-i386-u2/Server/iproute-2.6.18-7.el5.i386.rpm
        Package p = PackageManagerTest.addPackageToChannel("some-package", 
                tree.getChannel());
        String fileName = "some-package-2.13.1-6.fc9.x86_64.rpm";
        p.setPath("redhat/1/c7d/some-package/2.13.1-6.fc9/" +
                "x86_64/c7dd5e9b6975bc7f80f2f4657260af53/" +
                fileName);
        TestUtils.saveAndFlush(p);
        
        addRequestParameter("url", "/ks/dist/" + tree.getLabel() + "/Server/" + fileName);
        request.setQueryString("url=/ks/dist/" + tree.getLabel() + "/Server/" + fileName);
        actionPerform();
        // assertEquals("/kickstart/DownloadFile.do", getActualForward());
        assertNotNull(request.getAttribute("params"));
        // https://dhcp77-150.rhndev.redhat.com/
        // download/package/4ad2199e64aa756a21b9a33fe6f4faf355586b70/
        // 1236742778254/1/3709/alsa-utils-1.0.6-6.i386.rpm
        
    }
    public void testKsSessionDownload() throws Exception {
        // /ks/dist/f9-x86_64-distro/images/boot.iso
        KickstartSession ksession = 
            KickstartSessionTest.createKickstartSession(ksdata, user);
        
        ksession.setKstree(tree);
        ksession.setKsdata(ksdata);
        
        TestUtils.saveAndFlush(ksession);
        String encodedSession = SessionSwap.encodeData(ksession.getId().toString());

        addRequestParameter("url", "/ks/dist/session/" + encodedSession + "/" +
                tree.getLabel() + "/images/boot.iso");
        request.setQueryString("url=/ks/dist/session/" + encodedSession + "/" +
                tree.getLabel() + "/images/boot.iso");

        actionPerform();
        assertNull(getActualForward());
        assertNotNull(request.getAttribute("params"));
        Map params = (Map) request.getAttribute("params");
        // //tmp/images/boot.iso
        String filename = (String) params.get("filename");
        assertNotNull(filename);
    }
    
    public void testKSSessionAndPackageCount() throws Exception {
        Package p = PackageManagerTest.addPackageToChannel("some-package", 
                tree.getChannel());
        String fileName = "some-package-2.13.1-6.fc9.x86_64.rpm";
        p.setPath("redhat/1/c7d/some-package/2.13.1-6.fc9/" +
                "x86_64/c7dd5e9b6975bc7f80f2f4657260af53/" +
                fileName);
        TestUtils.saveAndFlush(p);
        
        KickstartSession ksession = 
            KickstartSessionTest.createKickstartSession(ksdata, user);
        ksession.setKstree(tree);
        ksession.setKsdata(ksdata);
        TestUtils.saveAndFlush(ksession);
        String encodedSession = SessionSwap.encodeData(ksession.getId().toString());

        addRequestParameter("url", "/ks/dist/session/" + encodedSession + "/" +
                tree.getLabel() +  "/Server/" + fileName);
        request.setQueryString("url=/ks/dist/session/" + encodedSession + "/" +
                tree.getLabel() +  "/Server/" + fileName);

        actionPerform();
        assertNotNull(request.getAttribute("params"));
        assertEquals(1, ksession.getPackageFetchCount().longValue());
        
        request.setHeader("Range", "333");
        actionPerform();
        assertEquals(1, ksession.getPackageFetchCount().longValue());
        
    }

    public void testDirHit() throws Exception {
        // /ks/dist/f9-x86_64-distro/images/boot.iso
        KickstartSession ksession = 
            KickstartSessionTest.createKickstartSession(ksdata, user);
        TestUtils.saveAndFlush(ksession);
        addRequestParameter("url", "/ks/dist/" + tree.getLabel() + "/images/");
        request.setQueryString("url=/ks/dist/" + tree.getLabel() + "/images/");
        actionPerform();
        assertNull(getActualForward());
        assertEquals("text/plain", getResponse().getContentType());
    }

}
