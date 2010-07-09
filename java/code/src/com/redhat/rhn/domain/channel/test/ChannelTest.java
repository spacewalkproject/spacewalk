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
package com.redhat.rhn.domain.channel.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.ContentSource;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.ServerTestUtils;
import com.redhat.rhn.testing.TestUtils;

import org.apache.log4j.Logger;

import java.util.HashSet;
import java.util.Set;

/**
 * ChannelTest
 * @version $Rev$
 */
public class ChannelTest extends BaseTestCaseWithUser {

    private static Logger log = Logger.getLogger(ChannelTest.class);


    public void testRemovePackage() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        Package p = PackageTest.createTestPackage();
        c.addPackage(p);
        ChannelFactory.save(c);
        c.removePackage(p, user);
        assertTrue(c.getPackageCount() == 0);
        assertTrue(c.getPackages().isEmpty());

    }

    public void testChannel() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        //add an errata
        Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getId());
        c.addErrata(e);
        assertEquals(c.getErratas().size(), 1);
        ChannelFactory.save(c);

        log.debug("Looking up id [" + c.getId() + "]");
        Channel c2 = ChannelFactory.lookupById(c.getId());
        log.debug("Finished lookup");
        assertEquals(c2.getErratas().size(), 1);

        assertEquals(c.getLabel(), c2.getLabel());
        assertNotNull(c.getChannelArch());

        Channel c3 = ChannelFactoryTest.createTestChannel();

        c.setParentChannel(c3);
        assertEquals(c.getParentChannel().getId(), c3.getId());

        //Test isGloballySubscribable
        assertTrue(c.isGloballySubscribable(c.getOrg()));
        c.setGloballySubscribable(false, c.getOrg());
        assertFalse(c.isGloballySubscribable(c.getOrg()));
        c.setGloballySubscribable(true, c.getOrg());
        assertTrue(c.isGloballySubscribable(c.getOrg()));


    }

    public void testEquals() throws Exception {
        Channel c1 = ChannelFactoryTest.createTestChannel(user);
        Channel c2 = ChannelFactoryTest.createTestChannel(user);
        assertFalse(c1.equals(c2));
        Channel c3 = ChannelFactory.lookupById(c1.getId());
        Set testSet = new HashSet();
        testSet.add(c1);
        testSet.add(c2);
        testSet.add(c3);
        assertTrue(testSet.size() == 2);
    }

    public void testDistChannelMap() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        ChannelTestUtils.addDistMapToChannel(c);
        c = (Channel) reload(c);
        assertNotNull(c.getDistChannelMaps());
        assertTrue(c.getDistChannelMaps().size() > 0);
    }

    public void testIsProxy() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel();
        ChannelFamily cfam = ChannelFamilyFactory
                             .lookupByLabel(ChannelFamilyFactory
                                            .PROXY_CHANNEL_FAMILY_LABEL,
                                            null);

        c.setChannelFamily(cfam);

        TestUtils.saveAndFlush(c);

        Channel c2 = ChannelFactory.lookupById(c.getId());
        assertTrue(c2.isProxy());
    }

    public void testIsSub() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        Server s = ServerTestUtils.createTestSystem(user);
        assertTrue(c.isSubscribable(c.getOrg(), s));
    }

    public void testDeleteChannel() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        Long id = c.getId();
        assertNotNull(c);
        ChannelFactory.save(c);
        assertNotNull(ChannelFactory.lookupById(id));
        ChannelFactory.remove(c);
        TestUtils.flushAndEvict(c);
        assertNull(ChannelFactory.lookupById(id));
    }

    public void testIsBaseChannel() {
        Channel c = new Channel();
        Channel p = new Channel();
        c.setParentChannel(p);
        assertFalse(c.isBaseChannel());
        c.setParentChannel(null);
        assertTrue(c.isBaseChannel());
    }

    public void testAddPackage() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        Package p = PackageTest.createTestPackage(user.getOrg());
        assertNotNull(c);
        assertEquals("channel-ia32", c.getChannelArch().getLabel());
        assertNotNull(p);
        assertEquals("noarch", p.getPackageArch().getLabel());

        try {
            c.addPackage(p);
        }
        catch (Exception e) {
            fail("noarch should be acceptible in an ia32 channel");
        }


        try {
            PackageArch pa = PackageFactory.lookupPackageArchByLabel("x86_64");
            assertNotNull(pa);
            p.setPackageArch(pa);
            c.addPackage(p);
            fail("x86_64 is not acceptible in an ia32 channel");
        }
        catch (Exception e) {
            // expected.
        }

    }

    public void testContentSource() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        ContentSource cs = new ContentSource();
        cs.setLabel("repo_label-" + c.getLabel());
        cs.setSourceUrl("fake url");
        cs.setType(ChannelFactory.CONTENT_SOURCE_TYPE_YUM);
        cs.setOrg(user.getOrg());
        cs = (ContentSource) TestUtils.saveAndReload(cs);
        c.getSources().add(cs);
        c = (Channel) TestUtils.saveAndReload(c);
        assertNotEmpty(c.getSources());
    }


}
