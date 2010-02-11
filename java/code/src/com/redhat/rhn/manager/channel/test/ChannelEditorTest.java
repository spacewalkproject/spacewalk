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
package com.redhat.rhn.manager.channel.test;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelEditor;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * ChannelEditorTest
 * @version $Rev$
 */
public class ChannelEditorTest extends RhnBaseTestCase {

    public void testAddRemovePackages() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Package pkg = PackageTest.createTestPackage(user.getOrg());
        assertTrue(UserManager.verifyPackageAccess(user.getOrg(), pkg.getId()));
        Channel channel = ChannelFactoryTest.createTestChannel(user);
        assertTrue(UserManager.verifyChannelAdmin(user, channel));
        assertEquals(0, channel.getPackages().size());
        
        List pkgList = new ArrayList();
        pkgList.add(pkg.getId());
        Long bogusId = new Long(System.currentTimeMillis());
        pkgList.add(bogusId);
        
        ChannelEditor editor = ChannelEditor.getInstance();
        try {
            editor.addPackages(user, channel, pkgList);
            fail();
        }
        catch (PermissionException e) {
            //success... bogusId does not exist
        }

        pkgList.remove(bogusId);
        editor.addPackages(user, channel, pkgList);
        assertEquals(1, channel.getPackages().size());
        
        Long cid = channel.getId();
        Channel c = ChannelManager.lookupByIdAndUser(cid, user);
        assertNotNull(c);
        assertEquals(1, c.getPackages().size());
        
        //Test package removal
        pkgList.add(bogusId);
        try {
            editor.removePackages(user, channel, pkgList);
            fail();
        }
        catch (PermissionException e) {
            //success... bogusId does not exist
        }
        
        pkgList.remove(bogusId);
        assertEquals(1, c.getPackages().size());
        editor.removePackages(user, channel, pkgList);
        assertEquals(0, c.getPackages().size());
        
        List intList = new ArrayList();
        intList.add(new Integer(pkg.getId().intValue()));
        editor.addPackages(user, channel, intList);
        assertEquals(1, channel.getPackages().size());
    }
}
