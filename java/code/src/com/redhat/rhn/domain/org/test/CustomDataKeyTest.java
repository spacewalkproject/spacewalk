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
package com.redhat.rhn.domain.org.test;

import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * CustomDataKeyTest
 * @version $Rev$
 */
public class CustomDataKeyTest extends RhnBaseTestCase {

    public void testCustomDataKey() {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        CustomDataKey key = createTestCustomDataKey(user);

        Long id = key.getId();
        String label = key.getLabel();

        CustomDataKey key2 = OrgFactory.lookupKeyByLabelAndOrg(label, user.getOrg());

        assertNotNull(key2);
        assertEquals(label, key2.getLabel());
        assertEquals(user, key2.getCreator());
        assertEquals(id, key2.getId());
    }

    public static CustomDataKey createTestCustomDataKey(User user) {
        String label = TestUtils.randomString();
        CustomDataKey key = new CustomDataKey();
        key.setCreator(user);
        key.setLabel(label);
        key.setDescription("testkey description");
        key.setOrg(user.getOrg());

        TestUtils.saveAndFlush(key);

        return key;
    }
}
