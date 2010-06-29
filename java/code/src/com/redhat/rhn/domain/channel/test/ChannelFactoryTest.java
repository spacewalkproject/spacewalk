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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.ClonedChannel;
import com.redhat.rhn.domain.channel.ProductName;
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.ChannelTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

/**
 * ChannelFactoryTest
 * @version $Rev$
 */
public class ChannelFactoryTest extends RhnBaseTestCase {
    
    public void testChannelFactory() throws Exception {
        Channel c = createTestChannel();
        
        assertNotNull(c.getChannelFamily());
        
        Channel c2 = ChannelFactory.lookupById(c.getId());
        assertEquals(c.getLabel(), c2.getLabel());
        
        Channel c3 = createTestChannel();
        Long id = c3.getId();
        assertNotNull(c.getChannelArch());
        ChannelFactory.remove(c3);
        flushAndEvict(c3);
        assertNull(ChannelFactory.lookupById(id));
    }
    
    public static Channel createTestChannel() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        return createTestChannel(user);
    }
    
    public static ProductName lookupOrCreateProductName(String label) throws Exception {
        ProductName attempt = ChannelFactory.lookupProductNameByLabel(label);
        if (attempt == null) {
            attempt = new ProductName();
            attempt.setLabel(label);
            attempt.setName(label);
            HibernateFactory.getSession().save(attempt);
        }
        return attempt;
    }
    
    public static Channel createBaseChannel(User user) throws Exception {
        Channel c = createTestChannel(user);
        c.setOrg(null);

        ProductName pn = lookupOrCreateProductName(ChannelManager.RHEL_PRODUCT_NAME);
        c.setProductName(pn);

        ChannelFactory.save(c);
        return c;
    }
    
    public static Channel createBaseChannel(User user,
                                ChannelFamily fam) throws Exception {
        Channel c = createTestChannel(null, fam);
        ProductName pn = lookupOrCreateProductName(ChannelManager.RHEL_PRODUCT_NAME);
        c.setProductName(pn);
        ChannelFactory.save(c);
        return (Channel)TestUtils.saveAndReload(c);
    }


    public static Channel createTestChannel(User user) throws Exception {
        Org org = user.getOrg();
        ChannelFamily cfam = user.getOrg().getPrivateChannelFamily();
        Channel c =  createTestChannel(org, cfam);
        // assume we want the user to have access to this channel once created
        UserManager.addChannelPerm(user, c.getId(), "subscribe");
        UserManager.addChannelPerm(user, c.getId(), "manage");
        ChannelFactory.save(c);
        return c; 
    }

    public static Channel createTestChannel(Org org, ChannelFamily cfam) throws Exception {
        String label = "ChannelLabel" + TestUtils.randomString();
        String basedir = "TestChannel basedir";
        String name = "ChannelName" + TestUtils.randomString();
        String summary = "TestChannel summary";
        String description = "TestChannel description";
        Date lastmodified = new Date();
        Date created = new Date();
        Date modified = new Date();
        String gpgurl = "TestChannel gpg key url";
        String gpgid = "GPGKEYID";
        String gpgfp = "TestChannel gpg key fp";
        Calendar cal = Calendar.getInstance();
        cal.roll(Calendar.DATE, true);
        Date endoflife = new Date(System.currentTimeMillis() + Integer.MAX_VALUE);

        Long testid = new Long(500);
        String query = "ChannelArch.findById";
        ChannelArch arch = (ChannelArch) TestUtils.lookupFromCacheById(testid, query);
        Channel c = new Channel();
        c.setOrg(org);
        c.setLabel(label);
        c.setBaseDir(basedir);
        c.setName(name);
        c.setSummary(summary);
        c.setDescription(description);
        c.setLastModified(lastmodified);
        c.setCreated(created);
        c.setModified(modified);
        c.setGPGKeyUrl(gpgurl);
        c.setGPGKeyId(gpgid);
        c.setGPGKeyFp(gpgfp);
        c.setEndOfLife(endoflife);
        c.setChannelArch(arch);
        c.setChannelFamily(cfam);
        ChannelFactory.save(c);
        return c; 
    }
 
    /**
     * TODO: need to fix this test when we put errata management back in.
     * @throws Exception 
     */
    public void testChannelsWithClonableErrata() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        ChannelManager.
            getChannelsWithClonableErrata(user.getOrg());
        
        Channel original = ChannelFactoryTest.createTestChannel(user);
        Channel clone = ChannelFactoryTest.createTestClonedChannel(original, user);
        TestUtils.flushAndEvict(original);
        TestUtils.flushAndEvict(clone);

        List channels = ChannelFactory.getChannelsWithClonableErrata(
                user.getOrg());

        assertTrue(channels.size() > 0);
    }
    
    /**
     * TODO: create a test base channel with child channels and perform search.
     */
    public void aTestChildChanneQuery() {
        Channel base = ChannelFactory.getBaseChannel(new Long(1005897296));
        List labels = new ArrayList();
        labels.add("redhat-rhn-proxy-3.7-as-i386-4");
        labels.add("redhat-rhn-proxy-as-i386-2.1");
        List children = ChannelFactory.getChildChannelsByLabels(base, labels);
        assertNotEmpty("List is empty", children);
    }    
    
    public void testLookupByLabel() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Channel rh = createTestChannel(user);
        String label = rh.getLabel();
        rh.setOrg(null);
        ChannelFactory.save(rh);
        assertNull(rh.getOrg());
        
        //Lookup a channel without an org (An RH channel)
        Channel c = ChannelFactory.lookupByLabel(user.getOrg(), label);
        assertEquals(label, c.getLabel());
        
        //Lookup a channel with an org (user custom channel)
        Channel cust = createTestChannel(user);
        label = cust.getLabel();
        assertNotNull(cust.getOrg());
        c = ChannelFactory.lookupByLabel(user.getOrg(), label);
        assertNotNull(c);
        assertEquals(label, c.getLabel());
        assertEquals(user.getOrg(), c.getOrg());
        
        //Lookup a channel in a different org
        return; //no need to test in sat since we have only one org.
    }
    
    public void testIsGloballySubscribable() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel c = createTestChannel(user);
        assertTrue(ChannelFactory.isGloballySubscribable(user.getOrg(), c));
    }
    
    public void testChannelArchByLabel() {
        assertNull("Arch found for null label",
                ChannelFactory.findArchByLabel(null));
        assertNull("Arch found for invalid label",
                ChannelFactory.findArchByLabel("some-invalid_arch_label"));
        
        ChannelArch ca = ChannelFactory.findArchByLabel("channel-x86_64");
        assertNotNull(ca);
        assertEquals("channel-x86_64", ca.getLabel());
        assertEquals("x86_64", ca.getName());
    }
    
    public void testVerifyLabel() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel c = createTestChannel(user);
        assertFalse(ChannelFactory.doesChannelLabelExist("foo"));
        assertTrue(ChannelFactory.doesChannelLabelExist(c.getLabel()));
    }
    
    public void testVerifyName() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel c = createTestChannel(user);
        assertFalse(ChannelFactory.doesChannelNameExist("power house foo channel"));
        assertTrue(ChannelFactory.doesChannelNameExist(c.getName()));
    }
    
    public void testKickstartableChannels() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        
        List channels = ChannelFactory.getKickstartableChannels(user.getOrg());
        assertNotNull(channels);
        int originalSize = channels.size();
        
        createTestChannel(user);

        channels = ChannelFactory.getKickstartableChannels(user.getOrg());
        assertNotNull(channels);
        assertTrue(channels.size() > 0);
        assertEquals(originalSize + 1, channels.size());
    }
    
    public void testPackageCount() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel original = ChannelFactoryTest.createTestChannel(user);
        assertEquals(0, ChannelFactory.getPackageCount(original));
        original.addPackage(PackageTest.createTestPackage(user.getOrg()));
        ChannelFactory.save(original);
        TestUtils.flushAndEvict(original);

        original = (Channel)reload(original);
        assertEquals(1, ChannelFactory.getPackageCount(original));
    }
    
    /**
     * Create a test cloned channel. NOTE: This function does not copy its 
     * original's package list like a real clone would. It is only useful for 
     * testing purposes.
     * @param original Channel to be cloned
     * @return a test cloned channel
     */
    public static Channel createTestClonedChannel(Channel original, User user) {
        Org org = user.getOrg();
        ClonedChannel clone = new ClonedChannel();
        ChannelFamily cfam = ChannelFamilyFactory.lookupOrCreatePrivateFamily(org);
        
        clone.setOrg(org);
        clone.setLabel("clone-" + original.getLabel());
        clone.setBaseDir(original.getBaseDir());
        clone.setName("Clone of " + original.getName());
        clone.setSummary(original.getSummary());
        clone.setDescription(original.getDescription());
        clone.setLastModified(new Date());
        clone.setCreated(new Date());
        clone.setModified(new Date());
        clone.setGPGKeyUrl(original.getGPGKeyUrl());
        clone.setGPGKeyId(original.getGPGKeyId());
        clone.setGPGKeyFp(original.getGPGKeyFp());
        clone.setEndOfLife(new Date());
        clone.setChannelFamily(cfam);
        clone.setChannelArch(original.getChannelArch());
        
        /* clone specific calls */
        clone.setOriginal(original);
        
        ChannelFactory.save(clone);
        
        // assume we want the user to have access to this channel once created
        UserManager.addChannelPerm(user, clone.getId(), "subscribe");
        UserManager.addChannelPerm(user, clone.getId(), "manage");
        
        return clone;
    }
    public void testAccessibleChildChannels() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel parent = ChannelFactoryTest.createBaseChannel(user);
        Channel child = ChannelFactoryTest.createTestChannel(user);
        child.setParentChannel(parent);
        TestUtils.saveAndFlush(child);
        TestUtils.saveAndFlush(parent);
        TestUtils.flushAndEvict(child);
        List<Channel> dr = parent.getAccessibleChildrenFor(user);
        
        assertFalse(dr.isEmpty());
        assertEquals(child, dr.get(0));
    }
    
    public static ProductName createProductName() {
        ProductName pn = new ProductName();
        pn.setLabel("Label - " + TestUtils.randomString());
        pn.setName("Name - " + TestUtils.randomString());
        TestUtils.saveAndFlush(pn);
        return pn;
    }
    
    public void testFindChannelArchesSyncdChannels() {
        List<String> labels = ChannelFactory.findChannelArchLabelsSyncdChannels();
        assertNotNull(labels);
        assertNotEmpty(labels);
    }
    
    public void testListAllBaseChannels() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        // do NOT use createBaseChannel here because that will create a Red Hat
        // base channel NOT a user owned base channel.
        Channel base = createTestChannel(user);
        List<Channel> channels = ChannelFactory.listAllBaseChannels(user);
        assertEquals(1, channels.size());

        assertNotNull(channels);
    }
    
    public void testLookupPackageByFileName() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Channel channel = ChannelTestUtils.createTestChannel(user);
        TestUtils.saveAndFlush(channel);
        Package p = PackageManagerTest.addPackageToChannel("some-package", channel);
        String fileName = "some-package-2.13.1-6.fc9.x86_64.rpm";
        p.setPath("redhat/1/c7d/some-package/2.13.1-6.fc9/" +
                "x86_64/c7dd5e9b6975bc7f80f2f4657260af53/" +
                fileName);
        TestUtils.saveAndFlush(p);
        
        Package lookedUp = ChannelFactory.lookupPackageByFilename(channel, 
                fileName);
        assertNotNull(lookedUp);
        assertEquals(p.getId(), lookedUp.getId());
        
        // Test in child channel.
        Channel child = ChannelTestUtils.createChildChannel(user, channel);
        Package cp = PackageManagerTest.addPackageToChannel("some-package-child", child);
        String fileNameChild = "some-package-child-2.13.1-6.fc9.x86_64.rpm";
        cp.setPath("redhat/1/c7d/some-package-child/2.13.1-6.fc9/" +
                "x86_64/c7dd5e9b6975bc7f80f2f4657260af53/" +
                fileNameChild);

        Package lookedUpChild = ChannelFactory.lookupPackageByFilename(channel, 
                fileNameChild);
        assertNotNull(lookedUpChild);
        assertEquals(cp.getId(), lookedUpChild.getId());
                
    }
    
    public void testfindChecksumByLabel() {
        assertNull("Checksum found for null label",
                ChannelFactory.findChecksumTypeByLabel(null));
        assertNull("Checksum found for invalid label",
                ChannelFactory.findChecksumTypeByLabel("some-invalid_checksum"));
        
        ChecksumType ct = ChannelFactory.findChecksumTypeByLabel("sha256");
        assertNotNull(ct);
        assertEquals("sha256", ct.getLabel());
        
        ChecksumType ct2 = ChannelFactory.findChecksumTypeByLabel("sha1");
        assertNotNull(ct2);
        assertEquals("sha1", ct2.getLabel());
    }

}
