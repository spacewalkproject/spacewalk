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
package com.redhat.rhn.frontend.action.rhnpackage.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.rhnpackage.DownloadConfirmAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * DownloadConfirmActionTest
 * @version $Rev$
 */
public class DownloadConfirmActionTest extends RhnBaseTestCase {
    
    public void testDownload() throws Exception {
        DownloadConfirmAction action = new DownloadConfirmAction();
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        ActionMapping mapping = new ActionMapping();
        
        User user = new RequestContext(request).getLoggedInUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true);
        Package p = PackageManagerTest.addPackageToSystemAndChannel(
                "test-package-name" + TestUtils.randomString(), server, 
                ChannelFactoryTest.createTestChannel(user));
        PackageFactoryTest.updateNeedsPackageCache(user.getOrg().getId(),
                server.getId(), p.getId());
        
        RhnSet set = RhnSetDecl.PACKAGES_UPGRADABLE.get(user);
        set.addElement(p.getPackageName().getId(), p.getPackageEvr().getId());
        RhnSetManager.store(set);
        
        request.setupAddParameter("sid", server.getId().toString());
        
        ActionForward af = action.download(mapping, form, request, response);
        assertNull(af);
        assertTrue(response.getRedirect()
                .startsWith(Config.get().getString("download_url",
                "/cgi-bin/download.pl/rhn-packages.tar") + "?token="));
        assertTrue(response.getRedirect().indexOf(p.getPath()) > 0);
    }

}
