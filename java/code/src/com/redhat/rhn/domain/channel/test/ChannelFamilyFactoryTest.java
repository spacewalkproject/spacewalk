/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.channel.PrivateChannelFamily;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.List;

/**
 * ChannelFamilyFactoryTest
 */
public class ChannelFamilyFactoryTest extends RhnBaseTestCase {

    public void testChannelFamilyFactory() throws Exception {
        ChannelFamily cfam = createTestChannelFamily();
        ChannelFamily cfam2 = ChannelFamilyFactory.lookupById(cfam.getId());

        assertEquals(cfam.getLabel(), cfam2.getLabel());

        ChannelFamily cfam3 = createTestChannelFamily();
        Long id = cfam3.getId();
        assertNotNull(cfam3.getName());
        ChannelFamilyFactory.remove(cfam3);

        TestUtils.flushAndEvict(cfam3);

        assertNull(ChannelFamilyFactory.lookupById(id));
    }

    public void testLookupByLabel() throws Exception {
        ChannelFamily cfam = createTestChannelFamily();
        ChannelFamily cfam2 = ChannelFamilyFactory.lookupByLabel(cfam.getLabel(),
                                                                 cfam.getOrg());

        assertEquals(cfam.getId(), cfam2.getId());
    }

    public void testLookupByLabelLike() throws Exception {
        ChannelFamily cfam = createTestChannelFamily();
        List cfams = ChannelFamilyFactory.lookupByLabelLike(cfam.getLabel(),
                                                                 cfam.getOrg());
        ChannelFamily cfam2 = (ChannelFamily) cfams.get(0);
        assertEquals(cfam.getId(), cfam2.getId());
    }


    public void testVerifyOrgFamily() throws Exception {
        User user = UserTestUtils.findNewUser("testUser",
                "testOrg" + this.getClass().getSimpleName());
        Org org = user.getOrg();
        ChannelFamily orgfam = ChannelFamilyFactory.lookupByOrg(org);

        //In hosted, the org is newly created, and thus doesn't have a channel family
        //In sat, org is the satellite org, and thus probably already has a channel family
        orgfam = ChannelFamilyFactory.lookupOrCreatePrivateFamily(org);
        assertNotNull(orgfam);

        assertEquals("private-channel-family-" + org.getId(), orgfam.getLabel());
        assertEquals(org.getName() + " (" + org.getId() + ") Channel Family",
                    orgfam.getName());
        assertEquals(org.getId(), orgfam.getOrg().getId());

        ChannelFamily orgfam2 = ChannelFamilyFactory.lookupOrCreatePrivateFamily(org);

        assertNotNull(orgfam2);

        assertEquals(orgfam.getLabel(), orgfam2.getLabel());
        assertEquals(orgfam.getName(), orgfam2.getName());
    }

    public static ChannelFamily createTestChannelFamily() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrgCreateTestChannelFamily");
        return createTestChannelFamily(user);
    }

    public static ChannelFamily createTestChannelFamily(User user) throws Exception {
        return createTestChannelFamily(user, false);
    }

    public static ChannelFamily createTestChannelFamily(User user, boolean nullOrg)
        throws Exception {
        return createTestChannelFamily(user, nullOrg, "ChannelFamily");
    }

    public static ChannelFamily createTestChannelFamily(User user, boolean nullOrg,
            String prefix) throws Exception {
        String label = prefix + "Label" + TestUtils.randomString();
        String name = prefix + "Name" + TestUtils.randomString();
        String productUrl = "http://www.example.com";

        ChannelFamily cfam = new ChannelFamily();
        cfam.setOrg(nullOrg ? null : user.getOrg());
        cfam.setLabel(label);
        cfam.setName(name);
        cfam.setProductUrl(productUrl);

        ChannelFamilyFactory.save(cfam);
        cfam = (ChannelFamily) TestUtils.reload(cfam);

        PrivateChannelFamily pcf = new PrivateChannelFamily();
        pcf.setOrg(user.getOrg());
        pcf.setChannelFamily(cfam);
        HibernateFactory.getSession().save(pcf);

        cfam.addPrivateChannelFamily(pcf);
        cfam = (ChannelFamily) TestUtils.reload(cfam);
        return cfam;
    }
}
