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
package com.redhat.rhn.frontend.xmlrpc.channel.org.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.xmlrpc.channel.org.ChannelOrgHandler;
import com.redhat.rhn.frontend.xmlrpc.org.OrgHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.List;
import java.util.Map;

/**
 * ChannelOrgHandlerTest
 * @version $Rev$
 */
public class ChannelOrgHandlerTest extends BaseHandlerTestCase {

    private ChannelOrgHandler handler = new ChannelOrgHandler();
    private OrgHandler orgHandler = new OrgHandler();

    public void setUp() throws Exception {
        super.setUp();
        admin.addRole(RoleFactory.SAT_ADMIN);
        TestUtils.saveAndFlush(admin);
    }

    public void testList() throws Exception {
        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        channel.setAccess(Channel.PROTECTED);
        admin.getOrg().addOwnedChannel(channel);

        Org org2 = createOrg();
        Org org3 = createOrg();

        org2.addTrust(admin.getOrg());
        org3.addTrust(admin.getOrg());

        channel.getTrustedOrgs().add(org3);

        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        // execute
        List<Map<String, Object>> result = handler.list(adminKey, channel.getLabel());

        // verify
        assertNotNull(result);
        assertTrue(result.size() >= 2);

        boolean foundOrg2 = false, foundOrg3 = false;
        for (Map<String, Object> org : result) {
            String name = (String) org.get("org_name");
            Integer orgId = (Integer) org.get("org_id");
            Boolean access = (Boolean) org.get("access_enabled");

            if (name.equals(org2.getName())) {
                foundOrg2 = true;
                assertEquals(org2.getId().intValue(), orgId.intValue());
                assertFalse(access);
            }
            if (name.equals(org3.getName())) {
                foundOrg3 = true;
                assertEquals(org3.getId().intValue(), orgId.intValue());
                assertTrue(access);
            }
        }
        assertTrue(foundOrg2);
        assertTrue(foundOrg3);
    }

    public void testEnableAccess() throws Exception {
        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);

        Org org2 = createOrg();
        Org org3 = createOrg();
        org2.addTrust(admin.getOrg());
        org3.addTrust(admin.getOrg());

        // only protected channels can have separate org trusts
        channel.setAccess(Channel.PROTECTED);

        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        assertFalse(channel.getTrustedOrgs().contains(org2));
        assertFalse(channel.getTrustedOrgs().contains(org3));

        // execute
        int result = handler.enableAccess(adminKey, channel.getLabel(),
                org3.getId().intValue());

        // verify
        assertEquals(1, result);
        channel = ChannelFactory.lookupByLabelAndUser(channel.getLabel(), admin);
        assertFalse(channel.getTrustedOrgs().contains(org2));
        assertTrue(channel.getTrustedOrgs().contains(org3));
    }

    public void testDisableAccess() throws Exception {
        // setup
        Channel channel = ChannelFactoryTest.createTestChannel(admin);
        admin.getOrg().addOwnedChannel(channel);

        Org org2 = createOrg();
        Org org3 = createOrg();
        org2.addTrust(admin.getOrg());
        org3.addTrust(admin.getOrg());

        channel.getTrustedOrgs().add(org2);
        channel.getTrustedOrgs().add(org3);

        // only protected channels can have separate org trusts
        channel.setAccess(Channel.PROTECTED);

        OrgFactory.save(admin.getOrg());
        ChannelFactory.save(channel);
        flushAndEvict(channel);

        // execute
        int result = handler.disableAccess(adminKey, channel.getLabel(),
                org3.getId().intValue());

        // verify
        assertEquals(1, result);
        channel = ChannelFactory.lookupByLabelAndUser(channel.getLabel(), admin);
        assertTrue(channel.getTrustedOrgs().contains(org2));
        assertFalse(channel.getTrustedOrgs().contains(org3));
    }

    private Org createOrg() throws Exception {
        String random = TestUtils.randomString();
        String orgName = "EdwardNortonOrg" + random;
        String login = "edward" + random;
        String password = "redhat";
        String prefix = "Mr.";
        String first = "Edward";
        String last = "Norton";
        String email = "EddieNorton@redhat.com";
        Boolean usePam = Boolean.FALSE;

        orgHandler.create(adminKey, orgName, login, password, prefix, first,
                last, email, usePam);

        Org org =  OrgFactory.lookupByName(orgName);
        assertNotNull(org);
        return org;
    }
}
